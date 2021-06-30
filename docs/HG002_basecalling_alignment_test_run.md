#### Demonstration for running an HG002 PromethION simulation on host instance and the corresponding base calling and alignment on instances with configuration specified above.
* Set up the host instance using [these instructions](./Setting_up_host_instance.md)
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
