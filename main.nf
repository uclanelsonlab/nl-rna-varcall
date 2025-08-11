nextflow.enable.dsl = 2

log.info """\
    RNASEQ - VARCALL _ W F   P I P E L I N E
    ===================================
    sample_name     : ${params.sample_name}
    alignment       : ${params.alignment}
    fasta           : ${params.fasta}
    fai             : ${params.fai}
    dict            : ${params.dict}
    """
    .stripIndent(true)

include { MOSDEPTH } from './modules/mosdepth/main.nf'
include { BEDTOOLS_MERGE_INTERSECT } from './modules/bedtools/main.nf'
include { DEEPVARIANT_RUNDEEPVARIANT } from './modules/deepvariant/main.nf'

workflow {
    def meta = [id: params.sample_name]
    Channel
        .value([meta, file(params.alignment), file(params.alignment_index)])
        .set { ch_input_prepare }

    ch_reference = Channel.fromPath(params.fasta)
        .map { fasta ->
            def fai = params.fai ? file(params.fai) : file("${fasta}.fai")
            return [[id:"reference"], fasta, fai]
        }
        .collect()
    
    ch_model = Channel.fromPath(params.model_data)
        .map { model_data ->
            def index = params.model_index ? file(params.model_index) : file("model.ckpt.index")
            def model_meta = params.model_meta ? file(params.model_meta) : file("model.ckpt.meta")
            return [[id:"model"], model_data, index, model_meta]
        }
        .collect()

    MOSDEPTH(ch_input_prepare, ch_reference)

    BEDTOOLS_MERGE_INTERSECT(MOSDEPTH.out.per_base_bed, params.gencode_bed, params.min_coverage)

    DEEPVARIANT_RUNDEEPVARIANT(ch_input_prepare, ch_reference, BEDTOOLS_MERGE_INTERSECT.out.cds_bed, ch_model)
}