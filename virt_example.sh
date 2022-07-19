#!/bin/bash -x

# With virtualization
"Would you like to use LXD clustering? (yes/no) [default=no]: yes
What IP address or DNS name should be used to reach this node? [default=128.110.219.179]: manager1
Are you joining an existing cluster? (yes/no) [default=no]: 
What name should be used to identify this node in the cluster? [default=manager1.simpeter-128914.cse453-pg0.utah.cloudlab.us]: manager1
Setup password authentication on the cluster? (yes/no) [default=no]: 
Do you want to configure a new local storage pool? (yes/no) [default=yes]: 
Name of the storage backend to use (btrfs, dir, lvm, zfs) [default=zfs]: lvm
Create a new LVM pool? (yes/no) [default=yes]: 
Would you like to use an existing empty block device (e.g. a disk or partition)? (yes/no) [default=no]: 
Size in GB of the new loop device (1GB minimum) [default=5GB]: 20GB
Do you want to configure a new remote storage pool? (yes/no) [default=no]: 
Would you like to connect to a MAAS server? (yes/no) [default=no]: 
Would you like to configure LXD to use an existing bridge or host interface? (yes/no) [default=no]: 
Would you like to create a new Fan overlay network? (yes/no) [default=yes]: 
What subnet should be used as the Fan underlay? [default=auto]: 10.10.1.0/24 
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]: 
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: "
sudo lxc cluster add machine1
sudo lxc cluster add machine2
#On each worker machine: repeat first 4 steps, but choose to join cluster
#sudo lxc launch ubuntu:20.04 manager1vm --vm -c limits.memory=64GB
sudo lxc launch images:ubuntu/20.04/cloud vm1 --vm -c limits.memory=4GB
#for i in `seq 19`; do sudo lxc launch images:ubuntu/20.04/cloud vm$i --vm -c limits.memory=4GB; done # launch 19 VMs on cluster
#sudo lxc launch images:ubuntu/20.04/default manager1vm --vm -c limits.memory=64GB

# In the VM shell
apt update
#for i in `seq 19`; do sudo lxc exec vm$i -n -- apt update & done; wait
apt install curl
#for i in `seq 19`; do sudo lxc exec vm$i -n -- apt install --yes curl & done; wait
curl -fsSL https://get.docker.com -o get-docker.sh
#for i in `seq 19`; do sudo lxc exec vm$i -n -- curl -fsSL https://get.docker.com -o get-docker.sh & done; wait
sudo sh get-docker.sh
#for i in `seq 19`; do sudo lxc exec vm$i -n -- sudo sh get-docker.sh & done; wait

# To have docker daemon listen on TCP
#sudo systemctl edit docker.service
# "
# [Service]
# ExecStart=
# ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375
# "
# sudo systemctl daemon-reload
# sudo systemctl restart docker.service
# On Docker controller host to connect to TCP
#sudo docker context create manager1vm --default-stack-orchestrator=swarm --docker host=http://<vm-ip>:2375
#sudo docker context use manager1vm

# Install DeathStarBench
sudo lxc exec vm1 -- bash
sudo apt install git
mkdir projects
cd projects
git clone https://githu1b.com/delimitrou/DeathStarBench.git
sudo docker swarm init
for i in `seq $nvms`; do sudo lxc exec vm$i -n -- docker swarm join --token <TOKEN> 240.3.0.66:2377 & done; wait
#Login to all worker nodes and run the join command displayed by swarm init
sudo docker stack deploy --compose-file docker-compose-swarm.yml hotelreservation

# Setup network forward (warning: this forwards the entire host IP -- keep an SSH session open)
sudo lxc network forward create lxdfan0 <local_cloudlab_host-ip> target_address=<VM-IP>

###### Setup device passthrough ######

# On machine[012]
sudo lxd init --preseed <<EOF
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
EOF

