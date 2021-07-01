#### Preparing the output of merged chr-wise BAM to test Sniffles for a subset of chromosomes for HG002
* Set up the host instance using [these instructions](./Setting_up_host_instance.md) 
* Create a working directory
```
WORK_DIR=/data/hg002_sniffles
mkdir -p $WORK_DIR/
```
* Create the configuration file (e.g. `sample.config` in the $PROJECT_DIR)
```
cp $PROJECT_DIR/sample.config $WORK_DIR/
CONFIG_PATH=$WORK_DIR/sample.config
```
* Create a Google Storage Bucket with a unique name and add the configuration file to it e.g.
```
BUCKET=gs://urwgs_hg002_test_$(date +%s)
gsutil mb $BUCKET
sed -i "s|^BUCKET=.*$|BUCKET=${BUCKET}|g" $CONFIG_PATH
gsutil cp $CONFIG_PATH ${BUCKET}/sample.config
```
* Transfer data and create the appropriate directory for testing
```
$PROJECT_DIR/simulation/simulate_merged_bam_output.sh
```
* Start 1 instance to run Sniffles on 1 set of chromosomes (chr - 4 5 7 8 10 11 14 15 16 18 19 20 21)
```
$PROJECT_DIR/create_instances/sniffles_instance.sh \
	sniffles-1 \
	chr16:chr4:chr5:chr7:chr8:chr10:chr11:chr14:chr15:chr18:chr19:chr20:chr21 \
	30:20:15:6:6:5:5:2:2:1:1:1:1 \
	${BUCKET}/sample.config
```
