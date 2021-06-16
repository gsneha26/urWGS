#!/bin/bash


if [ $# -eq 2 ]; then

	BUCKET=ultra_rapid_"$(echo $1 | tr [:upper:] [:lower:])"
	gsutil mb gs://${BUCKET}
	SCRIPT_DIR=$(dirname $(readlink -f $0))
	SAMPLE=$1
	SAMPLE_LOW=$(echo ${SAMPLE} | sed 's/_/-/g' | tr [:upper:] [:lower:])

	gcloud pubsub topics create ${SAMPLE}_topic
	gcloud pubsub subscriptions create ${SAMPLE}_sub  --topic=${SAMPLE}_topic

	gcloud compute project-info add-metadata \
		--metadata SAMPLE=$1
	if [ $2 -eq 6 ]; then
		parallel -j 1 ${SCRIPT_DIR}/../instance_types/guppy_mm2_v2_instance.sh ::: \
			${SAMPLE_LOW}-guppy-1 :::+ \
			1
	elif [ $2 -eq 8 ]; then
		parallel -j 1 ${SCRIPT_DIR}/../instance_types/guppy_mm2_v2_instance.sh ::: \
			${SAMPLE_LOW}-guppy-b :::+ \
			A
	elif [ $2 -eq 12 ]; then
		parallel -j 1 ${SCRIPT_DIR}/../instance_types/guppy_mm2_v2_instance.sh ::: \
			${SAMPLE_LOW}-guppy-1h1 :::+ \
			1h1
	elif [ $2 -eq 16 ]; then
		parallel -j 2 ${SCRIPT_DIR}/../instance_types/guppy_mm2_v2_instance.sh ::: \
			${SAMPLE_LOW}-guppy-ah{1..2} :::+ \
			Ah{1..2}
	fi

	exit 0
else
	1>&2 echo "Error: Provided $# arguments" 
	1>&2 echo "Need 2 input arguments"
	1>&2 echo "Usage: create_instances_guppy_mm2_v2.sh SAMPLE_NUMBER NUMBER_INSTANCES"
	exit 1
fi
