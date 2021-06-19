#!/bin/bash

HG002_SRC_DIR=/data/tmp/HG002/
HG002_DST_DIR=/data/prom/HG002/
HG002_SOURCE_BUCKET=gs://ur_wgs_public_data/HG002_raw_data

mkdir /data/prom/
mkdir $HG002_SRC_DIR
mkdir $HG002_DST_DIR

gsutil -m rsync -r \
	-x ".*[1-6][A-B].*$|.*[1-6][D-H].*$" \
	$HG002_SOURCE_BUCKET/ \
	$HG002_SRC_DIR/

echo "Started sequencing at "$(date +%T)
time parallel -j 6 \
	--dry-run \
	/data/scripts/prom_simulation/simulate_fc.sh ::: \
	{1..6}{C} ::: \
	$HG002_SRC_DIR ::: \
	$HG002_DEST_DIR ::: \
	5400
#time parallel -j 48 /data/scripts/prom_simulation/simulate_fc.sh ::: {1..6}{A..H}
