#### Preparing the output of Guppy and Minimap2 to test PEPPER-Margin-DeepVariant pipeline for a subset of chromosomes for HG002
* Set up the host instance using [these instructions](./Setting_up_host_instance.md) 
* Create a working directory
```
WORK_DIR=/data/hg002_pmdv
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
$PROJECT_DIR/simulation/simulate_alignment_output.sh
```
* Start 2 instances to run PEPPER-Margin-DeepVariant on chr2 and chr16,chr21
```
parallel -j 2 $PROJECT_DIR/create_instances/pmdv_instance.sh ::: \
	pmdv-{1..2} :::+ \
	chr2 \
	chr16:chr21 ::: \
	${BUCKET}/sample.config
```
