#!/bin/bash

gcloud compute instances create $1 \
        --zone us-west1-a \
        --source-instance-template guppy-mm2-template \
	--create-disk=boot=yes,image=guppy-mm2-image-v4,size=100GB \
	--local-ssd=interface=NVME \
	--local-ssd=interface=NVME \
	--local-ssd=interface=NVME \
        --metadata FC=$2,CONFIG_FILE_URL=$3,startup-script='#!/bin/bash
		echo "$HOME"
		echo "$USER"
		echo "$LOGNAME"
		gsutil cp gs://ur_wgs_public_data/mount_ssd_nvme.sh .
		bash -c mount_ssd_nvme.sh 
                gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp gs://ur_wgs_public_data/GRCh37.mmi /data/
		mkdir -p /data/urWGS
		gsutil -m rsync -r gs://ultra_rapid_nicu/urWGS/ /data/urWGS/
		export PROJECT_DIR=/data/urWGS
		CONFIG_FILE_URL=$(gcloud compute instances describe $(hostname) --zone=$(gcloud compute instances list --filter="name=($(hostname))" --format "value(zone)") --format=value"(metadata[CONFIG_FILE_URL])")
		gsutil cp $CONFIG_FILE_URL /data/
		echo "2" > /data/postprocess_status.txt
		chmod a+w -R /data/
		nvidia-smi -pm 1
		chmod +x $PROJECT_DIR/*/*.sh
                $PROJECT_DIR/guppy_mm2/generate_scripts.sh
		echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\n2-23/3\005432-53/3 * * * * bash -c /data/scripts/run_basecalling_wrapper.sh >> /data/logs/basecall_stdout.log 2>> /data/logs/basecall_stderr.log\n*/3 * * * * bash -c /data/scripts/run_alignment_wrapper.sh >> /data/logs/align_stdout.log 2>> /data/logs/align_stderr.log\n*/5 * * * * bash -c /data/scripts/upload_log.sh" | crontab -'
