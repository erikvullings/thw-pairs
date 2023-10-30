#!/bin/bash

prefix="gis-services"

# List all Docker volumes starting with the prefix
volumes=$(docker volume ls -q --filter name=^$prefix)

# Loop through the volume names and remove them
for volume in $volumes; do
    docker volume rm $volume
done
