#!/bin/bash -x

. config.sh

# This script runs only on server0
test x`hostname -s` == xserver0 || { echo "This script has to run on server0"; exit 1; }

ssh client0 "
sudo mkdir /mnt/reservation
sudo bash 'echo -e \'/mnt/reservation\t*(rw,no_root_squash)\' >> /etc/exports'
sudo /etc/init.d/nfs-kernel-server reload"

for i in `seq 0 $((n_servers - 1))`; do
    ssh -oStrictHostKeyChecking=no server$i "
sudo mkdir -p /mnt/reservation
sudo mount -t nfs client0:/mnt/reservation /mnt/reservation"
done

sudo docker service create --name registry --publish published=4000,target=5000 registry:2
sudo docker compose -f hotelreservation-nfs.yml build
sudo docker compose -f hotelreservation-nfs.yml push
sudo docker stack deploy --compose-file hotelreservation-nfs.yml hotelreservation
