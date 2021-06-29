#!/bin/bash

source /data/sample.config
CHR_FOLDER=/data/$1_folder

1>&2 echo "============================================================================"
cd $CHR_FOLDER/margin/
time (samtools index -@90 MARGIN_PHASED.PEPPER_SNP_MARGIN.haplotagged.bam
samtools addreplacerg -r '@RG\tID:HG002_guppy422_fl1\tLB:HG002_guppy422_fl1\tPL:HG002_guppy422_fl1\tPU:HG002_guppy422_fl1\tSM:HG002' -@31 -o MARGIN_PHASED.PEPPER_SNP_MARGIN.HEADER_FIXED.SAMTOOLS.haplotagged.bam MARGIN_PHASED.PEPPER_SNP_MARGIN.haplotagged.bam)
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
	email_vc_update "Margin BAM processing completed for $1" $1 "PEPPER-Margin-DeepVariant" 
else
	email_vc_update "Margin BAM processing failed for $1" $1 "PEPPER-Margin-DeepVariant Error" 
	exit 1
fi

time sudo pbrun deepvariant \
        --ref /data/GRCh37.fa \
        --in-bam $CHR_FOLDER/margin/MARGIN_PHASED.PEPPER_SNP_MARGIN.HEADER_FIXED.SAMTOOLS.haplotagged.bam \
        --out-variants $CHR_FOLDER/${SAMPLE}_pmdv_$1.vcf \
        --pb-model-file $PB_MODEL_FILE \
        --proposed-variants $CHR_FOLDER/pepper_hp/PEPPER_VARIANT_HP_OUTPUT.vcf.gz \
        --sort-by-haplotypes \
        --min-mapping-quality 1 \
        --min-base-quality 1 \
        --mode ont \
        --x3
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
	email_vc_update "Parabricks DeepVariant completed for $1" $1 "PEPPER-Margin-DeepVariant" 
else
	email_vc_update "Parabricks DeepVariant failed for $1" $1 "PEPPER-Margin-DeepVariant Error" 
	exit 1
fi

cd $CHR_FOLDER/
bgzip ${SAMPLE}_pmdv_$1.vcf

1>&2 echo "============================================================================"
1>&2 echo "current "$(TZ='America/Los_Angeles' date)
1>&2 echo "============================================================================"
