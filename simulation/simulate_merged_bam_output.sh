#!/bin/bash

1>&2 echo "current "$(date)
source /data/sample.config

BAM_SRC_BUCKET=gs://ur_wgs_test_data/HG002_chr_bam

gsutil -m rsync -r ${BAM_SRC_BUCKET}/ ${CHR_BAM_BUCKET}/

STATUS_DIR=/data/chr_bam_status
mkdir -p $STATUS_DIR/

for chr in 4 5 7 8 10 11 14 15 16 18 19 20 21;
do
	echo "1" > $STATUS_DIR/chr${chr}_bam_status.txt 
done

gsutil -m rsync -r $STATUS_DIR/ $BAM_STATUS_BUCKET/
