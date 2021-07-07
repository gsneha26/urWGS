#!/bin/bash

if [ $# -eq 1 ]; then
	CONFIG_FILE=$1

	if [ -f $CONFIG_FILE ]; then
		1>&2 echo "Error: Provided file $CONFIG_FILE does not exist"
		1>&2 echo "Usage: create_instances_guppy_mm2.sh CONFIG_FILE"
		exit 1
	else
		source $CONFIG_FILE

		gsutil cp $CONFIG_FILE ${BUCKET}/

		if [ "$GENDER" == "F" ];then
			parallel -j $NUM_PMD \
				${PROJECT_DIR}/manage_instances/pmdv_instance.sh ::: \
				pmdv-${SAMPLE_LOW}-{1..14} :::+ \
				chr1 \
				chr2 \
				chr3 \
				chr4:chrMT \
				chr5:chrY \
				chr6:chr22 \
				chr7:chr19 \
				chr8:chr20 \
				chr9:chr13 \
				chr10:chr18 \
				chr11:chr14 \
				chr12:chr15 \
				chrX:chr21 \
				chr16:chr17 ::: \
				${BUCKET}/sample.config	
		elif [ "$GENDER" == "M" ];then
			parallel -j $NUM_PMD \
				${PROJECT_DIR}/manage_instances/pmdv_instance.sh ::: \
				pmdv-${SAMPLE_LOW}-{1..14} :::+ \
				chr1 \
				chr2 \
				chr3 \
				chr4:chrMT \
				chr5:chr22 \
				chr6:chrY \
				chr7:chr18 \
				chr8:chr19 \
				chr9:chrX \
				chr10:chr15 \
				chr11:chr20 \
				chr12:chr14 \
				chr13:chr17 \
				chr16:chr21 ::: \
				${BUCKET}/sample.config	
		fi
		exit 0
	fi
else
	1>&2 echo "Error: Provided $# arguments" 
	1>&2 echo "Need 1 input argument"
	1>&2 echo "Usage: create_instances_pmdv.sh CONFIG_FILE"
	exit 1
fi
