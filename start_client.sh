#!/bin/bash -x

# Install DeathStarBench
mkdir ~/projects
cd ~/projects
git clone -n https://github.com/delimitrou/DeathStarBench.git
cd DeathStarBench && git checkout ff0c39df331106bbf1e20be5724be718f44b73f1

# Build wrk2
sudo apt-get install --yes python3-aiohttp libssl-dev libz-dev luarocks lua-socket
sudo luarocks install luasocket
make -C hotelReservation/wrk2
