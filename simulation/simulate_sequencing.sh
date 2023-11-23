#!/bin/bash

if [ $# -eq 3 ] && [ -n ${1//[0-9]/} ]; then
	PERIOD=$1
	SRC_DIR=$2  #/data/sneha/HG002_RK/
	DST_DIR=$3  #/data/prom_ph2/HG002_RK/
	#SRC_BUCKET=gs://ur_wgs_test_data/HG002_pod5
	
	mkdir -p $SRC_DIR
	mkdir -p $DST_DIR
	mkdir -p /data/logs
	
	# download pod5 files for row C of promethION
	#time gsutil -m rsync -r \
	#	-x ".*[1-6][A-B].*$|.*[1-6][D-H].*$" \
	#	$SRC_BUCKET/ \
	#	$SRC_DIR/
	
	# copy the directory structure to the destination folder 
	# (before copying the individual files)
	rsync -av -f"+ */" -f"- *" $SRC_DIR/ $DST_DIR/
	
	echo "Started sequencing at "$(date +%T)
	# parallel processes, one for each flowcell to copy the files
	# from the source to the destination folder at a uniform rate
	# based on the total number of files in each folder,
	# can vary from flowcell to flowcell
    #time parallel -j 6 \
    #	$PROJECT_DIR/simulation/simulate_flowcell.sh ::: \
    #	$SRC_DIR ::: \
    #	$DST_DIR ::: \
    #	{1..6}{A..H} ::: \
    #	$PERIOD
	
	# in case we want to simulate all 48 flow cells
	time parallel -j 48 $PROJECT_DIR/simulation/simulate_flowcell.sh ::: \
	       $SRC_DIR ::: \
	       $DST_DIR ::: \
	       {1..6}{A..H} ::: \
	       $PERIOD
	exit 0
else
	1>&2 echo "Error: Provided $# arguments" 
        1>&2 echo "Need 3 input argument"
        1>&2 echo "Usage: simulate_sequencing.sh simulation_duration_in_seconds source_directory destination_directory"
        exit 1
fi
