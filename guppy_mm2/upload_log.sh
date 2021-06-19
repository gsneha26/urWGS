#!/bin/bash

source /data/sample.config

export FAST5_FOLDER=/data/input_folder/
export FASTQ_FOLDER=/data/output_folder/
export BAM_FOLDER=/data/chr_bam
export LOG_FOLDER=/data/logs
export LOG_BUCKET=${GUPPY_MM2_UPDATES_BUCKET}/$(hostname)/

mkdir -p $LOG_FOLDER
echo "current "$(TZ='America/Los_Angeles' date) >> $LOG_FOLDER/fast5_files.log
ls -lRh $FAST5_FOLDER >> $LOG_FOLDER/fast5_files.log
echo "current "$(TZ='America/Los_Angeles' date) >> $LOG_FOLDER/fastq_files.log
ls -lRh $FASTQ_FOLDER >> $LOG_FOLDER/fastq_files.log
echo "current "$(TZ='America/Los_Angeles' date) >> $LOG_FOLDER/bam_files.log
ls -lRh $BAM_FOLDER >> $LOG_FOLDER/bam_files.log

echo "" >> $LOG_FOLDER/summary.log
echo "current "$(TZ='America/Los_Angeles' date) >> $LOG_FOLDER/summary.log
echo "==== FAST5 FOLDER ====" >> $LOG_FOLDER/summary.log
du -sh /data/input_folder/*/*/* >> $LOG_FOLDER/summary.log
du -sh /data/input_folder/ >> $LOG_FOLDER/summary.log
echo "" >> $LOG_FOLDER/summary.log
echo "==== FASTQ FOLDER ====" >> $LOG_FOLDER/summary.log
du -sh /data/output_folder/* >> $LOG_FOLDER/summary.log
du -sh /data/output_folder/ >> $LOG_FOLDER/summary.log
echo "" >> $LOG_FOLDER/summary.log
echo "==== BAM FOLDER ====" >> $LOG_FOLDER/summary.log
du -sh /data/chr_bam/ >> $LOG_FOLDER/summary.log
echo "" >> $LOG_FOLDER/summary.log
echo "==== PROCESS STATUS ====" >> $LOG_FOLDER/summary.log
SERVICE="/bin/bash $PROJECT_DIR/run_basecalling.sh"
if pgrep -f "$SERVICE" >/dev/null
then
        echo "Basecalling is running" >> $LOG_FOLDER/summary.log
else	
	echo "Basecalling is not running" >> $LOG_FOLDER/summary.log
fi
SERVICE="/bin/bash $PROJECT_DIR/run_alignment.sh"
if pgrep -f "$SERVICE" >/dev/null
then
        echo "Alignment is running" >> $LOG_FOLDER/summary.log
else
	echo "Alignment is not running" >> $LOG_FOLDER/summary.log
fi

time gsutil -m cp -r $LOG_FOLDER/*.log $LOG_BUCKET
