#!/bin/bash


if [ $# -eq 3 ]; then

	BUCKET=ultra_rapid_"$(echo $1 | tr [:upper:] [:lower:])"
	gsutil mb gs://${BUCKET}
	SCRIPT_DIR=$(dirname $(readlink -f $0))
	SAMPLE=$1
	SAMPLE_LOW=$(echo ${SAMPLE} | sed 's/_/-/g' | tr [:upper:] [:lower:])

	gcloud compute project-info add-metadata \
		--metadata SAMPLE=$1,BARCODE=$2
	if [ $3 -eq 6 ]; then
		parallel -j 1 ${SCRIPT_DIR}/../instance_types/guppy_mm2_instance.sh ::: \
			${SAMPLE_LOW}-guppy-1 :::+ \
			1
	elif [ $3 -eq 8 ]; then
		parallel -j 1 ${SCRIPT_DIR}/../instance_types/guppy_mm2_instance.sh ::: \
			${SAMPLE_LOW}-guppy-a :::+ \
			A
	elif [ $3 -eq 12 ]; then
		parallel -j 1 ${SCRIPT_DIR}/../instance_types/guppy_mm2_instance.sh ::: \
			${SAMPLE_LOW}-guppy-1h1 :::+ \
			1h1
	elif [ $3 -eq 16 ]; then
		parallel -j 1 ${SCRIPT_DIR}/../instance_types/guppy_mm2_instance.sh ::: \
			${SAMPLE_LOW}-guppy-ah1 :::+ \
			Ah1
	fi

	exit 0
else
	1>&2 echo "Error: Provided $# arguments" 
	1>&2 echo "Need 3 input arguments"
	1>&2 echo "Usage: create_instances_guppy_mm2.sh SAMPLE_NUMBER BARCODE_NUMBER NUMBER_INSTANCES"
	exit 1
fi
