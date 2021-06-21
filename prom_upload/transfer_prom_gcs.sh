#!/bin/bash

echo $PROJECT_DIR
1>&2 echo "current "$(date)
FAST5_FOLDER=/data/prom/HG002/
FAST5_BUCKET=gs://ultra_rapid_prom_data/prom/${SAMPLE}/
UPLOAD_STATUS_FILE=/data/upload_status.txt
UPLOAD_STATUS_BUCKET=gs://ultra_rapid_prom_data/prom

MIN_BUFFER=180 #3 minutes
MAX_BUFFER=540 #9 minutes
CURTIME=$(date +%s)
MAX_TIME=$(expr $CURTIME - $MIN_BUFFER)
MIN_TIME=$(expr $CURTIME - $MAX_BUFFER)

NFAST5=0
INCLUDE=\(
for i in $(find ${FAST5_FOLDER} -name "*.fast5");
do
	FILE=${i#"${FAST5_FOLDER}"}
	FILETIME=$(stat $i -c %Y)
	if [ $FILETIME -lt $MAX_TIME ]; then
		if [ $FILETIME -gt $MIN_TIME ]; then
			INCLUDE=${INCLUDE}\|$FILE
			NFAST5=$((NFAST5+1))
		fi
	fi
done
INCLUDE=${INCLUDE}\|\)

1>&2 echo $NFAST5
1>&2 echo $INCLUDE
if [ $NFAST5 -gt 0 ]; then
	echo "2" > $UPLOAD_STATUS_FILE
	echo "gsutil -m rsync -r -x '(?!${INCLUDE}$)' ${FAST5_FOLDER} ${FAST5_BUCKET}" | sh -ex
else
	echo "1" > $UPLOAD_STATUS_FILE
fi

gsutil cp $UPLOAD_STATUS_FILE $UPLOAD_STATUS_BUCKET/ 
