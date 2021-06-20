#!/bin/bash

HG002_SRC_DIR=/data/tmp/HG002/
HG002_DST_DIR=/data/prom/HG002/
HG002_SOURCE_BUCKET=gs://ur_wgs_public_data/HG002_raw_data

mkdir -p $HG002_SRC_DIR
mkdir -p $HG002_DST_DIR

# download fast5 files for row C of promethION
time gsutil -m rsync -r \
	-x ".*[1-6][A-B].*$|.*[1-6][D-H].*$" \
	$HG002_SOURCE_BUCKET/ \
	$HG002_SRC_DIR/

# copy the directory structure to the destination folder 
# (before copying the individual files)
rsync -av -f"+ */" -f"- *" $HG002_SRC_DIR/ $HG002_DST_DIR/

echo "Started sequencing at "$(date +%T)
# parallel processes, one for each flowcell to copy the files
# from the source to the destination folder at a uniform rate
# based on the total number of files in each folder,
# can vary from flowcell to flowcell
time parallel -j 6 \
	$HOME/urWGS-private/prom_simulation/simulate_flowcell.sh ::: \
	$HG002_SRC_DIR ::: \
	$HG002_DST_DIR ::: \
	{1..6}C ::: \
	5400

# in case we want to simulate all 48 flow cells
#time parallel -j 48 /data/scripts/prom_simulation/simulate_flowcell.sh ::: \
	$HG002_SRC_DIR ::: \
	$HG002_DST_DIR ::: \
	{1..6}{A..H} ::: \
	5400