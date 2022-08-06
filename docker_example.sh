# This script is not meant to be executed.
# It simply contains a few example commandlines.

# Run single server
cd DeathStarBench/hotelReservation/
sudo docker compose up -d --build
sudo docker compose -f docker-compose-localmounts.yml up -d --build
sudo docker compose -f hotelreservation-nvmdb.yml up -d --build -t1

# Run on cluster
sudo docker stack deploy --compose-file hotelreservation.yml hotelreservation

# Show services running
sudo docker stack services hotelreservation
sudo docker service ls

# Evaluate (from a client)
sudo apt install python3-aiohttp libssl-dev libz-dev luarocks lua-socket
sudo luarocks install luasocket
make -C DeathStarBench/hotelReservation/wrk2
./wrk2/wrk -D exp -t 10 -c 100 -d 10 -L -s ./wrk2/scripts/hotel-reservation/mixed-workload_type_1.lua http://server0:5000 -R 10000
./wrk2/wrk -D exp -t 10 -c 100 -d 10 -L -s /local/repository/reserve_only.lua http://server0:5000 -R 1000
stdbuf -oL ./wrk2/wrk -D fixed -t 1 -c 1 -s /local/repository/reserve_only.lua http://server0:5000 -R 10 -P -d 100 -T1s | tee lat.txt
cat lat.txt | awk '$3 == "@" { print int($4), $6 }' > lat.dat

# Test
curl 'http://server0:5000/reservation?inDate=2015-04-19&outDate=2015-04-24&lat=nil&lon=nil&hotelId=9&customerName=Cornell_1&username=Cornell_1&password=1111111111&number=1'
curl 'http://server0:5000/user?username=Cornell_1&password=1111111111'

# Trace
Connect to port 16686 on whichever server runs the jaeger service

# Inspect/debug
sudo docker ps
sudo docker exec -it hotel_reserv_reservation_mongo gdb -p 1 nvmdb
journalctl -u docker.service
sudo docker logs hotel_reserv_reservation_mongo

# Stopping and cleanup
sudo docker stack rm hotelreservation && sudo docker volume prune
sudo docker compose down -t1 && sudo docker volume prune
sudo docker compose -f hotelreservation-nvmdb.yml down -t1

sudo umount /mnt/*
sudo rm -rf /mnt/*
