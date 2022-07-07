#/bin/bash -x

# Install
mkdir projects
cd projects
git clone https://github.com/delimitrou/DeathStarBench.git
#sudo apt update
#sudo apt install docker-compose docker.io python3-aiohttp libssl-dev libz-dev luarocks lua-socket
#sudo apt install python3-aiohttp libssl-dev libz-dev luarocks lua-socket
#sudo luarocks install luasocket
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
# could create a CloudLab disk image here

# With virtualization (on manager node)
#sudo docker context create manager1vm --default-stack-orchestrator=swarm --docker host=http://<vm-ip>:2375

# With virtualization
sudo apt update
sudo apt install --yes snapd
#sudo snap install multipass lxd
sudo snap install lxd
sudo lxd init
"Would you like to use LXD clustering? (yes/no) [default=no]: yes
What IP address or DNS name should be used to reach this node? [default=128.110.219.179]: manager1
Are you joining an existing cluster? (yes/no) [default=no]: 
What name should be used to identify this node in the cluster? [default=manager1.simpeter-128914.cse453-pg0.utah.cloudlab.us]: manager1
Setup password authentication on the cluster? (yes/no) [default=no]: 
Do you want to configure a new local storage pool? (yes/no) [default=yes]: 
Name of the storage backend to use (btrfs, dir, lvm, zfs) [default=zfs]: lvm
Create a new LVM pool? (yes/no) [default=yes]: 
Would you like to use an existing empty block device (e.g. a disk or partition)? (yes/no) [default=no]: 
Size in GB of the new loop device (1GB minimum) [default=5GB]: 
Do you want to configure a new remote storage pool? (yes/no) [default=no]: 
Would you like to connect to a MAAS server? (yes/no) [default=no]: 
Would you like to configure LXD to use an existing bridge or host interface? (yes/no) [default=no]: 
Would you like to create a new Fan overlay network? (yes/no) [default=yes]: 
What subnet should be used as the Fan underlay? [default=auto]: 10.10.1.0/24 
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]: 
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: "
#sudo multipass set local.driver=lxd
#sudo multipass launch --name manager1vm
#sudo multipass shell manager1vm # Also starts a fresh VM if not running
sudo lxc cluster add worker1
sudo lxc cluster add worker2
#On each worker machine: repeat first 4 steps, but choose to join cluster
#sudo lxc launch ubuntu:20.04 manager1vm --vm -c limits.memory=64GB
sudo lxc launch images:ubuntu/20.04/cloud vm1 --vm #-c limits.memory=64GB
for i in `seq 19`; do sudo lxc launch images:ubuntu/20.04/cloud vm$i --vm; done # launch 19 VMs on cluster
#sudo lxc launch images:ubuntu/20.04/default manager1vm --vm -c limits.memory=64GB
#sudo lxc network forward create lxdbr0 <local_cloudlab_host-ip> target_address=<VM-IP>
sudo lxc exec manager1vm -- bash # Interactive single node

# In the VM shell
apt update
#for i in `seq 19`; do sudo lxc exec vm$i -n -- apt update & done; wait
apt install curl
#for i in `seq 19`; do sudo lxc exec vm$i -n -- apt install --yes curl & done; wait
curl -fsSL https://get.docker.com -o get-docker.sh
#for i in `seq 19`; do sudo lxc exec vm$i -n -- curl -fsSL https://get.docker.com -o get-docker.sh & done; wait
sudo sh get-docker.sh
#for i in `seq 19`; do sudo lxc exec vm$i -n -- sudo sh get-docker.sh & done; wait
#sudo systemctl edit docker.service
# "
# [Service]
# ExecStart=
# ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375
# "
# sudo systemctl daemon-reload
# sudo systemctl restart docker.service

# On Docker controller host
# sudo docker context use manager1vm

# Run single machine
cd projects/DeathStarBench/hotelReservation/
docker-compose up -d

# Run on cluster
IP=`ip ad show | grep -s '10.10.' | awk '{ print $2 }'` # Local network IP
sudo docker swarm init --advertise-addr ${IP%/*}
Login to all worker nodes and run the join command displayed by swarm init
sudo docker stack deploy --compose-file docker-compose-swarm.yml hotelreservation

# Show services running
sudo docker stack services hotelreservation

# Evaluate (from a client machine across Internet, but also locally works)
make -C DeathStarBench/hotelReservation/wrk2
./wrk2/wrk -D exp -t 1 -c 100 -d 10 -L -s ./wrk2/scripts/hotel-reservation/mixed-workload_type_1.lua http://localhost:5000 -R 10000

# Test
curl 'http://amd220.utah.cloudlab.us:5000/reservation?inDate=2015-04-19&outDate=2015-04-24&lat=nil&lon=nil&hotelId=9&customerName=Cornell_1&username=Cornell_1&password=1111111111&number=1'
curl 'http://amd220.utah.cloudlab.us:5000/user?username=Cornell_1&password=1111111111'

# Trace
Connect to port 16686 on whichever machine runs the jaeger service

# Inspect/debug
sudo docker container ls
sudo docker exec -it 7a61f3dc26d1 bash
