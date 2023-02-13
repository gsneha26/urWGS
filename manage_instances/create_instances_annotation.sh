#!/bin/bash

if [ $# -eq 1 ]; then
	CONFIG_FILE=$1

	if [ ! -f $CONFIG_FILE ]; then
		1>&2 echo "Error: Provided file $CONFIG_FILE does not exist"
		1>&2 echo "Usage: create_instances_guppy_mm2.sh CONFIG_FILE"
		exit 1
	else
		source $CONFIG_FILE

		gsutil cp $CONFIG_FILE ${BUCKET}/

		${PROJECT_DIR}/manage_instances/annotation_instance.sh \
			annotation-${SAMPLE_LOW}-1 \
			${BUCKET}/sample.config
		exit 0
	fi
else
	1>&2 echo "Error: Provided $# arguments" 
	1>&2 echo "Need 1 input argument"
	1>&2 echo "Usage: create_instances_annotation.sh CONFIG_FILE"
	exit 1
fi
