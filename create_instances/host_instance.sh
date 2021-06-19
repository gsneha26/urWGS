#!/bin/bash

gcloud compute instances create host-instance1 \
        --zone us-west1-a \
        --source-instance-template host-template \
	--local-ssd=interface=NVME \
	--local-ssd=interface=NVME \
        --metadata startup-script='#!/bin/bash
		sudo apt-get --yes install git parallel rsync'
#		sudo apt update && sudo apt -y install mdadm --no-install-recommends
#		DEVICES=$(ls  /dev/nvme0n*)
#		sudo mdadm --create /dev/md0 --level=0 --raid-devices=2 $DEVICES
#		sudo mkfs.ext4 -F /dev/md0
#		sudo mkdir -p /data
#		sudo mount /dev/md0 /data
#		sudo chmod a+w /data
#		git clone https://github.com/gsneha26/urWGS-private.git
