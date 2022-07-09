#!/bin/bash -x

# Configuration
n_machines=`geni-get manifest | xpath -e 'rspec/data_set/data_item[attribute::name = "emulab.net.parameter.n_machines"]/text()' -q`

### Configuration
# Number of VMs
nvms=3

function get_token()
{
    awk -F, "\$1 == \"machine$1\" { print \$2 }" /tmp/tokens.csv
}

# This script runs only on machine0
test x`hostname -s` == xmachine0 || exit 0

# Setup master LXD instance
sudo lxd init --preseed <<EOF
config:
  core.https_address: `hostname -s`:8443
networks:
- config:
    bridge.mode: fan
    fan.underlay_subnet: 10.10.1.0/24
  description: ""
  name: lxdfan0
  type: ""
  project: default
storage_pools:
- config:
    size: 20GB
  description: ""
  name: local
  driver: zfs
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      network: lxdfan0
      type: nic
    root:
      path: /
      pool: local
      type: disk
  name: default
projects: []
cluster:
  server_name: `hostname -s`
  enabled: true
  member_config: []
  cluster_address: ""
  cluster_certificate: ""
  server_address: ""
  cluster_password: ""
  cluster_certificate_path: ""
  cluster_token: ""
EOF

# Generate cluster join tokens
for i in `seq $((n_machines - 1))`; do
    sudo lxc cluster add machine$i
done
sudo lxc cluster list-tokens -f csv > /tmp/tokens.csv

# Join all cluster nodes
for i in `seq $((n_machines - 1))`; do
    ssh -oStrictHostKeyChecking=no machine$i "sudo lxd init --preseed <<EOF
config: {}
networks: []
storage_pools: []
profiles: []
projects: []
cluster:
  server_name: machine$i
  enabled: true
  member_config:
  - entity: storage-pool
    name: local
    key: size
    value: 20GB
    description: '\"size\" property for storage pool \"local\"'
  - entity: storage-pool
    name: local
    key: source
    value: \"\"
    description: '\"source\" property for storage pool \"local\"'
  - entity: storage-pool
    name: local
    key: zfs.pool_name
    value: \"\"
    description: '\"zfs.pool_name\" property for storage pool \"local\"'
  cluster_address: machine0:8443
  server_address: machine$i:8443
  cluster_password: \"\"
  cluster_certificate_path: \"\"
  cluster_token: \"`get_token $i`\"
EOF"
done

# Launch $nvms VMs on LXD cluster
for i in `seq $nvms`; do sudo lxc launch images:ubuntu/20.04/cloud vm$i --vm -c limits.memory=4GB; done

# Wait until all VMs are up
echo "Waiting 30 seconds for VMs to start..."
sleep 30

# Install docker on all VMs
for i in `seq $nvms`; do
    sudo lxc exec vm$i -n -- sh -c "
apt-get update
apt-get install --yes curl net-tools
ifconfig enp5s0 mtu 1450
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh" &
done
wait

# Install DeathStarBench
sudo lxc exec vm1 -- sh -c "
sudo apt-get install --yes git
mkdir projects
cd projects
git clone https://github.com/delimitrou/DeathStarBench.git
sudo docker swarm init"
