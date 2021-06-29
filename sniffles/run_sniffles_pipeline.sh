#!/bin/bash

source /data/sample.config
CHR_CONFIG=$(gcloud compute instances describe $(hostname) --zone=$(gcloud compute instances list --filter="name=($(hostname))" --format "value(zone)") --format=value"(metadata[CHR])")
THREAD_CONFIG=$(gcloud compute instances describe $(hostname) --zone=$(gcloud compute instances list --filter="name=($(hostname))" --format "value(zone)") --format=value"(metadata[THREADS])")
chr_args=$( echo $CHR_CONFIG | sed 's/:/ /g' )
thread_args=$( echo $THREAD_CONFIG | sed 's/:/ /g' )

num_chr=0
for ch in $chr_args; do
	num_chr=$((num_chr+1))
done

STATUS_DIR=/data/bam_status
SNIFFLES_STATUS_FILE=/data/sniffles_status.txt
SNIFFLES_STATUS=$(cat $SNIFFLES_STATUS_FILE)

mkdir -p $STATUS_DIR 
gsutil -q rsync ${BAM_STATUS_BUCKET}/ $STATUS_DIR

NUM_FILES=0
for  i in $(ls $STATUS_DIR); do
	if [ $(cat ${STATUS_DIR}/${ch}_bam_status.txt) == "1" ]; then
		NUM_FILES=$((NUM_FILES+1))
	fi
done

1>&2 echo "SUM OF CHR_BAM STATUS: $NUM_FILES"
1>&2 echo "SNIFFLES_STATUS: $SNIFFLES_STATUS"

if [ $NUM_FILES -eq $num_chr ] && [ $SNIFFLES_STATUS -eq 2 ]; then

	time parallel -j $num_chr $PROJECT_DIR/sniffles/run_sniffles_chr.sh ::: \
		${chr_args} :::+ \
		${thread_args}

	echo "1" > $SNIFFLES_STATUS_FILE
else
	echo "Not all status files found yet."
fi
