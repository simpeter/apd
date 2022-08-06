#!/bin/bash -x

sudo docker service create --name registry --publish published=4000,target=5000 registry:2
sudo docker compose -f hotelreservation-nfs.yml build
sudo docker compose -f hotelreservation-nfs.yml push
sudo docker stack deploy --compose-file hotelreservation-nfs.yml hotelreservation
