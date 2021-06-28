#### Demonstration for running an HG002 PromethION simulation on host instance and the corresponding base calling and alignment on instances with configuration specified above.
* Start an instance with Ubuntu16.04 and SSD with NVME interface and permissions to create storage buckets and other instances:
	* Set name of the instance
```
NAME=host-instance-$(date +%s)
```
	* Set zone of the instance
```
ZONE=us-west1-a
```
	* Command to start the instance
```
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
*Install pre-requisites:
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
* Create the configuration file (e.g. `sample.config` in the folder) 
* Create a Google Storage Bucket with a unique name and add the configuration file to it e.g.
```
BUCKET=gs://urwgs_hg002_test_$(date +%s)
gsutil mb $BUCKET
sed -i "s|^BUCKET=.*$|BUCKET=${BUCKET}|g" /path/to/sample.config
gsutil cp /path/to/sample.config ${BUCKET}/
```
* Add cron job 
```
echo -e "SHELL=/bin/bash\nPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin\nPROJECT_DIR=$PROJECT_DIR\n*/3 * * * * bash -c $PROJECT_DIR/prom_upload/upload_fast5.sh >> /data/logs/upload_stdout.log 2>> /data/logs/upload_stderr.log" | crontab -u $USER -
```
* The script below will simulate 6 flow cells which corresponds to computation (base calling and alignment) on 2 instances. The instances can be started as follows:
```
parallel -j 2 $PROJECT_DIR/create_instances/guppy_mm2_instance.sh ::: \
	guppy-ch{1..2} :::+ \
	Ch{1..2} ::: \
	${BUCKET}/sample.config
```
Instance `guppy-ch1` will base call and align the data from flow cells 1C, 2C, 3C and `guppy-ch2` from 4C, 5C, 6C. These 2 sets of flowcells correspond to the highest throughput as specifed in Supplementary Table 11. 
* Start a simulation for a given duration [`simulation_duration_in_seconds`=5400 for the example in the paper]
```
$PROJECT_DIR/simulation/simulate_sequencing.sh simulation_duration_in_seconds
```
