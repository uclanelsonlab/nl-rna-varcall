nextflow.enable.dsl = 2

log.info """\
    RNASEQ - VARCALL _ W F   P I P E L I N E
    ===================================
    samplesheet     : ${params.samplesheet}
    fasta           : ${params.fasta}
    fai             : ${params.fai}
    dict            : ${params.dict}
    """
    .stripIndent(true)

include { GATK4_SPLITNCIGARREADS as GATK4_SPLITNCIGARREADS_BAM; GATK4_SPLITNCIGARREADS as GATK4_SPLITNCIGARREADS_CRAM; GATK4_BASERECALIBRATOR; GATK4_APPLYBQSR; GATK4_HAPLOTYPECALLER } from './modules/gatk/main.nf'
include { SAMTOOLS_CONVERT2BAM } from './modules/samtools/main.nf'
include { DOWNLOAD_ALIGNMENT; DOWNLOAD_REFERENCE; UPLOAD_VARCALL } from './modules/download_upload/main.nf'

workflow {
    Channel.fromPath(params.samplesheet)
    | splitCsv( header: true )
    | map { row ->
        // Check if alignment is cram or bam
        def extension
        if (row.alignment.endsWith('.bam')) {
            extension = 'bam'   
        } else if (row.alignment.endsWith('.cram')) {
            extension = 'cram'
        } else {
            error "Alignment file '${row.alignment}' for sample '${row.sample}' must end with .bam or .cram"
        }
        def meta = [id:row.sample, sample:row.sample, s3_path:row.s3_path]
        [meta, row.alignment, row.index, extension]
    }
    | set { ch_input_prepare }



    ch_reference = Channel.fromPath(params.fasta).map{ fasta ->
        def meta = [id:"reference"]
        def fai = params.fai ? file(params.fai) : null
        def dict = params.dict ? file(params.dict) : null
        [meta, fasta, fai, dict]
    }.collect()
    ch_dbsnp = Channel.value([[id:"dbsnp138"], params.dbsnp138, params.dbsnp138_index])
    ch_known_indels = Channel.value([[id:"known_indels"], params.known_indels, params.known_indels_index])
    ch_indels_1000G = Channel.value([[id:"indels_1000G"], params.indels_1000G, params.indels_1000G_index])
    ch_af_only_gnomad = Channel.value([[id:"af_only_gnomad"], params.af_only_gnomad, params.af_only_gnomad_index])
    ch_small_exac_common_3 = Channel.value([[id:"small_exac_common_3"], params.small_exac_common_3, params.small_exac_common_3_index])

    // Download reference files
    DOWNLOAD_REFERENCE(
        ch_reference, 
        ch_dbsnp, 
        ch_known_indels, 
        ch_indels_1000G, 
        ch_af_only_gnomad, 
        ch_small_exac_common_3
    )

    // Download alignment files
    DOWNLOAD_ALIGNMENT(ch_input_prepare)

    // Split the downloaded files based on extension
    ch_bam_files = DOWNLOAD_ALIGNMENT.out.alignment.filter { meta, alignment, index_file, extension -> extension == 'bam' }
    ch_cram_files = DOWNLOAD_ALIGNMENT.out.alignment.filter { meta, alignment, index_file, extension -> extension == 'cram' }

    // Process bam files directly
    GATK4_SPLITNCIGARREADS_BAM(ch_bam_files, DOWNLOAD_REFERENCE.out.reference)

    // Process cram files - convert to bam first, then process
    SAMTOOLS_CONVERT2BAM(ch_cram_files, DOWNLOAD_REFERENCE.out.reference)
    GATK4_SPLITNCIGARREADS_CRAM(SAMTOOLS_CONVERT2BAM.out.bam, DOWNLOAD_REFERENCE.out.reference)

    // Merge the outputs from both bam and cram processing branches
    ch_split_reads = GATK4_SPLITNCIGARREADS_BAM.out.bam.mix(GATK4_SPLITNCIGARREADS_CRAM.out.bam)

    // BaseRecalibrator
    GATK4_BASERECALIBRATOR(
        ch_split_reads, 
        DOWNLOAD_REFERENCE.out.reference, 
        DOWNLOAD_REFERENCE.out.dbsnp,
        DOWNLOAD_REFERENCE.out.known_indels,
        DOWNLOAD_REFERENCE.out.indels_1000G,
        DOWNLOAD_REFERENCE.out.af_only_gnomad,
        DOWNLOAD_REFERENCE.out.small_exac_common_3)

    // ApplyBQSR    
    GATK4_APPLYBQSR(ch_split_reads, GATK4_BASERECALIBRATOR.out.table, DOWNLOAD_REFERENCE.out.reference)

    // HaplotypeCaller
    GATK4_HAPLOTYPECALLER(GATK4_APPLYBQSR.out.bam, DOWNLOAD_REFERENCE.out.reference, DOWNLOAD_REFERENCE.out.dbsnp)

    // Upload variant calling files
    UPLOAD_VARCALL(GATK4_HAPLOTYPECALLER.out.vcf_files)
}