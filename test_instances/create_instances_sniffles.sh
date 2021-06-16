#!/bin/bash

if [ $# -eq 1 ]; then
	source $1

	SCRIPT_DIR=$(dirname $(readlink -f $0))/..

	parallel -j 1 \
		 ${SCRIPT_DIR}/instance_types/sniffles_instance.sh ::: \
		 sniffles-${SAMPLE_LOW}-2 :::+ \
		 chr16:chr4:chr5 :::+ \
		 30:10:10
	exit 0
else
	1>&2 echo "Error: Provided $# arguments" 
	1>&2 echo "Need 1 input arguments"
	1>&2 echo "Usage: create_instances_sniffles.sh CONFIG_FILE"
	exit 1
fi
