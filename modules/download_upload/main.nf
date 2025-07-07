process DOWNLOAD_ALIGNMENT {
    tag "${meta.id}"
    label "Download alignment files"

    input:
        tuple val(meta), path(alignment), path(index), val(extension)

    output:
        tuple val(meta), path('*am'), path('*ai'), emit: alignment

    script:
    """
    aws s3 cp ${alignment} .
    aws s3 cp ${index} .
    """
}

process UPLOAD_VARCALL {
    tag "${meta.id}"
    label "Upload variant calling files"

    input:
        tuple val(meta), path(vcf), path(index)

    script:
    """
    aws s3 cp ${vcf} ${meta.s3_path}/hc/
    aws s3 cp ${index} ${meta.s3_path}/hc/
    """
}