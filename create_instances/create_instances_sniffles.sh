#!/bin/bash

if [ $# -eq 1 ]; then
	source $1

	SCRIPT_DIR=$(dirname $(readlink -f $0))/..

	parallel -j $NUM_SNIFFLES \
		 ${SCRIPT_DIR}/instance_types/sniffles_instance.sh ::: \
		 sniffles-${SAMPLE_LOW}-{1..2} :::+ \
		 chr16:chr4:chr5:chr7:chr8:chr10:chr11:chr14:chr15:chr18:chr19:chr20:chr21 chr1:chr2:chr3:chr6:chr12:chr13:chr9:chr17:chrX:chr22:chrY:chrMT :::+ \
		 30:20:15:6:6:5:5:2:2:1:1:1:1 21:21:17:13:5:5:5:3:3:1:1:1
	exit 0
else
	1>&2 echo "Error: Provided $# arguments" 
	1>&2 echo "Need 1 input arguments"
	1>&2 echo "Usage: create_instances_sniffles.sh CONFIG_FILE"
	exit 1
fi
