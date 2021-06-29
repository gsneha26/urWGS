#!/bin/bash

source /data/sample.config
EMAIL_SUB="Basecalling"
ERROR_EMAIL_SUB="Basecalling Error"

1>&2 echo ""
1>&2 echo "current "$(TZ='America/Los_Angeles' date)
CURRTIME=$(date +%s)
BATCH=batch_$CURRTIME

#################### Initialize folder and file names ###########################

FAST5_FOLDER=/data/input_folder
BATCH_FOLDER=/data/output_folder/$BATCH
UPLOAD_STATUS_FILE=/data/upload_status.txt
BASECALLING_STATUS_FILE=/data/basecalling_status.txt

mkdir -p $FAST5_FOLDER
mkdir -p $BATCH_FOLDER

LOG_FILE=${BATCH_FOLDER}/${BATCH}_basecalling.log

echo "" > $LOG_FILE 
1>&2 echo "New batch number: $CURRTIME"
echo "=========== Basecalling logs for batch_$CURRTIME ============" >> $LOG_FILE 

add_guppy_mm2_update "Created batch folder: $BATCH_FOLDER" $LOG_FILE

FAST5_LIST=${BATCH_FOLDER}/${BATCH}_fast5.lst
FASTQ_FOLDER=${BATCH_FOLDER}/guppy_output/
PASS_FASTQ_FOLDER=${BATCH_FOLDER}/guppy_output/pass
if [ ${BARCODE_DONE} == "YES" ]; then
	PASS_FASTQ_FOLDER=${PASS_FASTQ_FOLDER}/${BARCODE_NUM}
fi
TMP_FASTQ_FOLDER=/data/tmp_fastq

mkdir -p $TMP_FASTQ_FOLDER

#################### Download fast5 files ###########################

NUM_ATTEMPT=0
DWNLD_EXIT=1

while [ $DWNLD_EXIT -gt 0 ] && [ $NUM_ATTEMPT -lt 5 ] ; do

	add_guppy_mm2_update "Starting fast5 download" $LOG_FILE

	time gsutil -q -m rsync -r -x ".*[1-6][B-H].*$" $FAST5_BUCKET/ $FAST5_FOLDER/

	DWNLD_EXIT=$?
	NUM_ATTEMPT=$(((NUM_ATTEMPT)+1))

	gsutil -q cp $FAST5_STATUS_BUCKET /data/
done

if [ $DWNLD_EXIT -gt 0 ]; then

	add_guppy_mm2_update "Download failed more than 5 times, exiting job for batch $CURRTIME" $LOG_FILE
	email_guppy_mm2_update "BASECALLING STATUS: Download fast5 unsuccessful" $LOG_FILE $ERROR_EMAIL_SUB 
	exit 10

else

	add_guppy_mm2_update "Downloaded fast5 files in $NUM_ATTEMPT attempt/s" $LOG_FILE

fi

#################### Start generating fast5 file list and basecalling ###########################

NUM_ATTEMPT=0
GUPPY_EXIT=1

