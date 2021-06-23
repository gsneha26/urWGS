#!/bin/bash

source /data/sample.config
CHR_FOLDER=/data/$1_folder

1>&2 echo "============================================================================"
1>&2 echo "current "$(TZ='America/Los_Angeles' date)
1>&2 echo "============================================================================"
time sudo docker run \
	--ipc=host \
	-v /data:/data \
	kishwars/pepper_deepvariant:test-v0.5-rows pepper_variant make_images \
	-b $CHR_FOLDER/${SAMPLE}_$1.bam \
	-f /data/GRCh37_$1.fa \
	-o $CHR_FOLDER/pepper_snp/images/ \
	-t 90
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
	email_vc_update "PEPPER_SNP stage1 completed for $1" $1 "PEPPER-Margin-DeepVariant" 
else
	email_vc_update "PEPPER_SNP stage1 failed for $1" $1 "PEPPER-Margin-DeepVariant Error" 
fi

1>&2 echo "============================================================================"
time sudo docker run \
	--ipc=host \
	--gpus all \
	-v /data:/data \
	kishwars/pepper_deepvariant:test-v0.5-rows pepper_variant run_inference \
	-i $CHR_FOLDER/pepper_snp/images/ \
	-m /opt/pepper_models/PEPPER_SNP_R941_ONT_V4.pkl \
	-o $CHR_FOLDER/pepper_snp/predictions/ \
	-bs 512 \
	-g \
	-per_gpu 4 \
	-w 8 \
	-t 90
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
	email_vc_update "PEPPER_SNP stage2 completed for $1" $1 "PEPPER-Margin-DeepVariant" 
else
	email_vc_update "PEPPER_SNP stage2 failed for $1" $1 "PEPPER-Margin-DeepVariant Error" 
fi

1>&2 echo "============================================================================"
time sudo docker run \
	--ipc=host \
	-v /data:/data \
	kishwars/pepper_deepvariant:test-v0.5-rows pepper_variant find_candidates \
	-i $CHR_FOLDER/pepper_snp/predictions/ \
	-b $CHR_FOLDER/${SAMPLE}_$1.bam \
	-f /data/GRCh37_$1.fa \
	-s ${SAMPLE} \
	-o $CHR_FOLDER/pepper_snp/ \
	-t 90 \
	--ont
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
	email_vc_update "PEPPER_SNP stage3 completed for $1" $1 "PEPPER-Margin-DeepVariant" 
else
	email_vc_update "PEPPER_SNP stage3 failed for $1" $1 "PEPPER-Margin-DeepVariant Error" 
fi

1>&2 echo "============================================================================"
cd $CHR_FOLDER/pepper_snp/
time (bgzip PEPPER_VARIANT_SNP_OUTPUT.vcf
tabix -p vcf PEPPER_VARIANT_SNP_OUTPUT.vcf.gz)
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
	email_vc_update "PEPPER_SNP vcf processing completed for $1" $1 "PEPPER-Margin-DeepVariant" 
else
	email_vc_update "PEPPER_SNP vcf processing failed for $1" $1 "PEPPER-Margin-DeepVariant Error" 
fi

1>&2 echo "============================================================================"
time sudo docker run \
	--ipc=host \
	-v /data:/data \
	kishwars/pepper_deepvariant:test-v0.5-rows margin phase \
        $CHR_FOLDER/${SAMPLE}_$1.bam \
        /data/GRCh37_$1.fa \
        $CHR_FOLDER/pepper_snp/PEPPER_VARIANT_SNP_OUTPUT.vcf.gz \
	/opt/margin_dir/params/misc/allParams.ont_haplotag.json \
	-t 90 \
        -o $CHR_FOLDER/margin/MARGIN_PHASED.PEPPER_SNP_MARGIN
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
	email_vc_update "Margin completed for $1" $1 "PEPPER-Margin-DeepVariant" 
else
	email_vc_update "Margin failed for $1" $1 "PEPPER-Margin-DeepVariant Error" 
fi

1>&2 echo "============================================================================"
cd $CHR_FOLDER/margin/
time samtools index -@90 MARGIN_PHASED.PEPPER_SNP_MARGIN.haplotagged.bam
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
	email_vc_update "Margin BAM processing completed for $1" $1 "PEPPER-Margin-DeepVariant" 
else
	email_vc_update "Margin BAM processing failed for $1" $1 "PEPPER-Margin-DeepVariant Error" 
fi

1>&2 echo "============================================================================"
time sudo docker run \
	--ipc=host \
	-v /data:/data \
	kishwars/pepper_deepvariant:test-v0.5-rows pepper_variant make_images \
	-b $CHR_FOLDER/margin/MARGIN_PHASED.PEPPER_SNP_MARGIN.haplotagged.bam \
	-f /data/GRCh37_$1.fa \
	-t 90 \
	-o $CHR_FOLDER/pepper_hp/images/ \
	-hp
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
	email_vc_update "PEPPER_HP stage1 completed for $1" $1 "PEPPER-Margin-DeepVariant" 
else
	email_vc_update "PEPPER_HP stage1 failed for $1" $1 "PEPPER-Margin-DeepVariant Error" 
fi

1>&2 echo "============================================================================"
time sudo docker run \
	--ipc=host \
	--gpus all \
	-v /data:/data \
	kishwars/pepper_deepvariant:test-v0.5-rows pepper_variant run_inference \
	-i $CHR_FOLDER/pepper_hp/images/ \
	-m /opt/pepper_models/PEPPER_HP_R941_ONT_V4.pkl \
	-o $CHR_FOLDER/pepper_hp/predictions/ \
	-bs 512 \
	-g \
	-per_gpu 4 \
	-w 8 \
	-t 90 \
	-hp
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
	email_vc_update "PEPPER_HP stage2 completed for $1" $1 "PEPPER-Margin-DeepVariant" 
else
	email_vc_update "PEPPER_HP stage2 failed for $1" $1 "PEPPER-Margin-DeepVariant Error" 
fi

1>&2 echo "============================================================================"
time sudo docker run \
	--ipc=host \
	-v /data:/data \
	kishwars/pepper_deepvariant:test-v0.5-rows pepper_variant find_candidates \
	-i $CHR_FOLDER/pepper_hp/predictions/ \
	-b $CHR_FOLDER/margin/MARGIN_PHASED.PEPPER_SNP_MARGIN.haplotagged.bam \
	-f /data/GRCh37_$1.fa \
	-s ${SAMPLE} \
	-o $CHR_FOLDER/pepper_hp/ \
	-t 90 \
	-hp \
	--ont
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
	email_vc_update "PEPPER_HP stage3 completed for $1" $1 "PEPPER-Margin-DeepVariant" 
else
	email_vc_update "PEPPER_HP stage3 failed for $1" $1 "PEPPER-Margin-DeepVariant Error" 
fi

1>&2 echo "============================================================================"
cd $CHR_FOLDER/pepper_hp/
time (mv *.vcf PEPPER_VARIANT_HP_OUTPUT.vcf
bgzip PEPPER_VARIANT_HP_OUTPUT.vcf
tabix -p vcf PEPPER_VARIANT_HP_OUTPUT.vcf.gz)
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
	email_vc_update "PEPPER_HP vcf processing completed for $1" $1 "PEPPER-Margin-DeepVariant" 
else
	email_vc_update "PEPPER_HP vcf processing failed for $1" $1 "PEPPER-Margin-DeepVariant Error" 
fi

