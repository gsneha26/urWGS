#!/bin/bash

1>&2 echo "current "$(TZ='America/Los_Angeles' date)
SERVICE="/bin/bash $PROJECT_DIR/pmdv/run_pmdv_pipeline.sh"
PMDV_STATUS_FILE=/data/pmdv_status.txt
if pgrep -f "$SERVICE" >/dev/null
then
	1>&2 echo "$SERVICE is running"
else
	$PROJECT_DIR/pmdv/run_pmdv_pipeline.sh 
fi
