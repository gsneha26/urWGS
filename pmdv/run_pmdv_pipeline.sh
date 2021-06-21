#!/bin/bash

source /data/sample.config
chr_args=$( echo $INST_CHR | sed 's/:/ /g' )

STATUS_DIR=/data/guppy_minimap2_status/
PMD_STATUS_FILE=/data/pmdv_status.txt
PMD_STATUS=$(cat $PMD_STATUS_FILE)

mkdir -p $STATUS_DIR 
gsutil rsync ${GUPPY_MM2_STATUS_BUCKET}/ $STATUS_DIR
NUM_FILES=$(ls $STATUS_DIR | wc -l)

1>&2 echo "NUM_FILES: $NUM_FILES"
1>&2 echo "PMD_STATUS: $PMD_STATUS"

if [ $NUM_FILES -eq $NUM_GUPPY ] && [ $PMD_STATUS -eq 2 ]; then
	for ch in $chr_args; do
		email_vc_update "Starting Preprocess for $ch" $ch "PEPPER-Margin-DeepVariant" 
	done

	time parallel -j 2 $PROJECT_DIR/pmdv/preprocess_chr.sh ::: ${chr_args} ::: $BAM_MERGE
	EXIT_CODE=$?
	if [ $EXIT_CODE -eq 0 ]; then
		for ch in $chr_args; do
			email_vc_update "Preprocess completed for $ch" $ch "PEPPER-Margin-DeepVariant"
		done
	else
		for ch in $chr_args; do
			email_vc_update "Preprocess failed for $ch" $ch "PEPPER-Margin-DeepVariant Error" 
		done
	fi

	for ch in $chr_args; do
		time $PROJECT_DIR/pmdv/run_pepper_margin.sh $ch 2> /data/${ch}_folder/run_$ch.log
		if [ $DV == "google" ]; then
			if [ $ROWS == "YES" ]; then
				time $PROJECT_DIR/pmdv/run_google_dv_rows.sh $ch 2>> /data/${ch}_folder/run_$ch.log
			else 
				time $PROJECT_DIR/pmdv/run_google_dv_none.sh $ch 2>> /data/${ch}_folder/run_$ch.log
			fi
		elif [ $DV == "parabricks" ]; then
			if [ $PB_MODEL_FILE == "" ]; then
				email_vc_update "Model file not available for Parabricks" $ch "PEPPER-Margin-DeepVariant"
			else
				time $PROJECT_DIR/pmdv/run_parabricks_dv.sh $ch 2>> /data/${ch}_folder/run_$ch.log
			fi
		fi

		EXIT_CODE=$?
		if [ $EXIT_CODE -eq 0 ]; then
			email_vc_update "PEPPER-Margin-DeepVariant completed for $ch" $ch "PEPPER-Margin-DeepVariant" 
		else
			email_vc_update "PEPPER-Margin-DeepVariant failed for $ch" $ch "PEPPER-Margin-DeepVariant Error" 
		fi
	done

	time parallel -j 2 $PROJECT_DIR/pmdv/postprocess_chr.sh ::: $chr_args
	EXIT_CODE=$?
	if [ ${EXIT_CODE} -eq 0 ]; then
		for ch in $chr_args; do
			email_vc_update "Postprocess completed for $ch" $ch "PEPPER-Margin-DeepVariant" 
		done
	else
		for ch in $chr_args; do
			email_vc_update "Postprocess failed for $ch" $ch "PEPPER-Margin-DeepVariant Error" 
		done
	fi

	echo "1" > $PMD_STATUS_FILE
else
	echo "Not all status files found yet."
fi
