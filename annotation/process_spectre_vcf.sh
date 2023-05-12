#!/bin/bash 

set -x

source /data/sample.config
SPECTRE_ANNOTATION_FOLDER=/data/spectre_annotation
VCF_FOLDER=${SPECTRE_ANNOTATION_FOLDER}/spectre_output
FINAL_VCF=${SAMPLE}.spectre.merged.vcf
INPUT_VCF=${SAMPLE}_spectre.vcf.gz
INPUT_PREFIX=${INPUT_VCF%.vcf}

mkdir -p $SPECTRE_ANNOTATION_FOLDER
mkdir -p $VCF_FOLDER

cd $SPECTRE_ANNOTATION_FOLDER

gsutil -q -m rsync ${SPECTRE_VCF_BUCKET}/ ${VCF_FOLDER}/

cd $SPECTRE_ANNOTATION_FOLDER
bcftools concat \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr1.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr2.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr3.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr4.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr5.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr6.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr7.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr8.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr9.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr10.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr11.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr12.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr13.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr14.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr15.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr16.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr17.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr18.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr19.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr20.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr21.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr22.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chrX.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chrY.vcf \
	${VCF_FOLDER}/${INPUT_PREFIX}_chrMT.vcf | bgzip > ${INPUT_VCF}

gsutil -q cp ${INPUT_VCF} ${FINAL_OUTPUT_BUCKET}/

