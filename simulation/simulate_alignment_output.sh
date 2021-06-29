#! /bin/bash

1>&2 echo "current "$(date)
source /data/sample.config

ALIGNMENT_SRC_BUCKET=gs://ur_wgs_test_data/HG002_guppy_minimap2_bam

gsutil -m rsync -r ${ALIGNMENT_SRC_BUCKET}/ ${GUPPY_MM2_OUTPUT_BUCKET}/

STATUS_DIR=/data/guppy_minimap2_status
mkdir -p $STATUS_DIR/

for inst in {A..H}h{1..2};
do
	echo "1" > $STATUS_DIR/postprocess_${inst}_status.txt 
done

gsutil -m rsync -r $STATUS_DIR/ $GUPPY_MM2_STATUS_BUCKET/
