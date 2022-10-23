#!/bin/bash

source $PROJECT_DIR/sample.config
GUPPY_MM2_STATUS=$WORK_DIR/guppy_mm2_status
mkdir -p $GUPPY_MM2_STATUS

gsutil -q -m rsync -r $GUPPY_MM2_COMPLETE_STATUS_BUCKET/ $GUPPY_MM2_STATUS/ 

for instance in $(ls $GUPPY_MM2_STATUS/);
do
	if [ $(cat ${GUPPY_MM2_STATUS}/$instance) == "1" ]; then
        INSTANCE_NAME=${instance%_complete_status.txt}
		gcloud -q compute instances delete $INSTANCE_NAME \
            --zone=$(gcloud compute instances list --filter="name=($INSTANCE_NAME)" --format "value(zone)") \
			--delete-disks all
		if [ $? -eq 0 ]; then
			rm ${GUPPY_MM2_STATUS}/$instance
			gsutil rm ${GUPPY_MM2_COMPLETE_STATUS_BUCKET}/$instance
		fi
	fi
done
