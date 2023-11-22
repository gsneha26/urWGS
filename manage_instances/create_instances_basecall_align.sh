#!/bin/bash

if [ $# -eq 1 ]; then
	CONFIG_FILE=$1

	if [ -f $CONFIG_FILE ]; then
		source $CONFIG_FILE

		gsutil cp $CONFIG_FILE ${BUCKET}/

		BA_NAME_LIST=
		BA_FC_LIST=
		if [ $NUM_BA_INSTANCE -eq 1 ]; then
			BA_NAME_LIST=$(echo ba-${SAMPLE_LOW})
			BA_FC_LIST=$(echo "complete")
		elif [ $NUM_BA_INSTANCE -eq 6 ]; then
			BA_NAME_LIST=$(echo ba-${SAMPLE_LOW}-{1..6})
			BA_FC_LIST=$(echo {1..6})
		elif [ $NUM_BA_INSTANCE -eq 8 ]; then
			BA_NAME_LIST=$(echo ba-${SAMPLE_LOW}-{a..h})
			BA_FC_LIST=$(echo {A..H})
		elif [ $NUM_BA_INSTANCE -eq 12 ]; then
			BA_NAME_LIST=$(echo ba-${SAMPLE_LOW}-{1..6}h{1..2})
			BA_FC_LIST=$(echo {1..6}h{1..2})
		elif [ $NUM_BA_INSTANCE -eq 16 ]; then
			BA_NAME_LIST=$(echo ba-${SAMPLE_LOW}-{a..h}h{1..2})
			BA_FC_LIST=$(echo {A..H}h{1..2})
		elif [ $NUM_BA_INSTANCE -eq 24 ]; then
			BA_NAME_LIST=$(echo ba-${SAMPLE_LOW}-{a..h}t{1..3})
			BA_FC_LIST=$(echo {A..H}t{1..3})
		fi

		parallel -j 24 ${PROJECT_DIR}/manage_instances/basecall_align_instance.sh ::: \
			${BA_NAME_LIST} :::+ \
			${BA_FC_LIST} ::: \
			${BUCKET}/sample.config ::: \
            ${NUM_GPU_PER_BA_INSTANCE}
		exit 0
	else
		1>&2 echo "Error: Provided file $CONFIG_FILE does not exist"
		1>&2 echo "Usage: create_instances_basecall_align.sh CONFIG_FILE"
		exit 1
	fi
else
	1>&2 echo "Error: Provided $# arguments" 
	1>&2 echo "Need 1 input argument"
	1>&2 echo "Usage: create_instances_basecall_align.sh CONFIG_FILE"
	exit 1
fi
