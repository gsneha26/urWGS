#!/bin/bash

if [ $# -eq 1 ]; then
	source $1

	SCRIPT_DIR=$(dirname $(readlink -f $0))/..

	parallel -j $NUM_PMD \
		 ${SCRIPT_DIR}/instance_types/seq_pmd_v3_instance.sh ::: \
		 pmd-${SAMPLE_LOW}-2 :::+ \
		 chr17
	exit 0
else
	1>&2 echo "Error: Provided $# arguments" 
	1>&2 echo "Need 1 input arguments"
	1>&2 echo "Usage: create_instances_seq_pmd.sh CONFIG_FILE"
	exit 1
fi
