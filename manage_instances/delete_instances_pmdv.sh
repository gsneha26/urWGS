#!/bin/bash

source $PROJECT_DIR/sample.config
PMDV_STATUS=$WORK_DIR/pmdv_status
mkdir -p $PMDV_STATUS

gsutil -q -m rsync -r $PMDV_COMPLETE_STATUS_BUCKET/ $PMDV_STATUS/ 

for instance in $(ls $PMDV_STATUS/);
do
	if [ $(cat ${PMDV_STATUS}/$instance) == "1" ]; then
    INSTANCE_NAME=${instance%_complete_status.txt}
		gcloud -q compute instances delete $INSTANCE_NAME \
      --zone=$(gcloud compute instances list --filter="name=($INSTANCE_NAME)" --format "value(zone)") \
			--delete-disks all
		if [ $? -eq 0 ]; then
			rm ${PMDV_STATUS}/$instance
			gsutil rm ${PMDV_COMPLETE_STATUS_BUCKET}/$instance
		fi
	fi
done
