#### Preparing the output of variant calling pipeline to run annotation for HG002 vcf
* Set up the host instance using [these instructions](./Setting_up_host_instance.md) 
* Create a working directory
```
WORK_DIR=/data/hg002_annotation
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
$PROJECT_DIR/simulation/simulate_variant_calling_output.sh
```
* Add cron job for deleting instances based on the status from the instances
```     
(crontab -u $USER -l; echo -e "*/3 * * * * bash -c $PROJECT_DIR/manage_instances/delete_instances_annotation_wrapper.sh >> /data/logs/delete_instances_stdout.log 2>> /data/logs/delete_instances_stderr.log") | crontab -u $USER - 
```
* Start the annotation instance
```
NAME=annotation-1
${PROJECT_DIR}/manage_instances/annotation_instance.sh \
	$NAME \
	${BUCKET}/sample.config
```
* The generated output is transferred to `$BUCKET/annotation_output`.
