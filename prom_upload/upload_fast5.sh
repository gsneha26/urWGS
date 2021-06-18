#!/bin/bash

SERVICE="/bin/bash /data/scripts/prom_upload/upload_prom_gcs.sh"

1>&2 echo "current "$(TZ='America/Los_Angeles' date)
if pgrep -f "$SERVICE" >/dev/null
then
	1>&2 echo "$SERVICE is running"
else
	time /data/scripts/prom_upload/upload_prom_gcs.sh
fi
