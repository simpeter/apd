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
