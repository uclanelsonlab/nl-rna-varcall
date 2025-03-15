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

workflow {
    Channel.fromPath(params.samplesheet)
    | splitCsv( header: true )
    | map { row ->
        def meta = [id:row.sample, sample:row.sample]
        [meta, row.alignment, row.index]
    }
    | set { ch_input_prepare }

    ch_fasta = Channel.fromPath(params.fasta).map{ [[id:"reference"], it]}.collect()
    ch_fai = params.fai ? Channel.fromPath(params.fai).map{ [[id:"reference"], it]}.collect() : null
    ch_dict = params.dict ? Channel.fromPath(params.dict).map{ [[id:"reference"], it]}.collect() : null
    ch_dbsnp = Channel.value([[id:"dbsnp138"], params.dbsnp138, params.dbsnp138_index])
    ch_known_indels = Channel.value([[id:"known_indels"], params.known_indels, params.known_indels_index])
    ch_indels_1000G = Channel.value([[id:"indels_1000G"], params.indels_1000G, params.indels_1000G_index])
    ch_af_only_gnomad = Channel.value([[id:"af_only_gnomad"], params.af_only_gnomad, params.af_only_gnomad_index])
    ch_small_exac_common_3 = Channel.value([[id:"small_exac_common_3"], params.small_exac_common_3, params.small_exac_common_3_index])

    // ch_dbsnp.view { "Value: $it" }
    
    GATK4_SPLITNCIGARREADS(ch_input_prepare, ch_fasta, ch_fai, ch_dict)

    GATK4_BASERECALIBRATOR(
        GATK4_SPLITNCIGARREADS.out.bam, 
        ch_fasta, 
        ch_fai, 
        ch_dict, 
        ch_dbsnp,
        ch_known_indels,
        ch_indels_1000G,
        ch_af_only_gnomad,
        ch_small_exac_common_3)

    GATK4_APPLYBQSR(GATK4_SPLITNCIGARREADS.out.bam, GATK4_BASERECALIBRATOR.out.table, ch_fasta, ch_fai, ch_dict)
    GATK4_HAPLOTYPECALLER(GATK4_APPLYBQSR.out.bam, ch_fasta, ch_fai, ch_dict, ch_dbsnp)
}