#!/bin/bash

for z in $(gcloud compute machine-types list | grep n1-standard-96 | grep 'us-' | sort -V | awk '{print $2}'); do

  echo $z
  gcloud compute instances create $1 \
    --zone $z \
    --machine-type n1-standard-96 \
    --create-disk=boot=yes,image=variant-calling-v1,size=200GB,mode=rw,type=pd-balanced \
    --scopes=storage-full,compute-rw,logging-write \
    --local-ssd=interface=NVME \
    --metadata CONFIG_FILE_URL=$2,startup-script='#!/bin/bash
      rm -rf urWGS 
      git clone https://github.com/gsneha26/urWGS.git -b dorado_dev 
      bash -c ./urWGS/setup/mount_ssd_nvme.sh
      mv urWGS /data/
      gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp gs://ur_wgs_test_data/GRCh37.fa /data/
      export PROJECT_DIR=/data/urWGS
      mkdir -p /data/bed_files
      gsutil -o "GSUtil:parallel_thread_count=1" -o "GSUtil:sliced_object_download_max_components=8" cp gs://ur_wgs_public_data/small_variant_annotation/* /data/bed_files/
      CONFIG_FILE_URL=$(gcloud compute instances describe $(hostname) --zone=$(gcloud compute instances list --filter="name=($(hostname))" --format "value(zone)") --format=value"(metadata[CONFIG_FILE_URL])")
      gsutil cp $CONFIG_FILE_URL /data/sample.config
      echo "2" > /data/sniffles_download_status.txt 
      echo "2" > /data/spectre_download_status.txt 
      echo "2" > /data/pmdv_annotation_status.txt 
      echo "2" > /data/sniffles_annotation_status.txt 
      echo "2" > /data/spectre_annotation_status.txt 
      chmod a+w -R /data/
      chmod +x $PROJECT_DIR/*/*.sh
      echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin\nPROJECT_DIR=$PROJECT_DIR\n*/1 * * * * bash -c $PROJECT_DIR/annotation/annotate_pmdv_wrapper.sh >> /data/pmdv_stdout.log 2>> /data/pmdv_stderr.log\n*/1 * * * * bash -c $PROJECT_DIR/annotation/annotate_sniffles_wrapper.sh >> /data/sniffles_stdout.log 2>> /data/sniffles_stderr.log\n*/1 * * * * bash -c $PROJECT_DIR/annotation/annotate_spectre_wrapper.sh >> /data/spectre_stdout.log 2>> /data/spectre_stderr.log" | crontab -'

  EXIT_CODE=$?
  if [[ $EXIT_CODE -eq 0 ]]; then
      break
  fi
done
