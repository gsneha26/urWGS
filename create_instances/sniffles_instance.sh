#!/bin/bash

gcloud compute instances create $1 \
        --zone us-west1-a \
        --source-instance-template sniffles-template \
	--create-disk=boot=yes,image=sniffles-image-v1,size=100GB \
	--scopes=storage-full,compute-rw,logging-write \
	--local-ssd=interface=NVME \
        --metadata CHR=$2,THREADS=$3,startup-script='#!/bin/bash
		git clone https://gitfront.io/r/gsneha26/e351ab7e8a8eed487da76fbbc09fa73d7ab40dfb/urWGS.git
		bash -c ./urWGS/setup/mount_ssd_nvme.sh
		mv urWGS /data/
		export PROJECT_DIR=/data/urWGS
		CONFIG_FILE_URL=$(gcloud compute instances describe $(hostname) --zone=$(gcloud compute instances list --filter="name=($(hostname))" --format "value(zone)") --format=value"(metadata[CONFIG_FILE_URL])")
		gsutil cp $CONFIG_FILE_URL /data/
		echo "2" > /data/sniffles_status.txt 
		chmod a+w -R /data/
		chmod +x $PROJECT_DIR/*/*.sh
		echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin\nPROJECT_DIR=$PROJECT_DIR\n*/1 * * * * bash -c $PROJECT_DIR/sniffles/run_sniffles_pipeline_wrapper.sh >> /data/stdout.log 2>> /data/stderr.log" | crontab -'
