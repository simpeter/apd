#!/bin/bash -x

# Number of servers
n_servers=`geni-get manifest | xpath -e 'rspec/data_set/data_item[attribute::name = "emulab.net.parameter.n_servers"]/text()' -q`

# Number of clients
n_clients=`geni-get manifest | xpath -e 'rspec/data_set/data_item[attribute::name = "emulab.net.parameter.n_clients"]/text()' -q`

# Number of VMs
nvms=3
