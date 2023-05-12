#!/bin/bash

source /data/sample.config
SNIFFLES_ANNOTATION_FOLDER=/data/spectre_annotation
VCF_FOLDER=${SNIFFLES_ANNOTATION_FOLDER}/spectre_output
BAM_FOLDER=${SNIFFLES_ANNOTATION_FOLDER}/chr_bam

mkdir -p $SNIFFLES_ANNOTATION_FOLDER
mkdir -p $VCF_FOLDER
mkdir -p $BAM_FOLDER

cd $BAM_FOLDER
gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" -m cp ${CHR_BAM_BUCKET}/*.bam $BAM_FOLDER/
gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" -m cp ${CHR_BAM_BUCKET}/*.bai $BAM_FOLDER/
