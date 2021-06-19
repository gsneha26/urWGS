#!/bin/bash

gcloud compute instances create host-instance2 \
        --zone us-west1-a \
        --source-instance-template host-template \
	--local-ssd=interface=NVME \
        --metadata startup-script='#!/bin/bash
		sudo apt-get --yes install git parallel'
#		sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/nvme0n1
#		sudo mkdir -p /data
#		sudo mount -o discard,defaults /dev/nvme0n1 /data
#		sudo chmod a+w /data'
