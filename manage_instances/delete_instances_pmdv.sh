#!/bin/bash

source /data/hg002_pmdv/sample.config

PMDV_STATUS=/data/pmdv_status
mkdir -p $PMDV_STATUS

gsutil -q -m rsync -r $PMDV_COMPLETE_STATUS_BUCKET/ $PMDV_STATUS/ 

for instance in $(ls $PMDV_STATUS/);
do
	if [ $(cat ${PMDV_STATUS}/$instance) == "1" ]; then
		gcloud -q compute instances delete ${instance%_complete_status.txt} \
			--zone us-west1-a \
			--delete-disks all

	fi
done
