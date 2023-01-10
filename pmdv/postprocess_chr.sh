#!/bin/bash

source /data/sample.config
CHR_FOLDER=/data/$1_folder
PMDV_UPLOAD_STATUS_FILE=/data/complete_status.txt

gsutil -q cp $CHR_FOLDER/${SAMPLE}_pmdv_$1.vcf.gz ${PMDV_VCF_BUCKET}/
if [ $? -gt 0 ]; then
	1>&2 echo "Error with uploading pmdv vcf for chr"$1
	exit 1
fi

gsutil -q -o "GSUtil:parallel_composite_upload_threshold=750M" -m cp $CHR_FOLDER/intermediate_files/PHASED.PEPPER_MARGIN.haplotagged.bam ${HP_BAM_BUCKET}/${SAMPLE}_$1.bam
if [ $? -gt 0 ]; then
	1>&2 echo "Error with uploading haplotagged bam for chr"$1
	exit 1
fi

gsutil -q -o "GSUtil:parallel_composite_upload_threshold=750M" -m cp $CHR_FOLDER/intermediate_files/PHASED.PEPPER_MARGIN.haplotagged.bam.bai ${HP_BAM_BUCKET}/${SAMPLE}_$1.bam.bai
if [ $? -gt 0 ]; then
	1>&2 echo "Error with uploading haplotagged bam index file for chr"$1
	exit 1
fi

echo "1" > $CHR_FOLDER/$1_pmdv_status.txt
gsutil -q cp  $CHR_FOLDER/$1_pmdv_status.txt ${PMDV_STATUS_BUCKET}/

gsutil -q -m rsync -r $CHR_FOLDER/ ${PMDV_LOG_BUCKET}/$1_folder/

if [ $? -eq 0 ]; then
	echo "1" > $PMDV_UPLOAD_STATUS_FILE
else
	echo "3" > $PMDV_UPLOAD_STATUS_FILE
fi
gsutil -q cp $PMDV_UPLOAD_STATUS_FILE ${PMDV_COMPLETE_STATUS_BUCKET}/$(hostname)_complete_status.txt

