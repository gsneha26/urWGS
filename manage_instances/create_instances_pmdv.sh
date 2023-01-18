#!/bin/bash

if [ $# -eq 1 ]; then
	CONFIG_FILE=$1

	if [ ! -f "$CONFIG_FILE" ]; then
		1>&2 echo "Error: Provided file $CONFIG_FILE does not exist"
		1>&2 echo "Usage: create_instances_pmdv.sh CONFIG_FILE"
		exit 1
	else
      echo 'll'
		source $CONFIG_FILE

		gsutil cp $CONFIG_FILE ${BUCKET}/

    parallel -j $NUM_PMD \
      ${PROJECT_DIR}/manage_instances/pmdv_instance.sh ::: \
      pmdv-${SAMPLE_LOW}-{1..20} :::+ \
      chr1 \
      chr2 \
      chr3 \
      chr4 \
      chr5 \
      chr6 \
      chr7 \
      chr8 \
      chr9 \
      chr10 \
      chr11 \
      chr12 \
      chr13 \
      chr14 \
      chr15 \
      chr16 \
      chr17:chrMT \
      chr18:chrY \
      chr19:chr21 \
      chr20:chr21 ::: \
      ${BUCKET}/sample.config	
		exit 0
	fi
else
	1>&2 echo "Error: Provided $# arguments" 
	1>&2 echo "Need 1 input argument"
	1>&2 echo "Usage: create_instances_pmdv.sh CONFIG_FILE"
	exit 1
fi
