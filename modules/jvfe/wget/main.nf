process WGET {
    label 'process_single'

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'biocontainers/python:3.8.3' }"

    input:
    tuple val(meta), val(url)

    output:
    tuple val(meta), path("${meta.id}.fna"), emit: fasta

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    wget --output-document ${meta.id}.fna $url
    """
}
