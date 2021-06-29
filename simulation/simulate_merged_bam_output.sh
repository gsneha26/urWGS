#!/bin/bash

1>&2 echo "current "$(date)
source /data/sample.config

ALIGNMENT_SRC_BUCKET=gs://ur_wgs_test_data/HG002_guppy_minimap2_bam

gsutil -m rsync -r ${ALIGNMENT_SRC_BUCKET}/ ${GUPPY_MM2_OUTPUT_BUCKET}/
