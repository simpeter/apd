"""cse453 default profile to run DeathStarBench.

This profile is sourced from the cse453 gitlab repo at
https://gitlab.cs.washington.edu/syslab/cse453-cloud-project/. The
entire repo is checked out into /local/repository on each created machine.
"""

import geni.portal as portal
import geni.rspec.pg as pg
import geni.rspec.emulab as emulab

### Configuration

# Boilerplate setup
pc = portal.Context()
request = pc.makeRequestRSpec()

# Lab selection
lablist = [
    ('lab0', 'Lab 0'),
    ('lab1', 'Lab 1'),
    ('lab2', 'Lab 2')]
pc.defineParameter("lab", "Select the lab you are working on",
                   portal.ParameterType.STRING, lablist[0], lablist)

# Number of server machines
pc.defineParameter("n_servers", "Number of server machines",
                   portal.ParameterType.INTEGER, 3, advanced=True)

# Number of client machines
pc.defineParameter("n_clients", "Number of client machines",
                   portal.ParameterType.INTEGER, 1, advanced=True)

# Parameter to set virtualized mode or not
modelist = [
    ('default', 'default - Any x86 machine'),
    ('passthru', 'passthru - Only machines that support device pass-through')]
pc.defineParameter("mode", "Select default or device pass-through mode for servers",
                   portal.ParameterType.STRING, modelist[0], modelist, advanced=True)

# Retrieve the values the user specifies during instantiation
params = pc.bindParameters()

# Check parameter validity
if params.n_servers < 1 or params.n_servers > 10:
    pc.reportError(portal.ParameterError("You must choose at least 1 and no more than 10 servers.", ["n_servers"]))
if params.n_clients < 1 or params.n_clients > 1:
    pc.reportError(portal.ParameterError("You must choose at least 1 and no more than 1 clients.", ["n_clients"]))

# Abort execution if there are any errors, and report them
portal.context.verifyParameters()

if params.lab == 'lab0':
        params.n_servers = 3
        params.n_clients = 1
        params.mode = 'default'
elif params.lab == 'lab1':
        params.n_servers = 3
        params.n_clients = 1
        params.mode = 'passthru'
elif params.lab == 'lab2':
        params.n_servers = 1
        params.n_clients = 1
        params.mode = 'default'
else:
    pc.reportError(portal.ParameterError("Invalid lab selected!", ["lab"]))

# Retrieve the values the user specifies during instantiation
params = pc.bindParameters()

# Create starfish network topology
mylink = request.Link('mylink')
mylink.Site('undefined')

for i in range(params.n_servers):
    # Create node
    n = request.RawPC('server%u' % i)
    n.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU20-64-STD'
    iface = n.addInterface('interface-%u' % i)
    if params.mode == "passthru":
        # We know that the AMD machines support device pass-through.
        # XXX: This is restrictive, as other machine types might support it, too. Not clear how to constrain the hardware type to a set of machines, rather than just a single type.
        n.hardware_type = "c6525-25g"
    n.addService(pg.Execute(shell="bash", command="/local/repository/virtualize.sh"))
    mylink.addInterface(iface)

for i in range(params.n_clients):
    # Create node
    n = request.RawPC('client%u' % i)
    n.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU20-64-STD'
    iface = n.addInterface('interface-%u' % (params.n_servers + i))
    n.addService(pg.Execute(shell="bash", command="/local/repository/virtualize.sh"))
    mylink.addInterface(iface)

# Print the generated rspec
pc.printRequestRSpec(request)
