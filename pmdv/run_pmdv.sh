#!/bin/bash

source /data/sample.config
CHR_FOLDER=/data/$1_folder

1>&2 echo "============================================================================"
time sudo docker run --ipc=host \
        -v /data:/data \
        kishwars/pepper_deepvariant:r0.8 \
        run_pepper_margin_deepvariant call_variant \
        -b $CHR_FOLDER/${SAMPLE}_$1.bam \
        -f /data/GRCh37_$1.fa \
        -s ${SAMPLE} \
        -o ${CHR_FOLDER} \
        -p ${SAMPLE}_pmdv_$1 \
        -t 96 \
        --ont_r9_guppy5_sup \
        --keep_intermediate_bam_files \
        -k
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
