#!/bin/bash

RUNTIME=$2

INPUT_FOLDER=/data/hg002_test/HG002_No_BC/no_sample/*_${1}
OUTPUT_FOLDER=/data/hg002_simulation/HG002_No_BC/no_sample/*_${1}
NUM_FAST5=$(ls $INPUT_FOLDER/ | wc -l)
PERIOD=$(python -c "print (int(${RUNTIME}/${NUM_FAST5})-5)")

mkdir -p $OUTPUT_FOLDER
cd $INPUT_FOLDER

for i in $(ls *.fast5);
do
        cp --parents $i $OUTPUT_FOLDER/
        sleep ${PERIOD}s
done
