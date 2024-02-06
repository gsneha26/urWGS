#!/bin/bash

INSTANCE_FOUND=false
INSTANCES=$(gcloud compute instances list --filter="name=$1" --format="value(name,zone,status)")

if [ ! -z "$INSTANCES" ]; then
  INSTANCE_FOUND=true
  INSTANCE_ZONE=$(echo "$INSTANCES" | awk '{print $2}')
  INSTANCE_STATUS=$(echo "$INSTANCES" | awk '{print $3}')
  echo "Instance '$1' found in zone '$INSTANCE_ZONE' with status '$INSTANCE_STATUS'."
fi

# Create a new VM instance if it doesn't exist
if [ "$INSTANCE_FOUND" = false ]; then

    for z in $(gcloud compute accelerator-types list | grep nvidia-tesla-v100 | grep 'us' | sort -V | awk '{print $2}'); do
        if [ $4 = 4 ]; then
            gcloud compute instances create $1 \
                --zone $z \
                --machine-type=custom-48-319488 \
                --accelerator=count=4,type=nvidia-tesla-v100 \
                --create-disk=boot=yes,image=dorado-v2,size=500GB,mode=rw,type=pd-balanced \
                --scopes=storage-full,compute-rw,logging-write \
                --local-ssd=interface=NVME \
                --local-ssd=interface=NVME \
                --local-ssd=interface=NVME \
                --local-ssd=interface=NVME \
                --no-restart-on-failure \
                --maintenance-policy TERMINATE \
                --metadata FC=$2,CONFIG_FILE_URL=$3,startup-script='#!/bin/bash
                            nvidia-smi -pm 1
                            git clone https://github.com/gsneha26/urWGS.git -b dorado_dev
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
                            $PROJECT_DIR/basecall_align/generate_scripts.sh
                            echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\nPROJECT_DIR=$PROJECT_DIR\n* * * * * bash -c $PROJECT_DIR/basecall_align/run_basecalling_wrapper.sh >> /data/logs/basecall_stdout.log 2>> /data/logs/basecall_stderr.log\n* * * * * bash -c $PROJECT_DIR/basecall_align/run_alignment_wrapper.sh >> /data/logs/align_stdout.log 2>> /data/logs/align_stderr.log\n*/3 * * * * bash -c $PROJECT_DIR/basecall_align/upload_log.sh" | crontab -'

            EXIT_CODE=$?
            if [[ $EXIT_CODE -eq 0 ]]; then
                break
            fi
        elif [ $4 = 8 ]; then
            gcloud compute instances create $1 \
                --zone $z \
                --machine-type=custom-96-638976 \
                --accelerator=count=8,type=nvidia-tesla-v100 \
                --create-disk=boot=yes,image=dorado-v2,size=500GB,mode=rw,type=pd-balanced \
                --scopes=storage-full,compute-rw,logging-write \
                --local-ssd=interface=NVME \
                --local-ssd=interface=NVME \
                --local-ssd=interface=NVME \
                --local-ssd=interface=NVME \
                --no-restart-on-failure \
                --maintenance-policy TERMINATE \
                --metadata FC=$2,CONFIG_FILE_URL=$3,startup-script='#!/bin/bash
                            nvidia-smi -pm 1
                            git clone https://github.com/gsneha26/urWGS.git -b dorado_dev
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
                            $PROJECT_DIR/basecall_align/generate_scripts.sh
                            echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\nPROJECT_DIR=$PROJECT_DIR\n* * * * * bash -c $PROJECT_DIR/basecall_align/run_basecalling_wrapper.sh >> /data/logs/basecall_stdout.log 2>> /data/logs/basecall_stderr.log\n* * * * * bash -c $PROJECT_DIR/basecall_align/run_alignment_wrapper.sh >> /data/logs/align_stdout.log 2>> /data/logs/align_stderr.log\n*/3 * * * * bash -c $PROJECT_DIR/basecall_align/upload_log.sh" | crontab -'

            EXIT_CODE=$?
            if [[ $EXIT_CODE -eq 0 ]]; then
                break
            fi
        fi
    done
fi
