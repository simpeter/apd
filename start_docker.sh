#!/bin/bash -x

. config.sh

# This script runs only on server0
test x`hostname -s` == xserver0 || { echo "This script has to run on server0"; exit 1; }

# Start Docker on all servers
for i in `seq 0 $((n_servers - 1))`; do
    ssh -oStrictHostKeyChecking=no server$i "curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
done

sudo docker swarm init --advertise-addr 10.10.1.1
echo "Add other servers via the join command presented by docker"
