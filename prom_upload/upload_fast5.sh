#!/bin/bash

SERVICE="/bin/bash $PROJECT_DIR/prom_upload/tranfer_prom_gcs.sh"

1>&2 echo "current "$(TZ='America/Los_Angeles' date)
if pgrep -f "$SERVICE" >/dev/null
then
	1>&2 echo "$SERVICE is already running"
else
	time $PROJECT_DIR/prom_upload/transfer_prom_gcs.sh
fi
