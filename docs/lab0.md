# Lab 0: Setting Up

This lab is ungraded and intended to get you set up with the project's
infrastructure. Please go through all the steps, make sure that each
one works, and that you have access to everything described here.

## Create a CloudLab Account ([Link](https://www.cloudlab.us/signup.php?pid=cse453))

The majority of the project runs on CloudLab, for which you need an
account. To create an account, please use your UW email and use UW
NetID as the username. Upload your SSH public key file as you will be
using SSH to access the nodes in CloudLab. Click on `Submit
Request`. We will approve your request within 24 hours. If you already
have a CloudLab account, simply request to join the `cse453` project.

## Start an Experiment

To start a new experiment, go to your CloudLab dashboard and click on
the `Experiments` tab in the upper left corner, then select `Start
Experiment`.  This will lead to the profile selection panel. Click on
`Change Profile`, and select a profile from the list (TODO: provide
more details on the profile). Click on `Next` to move to the next
page.  Here you should name your experiment with
`<groupname>-<assignmentname>` (maybe there is a better way). The
purpose of doing this is to prevent everyone from picking random names
and ending up confusing each other since everyone in the project can
see all running experiments.

You can specify from which cluster you want to start your
experiment. Each cluster has a variety of hardware. For more
information on the hardware CloudLab provides, please refer to this
[page](http://docs.cloudlab.us/hardware.html).

Once the experiment is created, you should be able to view the
information under the [user dashboard
page](https://www.cloudlab.us/user-dashboard.php).

## Log into Experiment Machines

Once the experiment is ready (this can take a few minutes), click
`List View` and you will find SSH commands to access each node. On the
same tab, you can also reboot/reload your nodes if something goes
wrong.

## Find a Client Machine at UW

## Run iperf

Explain what iperf is

Run benchmark from UW client to baremetal machine

What's the expected output?

## Install and Start DeathStarBench on Bare Metal Machines

(look at example shell script docker_example.sh in repo to explain
this step)

Starting it up

## Testing DeathStarBench

Use curl. See example shell script

## Installing wrk2 on Client Machine

Look at docker_example.sh for prereqs

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

## Policies on Using CloudLab Resources

1. Before you start your first experiment, please read this
   [page](https://cloudlab.us/aup.php). 

2. By default, each experiment will expire in 16 hours. This is enough
   for most runs. If you run out of time, you can request an extension
   via the `Extend` button on your experiment's CloudLab profile
   page. To request an extension, you need to provide a
   reason. We are providing a template blurb for this purpose,
   below.
   
   Requests for extensions have to be approved and that might take a
   little while. Hence, we do not recommend this route. Instead, make
   sure that all your data is saved and create a new experiment
   whenever you can.
