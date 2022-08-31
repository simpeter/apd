# Lab 0: Setting Up

This lab is ungraded and intended to get you set up with the project's
infrastructure. Please go through all the steps, make sure that each
one works, that you have access to everything described here, and that
you **send us a link to your clone of this repository**.

## Form a group of 2 or 3 students and let us know who is in it

All projects of this course will be performed in groups of 2-3 students. Please 
declare your group's membership via TODO and by TODO. 


## Create a CloudLab Account ([Link](https://www.cloudlab.us/signup.php?pid=cse453)) and join the your project group

The majority of the project runs on CloudLab, for which you need an
account. To create an account, please use your UW email and use UW
NetID as the username. Upload your SSH public key file as you use SSH to 
access the nodes in CloudLab. Click on `Submit
Request`. We will approve your request within 24 hours. If you already
have a CloudLab account, simply request to join the `cse453` project.

Once you created an account and declared your group's membership, we will randomly assign 
one of the group member as the "group leader" and the leader can add their teammate(s). 
The group should then use that subgroup in CloudLab going forward. 

## Clone this repository and send us a link

TODO: Anirudh to describe: Students should clone the main repo and
then point to it in CloudLab. Send us a link. Will use this to submit
results.

## Start an Experiment

TODO: Change this to point to students' repo. Explain how to setup web
hook for auto-update of CloudLab.

To start a new experiment, follow these steps:

1. Select a profile: go to your CloudLab dashboard's [`Project
   Profile`](https://www.cloudlab.us/user-dashboard.php#projectprofiles)
   page. Go to `cse453repo` profile and click `instantiate` button.
2. Parameterize: select the lab you are working on. For lab 4, you can
   configure the number of server machines and the number of client
   machines under advanced options. Click on `Next` to move to the
   next page.
3. Finalize: Name your experiment, select your group name as the Group, instead of cse453, and 
   choose the cluster you want to start your
   experiment. If you are curious about the hardware CloudLab
   provides, you can refer to this
   [page](http://docs.cloudlab.us/hardware.html). In case your request
   cannot be fulfilled due to resources being unavailable, we
   recommend checking the [resource
   availability](https://www.cloudlab.us/resinfo.php) page to make
   sure you select a cluster with enough machines. Each lab
   automatically constrains the hardware choice to machines that have
   the features necessary to complete it, so you cannot make a wrong
   choice here. 
4. Schedule: Optionally, select when you would like to start this
   experiment. If you want to start your experiment immediately, skip
   this step and click `Finish`.

It may take a few mintues for the experiment to start. Once the
experiment is created, you should be able to view the information
under the
[`Experiments`](https://www.cloudlab.us/user-dashboard.php#experiments)
page.

Note: Each lab will create one or more client machines (named
`client[0-9]`) and one or more server machines (named
`server[0-9]`). You will deploy the applications on server machines
and run load generators on the client machines.

## Log into Experiment Machines

Click `List View`, and you will find SSH commands to access each
node. You can start logging in once all machines in the experiment are
`ready` and their `Startup` column says `Finished`. On the same tab,
you can also reboot/reload your nodes if something goes wrong. You can
also `Terminate` the entire experiment and start over from scratch.

Note that experiments automatically terminate after 16 hours (unless
you picked a different duration when you scheduled your
experiment). When this happens, all the data stored on the experiment
machines is deleted. To retain data across experiments and share it
with your team mates, you can push all important data to your cloned
repository.

### Setting up the SSH Authentication Agent

The following sections and labs will require you to run many
scripts. The scripts will setup various software packages across the
machines in your CloudLab experiment. To do so, they will log into
each machine using SSH. For this to work seamlessly, you need to setup
an SSH authentication agent on your local work computer and make sure
it is forwarded to the CloudLab machine that you have logged
into. Depending on which OS and SSH package you use, the process will
be different. We provide quick instructions for popular combinations
in this section.

**Mac OS.** Follow steps in this [link](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent)

**Linux and OpenSSH.** If it's not already running, you can start an
SSH authentication agent by typing `ssh-agent` into any terminal. This
will output a few shell commands. For example:

```console
simon@bigbox:~$ ssh-agent
SSH_AUTH_SOCK=/tmp/ssh-3NZIVp0q7Itp/agent.875946; export SSH_AUTH_SOCK;
SSH_AGENT_PID=875947; export SSH_AGENT_PID;
echo Agent pid 875947;
```

You should copy&paste these commands and run them in your
terminal. This ensures that future runs of SSH within the terminal are
able to find it. There are more permanent ways to setup `ssh-agent`
across all of your terminals. Please refer to your OS documentation on
how to do that.

Once `ssh-agent` is set up, you should then run `ssh-add` to add your
SSH keys to your agent. This might require you to enter a few
passwords. Once done, you can then run `ssh -A` to login to any of the
CloudLab hosts and `ssh` will forward the agent connection to those
hosts. This means that you and the scripts you'll run can SSH into
other CloudLab hosts without you needing to re-enter SSH key
passwords.

## Run iperf on bare metal servers

[iperf3](https://iperf.fr/iperf-doc.php) is a tool for network
throughput measurements between two hosts (a client that generates
traffic and a server that receives traffic). You'll use iperf to
measure the bandwidth between nodes in your experiment to make sure
everything is working okay. <br />

On the server side:
```console
user@server0:~$ iperf3 -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size:  128 KByte (default)
------------------------------------------------------------
[  4] local 10.10.1.1 port 5001 connected with 10.10.1.4 port 49842
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec  11.0 GBytes  9.40 Gbits/sec
[  4]  0.0-10.0 sec  11.0 GBytes  9.41 Gbits/sec
```

Then, log in one of the client machines:
```console
user@client0:~$ iperf3 -c server0
------------------------------------------------------------
Client connecting to 10.10.1.1, TCP port 5001
TCP window size: 3.79 MByte (default)
------------------------------------------------------------
[  3] local 10.10.1.4 port 49842 connected with 10.10.1.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  11.0 GBytes  9.41 Gbits/sec
```

The server and client will start printing measurement results around
the same time, once both are running. You should be able to get a
similar result.

## Install and Start DeathStarBench on Bare Metal Machines

SSH into the `server0` node.

```bash
# This directory always exists. It holds a checked-out cse453 repository.
cd /local/repository

