#!/bin/bash

for z in $(gcloud compute machine-types list | grep n1-standard-96 | grep 'us-' | sort -V | awk '{print $2}'); do

  echo $z
  gcloud compute instances create $1 \
    --zone $z \
    --machine-type n1-standard-96 \
    --create-disk=boot=yes,image=variant-calling-image-ph2-v1,size=100GB,mode=rw,type=pd-balanced \
    --scopes=storage-full,compute-rw,logging-write \
    --local-ssd=interface=NVME \
    --metadata CHR=$2,CONFIG_FILE_URL=$3,startup-script='#!/bin/bash
      rm -rf urWGS 
      git clone https://github.com/gsneha26/urWGS.git -b phase2 
      bash -c ./urWGS/setup/mount_ssd_nvme.sh
      mv urWGS /data/
      export PROJECT_DIR=/data/urWGS
      CONFIG_FILE_URL=$(gcloud compute instances describe $(hostname) --zone=$(gcloud compute instances list --filter="name=($(hostname))" --format "value(zone)") --format=value"(metadata[CONFIG_FILE_URL])")
      gsutil cp $CONFIG_FILE_URL /data/sample.config
      echo "2" > /data/pmdv_status.txt 
      chmod a+w -R /data/
      chmod +x $PROJECT_DIR/*/*.sh
      echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin\nPROJECT_DIR=$PROJECT_DIR\n*/1 * * * * bash -c $PROJECT_DIR/pmdv/run_pmdv_pipeline_wrapper.sh >> /data/stdout.log 2>> /data/stderr.log" | crontab -'

  EXIT_CODE=$?
  if [[ $EXIT_CODE -eq 0 ]]; then
      break
  fi
done
