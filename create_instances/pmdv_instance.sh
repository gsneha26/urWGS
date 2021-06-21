#!/bin/bash

gcloud compute instances create $1 \
        --zone us-west1-a \
        --source-instance-template pmpb-template \
	--create-disk=boot=yes,image=pmpb-image-v5,size=100GB \
	--local-ssd=interface=NVME \
        --metadata CHR=$2,STAGE=PMD,startup-script='#!/bin/bash
		sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/nvme0n1
		sudo mkdir -p /data
		sudo mount -o discard,defaults /dev/nvme0n1 /data
		sudo chmod a+w /data
		echo "2" > /data/pmdv_status.txt 
		gsutil cp gs://ultra_rapid_nicu/scripts/sample.config /data/
                mkdir /data/scripts
                gsutil -m cp gs://ultra_rapid_nicu/scripts/pmdv/* /data/scripts/
		mkdir /data/pb_model
		gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp gs://ur_wgs_public_data/GRCh37.fa /data/
                chmod +x /data/scripts/*.sh
		chmod a+w -R /data/
		echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\n*/1 * * * * bash -c /data/scripts/run_pmdv_pipeline_wrapper.sh >> /data/stdout.log 2>> /data/stderr.log" | crontab -u gsneha -'
