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
from bugs, over power failures, to memory and logic bit flips caused
by cosmic rays. Like regular consistency, a variety of "strengths" of
crash consistency are conceivable. In its simplest form, crash
consistency simply means that the database can recover some version of
the data. It doesn't have to be the latest version, only a
"consistent" version, as defined by the crash consistency
protocol. For example, always recovering an empty database may be
deemed crash consistent. For a write-only application, this is fine,
as long as the database continues to be writeable after
recovery. However, for most applications, this is not a particularly
useful form of crash consistency.

In this assignment, you will implement what is generally described as
strong crash consistency. While not a particularly descriptive term,
it generally describes that the database will be recovered into a
state as close as possible to its last update. This means that all
records that were inserted into the database right up to its crash
should be accessible after recovery. If an update was in progress
during the crash, then this update is typically eliminated from the
expectation, as there can be no physical guarantee that it was
successfully applied to a durable storage medium.

To ensure that database clients and server agree on what state has
been fully written, strong crash consistency requires that each write
is acknowledged to a client requesting it, **after** the write has
firmly hit the underlying storage media. This signals to the client
that the database will be able to recover the write under any of the
aforementioned crash scenarios.

Hence, your database needs to ensure that each new record is
persistent on the underlying storage media immediately and explicitly
acknowledge each insertion to the client. The existing protocol
already requires you to return `insert OK` whenever a record has been
inserted. Hence, all you need to do, is to ensure that you only return
this acknowledgment when you are sure you can recover the written data
in case of a crash.

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
found in the database. The script will also insert random data
corruptions to the database files to test whether these issues are
addressed, as well.

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
in assignment 2 of lab 2.

`start_docker.sh`. Now, run `start_tmpfs.sh` to start the `tmpfs`
ramdisk. Run

```console
docker compose -f hotelreservation-nvmdb.yml up -d --build -t1
```

to build the hotel reservation app with your NVMdb database
backend. Simply continue developing your existing database backend
from assignment 2 of lab 2 to incorporate crash consistency. One
requirement: Your database **must** store its files in
`/data/db`. This is the same directory MongoDB uses for its database
files and will be accessed by the test script.

To test the crash consistency of your database, you can run
`test_nvmdb.sh`. This works, even outside of the Docker container, as
long as you provide the `/data/db` directory. In order to use the
`test_nvmdb.sh` script, you need to edit line 3
(`DB_BINARY=./example`) to replace `example` with your database binary
to be tested. When doing this outside of the Docker container, make
sure that you have manually built your database binary. The script
with continually test your database. To exit, you simply interrupt it
via `Ctrl-C`. If you want to re-test from scratch, make sure to delete
all your database files in `/data/db` first.

Use `bench_reserve.sh` on the client to measure reservation
latency. You may also modify the parameters specified in the `curl`
command line used in the script to try your database with different
reservation settings.

Use

```console
wrk -D exp -t 10 -c 100 -d 10 -L -s /local/repository/reserve_only.lua
http://server0:5000 -R 1000
```

with appropriate parameters to `-t`, `-c`, and `-R`, to measure
reservation latency and throughput.

## Assignment 2: Availability (5 pts)

