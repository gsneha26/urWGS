#!/bin/bash

if [ $# -eq 1 ]; then
	source $1

	SCRIPT_DIR=$(dirname $(readlink -f $0))/..

	parallel -j 1 \
		 ${SCRIPT_DIR}/instance_types/annotation_instance.sh ::: \
		 annotation-${SAMPLE_LOW}-1
	exit 0
else
	1>&2 echo "Error: Provided $# arguments" 
	1>&2 echo "Need 1 input arguments"
	1>&2 echo "Usage: create_instances_annotation.sh CONFIG_FILE"
	exit 1
fi
