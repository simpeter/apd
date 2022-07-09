#!/bin/bash
#
# This runs as geniuser in /.

# All output and commands go to logfile in /tmp
set -x
exec 1>/tmp/virtualize.log 2>&1

#echo "running test" > /tmp/test.txt
#echo $PWD >> /tmp/test.txt
#echo $USER >> /tmp/test.txt

# With virtualization
sudo apt-get update
sudo apt-get install --yes snapd libxml-xpath-perl
sudo snap install lxd

# The rest runs only on machine0
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
