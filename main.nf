nextflow.enable.dsl = 2

log.info """\
    RNASEQ - VARCALL _ W F   P I P E L I N E
    ===================================
    samplesheet     : ${params.samplesheet}
    """
    .stripIndent(true)

include { GATK4_SPLITNCIGARREADS } from './modules/gatk/main.nf'

workflow {
    Channel.fromPath(params.samplesheet)
    | splitCsv( header: true )
    | map { row ->
        def meta = [id:row.sample, sample:row.sample]
        [meta, row.alignment, row.index]
    }
    | set { ch_input_prepare }

    ch_input_prepare.view { "Value: $it" }

    GATK4_SPLITNCIGARREADS(ch_input_prepare, params.fasta, params.fai, params.dict)
}