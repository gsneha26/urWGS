#!/bin/bash

for z in $(gcloud compute accelerator-types list | grep nvidia-tesla-a100 | grep 'us' | sort -V | awk '{print $2}'); do

  gcloud compute instances create $1 \
    --zone $z \
    --source-instance-template guppy-mm2-template-ph2 \
  	--create-disk=boot=yes,image=guppy-mm2-image-ph2-v1,size=100GB,mode=rw,type=pd-balanced \
  	--scopes=storage-full,compute-rw,logging-write \
  	--local-ssd=interface=NVME \
  	--local-ssd=interface=NVME \
  	--local-ssd=interface=NVME \
  	--local-ssd=interface=NVME \
    --no-restart-on-failure \
    --maintenance-policy=MIGRATE \
    --metadata FC=$2,CONFIG_FILE_URL=$3,startup-script='#!/bin/bash
  		nvidia-smi -pm 1
        rm -rf urWGS
  		git clone https://github.com/gsneha26/urWGS.git -b phase2 
  		bash -c ./urWGS/setup/mount_ssd_nvme.sh
  		mv urWGS /data/
  		export PROJECT_DIR=/data/urWGS
      gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp gs://ur_wgs_test_data/GRCh37.mmi /data/
  		CONFIG_FILE_URL=$(gcloud compute instances describe $(hostname) --zone=$(gcloud compute instances list --filter="name=($(hostname))" --format "value(zone)") --format=value"(metadata[CONFIG_FILE_URL])")
  		gsutil cp $CONFIG_FILE_URL /data/sample.config
  		echo "2" > /data/postprocess_status.txt
  		echo "2" > /data/basecalling_status.txt
  		echo "2" > /data/upload_status.txt
  		chmod a+w -R /data/
  		chmod +x $PROJECT_DIR/*/*.sh
        $PROJECT_DIR/guppy_mm2/generate_scripts.sh
  		echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\nPROJECT_DIR=$PROJECT_DIR\n* * * * * bash -c $PROJECT_DIR/guppy_mm2/run_basecalling_wrapper.sh >> /data/logs/basecall_stdout.log 2>> /data/logs/basecall_stderr.log\n* * * * * bash -c $PROJECT_DIR/guppy_mm2/run_alignment_wrapper.sh >> /data/logs/align_stdout.log 2>> /data/logs/align_stderr.log\n*/3 * * * * bash -c $PROJECT_DIR/guppy_mm2/upload_log.sh" | crontab -'
  
  EXIT_CODE=$?
  if [[ $EXIT_CODE -eq 0 ]]; then
      break
  fi
done
