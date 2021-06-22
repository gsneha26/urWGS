#!/bin/bash

if [ $# -eq 1 ]; then
	source $1

	gsutil cp $1 ${BUCKET}/

	parallel -j 1 \
		 ${PROJECT_DIR}/create_instances/annotation_instance.sh ::: \
		 annotation-${SAMPLE_LOW}-1
	exit 0
else
	1>&2 echo "Error: Provided $# arguments" 
	1>&2 echo "Need 1 input arguments"
	1>&2 echo "Usage: create_instances_annotation.sh CONFIG_FILE"
	exit 1
fi
