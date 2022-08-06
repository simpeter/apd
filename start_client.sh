#!/bin/bash -x

export MAKEFLAGS=-j

# Build wrk2
cd /local/repository/DeathStarBench
sudo apt-get install --yes python3-aiohttp libssl-dev libz-dev luarocks lua-socket nfs-kernel-server
sudo luarocks install luasocket
make -C hotelReservation/wrk2
