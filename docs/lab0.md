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

To start a new experiment, follow these steps:

1. Select a profile: go to your CloudLab dashboard's  [`Project Profile`](https://www.cloudlab.us/user-dashboard.php#projectprofiles) page. Go to `cse453repo` profile and click `instantiate` button. 
2. Parameterize: select the lab you are working on. Optionally, you can configure the number of server machines (maximum 10) and the number of client machines (maximum 3). Click on `Next` to move to the next page.
3. Finalize: Name and choose the cluster you want to start your experiment. For more information on the hardware CloudLab provides, please refer to this [page](http://docs.cloudlab.us/hardware.html). We also recommend checking the [resource availability](https://www.cloudlab.us/resinfo.php) page to make sure you select a cluster with enough machines.
4. Schedule: Optionally, select when you would like to start this experiment. If you want to start your experiment immediately, skip this step and click `Finish`.

It may take a few mintues for the experiment to start. Once the experiment is created, you should be able to view the
information under the [`Experiments`](https://www.cloudlab.us/user-dashboard.php#experiments) page.

Note: For each lab, you will create one or more client machines and one or more server machines. You will deploy the applications on server machines and run the load generator on the client machines.

## Log into Experiment Machines

Once the experiment is ready (this can take a few minutes), click
`List View`, and you will find SSH commands to access each node. On the
same tab, you can also reboot/reload your nodes if something goes wrong.

## Run iperf on bare mental servers

[iperf](https://iperf.fr/iperf-doc.php) is a tool for network throughput measurements between two hosts (a client that generates traffic and a server that receives traffic). You'll use iperf to measure the bandwidth between nodes in your experiment. <br />
Step 1: Log in and find the ip address of one of the server machines.
```console
user@server0:~$ ifconfig | grep -s '10.10.' | awk '{ print $2 }'
10.10.1.1
```

On the server side:
```console
user@server0:~$ iperf -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size:  128 KByte (default)
------------------------------------------------------------
[  4] local 10.10.1.1 port 5001 connected with 10.10.1.4 port 49842
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec  11.0 GBytes  9.40 Gbits/sec
[  4]  0.0-10.0 sec  11.0 GBytes  9.41 Gbits/sec
```
Step 2: Log in one of the client machines:
```console
user@client0:~$ iperf -c 10.10.1.1
------------------------------------------------------------
Client connecting to 10.10.1.1, TCP port 5001
TCP window size: 3.79 MByte (default)
------------------------------------------------------------
[  3] local 10.10.1.4 port 49842 connected with 10.10.1.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  11.0 GBytes  9.41 Gbits/sec
```

You should be able to get a similar result. 

## Install and Start DeathStarBench on Bare Metal Machines
ssh into the `server0` node.

```bash
git clone --recurse-submodules https://gitlab.cs.washington.edu/syslab/cse453-cloud-project.git
cd cse453-cloud-project

# This script will set up docker and docker swarm. Follow the instructions in the output to add other servers as workers (via `docker swarm join`).
sudo bash start_docker.sh

# Deploy the hotel reservation applicaion
cd DeathStarBench/hotelReservation
sudo docker compose up -d --build
sudo docker compose -f docker-compose-localmounts.yml up -d --build
sudo docker compose -f hotelreservation-nvmdb.yml up -d --build

# Check the status of deployment
sudo docker service ls
```
Make sure all services are running before you move to the next section.

## Testing DeathStarBench using curl
Once all services are running, ssh into one of the client machines. 
```console
user@client0:~$ curl 'http://server0:5000/reservation?inDate=2015-04-19&outDate=2015-04-24&lat=nil&lon=nil&hotelId=9&customerName=Cornell_1&username=Cornell_1&password=1111111111&number=1'
{"message":"Reserve successfully!"}
user@client0:~$ curl 'http://server0:5000/user?username=Cornell_1&password=1111111111'
{"message":"Login successfully!"}
```
You should be able to get the same result.

## Installing wrk2 on Client Machine
We will use wrk2, a HTTP benchmarking tool, as the load generator. You will install wrk2 on client machines in this step.
```bash
# Install wrk2
cd cse453-cloud-project
sudo bash start_client.sh
```

## Testing wrk2 on Client Machine
Once wrk2 is installed, you can test it with the following command.
```console
user@client0:~/cse453-cloud-project/DeathStarBench/hotelReservation$ ./wrk2/wrk -D exp -t 10 -c 100 -d 10 -s ./wrk2/scripts/hotel-reservation/mixed-workload_type_1.lua http://server0:5000 -R 10000
Running 10s test @ http://server0:5000
  10 threads and 100 connections
  Thread Stats   Avg      Stdev     99%   +/- Stdev
    Latency     2.29s     1.32s    4.76s    58.85%
    Req/Sec       -nan      -nan   0.00      0.00%
  54504 requests in 9.99s, 22.50MB read
Requests/sec:   5453.90
Transfer/sec:      2.25MB
```

## Starting VMs

In lab1, you will explore different virtualization technologies. Run the following script to set up VMs on each server.
```bash
bash start_vms.sh 
```

## Run iperf in VMs

Run the iperf client on client machines and the iperf server inside a VM. 

On the server side:
```console
xfzhu@server0:~$ sudo lxc exec vm1 -- bash
root@vm1:~# iperf -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size:  128 KByte (default)
------------------------------------------------------------
[  4] local 240.1.0.109 port 5001 connected with 10.10.1.4 port 50008
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec  10.7 GBytes  9.16 Gbits/sec
^Croot@vm1:~#
```

On the client side:
```console
user@client0:~$ iperf -c 10.10.1.1
------------------------------------------------------------
Client connecting to 10.10.1.1, TCP port 5001
TCP window size:  374 KByte (default)
------------------------------------------------------------
[  3] local 10.10.1.4 port 50008 connected with 10.10.1.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  10.7 GBytes  9.16 Gbits/sec
```

## Run DeathStarBench in VMs and Test It

Similar to testing DeathStarBench in bare mental servers, run curl on one of the client machines:

```console
user@client0:~$ curl 'http://server0:5000/reservation?inDate=2015-04-19&outDate=2015-04-24&lat=nil&lon=nil&hotelId=9&customerName=Cornell_1&username=Cornell_1&password=1111111111&number=1'
{"message":"Reserve successfully!"}
user@client0:~$ curl 'http://server0:5000/user?username=Cornell_1&password=1111111111'
{"message":"Login successfully!"}
```

<!-- Warning: Running the benchmark workload multiple times can give wrong
results. For example, the default workload has a limited date range
from which it reserves hotel beds. Once that range runs out, all
requests return an error and the benchmark will have a very high
throughput. -->

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
