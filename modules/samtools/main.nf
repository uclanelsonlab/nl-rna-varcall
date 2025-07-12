process SAMTOOLS_CONVERT2BAM {
    tag "${meta.id}"
    label "convert_alignment_to_bam"
    container 'quay.io/biocontainers/samtools:1.22--h96c455f_0'
    memory 200.GB
    cpus 48

    input:
        tuple val(meta), path(alignment), path(index)
        tuple val(meta2), path(fasta), path(fai), path(dict)
        
    output:
        tuple val(meta), path('*.bam'), path('*.bai'), emit: bam

    script:
        def prefix = task.ext.prefix ?: "${meta.id}"
        """
        # Check if reference files exist
        if [ ! -f "${fasta}" ]; then
            echo "Reference FASTA file not found: ${fasta}"
            exit 1
        fi
        
        if [ ! -f "${fai}" ]; then
            echo "Reference FAI file not found: ${fai}"
            exit 1
        fi
        
        samtools view -@ $task.cpus -b -T ${fasta} ${alignment} > ${prefix}.bam
        samtools index -@ $task.cpus ${prefix}.bam
        """
}