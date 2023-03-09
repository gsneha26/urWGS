#!/bin/bash 

set -x

source /data/sample.config
GENE_LIST=/data/sample_gene_list.txt
gsutil -q cp $GENE_LIST_URL $GENE_LIST
SPECTRE_ANNOTATION_FOLDER=/data/spectre_annotation
VCF_FOLDER=${SPECTRE_ANNOTATION_FOLDER}/spectre_output
BAM_FOLDER=${SPECTRE_ANNOTATION_FOLDER}/chr_bam
FINAL_VCF=${SAMPLE}.spectre.merged.vcf

mkdir -p $SPECTRE_ANNOTATION_FOLDER
mkdir -p $VCF_FOLDER

cd $SPECTRE_ANNOTATION_FOLDER
rm -f vcf.list.txt
rm -f bam.list.tsv
rm -rf mosdepth.* benchmark_sv_annotation/ $FINAL_VCF 
rm -f vcf/*.rn.vcf vcf/*.temp.txt

gsutil -q -m rsync ${SPECTRE_VCF_BUCKET}/ ${VCF_FOLDER}/

## make a file listing the sniffle VCFs, for example:
ls -v spectre_output/${SAMPLE}_spectre_chr*.vcf > vcf.list.txt

## make a file listing the BAMs (1st column is chr name), for example:
for CHR in $(seq 1 22) X Y MT;
do
echo -e "$CHR\tchr_bam/${SAMPLE}_chr$CHR.bam" >> bam.list.tsv
done

## start docker container
sudo docker run \
   -v /data:/data \
   -w $SPECTRE_ANNOTATION_FOLDER \
   -u `id \
   -u $USER` quay.io/jmonlong/svnicu:0.5 snakemake \
   --snakefile /scripts/Snakefile \
   --config ref=/data/GRCh37.fa \
   gene_list=${GENE_LIST} \
   bam_list=${SPECTRE_ANNOTATION_FOLDER}/bam.list.tsv \
   vcf_list=${SPECTRE_ANNOTATION_FOLDER}/vcf.list.txt \
   sample=${SAMPLE} \
   --cores 90

sudo docker run \
	-v /data:/data \
	-w $SPECTRE_ANNOTATION_FOLDER \
	-u `id \
	-u $USER` quay.io/jmonlong/svnicu:0.5 snakemake \
	--snakefile /scripts/Snakefile \
	--config ref=/data/GRCh37.fa \
	gene_list=${GENE_LIST} \
	bam_list=${SPECTRE_ANNOTATION_FOLDER}/bam.list.tsv \
	vcf_list=${SPECTRE_ANNOTATION_FOLDER}/vcf.list.txt \
	sample=${SAMPLE} \
	--cores 90

## upload files 
for file in $FINAL_VCF chr-arm-karyotype.tsv sv-annotated.tsv sv-report.html; 
do
	gsutil -q cp $file ${FINAL_OUTPUT_BUCKET}/
	gsutil -q cp ${FINAL_OUTPUT_BUCKET}/$file ${FINAL_OUTPUT_BUCKET_GC}/
done
