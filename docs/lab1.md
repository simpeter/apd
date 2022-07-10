# Lab 1: Virtualization

The cloud runtime environment determines the experience that
developers and users will receive. The level at which server hardware
is virtualized, in particular, has a major impact on application
performance. In this lab, you will evaluate some of the virtualization
and containerization solutions presented in the lecture.

## Performance

Cloud developers want a simple development experience that allows them
to quickly drive up service when there is demand. Users want quality
service. Since most cloud applications are interactive, quality is
most frequently determined by service latency of the connected cloud
application. Finally, as cloud operators, we want efficiency, as this
drives down operating cost. All of these demands are embodied in the
performance of a service.

Studies have shown that users can tolerate about half a second (500ms)
of service latency. Anything above this makes them increasingly likely
to assume that there is something wrong with the provided service and
go elsewhere.

Systems designers typically assess performance by evaluating service
latency provided under a variety of load conditions. System load has a
major effect on the provided service. If a service is overloaded, it
is generally going to provide terrible service---only the few lucky
users that got through will get an answer and even that answer is
going to take a while. Lower load conditions are going to provide a
spread of service latencies.

To see how a system performs under a variety of load conditions, we
draw latency-load curves. For each load level (presented on the x
axis), we assess service latency (presented on the y axis). For cloud
operators, it is typically not enough to keep average service
latencies below 500ms. Averages ignore the distribution of service
experiences and could preclude a potentially large fraction of users
from acceptable service. Instead, we care about the largest fraction
of users, knowing that some users are bound to have bad performance
for reasons outside of our control. Hence, we assess a sufficiently
large percentile of users. This is typically 99% of users or more. In
our project, we will care about 99% of users.

Assume that we have a number of virtualization technologies at our
disposal:

1. Bare metal with containers
2. Hardware virtualization with a software IO path
3. Hardware virtualization with hardware device passthrough
4. Trap and emulate virtualization with software IO

You will evaluate each of these technologies for their
efficiency.
