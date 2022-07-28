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
performance than hardware. For example, the class discusses a variety
of ways that storage stacks can be optimized for the underlying
technology. In particular, modifying file systems is one option cloud
operators have to transparently accelerate cloud
applications. Operators can go even further and provide entire
database backends that are hyper-optimized for their cloud
infrastructure and the applications running on top. The efficiency
gains can be passed on to the user by offering the backend for a
cheaper price, but at the same performance as a vanilla cloud
offering, such as MongoDB. Or we can offer it at a higher price, but
with better performance and/or more features.

In this assignment, you will develop a rudimentary, but optimized
database backend that replaces MongoDB for the hotel reservation
app. The underlying storage technology will be NVM. The hotel
reservation app uses the database like a key-value store (requesting
and writing singular values by key). Hence, the API that you will
provide shall support a `find` operation with three operands
(`hotelId`, `inDate`, and `outDate`) and it should return whether the
hotel with ID `hotelId` is already booked during the provided `inDate`
and `outDate`. The API shall also support an `insert` operation with
five arguments (`hotelId`, `inDate`, `outDate`, `customerName`, and
`number` of guests).

The hotel reservation app operates on singular nights in the database,
so you can assume that `outDate` is always `inDate` + 1 day. If the
user reserves more than one night, the app will issue `find` and
`insert` operations for each night of the stay. For `find`, your
database shall return `FOUND` or `NOTFOUND`, depending on whether the
hotel is booked that night. For `insert`, your database shall record
all provided operands and return `OK` when the records have been
written to storage. For simplicity, you can assume that each hotel has
only one room, that you will not run out of NVM storage space, and
that there are no device errors. You also do not have to worry about
concurrency or multi-threading. Finally, you do not have to worry
about crash consistency **yet**. We will change this in the next
assignment, so you might want to start thinking about a design that
can support crash consistency.

You should evaluate the performance of the hotel reservation app with
your database and compare it to the performance of the app with
MongoDB. You should investigate reservation latency, but also draw a
latency over throughput graph for reservations via the `wrk2`
benchmark tool. See the detailed instructions for further information.

### Detailed Instructions

To simplify your job, we have provided a simple frontend to your
database application that speaks enough of the MongoDB network API to
interface properly with the hotel reservation app. The frontend is
called NVMdb and is located in `/local/repository/nvmdb`. The frontend
interacts with the database backend that you will write via standard
input and output. The shell script
`/local/repository/nvmdb/start_nvmdb.sh` demonstrates how this works
and how to implement the API. You can implement your database backend
in any programming language and then uncomment the `exec` line in the
shell script to attach your backend's standard input and output to the
frontend.

Run `docker compose -f hotelreservation-nvmdb.yml up -d --build -t1`
to build the hotel reservation app with your NVMdb database backend.

If you run into trouble with the database frontend, you can comment
out the `-O2 -DNOLOG` parameters in `/local/repository/nvmdb/Makefile`
to see additional debugging output, which you can display with `sudo
docker logs hotel_reserv_reservation_mongo -f`.

For a fair comparison with MongoDB, you should again put MongoDB on
NVM, via `start_tmpfs.sh`. For NVMdb, the other MongoDB instances
should also run on NVM (via the same script).

To better see the difference in performance, you can edit
`DeathStarBench/hotelReservation/services/reservation/server.go`, line
214, to execute each insert operation 100 times, instead of once.

Use `bench_reserve.sh` on the client to measure reservation
latency. Use `wrk -D exp -t 10 -c 100 -d 10 -L -s
/local/repository/reserve_only.lua http://server0:5000 -R 1000` with
appropriate parameters to `-t`, `-c`, and `-R`, to measure reservation
latency and throughput.

### Bonus: Limited storage space (3 pts)

Add support for limited storage space and returning `FAIL` in response
to a failed `insert` operation to the database. In addition to adding
this support to your database backend, it will also require you to
modify the NVMdb frontend to return the appropriate error response to
the hotel reservation frontend.

### Bonus: Multi-threading (5 pts)

To scale to further clients, we have the option to shard the dataset
and run multiple instances of NVMdb. However, we can also scale up, by
supporting multiple threads of database execution. You will implement
the latter option in this bonus assignment.

In addition to adding multi-threading support to your backend, you
will likely also have to modify the interface to the frontend to
support more than just standard input and output file
descriptors. Otherwise, the API will quickly limit the performance
benefits of adding further backend threads.

<!-- Put a different file system in and measure performance. Why is the -->
<!-- perf different? -->
