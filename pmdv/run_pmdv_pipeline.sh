#!/bin/bash

source /data/sample.config

STATUS_DIR=/data/guppy_minimap2_status/
PMDV_STATUS_FILE=/data/pmdv_status.txt
PMDV_STATUS=$(cat $PMDV_STATUS_FILE)

mkdir -p $STATUS_DIR 
gsutil -q rsync ${GUPPY_MM2_STATUS_BUCKET}/ $STATUS_DIR
NUM_FILES=0
for i in $(ls $STATUS_DIR); do
        if [ $(cat ${STATUS_DIR}/$i) == "1" ]; then
                NUM_FILES=$((NUM_FILES+1))
        fi
done

1>&2 echo "PMDV_STATUS: $PMDV_STATUS"
1>&2 echo "SUM OF GUPPY_MINIMAP2 STATUS: $NUM_FILES"

if [ $NUM_FILES -eq $NUM_GUPPY ] && [ $PMDV_STATUS -eq 2 ]; then
  INST_CHR=$(gcloud compute instances describe $(hostname) --zone=$(gcloud compute instances list --filter="name=($(hostname))" --format "value(zone)") --format=value"(metadata[CHR])")
  chr_args=$( echo $INST_CHR | sed 's/:/ /g' )
	for ch in $chr_args; do
		email_vc_update "Starting Preprocess for $ch" $ch "PEPPER-Margin-DeepVariant" 
	done

	time parallel -j 2 $PROJECT_DIR/pmdv/preprocess_chr.sh ::: ${chr_args}
	EXIT_CODE=$?
	if [ $EXIT_CODE -eq 0 ]; then
		for ch in $chr_args; do
			email_vc_update "Preprocess completed for $ch" $ch "PEPPER-Margin-DeepVariant"
		done
	else
		for ch in $chr_args; do
			email_vc_update "Preprocess failed for $ch" $ch "PEPPER-Margin-DeepVariant Error" 
		done
		exit 1
	fi

	for ch in $chr_args; do
		time $PROJECT_DIR/pmdv/run_pmdv.sh $ch 2> /data/${ch}_folder/run_$ch.log
		EXIT_CODE=$?
		if [ $EXIT_CODE -eq 0 ]; then
			email_vc_update "PEPPER-Margin-DeepVariant completed for $ch" $ch
		else
			email_vc_update "PEPPER-Margini-DeepVariant failed for $ch" $ch
		fi
	done

	time parallel -j 2 $PROJECT_DIR/pmdv/postprocess_chr.sh ::: $chr_args
	EXIT_CODE=$?
	if [ ${EXIT_CODE} -eq 0 ]; then
		for ch in $chr_args; do
			email_vc_update "Postprocess completed for $ch" $ch "PEPPER-Margin-DeepVariant" 
		done
	else
		for ch in $chr_args; do
			email_vc_update "Postprocess failed for $ch" $ch "PEPPER-Margin-DeepVariant Error" 
		done
	fi

	TOTAL_STATUS=0
	num_chr=0
	for ch in $chr_args; do
		if [ $(cat /data/${ch}_folder/${ch}_pmdv_status.txt) == "1" ]; then
			TOTAL_STATUS=$((TOTAL_STATUS+1))
		fi
		num_chr=$((num_chr+1))
	done

	if [ $TOTAL_STATUS -eq $num_chr ]; then
		echo "1" > $PMDV_STATUS_FILE
	else
		echo "3" > $PMDV_STATUS_FILE
	fi

else
	echo "Not all status files found yet."
fi
