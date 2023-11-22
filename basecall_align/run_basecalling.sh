#!/bin/bash

source /data/sample.config
EMAIL_SUB="Basecalling"
ERROR_EMAIL_SUB="Basecalling Error"

1>&2 echo ""
1>&2 echo "current "$(TZ='America/Los_Angeles' date)
CURRTIME=$(date +%s)
BATCH=batch_$CURRTIME

#################### Initialize folder and file names ###########################

POD5_FOLDER=/data/input_folder
BATCH_FOLDER=/data/output_folder/$BATCH
UPLOAD_STATUS_FILE=/data/upload_status.txt
BASECALLING_STATUS_FILE=/data/basecalling_status.txt

mkdir -p $POD5_FOLDER
mkdir -p $BATCH_FOLDER

LOG_FILE=${BATCH_FOLDER}/${BATCH}_basecalling.log

echo "" > $LOG_FILE 
1>&2 echo "New batch number: $CURRTIME"
echo "=========== Basecalling logs for batch_$CURRTIME ============" >> $LOG_FILE 

add_basecall_align_update "Created batch folder: $BATCH_FOLDER" $LOG_FILE

POD5_FOLDER=${BATCH_FOLDER}/pod5
FASTQ_FOLDER=${BATCH_FOLDER}/basecall_output/
PASS_FASTQ_FOLDER=${BATCH_FOLDER}/basecall_output
TMP_FASTQ_FOLDER=/data/tmp_fastq

mkdir -p $POD5_FOLDER
mkdir -p $TMP_FASTQ_FOLDER

#################### Download fast5 files ###########################

NUM_ATTEMPT=0
DWNLD_EXIT=1

while [ $DWNLD_EXIT -gt 0 ] && [ $NUM_ATTEMPT -lt 5 ] ; do

	add_basecall_align_update "Starting fast5 download" $LOG_FILE

	time gsutil -q -m rsync -r -x ".*[1-6][B-H].*$" $POD5_BUCKET/ $POD5_FOLDER/

	DWNLD_EXIT=$?
	NUM_ATTEMPT=$(((NUM_ATTEMPT)+1))

	gsutil -q cp $POD5_STATUS_BUCKET /data/
done

if [ $DWNLD_EXIT -gt 0 ]; then

	add_basecall_align_update "Download failed more than 5 times, exiting job for batch $CURRTIME" $LOG_FILE
	email_basecall_align_update "BASECALLING STATUS: Download fast5 unsuccessful" $LOG_FILE $ERROR_EMAIL_SUB 
	exit 10

else

	add_basecall_align_update "Downloaded fast5 files in $NUM_ATTEMPT attempt/s" $LOG_FILE

fi

#################### Start generating fast5 file list and basecalling ###########################

NUM_ATTEMPT=0
GUPPY_EXIT=1

