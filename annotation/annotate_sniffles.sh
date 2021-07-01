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
BAM_STATUS_DIR=/data/bam_status
mkdir -p $BAM_STATUS_DIR
gsutil rsync ${BAM_STATUS_BUCKET}/ ${BAM_STATUS_DIR}/

SNIFFLES_ANNOTATION_STATUS_FILE=/data/sniffles_annotation_status.txt
SNIFFLES_ANNOTATION_STATUS=$(cat $SNIFFLES_ANNOTATION_STATUS_FILE)
SNIFFLES_STATUS_DIR=/data/sniffles_status
mkdir -p $SNIFFLES_STATUS_DIR
gsutil rsync ${SNIFFLES_STATUS_BUCKET}/ $SNIFFLES_STATUS_DIR/


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

if [ $SNIFFLES_ANNOTATION_STATUS -eq 2 ] && [ $DOWNLOAD_STATUS -eq 1 ]; then
        NUM_FILES=0
        for file in ${SNIFFLES_STATUS_DIR}/*_sniffles_status.txt; do
                if [ $(cat $file) == "1" ]; then
                        NUM_FILES=$((NUM_FILES+1))
                fi
        done

        1>&2 echo "NUM_FILES: $NUM_FILES"

        if [ ${NUM_FILES} -eq 25 ]; then

                $PROJECT_DIR/annotation/process_sniffles_vcf.sh

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
