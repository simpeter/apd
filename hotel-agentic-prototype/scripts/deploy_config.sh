#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <config_file.env>"
  exit 1
fi

CONFIG_FILE="$1"

# Load variables from .env-style file
echo "Loading config from $CONFIG_FILE"
set -o allexport
source "$CONFIG_FILE"
set +o allexport

# Deploy using both base and override Compose files
echo "Deploying stack..."
ssh server0 "sudo docker stack deploy -c /local/repository/hotelreservation.yml -c /local/repository/hotel-agentic-prototype/docker-compose.override.yml hotelreservation"
