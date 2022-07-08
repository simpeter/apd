#!/bin/bash

# All output and commands go to logfile in /tmp
set -x
exec 1>/tmp/virtualize.log 2>&1

function get_token()
{
    awk -F, "\$1 == \"machine$1\" { print \$2 }" tokens.csv
}

echo "running test" > /tmp/test.txt
echo $PWD >> /tmp/test.txt
echo $USER >> /tmp/test.txt

# With virtualization
apt-get update
apt-get install --yes snapd
snap install lxd

lxd init --preseed <<EOF
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
for i in `seq 9`; do
    lxc cluster add machine$i
done
lxc cluster list-tokens -f csv > tokens.csv

# Join all cluster nodes
for i in `seq 9`; do
    ssh machine$i "sudo lxd init --preseed <<EOF
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
