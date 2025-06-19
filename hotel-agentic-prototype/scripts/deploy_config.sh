#!/bin/bash
# Usage: ./deploy_config.sh configs/config1.env

CONFIG_FILE=$1
source $CONFIG_FILE
export GRPC_WORKER_THREADS

cd /local/repository

#docker stack rm hotelreservation
#sleep 5
#docker stack deploy --compose-file hotelreservation.yml hotelreservation

# docker-compose down
# docker-compose up -d --build
