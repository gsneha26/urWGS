#!/bin/bash

SAMPLE=Fast_110
DATA_FOLDER=/data/Rapid_Nicu/${SAMPLE}/
BUCKET_NAME=gs://ultra_rapid_prom_data/prom/${SAMPLE}/
UPLOAD_STATUS_FILE=/data/upload_status.txt

EXCLUDE=\(
INT1=180 #3 minutes
INT2=540 #9 minutes
CURTIME=$(date +%s)
TIMEDIFF1=$(expr $CURTIME - $INT1)
TIMEDIFF2=$(expr $CURTIME - $INT2)
1>&2 echo "current "$(date)
n=0
for i in `find ${DATA_FOLDER} -name "*.fast5"`;
do
	FILE=${i#"${DATA_FOLDER}"}
	FILETIME=$(stat $i -c %Y)
	if [ $FILETIME -lt $TIMEDIFF1 ]; then
		if [ $FILETIME -gt $TIMEDIFF2 ]; then
			EXCLUDE=${EXCLUDE}\|$FILE
			n=$((n+1))
		fi
	fi
done
EXCLUDE=${EXCLUDE}\|\)

1>&2 echo $n
1>&2 echo $EXCLUDE
if [ $n -gt 0 ]; then
	echo "2" > $UPLOAD_STATUS_FILE
	echo "gsutil -m rsync -r -x '(?!${EXCLUDE}$)' ${DATA_FOLDER} ${BUCKET_NAME}" | sh -ex
else
	echo "1" > $UPLOAD_STATUS_FILE
fi
gsutil cp $UPLOAD_STATUS_FILE gs://ultra_rapid_prom_data/prom/
1>&2 echo "completed"