while [ $GUPPY_EXIT -gt 0 ] && [ $NUM_ATTEMPT -lt 5 ] ; do

	rm -rf $FASTQ_FOLDER
	NUM_POD5=0

	add_basecall_align_update "Starting attempt $NUM_ATTEMPT" $LOG_FILE

	add_basecall_align_update "Starting fast5 file list generation" $LOG_FILE

	for i in `find ${POD5_FOLDER} -name "*.pod5"`;
	do
		FILE=$(readlink -f $i)
		FILETIME=$(stat $i -c %X)
		if [ $FILETIME -gt $CURRTIME ]; then
            ln -s "${FILE}" "${POD5_FOLDER}/$(basename "${i}")"
			NUM_POD5=$(((NUM_POD5)+1))
		fi
	done

	if [ ${NUM_POD5} -gt 0 ]; then

	#################### Check if NVIDIA driver works ###########################

		add_basecall_align_update "Fast5 file list generated" $LOG_FILE
	
		CUDA_EXIT=1
		CUDA_ATTEMPT=0

		while [ ${CUDA_EXIT} -gt 0 ] && [ $CUDA_ATTEMPT -lt 10 ]; do

			add_basecall_align_update "Checking if CUDA driver is working (attempt $CUDA_ATTEMPT)" $LOG_FILE

			nvidia-smi

			CUDA_EXIT=$?
			sleep 20s
			CUDA_ATTEMPT=$(((CUDA_ATTEMPT)+1))

		done

		if [ ${CUDA_EXIT} -gt 0 ]; then
			
			add_basecall_align_update "NVIDIA driver (nvidia-smi) exited with non-zero code $CUDA_EXIT even after 5 attempts, exiting job for batch $CURRTIME" $LOG_FILE
			email_basecall_align_update "BASECALLING STATUS: NVIDIA driver (nvidia-smi) unsuccessful" $LOG_FILE $ERROR_EMAIL_SUB 
			exit 11

		else

			add_basecall_align_update "CUDA driver (nvidia-smi) exited successfully in $CUDA_ATTEMPT attempt/s" $LOG_FILE

		fi	

		#################### Basecalling ###########################

		add_basecall_align_update "Starting basecalling job for ${NUM_POD5} fast5 file/s" $LOG_FILE

		mkdir -p $FASTQ_FOLDER
		MAX_READS=$((NUM_POD5*READS_PER_POD5))

        time dorado basecaller \
            -x cuda:all \
            --emit-fastq \
            /opt/dorado-0.4.3-linux-x64/${BA_MODEL} \
            ${POD5_FOLDER}/ > ${FASTQ_FOLDER}/${BATCH}.fastq 

		GUPPY_EXIT=$?

		add_basecall_align_update "Guppy basecalling completed with exit code ${GUPPY_EXIT}" $LOG_FILE
		echo "2" > $BASECALLING_STATUS_FILE

	else

		UPLOAD_STATUS=$(cat $UPLOAD_STATUS_FILE) 
		BASECALLING_STATUS=$(cat $BASECALLING_STATUS_FILE) 
		1>&2 echo "$UPLOAD_STATUS"

		if [ $UPLOAD_STATUS -eq 1 ] && [ $BASECALLING_STATUS -eq 2 ]; then
			echo "1" > $BASECALLING_STATUS_FILE
		fi
		
		add_basecall_align_update "No fast5 files to basecall; exiting job for batch $CURRTIME and deleting $BATCH_FOLDER" $LOG_FILE
		echo "BASECALLING STATUS: No fast5 files to basecall" > $LOG_FILE 
		rm -rf ${BATCH_FOLDER}
		exit 0
	fi

	NUM_ATTEMPT=$(((NUM_ATTEMPT)+1))
done

if [ $GUPPY_EXIT -gt 0 ]; then

	add_basecall_align_update "Guppy basecalling failed more than 5 times, exiting job for batch $CURRTIME" $LOG_FILE
	email_basecall_align_update "BASECALLING STATUS: Basecalling unsuccessful" $LOG_FILE $ERROR_EMAIL_SUB 
	exit 12

else

	add_basecall_align_update "Guppy basecalling completed successfully in $NUM_ATTEMPT attempt/s" $LOG_FILE

	echo "Sequencing summary" >> $LOG_FILE
	awk '{if($10=="TRUE") passed+=$14; total+=$14} END{print passed/total}' ${FASTQ_FOLDER}/sequencing_summary.txt >> $LOG_FILE

fi

#################### Check if pass fastq folder exists ###########################

if [ ! -d ${PASS_FASTQ_FOLDER} ]; then

	add_basecall_align_update "No pass folder; no alignment required" $LOG_FILE 
	email_basecall_align_update "BASECALLING STATUS: Basecalling successful and no minimap2 job to be started" $LOG_FILE $EMAIL_SUB 
	exit 0

fi

#################### Generate list of minimap2 jobs ###########################

add_basecall_align_update "Starting minimap2 command list generation" $LOG_FILE

if [ $(ls ${PASS_FASTQ_FOLDER}/*.fastq | wc -l) -eq 0 ]; then

	add_basecall_align_update "No fastq files in pass folder; no alignment required" $LOG_FILE
	email_basecall_align_update "BASECALLING STATUS: Basecalling successful and no minimap2 job to be started" $LOG_FILE $EMAIL_SUB 
	exit 0

else

	mkdir -p ${TMP_FASTQ_FOLDER}/${BATCH}
	rsync -r ${PASS_FASTQ_FOLDER}/ ${TMP_FASTQ_FOLDER}/${BATCH}/

	add_basecall_align_update "Minimap2 task added to the queue" $LOG_FILE 
	email_basecall_align_update "BASECALLING STATUS: Basecalling successful and minimap2 job added to the queue" $LOG_FILE $EMAIL_SUB

fi
