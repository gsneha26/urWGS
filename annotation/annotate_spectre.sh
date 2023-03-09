#!/bin/bash

set -x  

source /data/sample.config
ANNOTATION_FOLDER=/data/spectre_annotation
VCF_FOLDER=${ANNOTATION_FOLDER}/spectre_output
BAM_FOLDER=${ANNOTATION_FOLDER}/chr_bam

mkdir -p $ANNOTATION_FOLDER
mkdir -p $VCF_FOLDER
mkdir -p $BAM_FOLDER 

DOWNLOAD_STATUS_FILE=/data/download_status.txt
DOWNLOAD_STATUS=$(cat $DOWNLOAD_STATUS_FILE)
BAM_STATUS_DIR=/data/bam_status
mkdir -p $BAM_STATUS_DIR
gsutil rsync ${BAM_STATUS_BUCKET}/ ${BAM_STATUS_DIR}/

SPECTRE_ANNOTATION_STATUS_FILE=/data/spectre_annotation_status.txt
SPECTRE_ANNOTATION_STATUS=$(cat $SPECTRE_ANNOTATION_STATUS_FILE)
SPECTRE_STATUS_DIR=/data/spectre_status
mkdir -p $SPECTRE_STATUS_DIR
gsutil rsync ${SPECTRE_STATUS_BUCKET}/ $SPECTRE_STATUS_DIR/


if [ $DOWNLOAD_STATUS -eq 2 ]; then
	if [ $(ls ${BAM_STATUS_DIR}/ | wc -l) -gt 0 ]; then

		NUM_FILES=0
		for file in ${BAM_STATUS_DIR}/*_bam_status.txt; do
			if [ $(cat $file) == "1" ]; then
				NUM_FILES=$((NUM_FILES+1))
			fi
		done

		1>&2 echo "NUM_FILES: $NUM_FILES"

		if [ $NUM_FILES -eq 25 ]; then

			$PROJECT_DIR/annotation/download_data.sh
			if [ $? -eq 0 ]; then
				email_annotation_update "Data download completed"
				echo "1" > $DOWNLOAD_STATUS_FILE
				DOWNLOAD_STATUS=1
			else
				email_annotation_update "Data download error"
				echo "3" > $DOWNLOAD_STATUS_FILE
				DOWNLOAD_STATUS=3
			fi

		else
			echo "Not all status files found yet."
		fi
	else
		echo "No bam status file found yet"
	fi
elif [ $DOWNLOAD_STATUS -eq 3 ]; then
	echo "Data download error"
else
	echo "Data download already completed"
fi

if [ $SPECTRE_ANNOTATION_STATUS -eq 2 ] && [ $DOWNLOAD_STATUS -eq 1 ]; then
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
			email_annotation_update "Sniffles Annotation completed"
			echo "Sniffles Annotation completed"

			echo "1" > $SPECTRE_ANNOTATION_STATUS_FILE
			SPECTRE_ANNOTATION_STATUS=1
		else
			email_annotation_update "Sniffles Annotation Error"
			echo "Sniffles Annotation error"

			echo "3" > $SPECTRE_ANNOTATION_STATUS_FILE
			SPECTRE_ANNOTATION_STATUS=3
		fi
		gsutil cp $SPECTRE_ANNOTATION_STATUS_FILE ${ANNOTATION_COMPLETE_STATUS_BUCKET}/spectre_annotation_complete_status.txt
        else
                echo "Not all spectre vcfs generated"
        fi

else
        echo "Sniffles Annotation already completed"
fi
