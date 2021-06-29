#! /bin/bash

1>&2 echo "current "$(date)
source /data/sample.config

BAM_SRC_BUCKET=gs://ur_wgs_test_data/HG002_chr_bam

gsutil -m rsync -r ${ALIGNMENT_SRC_BUCKET}/ ${CHR_BAM_BUCKET}/
