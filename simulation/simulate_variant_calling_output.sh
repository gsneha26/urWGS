#! /bin/bash

1>&2 echo "current "$(date)
source /data/sample.config

BAM_SRC_BUCKET=gs://ur_wgs_test_data/HG002_chr_bam
PMDV_SRC_BUCKET=gs://ur_wgs_test_data/HG002_pmdv_google_rows_output
SNIFFLES_SRC_BUCKET=gs://ur_wgs_test_data/HG002_sniffles_output

gsutil -m rsync -r ${BAM_SRC_BUCKET}/ ${CHR_BAM_BUCKET}/
gsutil -m rsync -r ${PMDV_SRC_BUCKET}/ ${PMDV_VCF_BUCKET}/
gsutil -m rsync -r ${SNIFFLES_SRC_BUCKET}/ ${SV_VCF_BUCKET}/
