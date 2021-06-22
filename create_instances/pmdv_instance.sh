#!/bin/bash

gcloud compute instances create $1 \
        --zone us-west1-a \
        --source-instance-template pmpb-template \
	--create-disk=boot=yes,image=pmpb-image-v5,size=100GB \
	--local-ssd=interface=NVME \
        --metadata CHR=$2,STAGE=PMD,startup-script='#!/bin/bash
		gsutil cp gs://ur_wgs_public_data/mount_ssd_nvme.sh .
		bash -c mount_ssd_nvme.sh 
		mkdir -p /data/urWGS
                gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp gs://ur_wgs_public_data/GRCh37.mmi /data/
		gsutil -m rsync -r gs://ultra_rapid_nicu/urWGS/ /data/urWGS/
		export PROJECT_DIR=/data/urWGS
		echo "2" > /data/pmdv_status.txt 
		chmod a+w -R /data/
		chmod +x $PROJECT_DIR/*/*.sh
		echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin\n*/1 * * * * bash -c $PROJECT_DIR/pmdv/run_pmdv_pipeline_wrapper.sh >> /data/stdout.log 2>> /data/stderr.log" | crontab -u gsneha -'
