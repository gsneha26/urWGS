#!/bin/bash

1>&2 echo "current "$(TZ='America/Los_Angeles' date)
SERVICE="/bin/bash $PROJECT_DIR/sniffles/run_sniffles_pipeline.sh"
if pgrep -f "$SERVICE" >/dev/null
then
	1>&2 echo "$SERVICE is running"
else
	$PROJECT_DIR/sniffles/run_sniffles_pipeline.sh 
fi
