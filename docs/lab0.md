# Lab 0: Setting Up

This lab is ungraded and intended to get you set up with the project's
infrastructure. Please go through all the steps, make sure that each
one works and that you have access to everything described here.

## Create a CloudLab Account ([Link](https://www.cloudlab.us/signup.php?pid=cse453))

The majority of the project runs on CloudLab, for which you need an
account. To create an account, please use your UW email and use UW
NetID as the username. Upload your SSH public key file as you use SSH to 
access the nodes in CloudLab. Click on `Submit
Request`. We will approve your request within 24 hours. If you already
have a CloudLab account, simply request to join the `cse453` project.

## Start an Experiment

To start a new experiment, go to your CloudLab dashboard's  [`Project Profile`](https://www.cloudlab.us/user-dashboard.php#projectprofiles) page. Go to `cse453repo` profile and click `instantiate` button. 
You can configure the number of machines you need (maximum 10) and select mode. 
Click on `Next` to move to the next page. Name and choose the cluster you want to start your
experiment. For more information on the hardware CloudLab provides, please refer to this [page](http://docs.cloudlab.us/hardware.html).

It may take a few mintues for the experiment to start. Once the experiment is created, you should be able to view the
information under the [`Experiments`](https://www.cloudlab.us/user-dashboard.php#experiments) page.

## Log into Experiment Machines

Once the experiment is ready (this can take a few minutes), click
`List View`, and you will find SSH commands to access each node. On the
same tab, you can also reboot/reload your nodes if something goes wrong.

<!-- ## Find a Client Machine at UW -->

## Run iperf

[iperf](https://iperf.fr/iperf-doc.php) is a tool for network throughput measurements between two hosts (a client that generates traffic and a server that receives traffic). You'll use iperf to measure the bandwidth between nodes in your experiment. <br />
Step 1: Find the ip address of the server
```console
machine0:~> ifconfig | grep -s '10.10.' | awk '{ print $2 }'
10.10.1.1
```

On the server side:
```console
machine0:~> iperf -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size:  128 KByte (default)
------------------------------------------------------------
[  4] local 10.10.1.1 port 5001 connected with 10.10.1.2 port 52910
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec  11.0 GBytes  9.41 Gbits/sec
```
On the client side:
```console
machine1:~> iperf -c 10.10.1.1
------------------------------------------------------------
Client connecting to 10.10.1.1, TCP port 5001
TCP window size: 4.00 MByte (default)
------------------------------------------------------------
[  3] local 10.10.1.2 port 52910 connected with 10.10.1.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  11.0 GBytes  9.42 Gbits/sec
```

How to find the ip address? What's the expected output?

## Install and Start DeathStarBench on Bare Metal Machines
We will use docker and docker compose to run 

```bash
# Install docker and docker compose on each machine
mkdir projects
cd projects
git clone https://github.com/delimitrou/DeathStarBench.git
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
# TODO: install docker-compse
sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Set up docker swarm
IP=`ip ad show | grep -s '10.10.' | awk '{ print $2 }'` # Local network IP
sudo docker swarm init --advertise-addr ${IP%/*}
#Login to all worker nodes and run the join command displayed by swarm init
sudo docker stack deploy --compose-file docker-compose-swarm.yml hotelreservation

# Start hotel reservation application (run on a single machine)
cd DeathStarBench/hotelReservation/
docker-compose up -d

# Show services running
sudo docker stack services hotelreservation
```

Starting it up

## Testing DeathStarBench

```bash
# Test
curl 'http://amd220.utah.cloudlab.us:5000/reservation?inDate=2015-04-19&outDate=2015-04-24&lat=nil&lon=nil&hotelId=9&customerName=Cornell_1&username=Cornell_1&password=1111111111&number=1'
curl 'http://amd220.utah.cloudlab.us:5000/user?username=Cornell_1&password=1111111111'
```

## Installing wrk2 on Client Machine

Look at docker_example.sh for prereqs
```
# Evaluate (from a client machine across Internet, but also locally works)
#sudo apt install python3-aiohttp libssl-dev libz-dev luarocks lua-socket
#sudo luarocks install luasocket
make -C DeathStarBench/hotelReservation/wrk2
./wrk2/wrk -D exp -t 10 -c 100 -d 10 -L -s ./wrk2/scripts/hotel-reservation/mixed-workload_type_1.lua http://localhost:5000 -R 10000
```

## Testing wrk2

Run the default experiment (see docker_example.sh)

What's the expected output?

## Starting VMs

Select the virtualized option in the cse453repo profile. These come
with the VM monitor pre-installed. Then use start_vms.sh script that's
pulled automatically.

## Run iperf in VMs

Run benchmark from UW client to VM

What's the expected output?

## Run DeathStarBench in VMs and Test It

Warning: Running the benchmark workload multiple times can give wrong
results. For example, the default workload has a limited date range
from which it reserves hotel beds. Once that range runs out, all
requests return an error and the benchmark will have a very high
throughput.

## Policies on Using CloudLab Resources

1. Before you start your first experiment, please read this
   [page](https://cloudlab.us/aup.php). 

2. By default, each experiment will expire in 16 hours. This is enough
   for most runs. If you run out of time, you can request an extension
   via the `Extend` button on your experiment's CloudLab profile
   page. To request an extension, you need to provide a
   reason. We are providing a boilerplate blurb for this purpose,
   here.

        TODO

   We recommend you save your data and create a new experiment
   whenever you can. If you do have a need to extend the nodes, 
   do not extend them by more than one day. **We will terminate any cluster running for more than 48 hours**.

3. If you want to change the default shell, go to `Manage Account` -> `Default Shell`
