#!/bin/bash

source /data/sample.config
CHR_CONFIG=$(gcloud compute instances describe $(hostname) --zone=$(gcloud compute instances list --filter="name=($(hostname))" --format "value(zone)") --format=value"(metadata[CHR])")
chr_args=$( echo $CHR_CONFIG | sed 's/:/ /g' )

BAM_STATUS_DIR=/data/bam_status
SNIFFLES_STATUS_DIR=/data/sniffles_status
SNIFFLES_STATUS_FILE=/data/sniffles_status.txt
SNIFFLES_STATUS=$(cat $SNIFFLES_STATUS_FILE)

mkdir -p $BAM_STATUS_DIR 
mkdir -p $SNIFFLES_STATUS_DIR

num_chr=0
for i in $chr_args; do
    num_chr=$((num_chr+1))
done
gsutil -q -m rsync ${BAM_STATUS_BUCKET}/ $BAM_STATUS_DIR

while [ $SNIFFLES_STATUS -eq 2 ]; do

    time parallel -j $num_chr $PROJECT_DIR/sniffles/run_sniffles_chr.sh ::: \
        ${chr_args}

    TOTAL_STATUS=0

    for ch in $chr_args; do
        if [ $(cat /data/sniffles_status/${ch}_sniffles_status.txt) -eq 1 ]; then
            TOTAL_STATUS=$((TOTAL_STATUS+1))
        fi
    done

    if [ $TOTAL_STATUS -eq $num_chr ]; then
        echo "1" > $SNIFFLES_STATUS_FILE
    fi

    gsutil -q cp $SNIFFLES_STATUS_FILE ${SNIFFLES_COMPLETE_STATUS_BUCKET}/$(hostname)_complete_status.txt
    SNIFFLES_STATUS=$(cat $SNIFFLES_STATUS_FILE)

done

1>&2 echo "SNIFFLES_STATUS: $SNIFFLES_STATUS"
