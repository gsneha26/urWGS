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
(It will take a minute or 2 to start)

* Log into the instance
```
gcloud beta compute ssh --zone $ZONE $NAME --project "som-ashley-rapid-nicu-seq"
```
Instructions on the host instance

* Install pre-requisites:
```
sudo apt-get update
sudo apt-get -y install git parallel rsync
```
* Clone urWGS repository
```
git clone https://gitfront.io/r/gsneha26/e351ab7e8a8eed487da76fbbc09fa73d7ab40dfb/urWGS.git
cd urWGS/
export PROJECT_DIR=$(pwd)
```
* Mount the local ssd devices
```
$PROJECT_DIR/setup/mount_ssd_nvme.sh
```
* Create the configuration file (e.g. `sample.config` in the $PROJECT_FOLDER) 
* Create a Google Storage Bucket with a unique name and add the configuration file to it e.g.
```
CONFIG_PATH=$PROJECT_FOLDER/sample.config
BUCKET=gs://urwgs_hg002_test_$(date +%s)
gsutil mb $BUCKET
sed -i "s|^BUCKET=.*$|BUCKET=${BUCKET}|g" $CONFIG_PATH
gsutil cp $CONFIG_PATH ${BUCKET}/sample.config
cp $CONFIG_PATH /data/sample.config
```
