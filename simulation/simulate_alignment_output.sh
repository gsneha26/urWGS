#! /bin/bash

1>&2 echo "current "$(date)
source /data/sample.config

BAM_SRC_BUCKET=gs://ur_wgs_test_data/HG002_chr_bam

gsutil -m rsync -r ${BAM_SRC_BUCKET}/ ${CHR_BAM_BUCKET}/

STATUS_DIR=/data/chr_bam_status
mkdir -p $STATUS_DIR/

for inst in {A..H}h{1..2};
do
	echo "1" > $STATUS_DIR/postprocess_${inst}_status.txt 
done

gsutil -m rsync -r $STATUS_DIR/ $GUPPY_MM2_STATUS_BUCKET/
