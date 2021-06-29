#!/bin/bash

set -x

source /data/sample.config
PMD_ANNOTATION_STATUS_FILE=/data/pmdv_annotation_status.txt
PMD_ANNOTATION_STATUS=$(cat $PMD_ANNOTATION_STATUS_FILE)

if [ $PMD_ANNOTATION_STATUS -eq 2 ]; then
	STATUS_DIR=/data/pmdv_status
	mkdir -p $STATUS_DIR
	gsutil -q rsync ${PMD_STATUS_BUCKET}/ $STATUS_DIR

	NUM_FILES=0
	for file in ${STATUS_DIR}/*; do
		if [ $(cat $file) == "1" ]; then
			NUM_FILES=$((NUM_FILES+1))
		fi
	done

	1>&2 echo "NUM_FILES: $NUM_FILES"

	if [ $NUM_FILES -eq 25 ]; then

		/data/scripts/process_pmdv_vcf.sh

		email_annotation_update "PMD Annotation completed"
		echo "PMD Annotation completed"

		echo "1" > $PMD_ANNOTATION_STATUS_FILE
		PMD_ANNOTATION_STATUS=1
	else
		echo "Not all pmdv vcfs generated"
	fi
else
	echo "PMD Annotation completed"
fi
