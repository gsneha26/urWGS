#!/bin/bash

1>&2 echo "current "$(TZ='America/Los_Angeles' date)
SERVICE="/bin/bash /data/scripts/run_basecalling.sh"
if pgrep -f "$SERVICE" >/dev/null
then
	1>&2 echo "$SERVICE is running"
else
	/data/scripts/run_basecalling.sh 
	1>&2 echo "run_basecalling.sh exited with code $?" 
fi
