#!/bin/bash

echo "Started sequencing at "$(date +%T)
time parallel -j 48 --dry-run /data/scripts/prom_simulation/simulate_fc.sh ::: {1..6}{A..H}
