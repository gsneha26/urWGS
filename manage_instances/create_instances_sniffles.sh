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

		parallel -j $NUM_SNIFFLES \
			${PROJECT_DIR}/manage_instances/sniffles_instance.sh ::: \
			sniffles-${SAMPLE_LOW} ::: \
			chr16:chr4:chr5:chr7:chr8:chr10:chr11:chr14:chr15:chr18:chr19:chr20:chr21:chr1:chr2:chr3:chr6:chr12:chr13:chr9:chr17:chrX:chr22:chrY:chrMT ::: \
			${BUCKET}/sample.config
		exit 0
	fi
else
	1>&2 echo "Error: Provided $# arguments" 
	1>&2 echo "Need 1 input argument"
	1>&2 echo "Usage: create_instances_sniffles.sh CONFIG_FILE"
	exit 1
fi
