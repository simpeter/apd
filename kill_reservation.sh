#!/bin/bash

HOST=`sudo docker service ps hotelreservation_mongodb-reservation | awk '$5 == "Running" { print $4 }'`

ssh $HOST '
CID=`sudo docker container ls --filter name=hotelreservation_mongodb-reservation --format "{{.ID}}"`
sudo docker inspect -f '{{.State.Pid}} {{.Name}}' $CID | awk '{ print $1 }'
'
