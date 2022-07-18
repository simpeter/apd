# Lab 1: Virtualization

The cloud runtime environment has a major impact on the experience
that developers and users will receive. How server hardware is
virtualized, for example, impacts application performance. In this
lab, you will evaluate some of the virtualization and containerization
solutions presented in the lecture.

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
of service latency. Anything above this makes users increasingly
likely to assume that there is something wrong with the provided
service and go elsewhere. Hence, this number is typically used as an
upper bound on user quality of service tolerance.

We are going to ignore the developer goals (simplicity and elasticity)
for now. The DeathStarBench applications are developed as
microservices, a development model that provides a great degree of
simplicity and elasticity.

## Assessing Service Performance

We typically assess performance by evaluating service latency provided
under a variety of load conditions. System load has a major effect on
the provided service. If a service is overloaded, it is going to
provide terrible service---only the few lucky users that got through
will get an answer and even that answer is going to take a while, as
other answers will be processed first. Lower load conditions are going
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

## Assignment 1: Performance (10 pts)

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

Instantiate the `cse453repo` profile with 3 machines in the
appropriate mode for each experiment and deploy DeathStarBench on all
machines, running the hotel reservation workload. Then, attach your
client and start measuring with the default profile for hotel
reservation using the `wrk2` client. Make sure that you gather enough
data points to clearly show the latency-load curve that is going to
result as you drive load up towards overload. Also, make sure you
configure `wrk2` to generate enough load. Otherwise, your curve will
fail to materialize (it will not look like a curve). Remember that we
are interested in 99%-ile latency, not average.

Once you have all four curves, you should interpret them. What load
can each setup handle before 99%-ile latencies become untenable
(larger than 500ms)? Which technology provides the best performance?
Why does each technology provide each level of performance? What are
the characteristics of each curve? Where is the knee point and what
does it signify?

### Detailed Instructions

We have provided shell scripts in `/local/repository` that will help
you setup each virtualization mode. We explain how to run them,
here. For each of the configurations, make sure that the previous
instance of DeathStarBench is not running anymore. Otherwise, you can
performance crosstalk (lots of noise).

1. See `docker_example.sh` for instructions on how to install docker
   and DeathStarBench, as well as how to configure a swarm and run the
   hotel reservation benchmark on it.
   
2. Run `start_vms.sh` to setup VMs and a virtual network on each
   CloudLab machine.

3. 

4. Run `start_vms.sh` with parameter `trap+emulate`.

### Bonus: Error margin (2 pts)

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

Re-run each of the above experiments at least 3 times to get at least
4 measurements for each data point. Then, re-plot the graphs with
error bars attached. You can choose an error bar style that you think
is most appropriate for this experiment. Styles range from presenting
average and [standard
deviation](https://en.wikipedia.org/wiki/Standard_deviation), to
median and percentiles, as well as median, minimum, and maximum.

When presenting your graphs, explain why you selected this style of
error bars. Also, interpret the results. What level of noise is
visible and why might it be there. Is the level of noise acceptable?
