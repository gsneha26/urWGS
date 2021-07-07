#!/bin/bash

source /data/hg002_sniffles/sample.config

SNIFFLES_STATUS=/data/sniffles_status
mkdir -p $SNIFFLES_STATUS

gsutil -q -m rsync -r $SNIFFLES_COMPLETE_STATUS_BUCKET/ $SNIFFLES_STATUS/ 

for instance in $(ls $SNIFFLES_STATUS/);
do
	if [ $(cat ${SNIFFLES_STATUS}/$instance) == "1" ]; then
		gcloud -q compute instances delete ${instance%_complete_status.txt} \
			--zone us-west1-a \
			--delete-disks all

	fi
done
