#!/bin/bash

set -x  

source /data/sample.config
ANNOTATION_FOLDER=/data/spectre_annotation
VCF_FOLDER=${ANNOTATION_FOLDER}/spectre_output

mkdir -p $ANNOTATION_FOLDER
mkdir -p $VCF_FOLDER

DOWNLOAD_STATUS_FILE=/data/spectre_download_status.txt
DOWNLOAD_STATUS=$(cat $DOWNLOAD_STATUS_FILE)

SPECTRE_ANNOTATION_STATUS_FILE=/data/spectre_annotation_status.txt
SPECTRE_ANNOTATION_STATUS=$(cat $SPECTRE_ANNOTATION_STATUS_FILE)
SPECTRE_STATUS_DIR=/data/spectre_status
mkdir -p $SPECTRE_STATUS_DIR
gsutil rsync ${SPECTRE_STATUS_BUCKET}/ $SPECTRE_STATUS_DIR/


if [ $SPECTRE_ANNOTATION_STATUS -eq 2 ]; then
        NUM_FILES=0
        for file in ${SPECTRE_STATUS_DIR}/*_spectre_status.txt; do
                if [ $(cat $file) == "1" ]; then
                        NUM_FILES=$((NUM_FILES+1))
                fi
        done

        1>&2 echo "NUM_FILES: $NUM_FILES"

        if [ ${NUM_FILES} -eq 25 ]; then

                $PROJECT_DIR/annotation/process_spectre_vcf.sh

		if [ $? -eq 0 ]; then
			email_annotation_update "Spectre Annotation completed"
			echo "Spectre Annotation completed"

			echo "1" > $SPECTRE_ANNOTATION_STATUS_FILE
			SPECTRE_ANNOTATION_STATUS=1
		else
			email_annotation_update "Spectre Annotation Error"
			echo "Spectre Annotation error"

			echo "3" > $SPECTRE_ANNOTATION_STATUS_FILE
			SPECTRE_ANNOTATION_STATUS=3
		fi
		gsutil cp $SPECTRE_ANNOTATION_STATUS_FILE ${ANNOTATION_COMPLETE_STATUS_BUCKET}/spectre_annotation_complete_status.txt
        else
                echo "Not all spectre vcfs generated"
        fi

else
        echo "Spectre Annotation already completed"
fi
