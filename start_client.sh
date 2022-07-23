#!/bin/bash -x

# Build wrk2
cd DeathStarBench
sudo apt-get install --yes python3-aiohttp libssl-dev libz-dev luarocks lua-socket
sudo luarocks install luasocket
make -C hotelReservation/wrk2
