#!/bin/bash

set -x

source /data/sample.config
PMD_ANNOTATION_STATUS_FILE=/data/pmd_annotation_status.txt
PMD_ANNOTATION_STATUS=$(cat $PMD_ANNOTATION_STATUS_FILE)

if [ $PMD_ANNOTATION_STATUS -eq 2 ]; then
	STATUS_DIR=/data/pmd_status
	mkdir -p $STATUS_DIR
	gsutil rsync ${PMD_STATUS_BUCKET}/ $STATUS_DIR

	NUM_FILES=0
	for file in ${STATUS_DIR}/*; do
		if [ $(cat $file) == "1" ]; then
			NUM_FILES=$((NUM_FILES+1))
		fi
	done

	1>&2 echo "NUM_FILES: $NUM_FILES"

	#PMD_STATUS=0
	#for INST in {1..22} X Y MT;
	#do
	#	STATUS=$(gcloud pubsub subscriptions pull chr${INST}_sub_pmd --format=value"(message.data.decode(base64).decode(utf-8))")
	#	if [ "$STATUS" == "COMPLETE" ]; then
	#		PMD_STATUS=$((PMD_STATUS+1))
	#	fi
	#done

	#if [ ${PMD_STATUS} -eq 25 ]; then

	#	/data/scripts/process_pmd_vcf.sh

	#	email_annotation_update "PMD Annotation completed"
	#	echo "PMD Annotation completed"

	#	for INST in {1..22} X Y MT;
	#	do
	#		gcloud pubsub subscriptions delete chr${INST}_sub_pmd
	#	done

	#	echo "1" > $PMD_ANNOTATION_STATUS_FILE
	#	PMD_ANNOTATION_STATUS=1
	#else
	#	echo "Not all pmd vcfs generated"
	#fi

	if [ $NUM_FILES -eq 25 ]; then

		/data/scripts/process_pmd_vcf.sh

		email_annotation_update "PMD Annotation completed"
		echo "PMD Annotation completed"

		echo "1" > $PMD_ANNOTATION_STATUS_FILE
		PMD_ANNOTATION_STATUS=1
	else
		echo "Not all pmd vcfs generated"
	fi
else
	echo "PMD Annotation completed"
fi
