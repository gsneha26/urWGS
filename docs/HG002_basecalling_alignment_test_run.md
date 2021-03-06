#### Demonstration for running an HG002 PromethION simulation on host instance and the corresponding base calling and alignment on instances with configuration specified above.
* Set up the host instance using [these instructions](./Setting_up_host_instance.md)
* Create a working directory
```
WORK_DIR=/data/hg002_guppy_mm2
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
* Add cron job for periodic upload of fast5 files and deleting instances based on the status from the instances 
```
(crontab -u $USER -l; echo -e "*/3 * * * * bash -c $PROJECT_DIR/prom_upload/upload_fast5.sh >> /data/logs/upload_stdout.log 2>> /data/logs/upload_stderr.log\n*/3 * * * * bash -c $PROJECT_DIR/manage_instances/delete_instances_guppy_mm2_wrapper.sh >> /data/logs/delete_instances_stdout.log 2>> /data/logs/delete_instances_stderr.log") | crontab -u $USER -
```
* The script below will simulate 6 flow cells which corresponds to computation (base calling and alignment) on 2 instances. The instances can be started as follows:
```
parallel -j 2 $PROJECT_DIR/manage_instances/guppy_mm2_instance.sh ::: \
	guppy-ch{1..2} :::+ \
	Ch{1..2} ::: \
	${BUCKET}/sample.config
```
Instance `guppy-ch1` will base call and align the data from flow cells 1C, 2C, 3C and `guppy-ch2` from 4C, 5C, 6C. These 2 sets of flowcells correspond to the highest throughput as specifed in Supplementary Table 11. 
* Start a simulation for a given duration [`simulation_duration_in_seconds`=5400 for the example in the paper]. Ideally the process can be started using Linux Screen since the simulation will be active for the duration mentioned.
```
$PROJECT_DIR/simulation/simulate_sequencing.sh simulation_duration_in_seconds
```
* The generated output is transferred to `$BUCKET/guppy_minimap2_output`. It consists of multiple chromosome folders, each folder consists of the BAM files for the chromosome for each chromosome. 
