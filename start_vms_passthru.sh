#!/bin/bash -x

. config.sh

# This script runs only on server0
test x`hostname -s` == xserver0 || { echo "This script has to run on server0"; exit 1; }

DOMAIN=${HOSTNAME#*.}

# Start passthrough VMs on all servers
for i in `seq 0 $((n_servers - 1))`; do
    ssh -oStrictHostKeyChecking=no server$i.$DOMAIN "sudo lxd init --preseed <<EOF
config: {}
networks:
- config:
    ipv4.address: auto
    ipv6.address: auto
  description: ""
  name: lxdbr0
  type: ""
  project: default
storage_pools:
- config:
    size: 20GB
  description: ""
  name: default
  driver: zfs
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      network: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
projects: []
cluster: null
EOF"
    ssh -tt -oStrictHostKeyChecking=no server$i.$DOMAIN "
NETDEV=\`ip -br -oneline -4 ad show to 10.10.1.$((i + 1)) | cut -f1,1 -d' '\`
echo server$i NETDEV=\$NETDEV
sudo lxc init images:ubuntu/20.04/cloud vm$((i + 1)) --vm -c limits.memory=4GB
sudo lxc config device add vm$((i + 1)) eth1 nic nictype=physical parent=\$NETDEV
sudo lxc start vm$((i + 1))"
done

# Wait until all VMs are up
echo "Waiting 120 seconds for VMs to start..."
sleep 120

# Install docker on all VMs
for i in `seq 0 $((n_servers - 1))`; do
    ssh -oStrictHostKeyChecking=no server$i.$DOMAIN "sudo lxc exec vm$((i + 1)) -n -- sh -c \"
apt-get update
apt-get install --yes curl net-tools
ifconfig enp6s0 10.10.1.$((i + 1)) netmask 255.255.255.0 up
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh\""
done

# Install DeathStarBench
sudo lxc file push hotelreservation.yml vm1/root/
sudo lxc exec vm1 -- sh -c "sudo docker swarm init --advertise-addr 10.10.1.1"

# echo "Add other VMs via the join command presented by docker"
JOIN_COMMAND=$(sudo lxc exec vm1 -- sh -c "sudo docker swarm join-token worker | awk '/docker/ {print $1}'")

# Start Docker on all servers
for i in `seq 1 $((n_servers - 1))`; do
  ssh -oStrictHostKeyChecking=no server$i.$DOMAIN "sudo lxc exec vm$((i+1)) -n -- sh -c  '$JOIN_COMMAND'"
done



# Add the network forward (warning: this forwards the entire host IP -- keep an SSH session open)
#sudo lxc network forward create lxdbr0 <local_cloudlab_host-ip> target_address=<VM-IP>
