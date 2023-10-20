#!/usr/bin/env bash
# set -x

PWD=$(pwd)   # path to this directory

# Functions
exit_with_error()
{
    echo "$(date)" - "$1" >> "$PWD/errorlog.txt"
    echo "Error: $1" >&2
    # TODO: send email/notification?
    exit 1
}

# Check if docker is available
if ! [ -x "$(command -v docker)" ]; 
then
  exit_with_error "Docker is required, but it's not installed.  Aborting."
fi

# Check if script is already running
if psgrep 'setup-gis-services' >/dev/null; then
  exit_with_error "Script already running. Running services:\n
  $RUNNINGGISSERVICES \n
  Aborting script."
fi

# Source the .env file
if [[ -f .env ]]; then
    source "$PWD/.env"
else
cat <<EOF >> "$PWD/.env"
DOCKERPROTOCOL=http
DOCKERDOMAIN=localhost
DOCKERPORT=80
COUNTRIES="monaco"  # Separate countries with spaces
EOF
fi

# Variables
COUNTRIES="${COUNTRIES:-monaco}"

# Convert the space-separated string into an AREAS array
IFS=' ' read -ra AREAS <<< "$COUNTRIES"

DOCKERPROTOCOL="${DOCKERPROTOCOL:-http://}"     # protocol used, http for local, https for external hosting
DOCKERDOMAIN="${DOCKERDOMAIN:-127.0.0.1}"       # domain used, 127.0.0.1 for local, gisservices.duckdns.org (example, can be anything) for external hosting
DOCKERPORT="${DOCKERPORT:-80}"                  # port used, 80 for local (example, can be anything), 443 for external hosting

###############  Main script

# Create a variable holding the name for the merged .osm.pbf file. Export this to script for use in the debian container
MERGED_AREAS="merged_areas"

# Create volumes for docker containers
docker volume create gis-services-processing
docker volume create gis-services-maptiler
docker volume create gis-services-nominatim-data
docker volume create gis-services-nominatim-postgress
docker volume create gis-services-valhalla

# Download the latest .osm.pbf files of areas specified in the AREAS array
for AREA in "${AREAS[@]}"; do
    docker run --rm \
    -e JAVA_TOOL_OPTIONS="-Xmx1g" \
    -v gis-services-processing:/data \
    --name "gis-services-download-$AREA" \
    ghcr.io/onthegomap/planetiler:latest \
    --only-download --area=$AREA --force --fetch-wikidata \
  || exit_with_error "Error downloading .osm.pbf of $AREA.  Aborting."
done

# Create managing debian container, copy scripts to it
docker run -d -t \
  -v gis-services-processing:/processing \
  -v gis-services-maptiler:/maptiler \
  -v gis-services-nominatim-data:/nominatim-data \
  -v gis-services-valhalla:/valhalla \
  --name gis-services-ubuntu \
  ubuntu:22.04
docker exec -it gis-services-ubuntu bash -c 'apt update -y && apt install osmium-tool -y'
docker cp "$PWD/scripts" gis-services-ubuntu:/processing

# Merge .osm.pbf files with osmium in debian container
docker exec -t gis-services-ubuntu bash /processing/scripts/merge-osm-files.sh "$MERGED_AREAS"

# Run prepare scripts to prepare processing
docker exec -t gis-services-ubuntu bash /processing/scripts/prepare-valhalla-processing.sh "$MERGED_AREAS"
docker exec -t gis-services-ubuntu bash /processing/scripts/prepare-nominatim-processing.sh "$MERGED_AREAS"

# Valhalla processing - Build routing tiles
# echo "========================="
# echo "== VALHALLA processing =="
# echo "========================="
# docker run --rm \
#   -v gis-services-valhalla:/custom_files \
#   -e build_elevation=True \
#   -e build_admins=True \
#   -e build_time_zones=True \
#   -e serve_tiles=False \
#   -e traffic_name="" \
#   --name "gis-services-valhalla-prep" \
#   ghcr.io/gis-ops/docker-valhalla/valhalla:$VALHALLA_VERSION \
#   || exit_with_error "Error during Valhalla processing.  Aborting."

# # Maptiler processing - Build vector tiles
# echo "========================="
# echo "== MAPTILER processing =="
# echo "========================="
# docker run --rm \
#   -e JAVA_TOOL_OPTIONS="-Xmx1g" \
#   -v gis-services-processing:/data \
#   -v gis-services-maptiler:/maptiler \
#   --name "gis-services-generating-vector-tiles" \
#   ghcr.io/onthegomap/planetiler:latest \
#   --osm-path=/data/$MERGED_AREAS.osm.pbf --force --output=/maptiler/output.mbtiles \
#   || exit_with_error "Error generating vector tiles.  Aborting."

# Populate nominatim db
echo "=========================="
echo "== NOMINATIM processing =="
echo "=========================="
docker run -d -t --shm-size=1g \
  -e PBF_PATH=/nominatim/data/$MERGED_AREAS.osm.pbf \
  -e IMPORT_WIKIPEDIA=false \
  -e FREEZE=true \
  -v gis-services-nominatim-data:/nominatim/data/ \
  -v gis-services-nominatim-postgress:/var/lib/postgresql/12/main \
  --name "gis-services-nominatim-prepdb" \
  mediagis/nominatim:$NOMINATIM_VERSION
while [ "$(docker logs gis-services-nominatim-prepdb --tail 5 | grep -c "Nominatim is ready to accept requests")" -eq 0 ]; do
    echo "Populating Nominatim database..."
    sleep 2
done

docker stop gis-services-nominatim-prepdb && docker rm gis-services-nominatim-prepdb

# Clean up processing folders
docker exec -t gis-services-ubuntu bash /processing/scripts/cleanup-valhalla-processing.sh "$MERGED_AREAS"

# # Prepare images, take services down, update .env and nginx.conf, restart services
# cd $PWD
# docker compose pull
# docker compose down

# # Stopping and removing managing debian container and deleting processing volume
docker container stop "gis-services-ubuntu" && docker container rm "gis-services-ubuntu" && docker volume rm gis-services-processing

# # Delete old volumes of services
# echo Deleting old gis-services... volumes
# ./remove_gis_volumes.sh

# docker compose --env-file ./.env up -d 

echo "setup-gis-services script had finished"