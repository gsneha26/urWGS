#!/bin/bash

source /data/sample.config

cd /data
BAM_FILE=${SAMPLE}_${1}.bam
VCF_FILE=${SAMPLE}_sniffles_${1}.vcf

gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp ${CHR_BAM_BUCKET}/${BAM_FILE} /data/ 
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
        email_struc_vc_update "Downloaded $BAM_FILE" $1 "Sniffles" 
else
        email_struc_vc_update "Download $BAM_FILE failed" $1 "Sniffles Error"
fi

sniffles -n 60 -t $2 -m ${BAM_FILE} -v $VCF_FILE > sniffles_${1}.log 2> sniffles_${1}.err 
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
        email_struc_vc_update "Completed Sniffles for $1" $1 "Sniffles" 
else
        email_struc_vc_update "Sniffles failed for $1" $1 "Sniffles Error"
fi

gsutil cp $VCF_FILE ${SV_VCF_BUCKET}/
VC_CODE=$?
if [ $VC_CODE -eq 0 ]; then
        email_struc_vc_update "Uploaded $VCF_FILE" $1 "Sniffles" 
	echo "1" > $1_sniffles_status.txt
else
        email_struc_vc_update "Upload $VCF_FILE failed" $1 "Sniffles Error"
	echo "2" > $1_sniffles_status.txt
fi

gsutil cp $1_sniffles_status.txt ${SV_STATUS_BUCKET}/
