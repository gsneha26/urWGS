#!/bin/bash

gcloud compute instances create $1 \
        --zone us-west1-a \
        --source-instance-template annotation-template \
	--create-disk=boot=yes,image=annotation-image-v5,size=100GB \
	--local-ssd=interface=NVME \
        --metadata STAGE=ANNOTATION,startup-script='#!/bin/bash
		sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/nvme0n1
		sudo mkdir -p /data
		sudo mount -o discard,defaults /dev/nvme0n1 /data
		sudo chmod a+w /data
		echo "2" > /data/download_status.txt 
		echo "2" > /data/pmdv_annotation_status.txt 
		echo "2" > /data/sniffles_annotation_status.txt 
		gsutil cp gs://ultra_rapid_nicu/scripts/sample.config /data/
		mkdir /data/scripts/
		gsutil -m cp -r gs://ultra_rapid_nicu/scripts/annotation/* /data/scripts/
		gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp gs://ur_wgs_public_data/GRCh37.fa /data/
		chmod +x /data/scripts/*.sh
		chmod a+w -R /data/
		echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\n*/1 * * * * bash -c /data/scripts/annotate_pmdv_wrapper.sh >> /data/pmdv_stdout.log 2>> /data/pmdv_stderr.log\n*/1 * * * * bash -c /data/scripts/annotate_sniffles_wrapper.sh >> /data/sniffles_stdout.log 2>> /data/sniffles_stderr.log" | crontab -u gsneha -'
