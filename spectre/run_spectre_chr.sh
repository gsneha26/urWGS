#/bin/bash

source /data/sample.config

cd /data
BAM_STATUS=/data/bam_status/${1}_bam_status.txt
SPECTRE_STATUS=/data/spectre_status/${1}_spectre_status.txt
BAM_FILE=${SAMPLE}_${1}.bam
VCF_FILE=/data/${SAMPLE}_spectre_${1}.vcf
REFERENCE=/data/GRCh37_${1}.fa
REFERENCE1=/data/GRCh37.fa
BLACKLIST_GRCH37=/home/spectre/data/grch37_blacklist.bed  # Optional but recommended
WINSIZE=1000
COVERAGE_DIR=/data/coverage_dir/${1}
OUTPUT_DIR=/data/cnv_output/${1}
CHR_NUM=$(echo $1 | sed 's/chr//g')

mkdir -p ${COVERAGE_DIR}
mkdir -p ${OUTPUT_DIR}

if [ $(cat ${BAM_STATUS}) -eq 1 ] && [ $(cat ${SPECTRE_STATUS}) -eq 2 ]; then

    gsutil -q -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp gs://ultra_rapid_data/GRCh37_chr_fasta/GRCh37_${1}.fa /data/ 
    VC_CODE=$?
    if [ $VC_CODE -eq 0 ]; then
        email_vc_update "Downloaded chr_fasta" $1 "Spectre" 
    else
        email_vc_update "Download chr_fasta failed" $1 "Spectre Error"
        exit 1
    fi

    gsutil -q -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp ${CHR_BAM_BUCKET}/${BAM_FILE} /data/ 
    VC_CODE=$?
    if [ $VC_CODE -eq 0 ]; then
        email_vc_update "Downloaded $BAM_FILE" $1 "Spectre" 
    else
        email_vc_update "Download $BAM_FILE failed" $1 "Spectre Error"
        exit 1
    fi

    gsutil -q -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp ${CHR_BAM_BUCKET}/${BAM_FILE}.bai /data/ 
    VC_CODE=$?
    if [ $VC_CODE -eq 0 ]; then
        email_vc_update "Downloaded $BAM_FILE.bai" $1 "Spectre" 
    else
        email_vc_update "Download $BAM_FILE.bai failed" $1 "Spectre Error"
        exit 1
    fi

    sudo docker run -i -v /data:/data gsneha/sv_caller mosdepth \
        --by ${WINSIZE} \
        --threads 96 \
        --no-per-base \
        --mapq 20 \
        ${COVERAGE_DIR}/${1} \
        /data/${BAM_FILE}

    sudo docker run -i -v /data:/data gsneha/sv_caller python3 /home/spectre/spectre.py removeNs \
        --reference  ${REFERENCE} \
        --output-dir ${OUTPUT_DIR} \
        --output-file ${1}_genome.mdr \
        --bin-size 1000 \
        --save-only

    sudo docker run -i -v /data:/data gsneha/sv_caller python3 /home/spectre/spectre.py CNVCaller \
        --bin-size 1000 \
        --coverage ${COVERAGE_DIR} \
        --output-dir ${OUTPUT_DIR} \
        --sample-id ${SAMPLE} \
        --reference  ${REFERENCE} \
        --metadata ${OUTPUT_DIR}/${1}_genome.mdr \
        --only_chr $CHR_NUM \
        --black_list ${BLACKLIST_GRCH37}

    mv ${OUTPUT_DIR}/${SAMPLE}.vcf ${VCF_FILE} 

    VC_CODE=$?
    if [ $VC_CODE -eq 0 ]; then
        email_vc_update "Completed Spectre for $1" $1 "Spectre" 
    else
        email_vc_update "Spectre failed for $1" $1 "Spectre Error"
        exit 1
    fi

    gsutil -q cp $VCF_FILE ${SPECTRE_VCF_BUCKET}/
    VC_CODE=$?
    if [ $VC_CODE -eq 0 ]; then
        email_vc_update "Uploaded $VCF_FILE" $1 "Spectre" 
        echo "1" > $SPECTRE_STATUS
    else
        email_vc_update "Upload $VCF_FILE failed" $1 "Spectre Error"
        echo "3" > $SPECTRE_STATUS 
        exit 1
    fi

    gsutil -q cp ${SPECTRE_STATUS} ${SPECTRE_STATUS_BUCKET}/

fi
