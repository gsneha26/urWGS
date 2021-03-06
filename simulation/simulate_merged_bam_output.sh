#!/bin/bash

1>&2 echo "current "$(date)
source /data/hg002_sniffles/sample.config

BAM_SRC_BUCKET=gs://ur_wgs_test_data/HG002_chr_bam

gsutil -m rsync -r ${BAM_SRC_BUCKET}/ ${CHR_BAM_BUCKET}/

BAM_STATUS_DIR=/data/hg002_sniffles/chr_bam_status
mkdir -p $BAM_STATUS_DIR/

for chr in 4 5 7 8 10 11 14 15 16 18 19 20 21;
do
	echo "1" > $BAM_STATUS_DIR/chr${chr}_bam_status.txt 
done

gsutil -m rsync -r $BAM_STATUS_DIR/ $BAM_STATUS_BUCKET/
