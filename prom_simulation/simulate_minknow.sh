#!/bin/bash

echo "Started sequencing at "$(date +%T)
time parallel -j 48 < /data/scripts/prom_simulation/fc_simulation.lst 
