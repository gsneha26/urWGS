#! /bin/bash

NUM_SSD=$(ls  /dev/nvme0n* | wc -l)
sudo mkdir -p /data
if [ $NUM_SSD -gt 1 ]; then
	DEVICES=$(ls  /dev/nvme0n*)
	sudo mdadm --create /dev/md0 --level=0 --raid-devices=$NUM_SSD $DEVICES
	sudo mkfs.ext4 -F /dev/md0
	sudo mount -o discard,defaults /dev/md0 /data
else
	sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/nvme0n1
	sudo mount -o discard,defaults /dev/nvme0n1 /data
fi
sudo chmod a+w /data
