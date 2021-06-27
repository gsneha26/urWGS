#### Demonstration for running an HG002 PromethION simulation on host instance and the corresponding base calling and alignment on instances with configuration specified above.
* Start an instance with Ubuntu16.04 and SSD with NVME interface, the instance also has permissions to create storage buckets and other instances:
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
* Log into the instance and install pre-requisites:
```
sudo apt-get update
sudo apt-get -y install git parallel rsync
```
* Install Google Cloud SDK ([Instructions for a non-GCP instance](https://cloud.google.com/sdk/docs/install))
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
* Create the configuration file (e.g. `sample.config` in the folder) 
* Create a Google Storage Bucket with a unique name and add the configuration file to it e.g.
```
BUCKET=gs://urwgs_hg002_test_$(date +%s)
gsutil mb $BUCKET
sed -i "s|^BUCKET=.*$|BUCKET=${BUCKET}|g" /path/to/sample.config
gsutil cp /path/to/sample.config ${BUCKET}/
```
