#!/bin/bash

set -x

source /data/sample.config
PMDV_ANNOTATION_STATUS_FILE=/data/pmdv_annotation_status.txt
PMDV_ANNOTATION_STATUS=$(cat $PMDV_ANNOTATION_STATUS_FILE)

STATUS_DIR=/data/pmdv_status
mkdir -p $STATUS_DIR
gsutil -m -q rsync -r ${PMDV_STATUS_BUCKET}/ ${STATUS_DIR}/

if [ $PMDV_ANNOTATION_STATUS -eq 2 ]; then

        echo "Small variant call annotation started"
	NUM_FILES=0
	for file in ${STATUS_DIR}/*_pmdv_status.txt; do
		if [ $(cat $file) == "1" ]; then
			NUM_FILES=$((NUM_FILES+1))
		fi
	done

	1>&2 echo "NUM_FILES: $NUM_FILES"

	        if [ $NUM_FILES -eq 25 ]; then

                ${PROJECT_DIR}/annotation/process_pmdv_vcf.sh

		if [ $? -eq 0 ]; then
			email_annotation_update "PMDV Annotation completed"
			echo "PMDV Annotation completed"

			echo "1" > $PMDV_ANNOTATION_STATUS_FILE
			PMDV_ANNOTATION_STATUS=1
		else
			email_annotation_update "PMDV Annotation Error"
			echo "PMDV Annotation error"

			echo "3" > $PMDV_ANNOTATION_STATUS_FILE
			PMDV_ANNOTATION_STATUS=3
		fi
		gsutil cp $PMDV_ANNOTATION_STATUS_FILE ${ANNOTATION_COMPLETE_STATUS_BUCKET}/pmdv_annotation_complete_status.txt
        else
                echo "Not all pmd vcfs available"
        fi

elif [ $PMDV_ANNOTATION_STATUS -eq 1 ]; then 
        echo "Small variant call annotation completed"
else
	echo "Small variant call annotation Error"
fi
