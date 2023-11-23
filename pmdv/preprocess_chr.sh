#!/bin/bash

source /data/sample.config

CHR_FOLDER=/data/$1_folder
mkdir -p $CHR_FOLDER

gsutil -q -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp gs://ur_wgs_test_data/GRCh37_chr_fasta/GRCh37_$1.fa /data/

if [ $BAM_MERGE == "YES" ]; then

	gsutil -q -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp ${BASECALL_ALIGN_OUTPUT_BUCKET}/$1/*.bam $CHR_FOLDER/ 
	if [ $? -gt 0 ]; then
		1>&2 echo "BAM download failed for chr"$1
		exit 1
	fi	

	cd $CHR_FOLDER 
	for bam_file in *.bam;
	do
		samtools index -@10 $bam_file
		if [ $? -gt 0 ]; then
			1>&2 echo "Error with indexing "$bam_file
			exit 1
		fi	
		SAM_EXIT=$?
		if [ $SAM_EXIT -gt 0 ]; then
			rm $bam_file
			email_vc_update "Removing $bam_file" $1 "PEPPER-Margin-DeepVariant"
		fi
	done

	samtools merge -@10 ${SAMPLE}_$1.bam $CHR_FOLDER/*.bam
	if [ $? -gt 0 ]; then
		1>&2 echo "Error with merging bams for chr "$1
		exit 1
	fi	

	samtools index -@10 ${SAMPLE}_$1.bam
	if [ $? -gt 0 ]; then
		1>&2 echo "Error with indexing merged bam for chr "$1
		exit 1
	fi	

    if [ $1 == "chrMT" ]; then
        DEPTH=$(samtools depth -r MT ${SAMPLE}_$1.bam | awk '{sum+=$3} END {print int(sum/NR)}')

        if [ $DEPTH -gt 700 ]; then

            samtools view -s 0.20 -b -@16 ${SAMPLE}_$1.bam > ${SAMPLE}_$1.bam.700x.bam
            cp ${SAMPLE}_$1.bam.700x.bam ${SAMPLE}_$1.bam
            samtools index -@10 ${SAMPLE}_$1.bam
            if [ $? -gt 0 ]; then
                1>&2 echo "Error with indexing merged bam for chr "$1
                exit 1
            fi	
        fi
    fi

	gsutil -q -o "GSUtil:parallel_composite_upload_threshold=750M" -m cp ${SAMPLE}_$1.bam* ${CHR_BAM_BUCKET}/
	echo "1" > $CHR_FOLDER/$1_bam_status.txt
	gsutil -q cp  $CHR_FOLDER/$1_bam_status.txt ${BAM_STATUS_BUCKET}/

else 

	gsutil -q -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp ${CHR_BAM_BUCKET}/${SAMPLE}_$1.bam $CHR_FOLDER/ 
	if [ $? -gt 0 ]; then
		1>&2 echo "Error with downloading bam for chr "$1
		exit 1
	fi	

	gsutil -q -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp ${CHR_BAM_BUCKET}/${SAMPLE}_$1.bam.bai $CHR_FOLDER/ 

fi
