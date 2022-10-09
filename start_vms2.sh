#!/bin/bash -x

. config.sh

# Launch $nvms VMs on LXD cluster
for i in `seq $nvms`; do sudo lxc launch images:ubuntu/20.04/cloud vm$((i+3)) --vm -c limits.memory=4GB -c limits.cpu=`getconf _NPROCESSORS_ONLN` "${LXC_OPTS[@]}"; done

# Wait until all VMs are up
echo "Waiting 120 seconds for VMs to start..."
sleep 120

# Install docker on all VMs
for i in `seq $nvms`; do
    sudo lxc exec vm$((i+3)) -n -- sh -c "
apt-get update
apt-get install --yes curl net-tools iperf3
ifconfig enp5s0 mtu 1450
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh" &
done
wait

# Install DeathStarBench
sudo lxc file push hotelreservation.yml vm4/root/
sudo lxc exec vm4 -- sh -c "sudo docker swarm init"

JOIN_COMMAND=$(sudo lxc exec vm4 -- sh -c "sudo docker swarm join-token worker | awk '/docker/ {print $1}'")

# Start Docker on all servers
for i in `seq 2 $nvms`; do
    sudo lxc exec vm$((i+3)) -n -- sh -c  "$JOIN_COMMAND"
done

