#!/bin/bash -x

. config.sh

# This script runs only on machine0
test x`hostname -s` == xmachine0 || { echo "This script has to run on machine0"; exit 1; }

# Start Docker on all machines
for i in `seq 0 $((n_machines - 1))`; do
    ssh -oStrictHostKeyChecking=no machine$i "curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh"

# Install DeathStarBench
mkdir projects
cd projects
git clone -n https://github.com/delimitrou/DeathStarBench.git
cd DeathStarBench && git checkout ff0c39df331106bbf1e20be5724be718f44b73f1
sudo docker swarm init --advertise-addr 10.10.1.1

echo "Add other machines via the join command presented by docker"
