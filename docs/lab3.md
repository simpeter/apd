# Lab 3: Fail-over and Availability

## Assignment 1: Crash Consistency (10 pts)

You now have to ensure that your database is providing strong crash
consistency. This means that the process or machine should be allowed
to crash at any moment and, when restarted, your database should be
able to restore all of its data to the most recently written and
acknowledged point. To help you with the design, we will elaborate on
crash consistency in this section.

Crash consistency is a form of database consistency that extends
across crashes of the database and its surrounding environment,
including the machine it runs on. Crashes may be induced by anything,
from bugs, over power failures, to memory and logic bit flips. Like
regular consistency, a variety of "strengths" of crash consistency
have been proposed. In its simplest form, crash consistency simply
means that the database can recover some version of the data. It
doesn't have to be the latest version, only a "consistent" version, as
defined by the crash consistency protocol. For example, always
recovering an empty database may be deemed crash consistent. For a
write-only application, this is fine, as long as the database
continues to be writeable after recovery. However, for most
applications, this is not a particularly useful form of crash
consistency.

In this assignment, you will implement what is generally described as
strong crash consistency. While not a particularly descriptive term,
it describes that the database will be recovered into a state as close
as possible to its last update. This means that all records that were
inserted into the database right up to its crash should be accessible
after recovery. If an update was in progress during the crash but did
not finish, then this update is eliminated, as there can be no
physical guarantee that it was successfully applied to a durable
storage medium.

To ensure that database clients and servers agree on what state has
been fully written, strong crash consistency requires that each write
is acknowledged to a client requesting it, **after** the write has
firmly hit the underlying storage media. This signals to the client
that the database will be able to recover the write under any of the
aforementioned crash scenarios.

Hence, your database needs to ensure that each new record is
persistent on the underlying storage media and explicitly acknowledge
each insertion to the client. The existing protocol already requires
you to return `insert OK` whenever a record has been inserted. Hence,
all you need to do, is to ensure that you only return this
acknowledgment when you are sure you can recover the written data in
case of a crash.

There are a variety of mechanisms with different overheads to ensure
that data has hit persistent storage. The most commonly used, with
very low overhead, is an **update log**. Your database simply logs all
updates to a file. On recovery, the database can find this file and
replay all updates one by one to recover the full state of the
database. There is a caveat: You have to make sure that incomplete
records, which have not been acknowledged on their initial write, are
properly discarded on recovery. Commit records can help with this
problem. You also may want to make sure that data is not corrupted
when a machine crashes during the write. To address this challenge, a
checksum can help.

To evaluate the crash consistency of your database, we have provided a
script that will run a large number of random crash tests. The script
inserts records into the database, crashing the database at random
instances during the insertion process, restarting it, and assesses
whether all previously written and acknowledged records can still be
found in the database.

Once you have tested that your database is indeed crash consistent,
you should also evaluate the performance of the hotel reservation app
with your crash consistent database and compare it to your version
from lab 2. As before, you should investigate reservation latency, but
also draw a latency over throughput graph for reservations via the
`wrk2` benchmark tool.

### Detailed Instructions

For this assignment, you can continue to run the `lab2`
parameter. `lab3` is also fine, but not necessary.

You will continue to use the special version of the hotel reservation
app that enables synchronous journaling. This version was introduced
in lab 2.

`start_docker.sh`. Now, run `start_tmpfs.sh` to start the `tmpfs`
ramdisk. Run

```console
docker compose -f hotelreservation-nvmdb.yml up -d --build -t1
```

to build the hotel reservation app with your NVMdb database
backend. Simply continue developing your existing database backend
from assignment 2 of lab 2 to incorporate crash consistency. One
requirement: Your database **must** store its data in
`/data/db`. This is the same directory MongoDB uses for its database
files and it is necessary for the next assignment.

