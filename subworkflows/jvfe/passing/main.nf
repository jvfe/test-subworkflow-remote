#!/usr/bin/env nextflow

// This subworkflow takes an input fasta sequence and csv style list of hic cram file to return
// alignment files including .mcool, pretext and .hic.
// Input - Assembled genomic fasta file, cram file directory
// Output - .mcool, .pretext, .hic

//
// MODULE IMPORT BLOCK
//
include { CRAM_FILTERALIGN } from '../../../modules/jvfe/cram/filteralign/main'
include { BWAMEM2_INDEX     } from '../../../modules/jvfe/bwamem2/index/main'

workflow HIC_BWAMEM2 {
    take:
    reference_tuple     // Channel: tuple [ val(meta), path( file )      ]
    csv_ch

    main:
    ch_versions         = Channel.empty()
    mappedbam_ch        = Channel.empty()

    BWAMEM2_INDEX (
        reference_tuple
        )
    ch_versions         = ch_versions.mix( BWAMEM2_INDEX.out.versions )

    csv_ch
        .splitCsv()
        .combine ( reference_tuple )
        .combine ( BWAMEM2_INDEX.out.index )
        .map{ cram_id, cram_info, ref_id, ref_dir, bwa_id, bwa_path ->
            tuple([
                    id: cram_id.id
                    ],
                file(cram_info[0]),
                cram_info[1],
                cram_info[2],
                cram_info[3],
                cram_info[4],
                cram_info[5],
                cram_info[6],
                bwa_path.toString() + '/' + ref_dir.toString().split('/')[-1],
                ref_dir
            )
    }
    .set { ch_filtering_input }
    ch_filtering_input.view()
    //
    // MODULE: map hic reads by 10,000 container per time using bwamem2
    //
    CRAM_FILTER_ALIGN_BWAMEM2_FIXMATE_SORT (
        ch_filtering_input

    )
    ch_versions         = ch_versions.mix( CRAM_FILTER_ALIGN_BWAMEM2_FIXMATE_SORT.out.versions )
    mappedbam_ch        = CRAM_FILTER_ALIGN_BWAMEM2_FIXMATE_SORT.out.mappedbam

    //
    // LOGIC: PREPARING BAMS FOR MERGE
    //
    mappedbam_ch
        .map{ meta, file ->
            tuple( file )
        }
        .collect()
        .map { file ->
            tuple (
                [
                id: file[0].toString().split('/')[-1].split('_')[0] + '_' + file[0].toString().split('/')[-1].split('_')[1]
                ],
                file
            )
        }
        .set { collected_files_for_merge }

    emit:
    mappedbams           = collected_files_for_merge
    versions            = ch_versions.ifEmpty(null)
}

