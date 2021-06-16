#!/bin/bash

if [ $# -eq 1 ]; then
	source $1

	gsutil mb ${BUCKET}
	SCRIPT_DIR=$(dirname $(readlink -f $0))/..

	#gcloud pubsub topics create ${PUBSUB_TOPIC}

	parallel -j ${NUM_GUPPY} ${SCRIPT_DIR}/instance_types/guppy_mm2_instance.sh ::: \
		${GUPPY_NAME_LIST} :::+ \
		${GUPPY_FC_LIST}
		#${PUBSUB_TOPIC}
	exit 0
else
	1>&2 echo "Error: Provided $# arguments" 
	1>&2 echo "Need 1 input arguments"
	1>&2 echo "Usage: create_instances_guppy_mm2.sh CONFIG_FILE"
	exit 1
fi
