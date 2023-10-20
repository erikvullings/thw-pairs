#!/usr/bin/env bash

# Access the passed variable
MERGED_AREAS="$1"

echo "merge-osm-files script has started"
# source /processing/scripts/set-environment.sh
AREAFILES=$(find /processing/sources/ -name "*.osm.pbf")

# Install osmium
# apt update -y && apt install osmium-tool -y

# Merge the .osm.pbf files into 1 .osm.pbf with osmium 
osmium merge $AREAFILES --output /processing/$MERGED_AREAS.osm.pbf --fsync --overwrite

status=$?
[ $status -eq 0 ] && echo "$(date) merge command was successful" >> log.txt || echo "$(date) merge command failed" >> log.txt

echo "merge-osm-files script has finished"
