#!/bin/bash

source /data/sample.config
CHR_CONFIG=$(gcloud compute instances describe $(hostname) --zone=$(gcloud compute instances list --filter="name=($(hostname))" --format "value(zone)") --format=value"(metadata[CHR])")
chr_args=$( echo $CHR_CONFIG | sed 's/:/ /g' )

BAM_STATUS_DIR=/data/bam_status
SPECTRE_STATUS_DIR=/data/spectre_status
SPECTRE_STATUS_FILE=/data/spectre_status.txt
SPECTRE_STATUS=$(cat $SPECTRE_STATUS_FILE)
COVERAGE_DIR=/data/coverage_dir

mkdir -p $BAM_STATUS_DIR 
mkdir -p $SPECTRE_STATUS_DIR
mkdir -p $COVERAGE_DIR

num_chr=0
for i in $chr_args; do
    num_chr=$((num_chr+1))
done
gsutil -q -m rsync ${BAM_STATUS_BUCKET}/ $BAM_STATUS_DIR

while [ $SPECTRE_STATUS -eq 2 ]; do

    time parallel -j $num_chr $PROJECT_DIR/spectre/run_spectre_chr.sh ::: \
        ${chr_args}

    TOTAL_STATUS=0

    for ch in $chr_args; do
        if [ $(cat /data/spectre_status/${ch}_spectre_status.txt) -eq 1 ]; then
            TOTAL_STATUS=$((TOTAL_STATUS+1))
        fi
    done

    if [ $TOTAL_STATUS -eq $num_chr ]; then
        echo "1" > $SPECTRE_STATUS_FILE
    fi

    gsutil -q cp $SPECTRE_STATUS_FILE ${SPECTRE_COMPLETE_STATUS_BUCKET}/$(hostname)_complete_status.txt
    SPECTRE_STATUS=$(cat $SPECTRE_STATUS_FILE)

done

1>&2 echo "SPECTRE_STATUS: $SPECTRE_STATUS"
