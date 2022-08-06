#!/bin/bash

HOST=`sudo docker service ps hotelreservation_mongodb-reservation | awk '$5 == "Running" { print $4 }'`

ssh -oStrictHostKeyChecking=no $HOST '
CID=`sudo docker container ls --filter name=hotelreservation_mongodb-reservation --format "{{.ID}}"`
PID=`sudo docker inspect -f "{{.State.Pid}} {{.Name}}" $CID | cut -f1,1 -d" "`
echo Killing $PID on `hostname`
sudo kill -9 $PID
'
