#!/bin/bash -x

# Number of geni machines
n_machines=`geni-get manifest | xpath -e 'rspec/data_set/data_item[attribute::name = "emulab.net.parameter.n_machines"]/text()' -q`

# Number of VMs
nvms=3
