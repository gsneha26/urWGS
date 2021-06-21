#!/bin/bash

source /data/sample.config

CHR_FOLDER=/data/$1_folder
mkdir -p $CHR_FOLDER
mkdir -p $CHR_FOLDER/pepper_snp
mkdir -p $CHR_FOLDER/margin
mkdir -p $CHR_FOLDER/pepper_hp

gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp gs://ur_wgs_public_data/GRCh37_chr_fasta/GRCh37_$1.fa /data/

if [ $2 == "YES" ]; then

	gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp ${GUPPY_MM2_OUTPUT_BUCKET}/$1/*.bam $CHR_FOLDER/ 
	cd $CHR_FOLDER 
	for bam_file in *.bam;
	do
		samtools index -@10 $bam_file
		SAM_EXIT=$?
		if [ $SAM_EXIT -gt 0 ]; then
			rm $bam_file
			email_small_vc_update "Removing $bam_file" $1 "PEPPER-Margin-DeepVariant"
		fi
	done
	samtools merge -@10 ${SAMPLE}_$1.bam $CHR_FOLDER/*.bam
	samtools index -@10 ${SAMPLE}_$1.bam
	gsutil -o "GSUtil:parallel_composite_upload_threshold=750M" -m cp ${SAMPLE}_$1.bam* ${CHR_BAM_BUCKET}/
	echo "1" > $CHR_FOLDER/$1_status.txt
	gsutil cp  $CHR_FOLDER/$1_status.txt ${BAM_STATUS_BUCKET}/

elif [ $2 == "NO" ]; then

	gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp ${CHR_BAM_BUCKET}/${SAMPLE}_$1.bam $CHR_FOLDER/ 
	gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp ${CHR_BAM_BUCKET}/${SAMPLE}_$1.bam.bai $CHR_FOLDER/ 

fi
