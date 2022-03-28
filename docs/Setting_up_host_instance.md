### Setting up host instance required for all demonstrations

* Start an instance with Ubuntu16.04 and SSD with NVME interface and permissions to create storage buckets and other instances:
```
NAME=host-instance-$(date +%s)
ZONE=us-west1-a
gcloud compute instances create $NAME \
        --zone $ZONE \
	--machine-type='n1-standard-16' \
	--create-disk=boot=yes,image-project='ubuntu-os-cloud',image='ubuntu-1604-xenial-v20210429',size=100GB \
	--scopes=storage-full,compute-rw,logging-write \
        --local-ssd=interface=NVME \
        --local-ssd=interface=NVME
```
(It will take a minute or two to start)

* Log into the instance
```
gcloud beta compute ssh --zone $ZONE $NAME --project $GCP_PROJECT_NAME
```
($GCP_PROJECT_NAME - name of your project on Google Cloud Platform)
Instructions on the host instance

* Install pre-requisites:
```
sudo apt-get update
sudo apt-get -y install git parallel rsync
```
* Clone urWGS repository
```
git clone https://github.com/gsneha26/urWGS.git
cd urWGS/
export PROJECT_DIR=$(pwd)
```
* Mount the local ssd devices and create log folder
```
$PROJECT_DIR/setup/mount_ssd_nvme.sh
mkdir -p /data/logs
```
* Create environment for cron job 
```
echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin\nPROJECT_DIR=$PROJECT_DIR" | crontab -u $USER -
```
