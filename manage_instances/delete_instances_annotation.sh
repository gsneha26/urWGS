#!/bin/bash

source /data/hg002_annotation/sample.config

ANNOTATION_STATUS=/data/annotation_status
mkdir -p $ANNOTATION_STATUS

gsutil -q -m rsync -r $ANNOTATION_COMPLETE_STATUS_BUCKET/ $ANNOTATION_STATUS/ 

if [ -f ${ANNOTATION_STATUS}/pmdv_annotation_complete_status.txt ] && [ -f ${ANNOTATION_STATUS}/sniffles_annotation_complete_status.txt ]; then
	if [ $(cat ${ANNOTATION_STATUS}/pmdv_annotation_complete_status.txt) == "1" ] && [ $(cat ${ANNOTATION_STATUS}/sniffles_annotation_complete_status.txt) == "1" ]; then
		gcloud -q compute instances delete annotation-1 \
			--zone us-west1-a \
			--delete-disks all
		if [ $? -eq 0 ]; then
			rm ${ANNOTATION_STATUS}/*
			gsutil rm ${ANNOTATION_COMPLETE_STATUS_BUCKET}/*
		fi
	fi
fi
