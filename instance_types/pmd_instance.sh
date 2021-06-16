#!/bin/bash

gcloud compute instances create $1 \
        --zone us-central1-c \
        --source-instance-template pmpb-template \
	--create-disk=boot=yes,image=pmpb-image-v5,size=100GB \
	--local-ssd=interface=NVME \
        --metadata CHR=$2,STAGE=PMD,startup-script='#!/bin/bash
                mount_1nvme.sh
		echo "2" > /data/pmd_status.txt 
		gsutil cp gs://ultra_rapid_nicu/scripts/sample.config /data/
                mkdir /data/scripts
                gsutil -m cp gs://ultra_rapid_nicu/scripts/seq_pmd/* /data/scripts/
		mkdir /data/pb_model
		gsutil cp gs://ultra_rapid_nicu/scripts/models/pb/deepvar_ont_kishwar_P100.eng /data/pb_model/
		gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp gs://ultra_rapid_nicu/GRCh37.fa /data/
                chmod +x /data/scripts/*.sh
		chmod a+w -R /data/
		echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\n*/1 * * * * bash -c /data/scripts/run_pmd_pipeline_wrapper.sh >> /data/stdout.log 2>> /data/stderr.log" | crontab -u gsneha -'
