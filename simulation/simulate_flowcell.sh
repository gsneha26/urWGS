#!/bin/bash

INPUT_FOLDER=$1/no_sample/*_${3}_*
OUTPUT_FOLDER=$2/no_sample/*_${3}_*
RUNTIME=$4

NUM_POD5=$(find $INPUT_FOLDER/ -name '*.pod5' | wc -l)
PERIOD=$(python3 -c "print (abs(int(${RUNTIME}/${NUM_POD5})))")

cd $INPUT_FOLDER
echo $INPUT_FOLDER

# copy one file at a time, separated by $PERIOD seconds
for i in $(find . -name '*.pod5');
do
        cp --parents $i $OUTPUT_FOLDER/
        sleep ${PERIOD}s
done
