#!/usr/bin/env bash

# Access the passed variable
MERGED_AREAS="$1"

echo "cleanup-valhalla-processing script has started"
echo "Removing $MERGED_AREAS.osm.pbf";
rm /valhalla/$MERGED_AREAS.osm.pbf
echo "cleanup-valhalla-processing script has finished"