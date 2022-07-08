#!/bin/bash -x

nvms=19

# Launch $nvms VMs on LXD cluster
for i in `seq $nvms`; do sudo lxc launch images:ubuntu/20.04/cloud vm$i --vm -c limits.memory=4GB; done

# Install docker on all VMs
for i in `seq $nvms`; do
    lxc exec vm$i -n -- sh -c "
apt-get update
apt-get install --yes curl
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh" &
done
wait

# Install DeathStarBench
lxc exec vm1 -- sh -c "
sudo apt-get install --yes git
mkdir projects
cd projects
git clone https://github.com/delimitrou/DeathStarBench.git
sudo docker swarm init"
