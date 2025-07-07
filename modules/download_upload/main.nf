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