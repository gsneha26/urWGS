#!/bin/bash 

set -x
source /data/sample.config
PMD_ANNOTATION_FOLDER=/data/pmdv_annotation
VCF_FOLDER=${PMD_ANNOTATION_FOLDER}/pmdv_output
INPUT_VCF=${SAMPLE}_pmdv.vcf.gz 
INPUT_PREFIX=${INPUT_VCF%.vcf.gz}

mkdir -p $PMD_ANNOTATION_FOLDER
mkdir -p $VCF_FOLDER

gsutil -m rsync -r ${PMD_VCF_BUCKET}/ $VCF_FOLDER/

cd $PMD_ANNOTATION_FOLDER/
bcftools concat \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr1.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr2.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr3.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr4.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr5.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr6.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr7.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr8.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr9.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr10.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr11.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr12.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr13.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr14.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr15.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr16.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr17.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr18.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr19.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr20.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr21.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chr22.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chrX.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chrY.vcf.gz \
	${VCF_FOLDER}/${INPUT_PREFIX}_chrMT.vcf.gz | bgzip > ${INPUT_VCF}
tabix -p vcf ${INPUT_VCF}

bedtools subtract -header -A \
	-a ${INPUT_VCF} \
	-b /data/scripts/GRCh37_AllHomopolymers_gt6bp_imperfectgt10bp_slop5.bed.gz | bgzip > ${INPUT_PREFIX}.no_long_homopolymer.vcf.gz

bedtools subtract -header -A \
	-a ${INPUT_PREFIX}.no_long_homopolymer.vcf.gz \
	-b /data/scripts/grch37.4bp_to_6bp_homopolymers_left_pad_1bp.bed | bgzip > ${INPUT_PREFIX}.no_homopolymer.vcf.gz

tabix -p vcf ${INPUT_PREFIX}.no_homopolymer.vcf.gz

bedtools intersect -header -u \
	-a ${INPUT_VCF} \
	-b /data/scripts/GRCh37_AllHomopolymers_gt6bp_imperfectgt10bp_slop5.bed.gz | awk -F'\t' -vOFS='\t' '{ if(!($1 ~ /^#/)) $7 = "Homopolymer"}1' | bgzip | bcftools annotate -h /data/scripts/Homopolymer_header.txt --output-type z -o ${INPUT_PREFIX}.long_homopolymer.vcf.gz

tabix -p vcf ${INPUT_PREFIX}.long_homopolymer.vcf.gz

bedtools intersect -header -u \
	-a ${INPUT_PREFIX}.no_long_homopolymer.vcf.gz \
	-b /data/scripts/grch37.4bp_to_6bp_homopolymers_left_pad_1bp.bed | awk -F'\t' -vOFS='\t' '{ if(!($1 ~ /^#/)) $7 = "ShortHomopolymer"}1' | bgzip | bcftools annotate -h /data/scripts/ShortHomopolymer_header.txt --output-type z -o ${INPUT_PREFIX}.short_homopolymer.vcf.gz

tabix -p vcf ${INPUT_PREFIX}.short_homopolymer.vcf.gz

bcftools concat -a \
	${INPUT_PREFIX}.long_homopolymer.vcf.gz \
	${INPUT_PREFIX}.short_homopolymer.vcf.gz \
	${INPUT_PREFIX}.no_homopolymer.vcf.gz | bcftools sort | bgzip > ${INPUT_PREFIX}.annotated.vcf.gz

tabix -p vcf ${INPUT_PREFIX}.annotated.vcf.gz

gsutil cp ${INPUT_PREFIX}.annotated.vcf.gz* ${FINAL_OUTPUT_BUCKET}/ 
gsutil cp ${INPUT_VCF} ${FINAL_OUTPUT_BUCKET}/ 
