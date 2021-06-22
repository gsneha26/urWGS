#!/bin/bash

if [ $# -eq 1 ]; then
	source $1

	gsutil cp $1 ${BUCKET}/

	GUPPY_NAME_LIST=
	GUPPY_FC_LIST=
	if [ $NUM_GUPPY -eq 1 ]; then
		GUPPY_NAME_LIST=$(echo guppy-${SAMPLE_LOW})
		GUPPY_FC_LIST=$(echo "complete")
	elif [ $NUM_GUPPY -eq 6 ]; then
		GUPPY_NAME_LIST=$(echo guppy-${SAMPLE_LOW}-{1..6})
		GUPPY_FC_LIST=$(echo {1..6})
	elif [ $NUM_GUPPY -eq 8 ]; then
		GUPPY_NAME_LIST=$(echo guppy-${SAMPLE_LOW}-{a..h})
		GUPPY_FC_LIST=$(echo {A..H})
	elif [ $NUM_GUPPY -eq 12 ]; then
		GUPPY_NAME_LIST=$(echo guppy-${SAMPLE_LOW}-{1..6}h{1..2})
		GUPPY_FC_LIST=$(echo {1..6}h{1..2})
	elif [ $NUM_GUPPY -eq 16 ]; then
		GUPPY_NAME_LIST=$(echo guppy-${SAMPLE_LOW}-{a..h}h{1..2})
		GUPPY_FC_LIST=$(echo {A..H}h{1..2})
	fi

	parallel -j ${NUM_GUPPY} ${PROJECT_DIR}/create_instances/guppy_mm2_instance.sh ::: \
		${GUPPY_NAME_LIST} :::+ \
		${GUPPY_FC_LIST}
	exit 0
else
	1>&2 echo "Error: Provided $# arguments" 
	1>&2 echo "Need 1 input arguments"
	1>&2 echo "Usage: create_instances_guppy_mm2.sh CONFIG_FILE"
	exit 1
fi
