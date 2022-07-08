#/bin/bash -x

# Install
mkdir projects
cd projects
git clone https://github.com/delimitrou/DeathStarBench.git
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
# could create a CloudLab disk image here

# Run single machine
cd projects/DeathStarBench/hotelReservation/
docker-compose up -d

# Run on cluster
IP=`ip ad show | grep -s '10.10.' | awk '{ print $2 }'` # Local network IP
sudo docker swarm init --advertise-addr ${IP%/*}
#Login to all worker nodes and run the join command displayed by swarm init
sudo docker stack deploy --compose-file docker-compose-swarm.yml hotelreservation

# Show services running
sudo docker stack services hotelreservation

# Evaluate (from a client machine across Internet, but also locally works)
#sudo apt install python3-aiohttp libssl-dev libz-dev luarocks lua-socket
#sudo luarocks install luasocket
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