while [ $GUPPY_EXIT -gt 0 ] && [ $NUM_ATTEMPT -lt 5 ] ; do

	echo > $FAST5_LIST
	rm -rf $FASTQ_FOLDER
	NUM_FAST5=0

	add_guppy_mm2_update "Starting attempt $NUM_ATTEMPT" $LOG_FILE

	add_guppy_mm2_update "Starting fast5 file list generation" $LOG_FILE

	for i in `find ${FAST5_FOLDER} -name "*.fast5"`;
	do
		FILE=$(readlink -f $i)
		FILETIME=$(stat $i -c %X)
		if [ $FILETIME -gt $CURRTIME ]; then
			echo $FILE >> $FAST5_LIST
			NUM_FAST5=$(((NUM_FAST5)+1))
		fi
	done

	if [ ${NUM_FAST5} -gt 0 ]; then

	#################### Check if NVIDIA driver works ###########################

		add_guppy_mm2_update "Fast5 file list generated" $LOG_FILE
	
		CUDA_EXIT=1
		CUDA_ATTEMPT=0

		while [ ${CUDA_EXIT} -gt 0 ] && [ $CUDA_ATTEMPT -lt 10 ]; do

			add_guppy_mm2_update "Checking if CUDA driver is working (attempt $CUDA_ATTEMPT)" $LOG_FILE

			nvidia-smi

			CUDA_EXIT=$?
			sleep 20s
			CUDA_ATTEMPT=$(((CUDA_ATTEMPT)+1))

		done

		if [ ${CUDA_EXIT} -gt 0 ]; then
			
			add_guppy_mm2_update "NVIDIA driver (nvidia-smi) exited with non-zero code $CUDA_EXIT even after 5 attempts, exiting job for batch $CURRTIME" $LOG_FILE
			email_guppy_mm2_update "BASECALLING STATUS: NVIDIA driver (nvidia-smi) unsuccessful" $LOG_FILE $ERROR_EMAIL_SUB 
			exit 11

		else

			add_guppy_mm2_update "CUDA driver (nvidia-smi) exited successfully in $CUDA_ATTEMPT attempt/s" $LOG_FILE

		fi	

		#################### Basecalling ###########################

		add_guppy_mm2_update "Starting basecalling job for ${NUM_FAST5} fast5 file/s" $LOG_FILE

		mkdir -p $FASTQ_FOLDER
		MAX_READS=$((NUM_FAST5*READS_PER_FAST5))

		if [ ${BARCODE_DONE} == "YES" ]; then
			time guppy_basecaller \
				--config /opt/ont/guppy/data/dna_r9.4.1_450bps_hac_prom.cfg \
				--input_file_list $FAST5_LIST \
				--barcode_kits "EXP-NBD104" \
				--qscore_filtering \
				-s $FASTQ_FOLDER \
				-x cuda:all \
				-q ${MAX_READS} \
				--read_batch_size ${MAX_READS}
		else
			time guppy_basecaller \
				--config /opt/ont/guppy/data/dna_r9.4.1_450bps_hac_prom.cfg \
				--input_file_list $FAST5_LIST \
				--qscore_filtering \
				-s $FASTQ_FOLDER \
				-x cuda:all \
				-q ${MAX_READS} \
				--read_batch_size ${MAX_READS}

		fi
		GUPPY_EXIT=$?

		add_guppy_mm2_update "Guppy basecalling completed with exit code ${GUPPY_EXIT}" $LOG_FILE
		echo "2" > $BASECALLING_STATUS_FILE

	else

		UPLOAD_STATUS=$(cat $UPLOAD_STATUS_FILE) 
		BASECALLING_STATUS=$(cat $BASECALLING_STATUS_FILE) 
		1>&2 echo "$UPLOAD_STATUS"

		if [ $UPLOAD_STATUS -eq 1 ] && [ $BASECALLING_STATUS -eq 2 ]; then
			echo "1" > $BASECALLING_STATUS_FILE
		fi
		
		add_guppy_mm2_update "No fast5 files to basecall; exiting job for batch $CURRTIME and deleting $BATCH_FOLDER" $LOG_FILE
		echo "BASECALLING STATUS: No fast5 files to basecall" | cat - $LOG_FILE | sponge $LOG_FILE
		rm -rf ${BATCH_FOLDER}
		exit 0
	fi

	NUM_ATTEMPT=$(((NUM_ATTEMPT)+1))
done

if [ $GUPPY_EXIT -gt 0 ]; then

	add_guppy_mm2_update "Guppy basecalling failed more than 5 times, exiting job for batch $CURRTIME" $LOG_FILE
	email_guppy_mm2_update "BASECALLING STATUS: Basecalling unsuccessful" $LOG_FILE $ERROR_EMAIL_SUB 
	exit 12

else

	add_guppy_mm2_update "Guppy basecalling completed successfully in $NUM_ATTEMPT attempt/s" $LOG_FILE

	echo "Sequencing summary" >> $LOG_FILE
	awk '{if($10=="TRUE") passed+=$14; total+=$14} END{print passed/total}' ${FASTQ_FOLDER}/sequencing_summary.txt >> $LOG_FILE

fi

#################### Check if pass fastq folder exists ###########################

if [ ! -d ${PASS_FASTQ_FOLDER} ]; then

	add_guppy_mm2_update "No pass folder; no alignment required" $LOG_FILE 
	email_guppy_mm2_update "BASECALLING STATUS: Basecalling successful and no minimap2 job to be started" $LOG_FILE $EMAIL_SUB 
	exit 0

fi

#################### Generate list of minimap2 jobs ###########################

add_guppy_mm2_update "Starting minimap2 command list generation" $LOG_FILE

if [ $(ls ${PASS_FASTQ_FOLDER}/*.fastq | wc -l) -eq 0 ]; then

	add_guppy_mm2_update "No fastq files in pass folder; no alignment required" $LOG_FILE
	email_guppy_mm2_update "BASECALLING STATUS: Basecalling successful and no minimap2 job to be started" $LOG_FILE $EMAIL_SUB 
	exit 0

else

	mkdir -p ${TMP_FASTQ_FOLDER}/${BATCH}
	rsync -r ${PASS_FASTQ_FOLDER}/ ${TMP_FASTQ_FOLDER}/${BATCH}/

	add_guppy_mm2_update "Minimap2 task added to the queue" $LOG_FILE 
	email_guppy_mm2_update "BASECALLING STATUS: Basecalling successful and minimap2 job added to the queue" $LOG_FILE $EMAIL_SUB

fi
