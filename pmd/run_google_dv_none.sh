#!/bin/bash

source /data/sample.config
CHR_FOLDER=/data/$1_folder

1>&2 echo "============================================================================"
time docker run --ipc=host \
	--gpus all \
	-v /data:/data \
	kishwars/pepper_deepvariant:test-v0.5 \
	time /opt/deepvariant/bin/run_deepvariant \
	--model_type WGS \
	--customized_model /opt/dv_models/ont_1121_none/model.ckpt-30200 \
	--ref /data/GRCh37_$1.fa \
	--reads $CHR_FOLDER/margin/MARGIN_PHASED.PEPPER_SNP_MARGIN.haplotagged.bam \
	--output_vcf ${CHR_FOLDER}/${SAMPLE}_pmd_$1.vcf \
	--sample_name ${SAMPLE} \
	--intermediate_results_dir ${CHR_FOLDER}/dv_intermediate_outputs/ \
	--num_shards 90  \
	--make_examples_extra_args "alt_aligned_pileup=none,realign_reads=false,min_mapping_quality=1,min_base_quality=1,sort_by_haplotypes=true,parse_sam_aux_fields=true,add_hp_channel=false,variant_caller=vcf_candidate_importer,proposed_variants=$CHR_FOLDER/pepper_hp/PEPPER_VARIANT_HP_OUTPUT.vcf.gz" \
	--postprocess_variants_extra_args "use_multiallelic_model=True"
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
	email_vc_update "Google DeepVariant completed for $1" $1 "PEPPER-Margin-DeepVariant" 
else
	email_vc_update "Google DeepVariant failed for $1" $1 "PEPPER-Margin-DeepVariant Error" 
fi

cd $CHR_FOLDER/
bgzip ${SAMPLE}_pmd_$1.vcf

1>&2 echo "============================================================================"
1>&2 echo "current "$(TZ='America/Los_Angeles' date)
1>&2 echo "============================================================================"
