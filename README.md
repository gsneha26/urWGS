# Ultra-Rapid Whole Genome Sequencing pipeline

#### Running an HG002 PromethION simulation on host instance
* Start an instance with Ubuntu18.04 and SSD with NVME interface:
```
gcloud compute instances create host-instance1 \
        --zone us-west1-a \
	--machine-type='n1-standard-16' \
	--create-disk=boot=yes,image-project='ubuntu-os-cloud',image='ubuntu-1804-bionic-v20210604',size=100GB \
        --local-ssd=interface=NVME \
        --local-ssd=interface=NVME
```
* Log into the instance and install pre-requisites:
```
sudo apt-get update
sudo apt-get --yes install git parallel rsync
```
* Install Google Cloud SDK ([Instructions for a non-GCP instance](https://cloud.google.com/sdk/docs/install))
* Clone urWGS repository
```
git clone https://github.com/gsneha26/urWGS-private
cd urWGS-private/
export PROJECT_DIR=$(pwd)
```
* Mount the local ssd devices
```
$PROJECT_DIR/setup/mount_nvme.sh
```
* Create a Google Storage Bucket with a unique name e.g.
```
BUCKET=gs://urwgs_hg002_test_$(date +%s)
gsutil mb $BUCKET
sed -i "s|^BUCKET=.*$|BUCKET=${BUCKET}|g" /path/to/sample.config
```
* The script will simulate 6 flow cells which corresponds to computation (base calling and alignment) on 2 instances. The instances can be spun off in the following manner:
```
parallel -j 2 $PROJECT_DIR/create_instances/guppy_mm2_instance.sh ::: \
	guppy-ch{1..2} :::+ \
	Ch{1..2}
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
## Base calling and Alignment
### Software:
* Guppy v4.2.2 (Commercial software from Oxford Nanopore Technologies)
* Minimap2 [v2.17-r974](https://github.com/lh3/minimap2/commit/2da649d1d724561d4c2bbe1be9123e2b61bc0029)
* samtools [v1.11](https://github.com/samtools/samtools/commit/d58fc8a16729f25407da6729c440a51140396f4c)
* CUDA
* parallel

### Instance type:
* Custom N1 instance
* 48 vCPUs
* 200 GB RAM
* 4 x NVIDIA Tesla V100
* 3 x Local SSD Scratch Disk

## Small Variant Calling
### Software:
* PEPPER (Docker image - `kishwars/pepper_deepvariant:test-v0.5`)
* Margin (Docker image - `kishwars/pepper_deepvariant:test-v0.5`)
* Google DeepVariant
  * none model (Docker image - `kishwars/pepper_deepvariant:test-v0.5`)
  * rows model (Docker image - `kishwars/pepper_deepvariant:test-v0.5-rows`)
* samtools [v1.11](https://github.com/samtools/samtools/commit/d58fc8a16729f25407da6729c440a51140396f4c)
* bgzip
* docker

### Instance type:
* Standard N1 instance
* 96 vCPUs
* 360 GB RAM
* 4 x NVIDIA Tesla P100
* 1 x Local SSD Scratch Disk

NOTE: [Parabricks DeepVariant](https://developer.nvidia.com/clara-parabricks) is commercially licensed and not available as a part of this repository for testing this pipeline.

## Structural Variant Calling
### Software:
* Sniffles [v1.0.12](https://github.com/fritzsedlazeck/Sniffles/commit/0f9a068ecee84fff862c12e581693be273ccf89e)
* parallel

### Instance type:
* Standard N1 instance
* 96 vCPUs
* 360 GB RAM
* 1 x Local SSD Scratch Disk

## Variant Call Annotation
### Software:
* bctools [v1.11](https://github.com/samtools/bcftools/commit/df43fd4781298e961efc951ba33fc4cdcc165a19)
* bedtools
* tabix
* bgzip
* docker

### Instance type:
* Standard N1 instance
* 64 vCPUs
* 240 GB RAM
* 1 x Local SSD Scratch Disk
