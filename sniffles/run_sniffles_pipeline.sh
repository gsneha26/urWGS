#!/bin/bash

source /data/sample.config
CHR_CONFIG=$(gcloud compute instances describe $(hostname) --zone=$(gcloud compute instances list --filter="name=($(hostname))" --format "value(zone)") --format=value"(metadata[CHR])")
#THREAD_CONFIG=$(gcloud compute instances describe $(hostname) --zone=$(gcloud compute instances list --filter="name=($(hostname))" --format "value(zone)") --format=value"(metadata[THREADS])")
chr_args=$( echo $CHR_CONFIG | sed 's/:/ /g' )
#thread_args=$( echo $THREAD_CONFIG | sed 's/:/ /g' )

STATUS_DIR=/data/bam_status
SNIFFLES_STATUS_FILE=/data/sniffles_status.txt
SNIFFLES_STATUS=$(cat $SNIFFLES_STATUS_FILE)

mkdir -p $STATUS_DIR 
gsutil -q -m rsync ${BAM_STATUS_BUCKET}/ $STATUS_DIR

NUM_FILES=0
num_chr=0
for ch in $chr_args; do
	num_chr=$((num_chr+1))
	if [ $(cat ${STATUS_DIR}/${ch}_bam_status.txt) == "1" ]; then
		NUM_FILES=$((NUM_FILES+1))
	fi
done

1>&2 echo "SUM OF CHR_BAM STATUS: $NUM_FILES"
1>&2 echo "SNIFFLES_STATUS: $SNIFFLES_STATUS"

if [ $NUM_FILES -eq $num_chr ] && [ $SNIFFLES_STATUS -eq 2 ]; then

	time parallel -j $num_chr $PROJECT_DIR/sniffles/run_sniffles_chr.sh ::: \
		${chr_args}

	    TOTAL_STATUS=0

        for ch in $chr_args; do
                if [ $(cat /data/${ch}_sniffles_status.txt) == "1" ]; then
                        TOTAL_STATUS=$((TOTAL_STATUS+1))
                fi
        done

        if [ $TOTAL_STATUS -eq $num_chr ]; then
                echo "1" > $SNIFFLES_STATUS_FILE
        else
                echo "3" > $SNIFFLES_STATUS_FILE
        fi

	gsutil -q cp $SNIFFLES_STATUS_FILE ${SNIFFLES_COMPLETE_STATUS_BUCKET}/$(hostname)_complete_status.txt

else
	echo "Not all status files found yet."
fi