To test the crash consistency of your database, you can run
`test_nvmdb.sh`. This works, even outside of the Docker container, as
long as you create a `/data/db` directory on the host. In order to use
the `test_nvmdb.sh` script, you need to edit line 3
(`DB_BINARY=./example`) to replace `example` with your database binary
to be tested. When doing this outside of the Docker container, make
sure that you have manually built your database binary. The script
with continually test your database. To exit, you simply interrupt it
via `Ctrl-C`. If you want to re-test from scratch, make sure to delete
all your database files in `/data/db` first. You should test your
database for at least 100 insertions, but ideally much more. Note that
the test script will use arbitrary strings for the values of
`hotelId`, `inDate`, and `outDate`. Do not expect the values for
`inDate` and `outDate` to be properly formatted dates, for example. If
this is a problem for your database, you may modify `test_nvmdb.sh` to
provide dates of the proper format. In that case, please submit your
modified `test_nvmdb.sh` with your code to us.

Use `bench_reserve.sh` on the client to measure reservation
latency. You may also modify the parameters specified in the `curl`
command line used in the script to try your database with different
reservation settings.

Use

```console
wrk -D exp -t 10 -c 100 -d 10 -L -s /local/repository/reserve_only.lua http://server0:5000 -R 1000
```

with appropriate parameters to `-t`, `-c`, and `-R`, to measure
reservation latency and throughput.

## Assignment 2: Availability (5 pts)

You will now evaluate the availability of the hotel reservation app
with your database and compare it to that of MongoDB. Remember that
the app is only considered available if it is responding within the
service level objective (SLO) of 500ms. It is not enough for the
service to simply be able to respond if those responses take too long.

To get a clear picture of service response times, you will run a
benchmark that records each request along with the latency of the
associated response. You should visualize these latencies by drawing a
scatterplot of successful operation latency over time. The x axis
shows operation latency, the y axis is time from the beginning of the
experiment. Each operation will have one dot plotted. You can then
assess when latencies return to within the SLO. Also, you should
discuss how recovery time of your database might be accelerated.

### Detailed Instructions

This assignment requires the `lab3` configuration.

`start_docker.sh`. Now, run `start_nfs.sh`. This will start a remote NFS mount
going from `client0` to both servers. `client0` fulfills the role of a
distributed file system storage backend. Then, run:

```console
build_swarm.sh hotelreservation-nfs.yml
```

to build a special version of the hotel reservation app that uses the
NFS mount for reservations. The NFS mount is required to carry over
the database stored on one server to the other server.

You can then deploy the swarm with:

```console
docker stack deploy --compose-file hotelreservation-nfs.yml hotelreservation
```

On the client, generate the operation latency data with:

```console
stdbuf -oL ./wrk2/wrk -D fixed -t 1 -c 1 -s /local/repository/reserve_only.lua http://server0:5000 -R 10 -P -d 100 -T1s | tee lat.txt
```

This will send 10 reservation requests per second and output each
request's latency on the console. It will also write the latencies to
the file `lat.txt`. You will process this file to graph the operation
latencies. Remember to graph only `complete` operations, not `failed`
ones.

This scipt will run for 100 seconds. During this time, you should kill
the database, with:

```console
./kill_reservation.sh
```

The script will automatically find the right machine and kill the
database process on it. This will cause Docker to eventually detect
the failure and restart the database, which will recover before
serving further requests. This entire process should be reflected in
your graphed scatterplot. There will be a time when no completed
operations are processed and potentially a time where latencies are
longer than usual.

When done, you will then repeat this process with your database. To do
so, you can use:

```console
build_swarm.sh hotelreservation-nvmdb-nfs.yml
```

which will build the swarm with your database. Before running it, make
sure to remove the old swarm and clean up the NFS directory. You can
remove the old swarm with:

```console
docker compose down -t1
docker volume prune
```

Now, plot the operation latencies of the app using your database
during fail-over. When done, compare both scatterplot and comment on
the measured recovery times.
