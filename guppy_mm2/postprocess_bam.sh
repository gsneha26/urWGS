#!/bin/bash                                                                              

source /data/sample.config
EMAIL_SUB="Postprocess"
ERROR_EMAIL_SUB="Postprocess Error"

CHR_BAM_FOLDER=/data/chr_bam
FINAL_BAM_FOLDER=/data/final_bam
LOG_FILE=/data/logs/postprocess.log
POSTPROCESS_STATUS_FILE=/data/postprocess_status.txt

mkdir -p $FINAL_BAM_FOLDER

NUM_ATTEMPT=0
PP_EXIT=1

while [ $PP_EXIT -gt 0 ] && [ $NUM_ATTEMPT -lt 5 ] ; do

	add_guppy_mm2_update "Starting attempt $NUM_ATTEMPT" $LOG_FILE

	add_guppy_mm2_update "Starting chr-wise samtools merge using parallel utility" $LOG_FILE

	parallel --verbose -k -j 9 samtools merge -@5 -f /data/final_bam/chr{1}_${FC}.bam /data/chr_bam/*_chr{1}.bam ::: {1..22} X Y MT
	PP_EXIT=$?

	NUM_ATTEMPT=$(((NUM_ATTEMPT)+1))

done

if [ ${PP_EXIT} -gt 0 ]; then

	add_guppy_mm2_update "Parallel chr-wise samtools merge jobs exited with non-zero code $PP_EXIT even after 5 attempts, exiting job" $LOG_FILE
	email_guppy_mm2_update "POSTPROCESS STATUS: Parallel chr-wise samtools merge jobs unsuccessful" $LOG_FILE $ERROR_EMAIL_SUB 
	exit 21

else

	add_guppy_mm2_update "Parallel chr-wise samtools merge jobs exited successfully in $NUM_ATTEMPT attempt/s" $LOG_FILE

fi

NUM_ATTEMPT=0
PP_EXIT=1

while [ $PP_EXIT -gt 0 ] && [ $NUM_ATTEMPT -lt 5 ] ; do

	add_guppy_mm2_update "Starting attempt $NUM_ATTEMPT" $LOG_FILE

	add_guppy_mm2_update "Starting chr-wise bam upload using parallel utility" $LOG_FILE

	parallel --verbose -k -j 9 gsutil -o "GSUtil:parallel_composite_upload_threshold=250M" cp /data/final_bam/chr{1}_*.bam ${GUPPY_MM2_OUTPUT_BUCKET}/chr{1}/ ::: {1..22} X Y MT
	PP_EXIT=$?

	NUM_ATTEMPT=$(((NUM_ATTEMPT)+1))

done

if [ ${PP_EXIT} -gt 0 ]; then

	add_guppy_mm2_update "Parallel chr-wise bam upload jobs exited with non-zero code $PP_EXIT even after 5 attempts, exiting job" $LOG_FILE
	email_guppy_mm2_update "POSTPROCESS STATUS: Parallel chr-wise samtools upload jobs unsuccessful" $LOG_FILE $ERROR_EMAIL_SUB 
	exit 22

else

	add_guppy_mm2_update "Parallel chr-wise bam upload jobs exited successfully in $NUM_ATTEMPT attempt/s" $LOG_FILE
	email_guppy_mm2_update "POSTPROCESS STATUS: Job successful" $LOG_FILE $EMAIL_SUB 
	echo "1" > $POSTPROCESS_STATUS_FILE
	gsutil cp $POSTPROCESS_STATUS_FILE ${GUPPY_MM2_STATUS_BUCKET}/postprocess_${FC}.status
	gsutil -m rsync -r /data/output_folder/ ${GUPPY_MM2_LOG_BUCKET}/$(hostname)/
	echo "Upload completed" | sudo mail -t goenkasneha26@gmail.com -s $(hostname)' '${SAMPLE}' Upload Update' -aFrom:${EMAIL_SENDER}

fi
