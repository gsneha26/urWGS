#!/bin/bash

gcloud compute instances create $1 \
        --zone us-west1-a \
        --source-instance-template guppy-mm2-template \
	--create-disk=boot=yes,image=guppy-mm2-image-v4,size=100GB \
	--local-ssd=interface=NVME \
	--local-ssd=interface=NVME \
	--local-ssd=interface=NVME \
	--local-ssd=interface=NVME \
        --metadata FC=$2,STAGE=GUPPY_MM2,startup-script='#!/bin/bash
                mount_nvme.sh 4
		nvidia-smi -pm 1
		echo "2" > /data/postprocess_status.txt
                gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp gs://ultra_rapid_nicu/GRCh37.mmi /data/
		gsutil cp gs://ultra_rapid_nicu/scripts/sample.config /data/
                mkdir /data/scripts
                gsutil -m cp gs://ultra_rapid_nicu/scripts/guppy_mm2/* /data/scripts/
                chmod +x /data/scripts/*.sh
                /data/scripts/generate_scripts.sh
		chmod a+w -R /data/
		echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\n2-23/3\005432-53/3 * * * * bash -c /data/scripts/run_basecalling_wrapper.sh >> /data/logs/basecall_stdout.log 2>> /data/logs/basecall_stderr.log\n*/3 * * * * bash -c /data/scripts/run_alignment_wrapper.sh >> /data/logs/align_stdout.log 2>> /data/logs/align_stderr.log\n*/5 * * * * bash -c /data/scripts/upload_log.sh" | crontab -u gsneha -'
