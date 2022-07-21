#!/bin/bash -x

. config.sh

# This script runs only on server0
test x`hostname -s` == xserver0 || { echo "This script has to run on server0"; exit 1; }

# Start Docker on all servers
for i in `seq 0 $((n_servers - 1))`; do
    ssh -oStrictHostKeyChecking=no server$i "curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
done

# Install DeathStarBench
# mkdir ~/projects
# cd ~/projects
# git clone -n https://github.com/delimitrou/DeathStarBench.git
# cd DeathStarBench && git checkout ff0c39df331106bbf1e20be5724be718f44b73f1
sudo docker swarm init --advertise-addr 10.10.1.1

echo "Add other servers via the join command presented by docker"
