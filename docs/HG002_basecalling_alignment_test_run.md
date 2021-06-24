#### Demonstration for running an HG002 PromethION simulation on host instance and the corresponding base calling and alignment on instances with configuration specified above.
* Start an instance with Ubuntu18.04 and SSD with NVME interface:
```
NAME=host-instance-$(date +%s)
ZONE=us-west1-a
gcloud compute instances create $NAME \
        --zone $ZONE \
	--machine-type='n1-standard-16' \
	--create-disk=boot=yes,image-project='ubuntu-os-cloud',image='ubuntu-1604-xenial-v20210429',size=100GB \
        --local-ssd=interface=NVME \
        --local-ssd=interface=NVME
```
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
* The script will simulate 6 flow cells which corresponds to computation (base calling and alignment) on 2 instances. The instances can be started as follows:
```
parallel -j 2 $PROJECT_DIR/create_instances/guppy_mm2_instance.sh ::: \
	guppy-ch{1..2} :::+ \
	Ch{1..2} ::: \
	${BUCKET}/sample.config
```
Instance `guppy-ch1` will base call and align the data from flow cells 1C, 2C, 3C and `guppy-ch2` from 4C, 5C, 6C.
* Add cron job 
```
echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin\nPROJECT_DIR=$PROJECT_DIR\n*/3 * * * * bash -c $PROJECT_DIR/prom_upload/upload_fast5.sh >> $HOME/upload_stdout.log 2>> $HOME/upload_stderr.log" | crontab -u $USER -
```
* Start a simulation for a given duration [`simulation_duration_in_seconds`=5400 for the example in the paper]
```
$PROJECT_DIR/prom_simulation/simulate_prom.sh simulation_duration_in_seconds
```