# Interactive equivalent to the above
# sudo lxd init
# "Would you like to use LXD clustering? (yes/no) [default=no]: 
# Do you want to configure a new storage pool? (yes/no) [default=yes]: 
# Name of the new storage pool [default=default]: 
# Name of the storage backend to use (ceph, btrfs, dir, lvm, zfs) [default=zfs]: 
# Create a new ZFS pool? (yes/no) [default=yes]: 
# Would you like to use an existing empty block device (e.g. a disk or partition)? (yes/no) [default=no]: 
# Size in GB of the new loop device (1GB minimum) [default=5GB]: 20GB
# Would you like to connect to a MAAS server? (yes/no) [default=no]: 
# Would you like to create a new local network bridge? (yes/no) [default=yes]: 
# What should the new bridge be called? [default=lxdbr0]: 
# What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: 
# What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: 
# Would you like the LXD server to be available over the network? (yes/no) [default=no]: 
# Would you like stale cached images to be updated automatically? (yes/no) [default=yes]: 
# Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: "

# Old cluster-based try -- didn't work because adding physical network devices seems to always refer to machine0 on the cluster, which is stupid
# "Would you like to use LXD clustering? (yes/no) [default=no]: 
# Do you want to configure a new storage pool? (yes/no) [default=yes]: 
# Name of the new storage pool [default=default]: 
# Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]: 
# Create a new ZFS pool? (yes/no) [default=yes]: 
# Would you like to use an existing empty block device (e.g. a disk or partition)? (yes/no) [default=no]: 
# Size in GB of the new loop device (1GB minimum) [default=5GB]: 20GB
# Would you like to connect to a MAAS server? (yes/no) [default=no]: 
# Would you like to create a new local network bridge? (yes/no) [default=yes]: 
# What should the new bridge be called? [default=lxdbr0]: 
# What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: 
# What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: 
# Would you like the LXD server to be available over the network? (yes/no) [default=no]: yes
# Address to bind LXD to (not including port) [default=all]: <PUBLIC-IP>
# Port to bind LXD to [default=8443]: 
# Trust password for new clients: 
# Again: 
# Would you like stale cached images to be updated automatically? (yes/no) [default=yes]: 
# Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: "
# sudo lxc cluster enable machine0
# sudo lxc cluster add machine1
# sudo lxc cluster add machine2

# sudo lxd init
# "Would you like to use LXD clustering? (yes/no) [default=no]: yes
# What IP address or DNS name should be used to reach this node? [default=128.110.219.109]: 
# Are you joining an existing cluster? (yes/no) [default=no]: yes
# Do you have a join token? (yes/no/[token]) [default=no]: eyJzZXJ2ZXJfbmFtZSI6Im1hY2hpbmUxIiwiZmluZ2VycHJpbnQiOiIwZWRjOWUyODdjYmI1NmI1NzZjOTU3ZGFjYzFkMWI4YjhhNTc4OTE1NDMyNjNiM2FhMGIwZWU3N2ViMmRjMzRlIiwiYWRkcmVzc2VzIjpbIjEyOC4xMTAuMjE5LjExMTo4NDQzIl0sInNlY3JldCI6IjE3NWU0NjU0OWQxODA2MTk5ZDc2MDllNmRhZjcyZjJiZGJiNGM1MGY1YzBjZmZiOGJkOTQ3ZDA4MTFmZTVkZDgifQ==
# All existing data is lost when joining a cluster, continue? (yes/no) [default=no] yes
# Choose "size" property for storage pool "default": 20GB
# Choose "source" property for storage pool "default": 
# Choose "zfs.pool_name" property for storage pool "default": 
# Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: "

# Init VMs on machine[012]
sudo lxc init images:ubuntu/20.04/cloud vm1 --vm -c limits.memory=4GB
sudo lxc config device add vm1 eth1 nic nictype=physical parent=ens1f0
sudo lxc start vm1

# In VMs
apt install net-tools
ifconfig enp6s0 10.10.1.[123] netmask 255.255.255.0 up
