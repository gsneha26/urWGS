#!/bin/bash

gcloud compute instances create $1 \
        --zone us-west1-a \
        --source-instance-template annotation-template \
	--create-disk=boot=yes,image=annotation-image-v5,size=100GB \
	--local-ssd=interface=NVME \
        --metadata STAGE=ANNOTATION,startup-script='#!/bin/bash
		mount_1nvme.sh
		echo "2" > /data/download_status.txt 
		echo "2" > /data/pmd_annotation_status.txt 
		echo "2" > /data/sniffles_annotation_status.txt 
		gsutil cp gs://ultra_rapid_nicu/scripts/sample.config /data/
		mkdir /data/scripts/
		gsutil -m cp -r gs://ultra_rapid_nicu/scripts/annotation_v3/* /data/scripts/
		gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp gs://ultra_rapid_nicu/GRCh37.fa /data/
		chmod +x /data/scripts/*.sh
		chmod a+w -R /data/
		echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\n*/1 * * * * bash -c /data/scripts/annotate_pmd_wrapper.sh >> /data/pmd_stdout.log 2>> /data/pmd_stderr.log\n*/1 * * * * bash -c /data/scripts/annotate_sniffles_wrapper.sh >> /data/sniffles_stdout.log 2>> /data/sniffles_stderr.log" | crontab -u gsneha -'
