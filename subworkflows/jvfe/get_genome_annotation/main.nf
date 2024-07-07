include { WGET      } from '../../../modules/jvfe/wget/main'
include { PROKKA     } from '../../../modules/nf-core/prokka/main'

workflow GET_GENOME_ANNOTATION {
    take:
    urls     // Channel: tuple [ val(meta), val( url )      ]

    main:
    ch_versions         = Channel.empty()

    // Download genome

    WGET {
        url
    }

    // Run Prokka
    PROKKA {
        WGET.out.fasta
    }
    ch_versions = ch_versions.mix(PROKKA.out.versions.first().ifEmpty(null))

    emit:
    prokka_res          = PROKKA.out
    versions            = ch_versions.ifEmpty(null)
}

