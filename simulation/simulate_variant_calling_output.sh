#! /bin/bash

1>&2 echo "current "$(date)
source /data/sample.config

BAM_SRC_BUCKET=gs://ur_wgs_test_data/HG002_chr_bam
PMDV_SRC_BUCKET=gs://ur_wgs_test_data/HG002_pmdv_google_rows_output
SNIFFLES_SRC_BUCKET=gs://ur_wgs_test_data/HG002_sniffles_output

gsutil -m rsync -r ${BAM_SRC_BUCKET}/ ${CHR_BAM_BUCKET}/
gsutil -m rsync -r ${PMDV_SRC_BUCKET}/ ${PMDV_VCF_BUCKET}/
gsutil -m rsync -r ${SNIFFLES_SRC_BUCKET}/ ${SNIFFLES_VCF_BUCKET}/

BAM_STATUS_DIR=/data/chr_bam_status
SNIFFLES_STATUS_DIR=/data/sniffles_status
PMDV_STATUS_DIR=/data/pmdv_status

mkdir -p $BAM_STATUS_DIR/
mkdir -p $SNIFFLES_STATUS_DIR/
mkdir -p $PMDV_STATUS_DIR/

for chr in `seq 1 22` X Y MT;
do
	echo "1" > $BAM_STATUS_DIR/chr${chr}_bam_status.txt 
	echo "1" > $SNIFFLES_STATUS_DIR/chr${chr}_sniffles_status.txt 
	echo "1" > $PMDV_STATUS_DIR/chr${chr}_pmdv_status.txt 
done

gsutil -m rsync -r $BAM_STATUS_DIR/ $BAM_STATUS_BUCKET/
gsutil -m rsync -r $SNIFFLES_STATUS_DIR/ $SNIFFLES_STATUS_BUCKET/
gsutil -m rsync -r $PMDV_STATUS_DIR/ $PMDV_STATUS_BUCKET/
