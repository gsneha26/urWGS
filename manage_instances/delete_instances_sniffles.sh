#!/bin/bash

source $PROJECT_DIR/sample.config
SNIFFLES_STATUS=$WORK_DIR/sniffles_status
mkdir -p $SNIFFLES_STATUS

gsutil -q -m rsync -r $SNIFFLES_COMPLETE_STATUS_BUCKET/ $SNIFFLES_STATUS/ 

for instance in $(ls $SNIFFLES_STATUS/);
do
	if [ $(cat ${SNIFFLES_STATUS}/$instance) == "1" ]; then
    INSTANCE_NAME=${instance%_complete_status.txt}
		gcloud -q compute instances delete $INSTANCE_NAME \
      --zone=$(gcloud compute instances list --filter="name=($INSTANCE_NAME)" --format "value(zone)") \
			--delete-disks all
		if [ $? -eq 0 ]; then
			rm ${SNIFFLES_STATUS}/$instance
			gsutil rm ${SNIFFLES_COMPLETE_STATUS_BUCKET}/$instance
		fi
	fi
done
