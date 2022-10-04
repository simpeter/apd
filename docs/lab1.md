# Lab 1: Virtualization

The cloud runtime environment has a major impact on the experience
that developers and users will receive. How server hardware is
virtualized, for example, impacts application performance. In this
lab, you will evaluate some of the virtualization and containerization
solutions presented in the lecture.

Note: Please use this [doc](https://docs.google.com/document/d/1uS6lgpEdUd0KnEcYGbrs1YdBTV_z-TQjsJ1XSgA1EJQ/edit?usp=sharing) as a template when submitting your results. (You can make a copy and add your answers). For each assignment, report the type of node you get from Cloudlab.

## Defining Performance

Three parties are involved, with different performance goals, in every
cloud application: developers, users, and cloud operators. Cloud
developers want a simple development experience for their applications
that allows them to elastically increase application service when
there is demand. Users, on the other hand, want quality service. Since
most cloud applications are interactive, one very important quality
metric is the service latency of the cloud application that the user
connects to via the Internet. Finally, as cloud operators, we want
efficiency, as this drives down operating cost. All of these demands
are embodied in the performance of a service.

Studies have shown that users can tolerate about half a second (500ms)
of service latency. (service latency means, for example, the time when 
the user clicks a website link to when the resulting page is fully loaded). 
Anything above this makes users increasingly likely to assume that there is 
something wrong with the provided service and go elsewhere. Hence, this number 
is typically used as an upper bound on user quality of service tolerance.

We are going to ignore the developer goals (simplicity and elasticity)
for now. The DeathStarBench applications are developed as
microservices, a development model that provides a great degree of
simplicity and elasticity.

## Assessing Service Performance

We typically assess performance by evaluating service latency provided
under a variety of load conditions. System load has a major effect on
the provided service. If a service is overloaded (i.e., the service 
approaches or exceeds its capacity), it is going to provide terrible 
service---a large portion of users' request is going to take a while,
as other answers will be processed first. Lower load conditions are going
to provide a spread of better service latencies. To see how a system
performs under a variety of load conditions, we draw latency-load
curves. For each load level (presented on the x axis), we assess
service latency (presented on the y axis).

For cloud operators, it is typically not enough to keep average
service latencies below 500ms. Averages ignore the distribution of
service experiences. Thus, they could preclude a potentially large
fraction of users from acceptable service. Instead, we care about the
largest fraction of users, knowing that some users are bound to have
bad performance for reasons outside of our control (e.g., due to a bad
Internet connection). Hence, we assess a sufficiently large percentile
of users. This is typically 99% of users or more. The actual number
depends on our assessment of what is in our control and what is
not. In our project, we will care about 99% of users.

## Assignment 1: Performance (5 pts)

Assume that we have a number of virtualization technologies at our
disposal:

1. Bare metal servers running containers
2. Virtual machines (VMs) running with hardware virtualization and a
   software IO path
3. VMs running with hardware virtualization and hardware device
   passthrough
4. VMs running with trap and emulate virtualization with software IO

You will evaluate each of these technologies for their provided
application performance. To do so, you will run the hotel reservation
DeathStarBench application using each of these technologies and
evaluate 99 percentile service latencies under a variety of load
points. Draw the latency-load curve for each technology.

Once you have all four curves, you should interpret them. What load
can each setup handle before 99%-ile latencies become untenable
(larger than 500ms)? Which technology provides the best performance?
Why does each technology provide each level of performance? What are
the characteristics of each curve? Where is the knee point and what
does it signify?

### Detailed Instructions

(Note: Please use the Utah cluster for this assignment.)
Instantiate the `cse453repo` profile with 3 servers in `passthru`
mode for the experiment and deploy DeathStarBench on all machines, 
running the hotel reservation workload. Check the [`resource availability`](https://www.cloudlab.us/resinfo.php)
page first and select the node type with enough available machines (minimum 4). 
These machine types are known to work: Utah: c6525-25g, c6525-100g; APT: r320; Wisconin: c220g2, c220g1.

Then, attach your client and
start measuring with the default profile for hotel reservation using
the `wrk2` client. Make sure that you gather enough data points to
clearly show the latency-load curve that is going to result as you
drive load up towards overload. Also, make sure you configure `wrk2`
to generate enough load and run for enough time (>20s). Otherwise, your curve will fail to materialize 
(it will not look like a curve). Remember that we are interested in 99%-ile latency, not average.

We have provided shell scripts in `/local/repository` that will help
you setup each virtualization mode. We explain how to run them,
here. For each of the configurations, make sure that the previous
instance of DeathStarBench is not running anymore. Otherwise, you can
get performance crosstalk (lots of noise).

1. Run `./start_docker.sh` to install and start docker. Then, follow
   instructions in [Lab0](https://gitlab.cs.washington.edu/syslab/cse453-cloud-project/-/blob/main/docs/lab0.md#install-and-start-deathstarbench-on-bare-metal-machines) 
   to setup the benchmark.
   
2. Run `start_vms.sh` to setup VMs and a virtual network on each
   CloudLab machine. Then, follow instructions in [Lab0](https://gitlab.cs.washington.edu/syslab/cse453-cloud-project/-/blob/main/docs/lab0.md#run-deathstarbench-in-vms-and-test-it) 
   to setup the benchmark within those VMs.

3. Run `start_vms_passthru.sh` to setup VMs using each bare metal
   machine's physical network interface that is connected to the
   internal network (`10.10.1.x`). Then, follow instructions in [Lab0](https://gitlab.cs.washington.edu/syslab/cse453-cloud-project/-/blob/main/docs/lab0.md#run-deathstarbench-in-vms-and-test-it) 
   to setup the benchmark within those VMs.

4. Run `start_vms.sh` with parameter `--tcg`. 
   Then, follow instructions in [Lab0](https://gitlab.cs.washington.edu/syslab/cse453-cloud-project/-/blob/main/docs/lab0.md#run-deathstarbench-in-vms-and-test-it) 
   to setup the benchmark within those VMs. (Note: it may take a while to 
   start the DeathStarBench in this mode. Make sure all containers are running before starting your 
   measurement.)
   
For each setup, run `wrk2` from your client machine, using the
workload configuration file provided in the hotel reservation
benchmark. Specify a load rate and record the measured 99-percentile
latency and throughput. Pay close attention to any errors in `wrk2`'s
output. Also, make sure that you specify enough threads and
connections to be able to provide the given load. Please record the
specified offered rate and what throughput was reported by
`wrk2`. Doing so will help you determine whether you are indeed
configuring `wrk2` properly to offer enough load. 
<!-- Also, report the offered load for each data point to us. -->

No experiment setup is perfect. In the real world, there are always
factors outside of our control. From the already mentioned bad
Internet connection down to the temperature that day affecting server
performance, each impact the experiment outcome. Hence, re-running the
experiment is going to produce slightly different results. The
difference in results is generally described as *noise* or *error*. We
strive to create experimental environments where the noise is
minimized, leaving mostly the true result, or *signal*.

One way to control for noise is to run the experiment multiple times
and to calculate average data points from each run. However, while
this smoothes results, it does not give us an understanding as to the
extent of the noise. As experimenters, we should quantify the noise to
show that our experiment is indeed measuring the signal and not
presenting mostly noise. To do so, we attach *error bars* to each data
point.

Run the experiment at least 4 times. Then, plot the graphs with
error bars attached. You can choose an error bar style that you think
is most appropriate for this experiment. Styles range from presenting
average and [standard
deviation](https://en.wikipedia.org/wiki/Standard_deviation), to
median and percentiles, as well as median, minimum, and maximum.

When presenting your graphs, explain why you selected this style of
error bars. Also, interpret the results. What level of noise is
visible and why might it be there. Is the level of noise acceptable?

### Bonus: Device Pass-through for Containers? (2 pts)

Would device pass-through work with containers? If so, how would it
work? If not, why not?

## Assignment 2: Performance Isolation (5 pts)

Of course, tenants do not just run applications on cloud hosts in
isolation. The common case is that machines are shared among multiple
tenants, each running their application. You are going to investigate
this scenario in this assignment.

The performance goals are identical to assignment 1 (we want
acceptable 99%-ile latency (i.e. 500ms), while maximimzing load). Let's first look
at the different virtualization technologies. In this case, we are
going to ignore device passthrough, as it requires hardware IO
virtualization to enable multiple tenants to share devices, which is
not available on all CloudLab machines. We are also going to ignore
trap+emulate virtualization, as it is too heavy-weight. Two
configurations remain:

1. Bare metal servers running containers

2. VMs running with hardware virtualization and a software IO path

You are going to run two instances of the hotel reservation
application simultaneously. In the VM case, this means creating two
separate VMs per CloudLab machine, so each tenant can run in their own
VM.

You will again evaluate each of these technologies for their provided
application performance. To do so, you will run the hotel reservation
DeathStarBench application using each of these technologies and
evaluate 99 percentile service latencies under a variety of load
points for both tenants. Draw the latency-load curve for each
technology and tenant, keeping both tenants' load identical.

In a second benchmark, you will evaluate the technologies for
disparate tenant loads. The benchmark is the same, but you keep one
tenant at the load that you determined to be the knee-point of the
latency-load curve in assignment 1, when the tenant was running
alone. Keep that load running in the background (just set a long
duration). Then, set a load of 1/3 the load of the first tenat requests/s 
for the second tenant and investigate the 99%-ile latency of the first tenat.

<!-- For the second benchmark, you should also compare these latencies with
a scenario where multiple clients connect to the same tenant's
service, without there being a second tenant. How do the latencies
compare?  -->

### Detailed Instructions

Instantiate the `cse453repo` profile with 3 machines in `default` mode
(you can keep using the experiment you created for assignment 1 if they are not expired.). 

1. (for bare mental servers) Run `./start_docker.sh` to install and start docker. Deploy hotel reservation on all machines as in assignment 1. Then, run `sudo docker stack deploy --compose-file hotelreservation2.yml hotelreservation2` to start the second tenant. 

2. (For VMs) Run `start_vms.sh` to setup VMs and a virtual network on each CloudLab machine. Deploy hotel reservation on all VMs as in assignment 1. Then, run './start_vms2.sh` to set up the second VM on each machine. Deploy the hotel reservation on second VMs (use the same set of commands by replace `vm1` with `vm4`.) 

Depending on the benchmark, different configurations are useful:

1. Start both clients at roughly the same time, using two logins to
   your client machine. 

2. Start the background client, running for a long time. Then, in
   another terminal, start the foreground client.

Note: 
1. when measuring the second tenat, you need to change the port number in `wrk2` command from `http://server0:5000` to `http://server0:5001`.
2. If you use different node type for assignment 1 and assignment 2, it is likely the performance changes due to hardware. You need to re-run the experiment to determine the new knee point.

### Bonus: Latency over Time (2 pts)

Is the background workload affected by the foreground tenant?
Investigate request latencies over time for the background workload,
as you start and stop the foreground tenant. You can draw these
background-tenant latencies over time on a graph. The `-P` option of
the `wrk2` program will store the latency of each request in the directory
you run it. 

## Assignment 3: Consolidation (5 pts)

The cloud operator's goal is to minimize cost. Currently, the hotel
reservation application requires 3 servers. Can we reduce this number?
Start the experiment with just a single server and measure latency
over load.

How does the measured knee-point of the curve compare to the one
measured in assignment 1? Calculate the ratio of the knee-point
throughputs between the two cases and compare it to the ratio of
machines used. Is the comparison favorable? Stipulate what might
impact whether the comparison is favorable or not.

### Detailed Instructions
You only need to run the experiment for bare mental servers running containers.
First, start the experiment with only one server. Then, run the workload as described
in assignment 1 using the same set of loads you used in assignment 1. Finally,
compare the load to latency curve (pay closer attention to the knee-point).

Note: 
1. If you use different node type for assignment 1 and assignment 3, it is likely the performance changes due to hardware. You need to re-run the experiment to determine the new knee point. 
2. You can reduce the number of servers by 1) restart an experiment with the same node type or 2) remove server 2 and 3 from the `list view` tab.
