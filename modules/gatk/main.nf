process GATK4_SPLITNCIGARREADS {
    tag "$meta.id"
    label "SplitNCigarReads"
    container 'quay.io/biocontainers/gatk4:4.6.1.0--py310hdfd78af_0'
    cpus 16

    input:
        tuple val(meta), path(bam), path(bai)
        tuple val(meta2), path(fasta)
        tuple val(meta3), path(fai)
        tuple val(meta4), path(dict)
        
    output:
        tuple val(meta), path('*.bam'), emit: bam
        path  "versions.yml",           emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def prefix = task.ext.prefix ?: "${meta.id}"
        def avail_mem = 3072
        if (!task.memory) {
            log.info '[GATK SplitNCigarReads] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
        } else {
            avail_mem = (task.memory.mega*0.8).intValue()
        }
        """
        gatk --java-options "-Xmx${avail_mem}M -XX:-UsePerfData" \\
            SplitNCigarReads \\
            -R ${fasta} \\
            -I ${alignment} \\
            -O ${prefix}.cigar.bam \\
            --tmp-dir .

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            gatk4: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
        END_VERSIONS
        """

    stub:
        def prefix = task.ext.prefix ?: "${meta.id}"

        """
        touch ${prefix}.bam

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            gatk4: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
        END_VERSIONS
        """
}