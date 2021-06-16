#!/bin/bash

export INPUT_FOLDER=no_sample/*_$1_*/fast5
export OUTPUT_FOLDER=/data/simulation_test_v2/sim1/

mkdir -p $OUTPUT_FOLDER
cd /data/simulation_test/Fast_001/

for i in $INPUT_FOLDER/*;
do
	cp --parents $i $OUTPUT_FOLDER/
	sleep 200s
done
