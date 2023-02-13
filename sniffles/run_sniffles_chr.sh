#!/bin/bash

source /data/sample.config

cd /data
BAM_STATUS=/data/bam_status/${1}_bam_status.txt
SNIFFLES_STATUS=/data/sniffles_status/${1}_sniffles_status.txt
BAM_FILE=${SAMPLE}_${1}.bam
VCF_FILE=${SAMPLE}_sniffles_${1}.vcf

if [ $(cat ${BAM_STATUS}) -eq 1 ] && [ $(cat ${SNIFFLES_STATUS}) -eq 2 ]; then

    gsutil -q -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp ${CHR_BAM_BUCKET}/${BAM_FILE} /data/ 
    VC_CODE=$?
    if [ $VC_CODE -eq 0 ]; then
        email_vc_update "Downloaded $BAM_FILE" $1 "Sniffles" 
    else
        email_vc_update "Download $BAM_FILE failed" $1 "Sniffles Error"
        exit 1
    fi

    gsutil -q -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp ${CHR_BAM_BUCKET}/${BAM_FILE}.bai /data/ 
    VC_CODE=$?
    if [ $VC_CODE -eq 0 ]; then
        email_vc_update "Downloaded $BAM_FILE.bai" $1 "Sniffles" 
    else
        email_vc_update "Download $BAM_FILE.bai failed" $1 "Sniffles Error"
        exit 1
    fi

    sudo docker run -i -v /data:/data gsneha/sv_caller sniffles \
        --input /data/${BAM_FILE} \
        --reference /data/GRCh37.fa \
        --vcf /data/${VCF_FILE} \
        -t 96 --minsvlen 50  --mapq 20

    VC_CODE=$?
    if [ $VC_CODE -eq 0 ]; then
        email_vc_update "Completed Sniffles for $1" $1 "Sniffles" 
    else
        email_vc_update "Sniffles failed for $1" $1 "Sniffles Error"
        exit 1
    fi

    gsutil -q cp $VCF_FILE ${SNIFFLES_VCF_BUCKET}/
    VC_CODE=$?
    if [ $VC_CODE -eq 0 ]; then
        email_vc_update "Uploaded $VCF_FILE" $1 "Sniffles" 
        echo "1" > $SNIFFLES_STATUS
    else
        email_vc_update "Upload $VCF_FILE failed" $1 "Sniffles Error"
        echo "3" > $SNIFFLES_STATUS 
        exit 1
    fi

    gsutil -q cp ${SNIFFLES_STATUS} ${SNIFFLES_STATUS_BUCKET}/

else
    echo "2" > ${SNIFFLES_STATUS}
fi
