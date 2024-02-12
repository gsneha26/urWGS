#!/bin/bash

source /data/sample.config
CHR_FOLDER=/data/chr$1_folder
INTERMEDIATE_DIRECTORY="intermediate_results_dir"

mkdir -p ${CHR_FOLDER}
mkdir -p /data/"${INTERMEDIATE_DIRECTORY}"

1>&2 echo "============================================================================"
BIN_VERSION=$DV_VERSION
time sudo docker run --ipc=host \
        -v /data:/data \
        google/deepvariant:"${BIN_VERSION}" \
        /opt/deepvariant/bin/run_deepvariant \
        --model_type ONT_R104 \
        --ref /data/GRCh37_chr$1.fa \
        --reads $CHR_FOLDER/${SAMPLE}_chr$1.bam \
        --output_vcf /data/${SAMPLE}_pmdv_chr$1.vcf.gz \
        --output_gvcf /data/${SAMPLE}_pmdv_chr$1.g.vcf.gz \
        --num_shards 96 \
        --regions "$1" \
        --intermediate_results_dir /data/"${INTERMEDIATE_DIRECTORY}" 
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
        email_vc_update "PMDV completed for $1" $1 
else
        email_vc_update "PMDV failed for $1" $1
        exit 1
fi

1>&2 echo "============================================================================"
1>&2 echo "current "$(TZ='America/Los_Angeles' date)
1>&2 echo "============================================================================"
