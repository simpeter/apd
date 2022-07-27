# Lab 2: Storage

In this lab, you are going to investigate the performance impact of
storage hardware and software technologies on cloud application
performance.

## Assignment 1: Storage Hardware Performance Impact (5 pts)

Storage hardware can have a major impact on cloud application
performance. The lecture has introduced a variety of common cloud
storage hardware technologies, including the recent non-volatile
memory (NVM). NVM has the potential to dramatically accelerate cloud
applications when used as the main storage technology. It is 100x
faster than flash-based SSDs and many orders of magnitude faster than
hard disk drives. As a tradeoff, it is much more expense per byte of
storage. Nevertheless, if an application has only modest storage
requirements, NVM can provide a large performance boost, which can
either accelerate the application or be used by the cloud operator to
run more work on the same resources.

In this assignment you are going to evaluate the performance gains of
the hotel reservation application when NVM is used to store its data.
The app has a storage backend based on the MongoDB database. The data
is also sharded, by use case (room rates, hotel profiles,
reservations, geolocation, recommendations, and user login
information), leveraging one MongoDB instance for each shard. The
CloudLab servers do not provide NVM, so we are going to emulate it
using DRAM. DRAM has a similar (better) performance profile, so we
expect to see at least as good a performance boost.

You are going to mount a `tmpfs` file system for the datastore of the
MongoDB instances. `tmpfs` is a RAMdisk, so it will use the machine's
DRAM for storage (obviously, `tmpfs` is not crash-safe, but we will
ignore that for the moment). You are then going to run the `wrk2`
benchmark and compare the result to a run with the vanilla version of
the hotel reservation app that uses the default file system on SSD or
HDD (depending on what your CloudLab server supports). Repeat each run
a few times and compare the average. Quantify the performance
difference. Is it 100x and more (the performance difference of NVM to
the other storage media)? Explain the observed performance difference
by describing how the hotel reservation app uses storage for the
variety of operations that are part of the benchmark.

### Detailed Instructions

Run `cse453` cloudlab profile with `lab2` parameter.

`start_docker.sh`.

Measure maximum throughput with default deployment.

Now, `start_tmpfs.sh`.

You will compile and run a special version of the hotel reservation
app that enables synchronous journaling. The vanilla version uses
asynchronous journaling, which is not durable under all failure
situations, but this version is. The reason for using asynchronous
journaling in the vanilla version is that SSDs and HDDs are often not
fast enough to provide good performance with synchronous
journaling. Hence, another way to view the performance benefit of NVM
is that the added performance can be used to provide extra features
for free.

Deploy `hotelreservation-tmpfs.yml` and remeasure. Perf difference?

To help explain how hotel reservation app's storage system works, read
the Go code and look at jaeger traces. You also have a number of knobs
to experiment with the app. For example, you can change the mix of
workload operations. You can try each operation individually. Which
one is most impacted by the storage system? Why?

## Assignment 2: Storage Software Performance Impact (10 pts)

Software can often have an even larger impact on application
performance than hardware. The class mentioned a variety of ways that
storage stacks can be optimized for the underlying
technology. Modifying file systems is one option cloud operators have
to transparently accelerate cloud applications. Of course, operators
can go even further and provide entire database backends that are
hyper-optimized for their cloud infrastructure. The efficiency gains
can be passed on to the user by offering the backend for a cheaper
price, but at the same performance as a vanilla cloud offering, such
as MongoDB. Or they can offer it at a higher price, but with better
performance.

In this assignment, you will develop a rudimentary database backend
that replaces MongoDB for the hotel reservation app.

### Detailed Instructions

To simplify your job, we have provided a simple network frontend to
your database application that speaks enough of the MongoDB network
API to interface properly with the hotel reservation app.

Use `start_tmpfs.sh` to put other MongoDB instances on tmpfs.

To better see the difference in performance, you are going to edit
`DeathStarBench/hotelReservation/services/reservation/server.go`, line
214, to execute the loop 100 times, instead of once. Run `docker
compose -f hotelreservation-nvmdb.yml up -d --build -t1` to build the
new hotel reservation app.

Use `bench_reserve.sh` on the client to measure. 

<!-- Put a different file system in and measure performance. Why is the -->
<!-- perf different? -->
