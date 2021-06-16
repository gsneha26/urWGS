#!/bin/bash

set -x 

source /data/sample.config
ANNOTATION_FOLDER=/data/sniffles_annotation
VCF_FOLDER=${ANNOTATION_FOLDER}/sniffles_output
BAM_FOLDER=${ANNOTATION_FOLDER}/chr_bam

mkdir -p $ANNOTATION_FOLDER
mkdir -p $VCF_FOLDER
mkdir -p $BAM_FOLDER

DOWNLOAD_STATUS_FILE=/data/download_status.txt
DOWNLOAD_STATUS=$(cat $DOWNLOAD_STATUS_FILE)

SNIFFLES_ANNOTATION_STATUS_FILE=/data/sniffles_annotation_status.txt
SNIFFLES_ANNOTATION_STATUS=$(cat $SNIFFLES_ANNOTATION_STATUS_FILE)

if [ $DOWNLOAD_STATUS -eq 2 ]; then
	STATUS_DIR=/data/bam_status
	mkdir -p $STATUS_DIR
	gsutil rsync ${BAM_STATUS_BUCKET}/ $STATUS_DIR

	NUM_FILES=0
	for file in ${STATUS_DIR}/*; do
		if [ $(cat $file) == "1" ]; then
			NUM_FILES=$((NUM_FILES+1))
		fi
	done

	1>&2 echo "NUM_FILES: $NUM_FILES"

	if [ $NUM_FILES -eq 25 ]; then

		/data/scripts/download_data.sh
		email_annotation_update "Data download completed"
		echo "1" > $DOWNLOAD_STATUS_FILE
		DOWNLOAD_STATUS=1

	else
		echo "Not all status files found yet."
	fi
else
	echo "Data download already completed"
fi

if [ $SNIFFLES_ANNOTATION_STATUS -eq 2 ] && [ $DOWNLOAD_STATUS -eq 1 ]; then
	STATUS_DIR=/data/sniffles_status
	mkdir -p $STATUS_DIR
	gsutil rsync ${SV_STATUS_BUCKET}/ $STATUS_DIR

	NUM_FILES=0
	for file in ${STATUS_DIR}/*; do
		if [ $(cat $file) == "1" ]; then
			NUM_FILES=$((NUM_FILES+1))
		fi
	done

	1>&2 echo "NUM_FILES: $NUM_FILES"

	#SNIFFLES_STATUS=0
	#for INST in {1..22} X Y MT;
	#do
	#	STATUS=$(gcloud pubsub subscriptions pull chr${INST}_sub_sniffles --format=value"(message.data.decode(base64).decode(utf-8))")
	#	if [ "$STATUS" == "COMPLETE" ]; then
	#		SNIFFLES_STATUS=$((SNIFFLES_STATUS+1))
	#	fi
	#done

	#if [ ${SNIFFLES_STATUS} -eq 25 ]; then

	#	/data/scripts/process_sniffles_vcf.sh

	#	email_annotation_update "Sniffles Annotation completed"
	#	echo "Sniffles Annotation completed"

	#	for INST in {1..22} X Y MT;
	#	do
	#		gcloud pubsub subscriptions delete chr${INST}_sub_sniffles
	#	done

	#	echo "1" > $SNIFFLES_ANNOTATION_STATUS_FILE
	#	SNIFFLES_ANNOTATION_STATUS=1
	#else
	#	echo "Not all sniffles vcfs generated"
	#fi

	if [ ${NUM_FILES} -eq 25 ]; then

		/data/scripts/process_sniffles_vcf.sh

		email_annotation_update "Sniffles Annotation completed"
		echo "Sniffles Annotation completed"

		echo "1" > $SNIFFLES_ANNOTATION_STATUS_FILE
		SNIFFLES_ANNOTATION_STATUS=1
	else
		echo "Not all sniffles vcfs generated"
	fi

else
	echo "Sniffles Annotation already completed"
fi
