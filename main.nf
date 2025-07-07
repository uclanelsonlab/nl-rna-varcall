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

include { GATK4_SPLITNCIGARREADS; GATK4_BASERECALIBRATOR; GATK4_APPLYBQSR; GATK4_HAPLOTYPECALLER } from './modules/gatk/main.nf'
include { SAMTOOLS_CONVERT2BAM } from './modules/samtools/main.nf'
include { DOWNLOAD_ALIGNMENT } from './modules/download_upload/main.nf'

workflow {
    Channel.fromPath(params.samplesheet)
    | splitCsv( header: true )
    | map { row ->
        // Check if alignment is cram or bam
        if (row.alignment.endsWith('.bam')) {
            def extension = 'bam'   
        } else if (row.alignment.endsWith('.cram')) {
            def extension = 'cram'
        } else {
            error "Alignment file '${row.alignment}' for sample '${row.sample}' must end with .bam or .cram"
        }
        def meta = [id:row.sample, sample:row.sample]
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

    // Download alignment files
    DOWNLOAD_ALIGNMENT(ch_input_prepare)

    // Check if we need to transform the alignment file to bam
    if (ch_input_prepare.extension == 'cram') {
        SAMTOOLS_CONVERT2BAM(DOWNLOAD_ALIGNMENT.out.alignment, ch_reference)
        GATK4_SPLITNCIGARREADS(SAMTOOLS_CONVERT2BAM.out.bam, ch_reference)
    } else {
        GATK4_SPLITNCIGARREADS(DOWNLOAD_ALIGNMENT.out.alignment, ch_reference)
    }

    GATK4_BASERECALIBRATOR(
        GATK4_SPLITNCIGARREADS.out.bam, 
        ch_reference, 
        ch_dbsnp,
        ch_known_indels,
        ch_indels_1000G,
        ch_af_only_gnomad,
        ch_small_exac_common_3)

    GATK4_APPLYBQSR(GATK4_SPLITNCIGARREADS.out.bam, GATK4_BASERECALIBRATOR.out.table, ch_reference)
    GATK4_HAPLOTYPECALLER(GATK4_APPLYBQSR.out.bam, ch_reference, ch_dbsnp)
}