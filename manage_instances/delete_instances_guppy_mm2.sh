#!/bin/bash

source /data/hg002_guppy_mm2/sample.config

GUPPY_MM2_STATUS=/data/guppy_mm2_status
mkdir -p $GUPPY_MM2_STATUS

gsutil -q -m rsync -r $GUPPY_MM2_COMPLETE_STATUS_BUCKET/ $GUPPY_MM2_STATUS/ 

for instance in $(ls $GUPPY_MM2_STATUS/);
do
	if [ $(cat ${GUPPY_MM2_STATUS}/$instance) == "1" ]; then
		gcloud -q compute instances delete ${instance%_complete_status.txt} \
			--zone us-west1-a \
			--delete-disks all
		if [ $? -eq 0 ]; then
			rm ${GUPPY_MM2_STATUS}/$instance
			gsutil rm ${GUPPY_MM2_COMPLETE_STATUS_BUCKET}/$instance
		fi
	fi
done
