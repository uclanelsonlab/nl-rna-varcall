process DOWNLOAD_ALIGNMENT {
    tag "${meta.id}"
    label "download_alignment_files"

    input:
        tuple val(meta), val(alignment), val(index), val(extension)

    output:
        tuple val(meta), path('*am'), path('*ai'), val(extension), emit: alignment

    script:
    """
    aws s3 cp ${alignment} .
    aws s3 cp ${index} .
    """
}

process UPLOAD_VARCALL {
    tag "${meta.id}"
    label "upload_varcall_files"

    input:
        tuple val(meta), path(vcf), path(index)

    script:
    """
    aws s3 cp ${vcf} ${meta.s3_path}/hc/
    aws s3 cp ${index} ${meta.s3_path}/hc/
    """
}

process DOWNLOAD_REFERENCE {
    tag "${meta.id}"
    label "download_reference_files"

    input:
        tuple val(meta), val(fasta), val(fai), val(dict)
        tuple val(meta), val(dbsnp), val(dbsnp_index)
        tuple val(meta), val(known_indels), val(known_indels_index)
        tuple val(meta), val(indels_1000G), val(indels_1000G_index)
        tuple val(meta), val(af_only_gnomad), val(af_only_gnomad_index)
        tuple val(meta), val(small_exac_common_3), val(small_exac_common_3_index) 

    output:
        tuple val(meta), path('*.fa'), path('*.fai'), path('*.dict'), emit: reference
        tuple val(meta), path('*.dbsnp138.vcf.gz'), path('*.dbsnp138.vcf.gz.tbi'), emit: dbsnp
        tuple val(meta), path('*.known_indels.vcf.gz'), path('*.known_indels.vcf.gz.tbi'), emit: known_indels
        tuple val(meta), path('*_standard.indels.hg38.vcf.gz'), path('*_standard.indels.hg38.vcf.gz.tbi'), emit: indels_1000G
        tuple val(meta), path('af-only-gnomad.hg38.vcf.gz'), path('af-only-gnomad.hg38.vcf.gz.tbi'), emit: af_only_gnomad
        tuple val(meta), path('small_exac_common_3.hg38.vcf.gz'), path('small_exac_common_3.hg38.vcf.gz.tbi'), emit: small_exac_common_3

    script:
        """
        aws s3 cp ${fasta} .
        aws s3 cp ${fai} .
        aws s3 cp ${dict} .
        aws s3 cp ${dbsnp} .
        aws s3 cp ${dbsnp_index} .
        aws s3 cp ${known_indels} .
        aws s3 cp ${known_indels_index} .
        aws s3 cp ${indels_1000G} .
        aws s3 cp ${indels_1000G_index} .
        aws s3 cp ${af_only_gnomad} .
        aws s3 cp ${af_only_gnomad_index} .
        aws s3 cp ${small_exac_common_3} .
        aws s3 cp ${small_exac_common_3_index} .
        """
}