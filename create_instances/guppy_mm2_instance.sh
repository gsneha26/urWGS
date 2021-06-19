#!/bin/bash

gcloud compute instances create $1 \
        --zone us-west1-a \
        --source-instance-template guppy-mm2-template \
	--create-disk=boot=yes,image=guppy-mm2-image-v4,size=100GB \
	--local-ssd=interface=NVME \
	--local-ssd=interface=NVME \
	--local-ssd=interface=NVME \
        --metadata FC=$2,STAGE=GUPPY_MM2,startup-script='#!/bin/bash
		sudo apt update && sudo apt -y install mdadm --no-install-recommends
		DEVICES=$(ls  /dev/nvme0n*)
		sudo mdadm --create /dev/md0 --level=0 --raid-devices=3 $DEVICES
		sudo mkfs.ext4 -F /dev/md0
		sudo mkdir -p /data
		sudo mount /dev/md0 /data
		sudo chmod a+w /data
		nvidia-smi -pm 1
		echo "2" > /data/postprocess_status.txt
                gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp gs://ur_wgs_public_data/GRCh37.mmi /data/
		gsutil cp gs://ultra_rapid_nicu/scripts/sample.config /data/
                mkdir /data/scripts
                gsutil -m cp gs://ultra_rapid_nicu/scripts/guppy_mm2/* /data/scripts/
                chmod +x /data/scripts/*.sh
                /data/scripts/generate_scripts.sh
		chmod a+w -R /data/
		echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\n2-23/3\005432-53/3 * * * * bash -c /data/scripts/run_basecalling_wrapper.sh >> /data/logs/basecall_stdout.log 2>> /data/logs/basecall_stderr.log\n*/3 * * * * bash -c /data/scripts/run_alignment_wrapper.sh >> /data/logs/align_stdout.log 2>> /data/logs/align_stderr.log\n*/5 * * * * bash -c /data/scripts/upload_log.sh" | crontab -u gsneha -'