# This script will set up docker and docker swarm. It will output what
# it is doing. Follow the instructions in the output to add other servers as workers (via `docker swarm join`).
sudo ./start_docker.sh

# Deploy the hotel reservation application
sudo docker stack deploy --compose-file hotelreservation.yml hotelreservation

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

<!-- ## Installing wrk2 on Client Machine

Many assignments will use `wrk2`, a HTTP benchmarking tool, as the load generator. You will install wrk2 on client machines in this step.

```bash
# Install wrk2
cd /local/repository
./start_client.sh
``` -->
## Running wrk2 on Client Machine

Many assignments will use `wrk2`, a HTTP benchmarking tool, as the load generator. `wrk2` will be automatically built on machine initialization. Run it with the following command:
```console
xfzhu@client0:~$ cd /local/repository/DeathStarBench/hotelReservation
user@client0:/local/repository/DeathStarBench/hotelReservation$ ./wrk2/wrk -D exp -t 10 -c 100 -d 10 -s ./wrk2/scripts/hotel-reservation/mixed-workload_type_1.lua http://server0:5000 -R 2000 -L
Running 10s test @ http://server0:5000
  10 threads and 100 connections
  Thread calibration: mean lat.: 3.821ms, rate sampling interval: 15ms
  Thread calibration: mean lat.: 3.833ms, rate sampling interval: 15ms
  Thread calibration: mean lat.: 3.870ms, rate sampling interval: 16ms
  Thread Stats   Avg      Stdev     99%   +/- Stdev
    Latency     3.81ms    2.74ms  12.71ms   83.30%
    Req/Sec       -nan      -nan   0.00      0.00%
  Latency Distribution (HdrHistogram - Recorded Latency)
 50.000%    2.63ms
 75.000%    5.24ms
 90.000%    7.79ms
 99.000%   12.71ms
 99.900%   16.88ms
 99.990%   21.15ms
 99.999%   28.03ms
100.000%   28.03ms
----------------------------------------------------------
  19769 requests in 10.01s, 8.15MB read
Requests/sec:   1975.06
Transfer/sec:    834.26KB
```

Feel free to run `./wrk2/wrk` to learn the command line options of wrk. Once you finish testing, stop and remove the hotel reservation application via `sudo docker stack rm hotelreservation`.

## Starting VMs

In lab1, you will explore different virtualization technologies. Let's
test that everything works for this. Run the following script to set
up VMs on `server0`.

```bash
cd /local/repository
./start_vms.sh 
```

## Run iperf in VMs

Run the iperf3 client on a client machine and the iperf3 server inside `vm1`.

On the server side:

```console
user@server0:~$ VM1_IP=$(sudo lxc exec vm1 -- sh -c "ifconfig | grep '240' " | awk '{ print $2}')
user@server0:~$ LOCAL_IP=$(ifconfig | grep -s '10.10.' | awk '{ print $2 }')
user@server0:~$ sudo lxc network forward create lxdfan0 $LOCAL_IP target_address=$VM1_IP
# NOTE: Do not close the SSH session after the last command or you'll
# lose connectivity to the server
user@server0:~$ sudo lxc exec vm1 -- bash
root@vm1:~# iperf3 -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size:  128 KByte (default)
------------------------------------------------------------
[  4] local 240.1.0.109 port 5001 connected with 10.10.1.4 port 50008
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec  10.7 GBytes  9.16 Gbits/sec
^C
root@vm1:~# exit
user@server0:~$ sudo lxc network forward delete lxdfan0 10.10.1.1
```

On the client side:

```console
user@client0:~$ iperf3 -c 10.10.1.1
------------------------------------------------------------
Client connecting to 10.10.1.1, TCP port 5001
TCP window size:  374 KByte (default)
------------------------------------------------------------
[  3] local 10.10.1.4 port 50008 connected with 10.10.1.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  10.7 GBytes  9.16 Gbits/sec
```

## Run DeathStarBench in VMs and Test It

Similar to testing DeathStarBench in bare metal servers, on `server0`, run:

```console
VM1_IP=$(sudo lxc exec vm1 -- sh -c "ifconfig | grep '240' " | awk '{ print $2}')
LOCAL_IP=$(ifconfig | grep -s '10.10.' | awk '{ print $2 }')
sudo lxc network forward create lxdfan0 $LOCAL_IP target_address=$VM1_IP
# NOTE: Do not close the SSH session after the last command or you'll
# lose connectivity to the server

sudo lxc exec vm1 -- docker stack deploy --compose-file hotelreservation.yml hotelreservation
```

Then, run curl on one of the client machines (make sure all services
are running via `sudo lxc exec vm1 -- docker service ls`):

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

        I am still running experiments. Please grant me a short extension. 

   We recommend you save your data and create a new experiment
   whenever you can. If you do have a need to extend the nodes, do not
   extend them by more than one day. **We will terminate any cluster
   running for more than 48 hours**.

3. If you want to change the default shell, go to `Manage Account` -> `Default Shell`
