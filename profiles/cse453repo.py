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

# Number of machines
pc.defineParameter("n_machines", "Number of machines",
                   portal.ParameterType.INTEGER, 3)

# Parameter to set virtualized mode or not
# XXX: Outdated. We just always install the VMM now. It doesn't harm anything if no VMs are started.
# modelist = [
#     ('bare', 'Bare metal'),
#     ('vm', 'Virtualized')]
# pc.defineParameter("mode", "Select VM or baremetal mode",
#                    portal.ParameterType.STRING,
#                    modelist[0], modelist)

# Retrieve the values the user specifies during instantiation
params = pc.bindParameters()

# Check parameter validity
if params.n_machines < 1 or params.n_machines > 10:
    pc.reportError(portal.ParameterError("You must choose at least 1 and no more than 10 machines.", ["n_machines"]))

# Abort execution if there are any errors, and report them
portal.context.verifyParameters()

# Create starfish network topology
mylink = request.Link('mylink')
mylink.Site('undefined')

for i in range(params.n_machines):
    # Create node
    n = request.RawPC('machine%u' % i)
    n.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU20-64-STD'
    iface = n.addInterface('interface-%u' % i)
    # if params.mode == "vm":
    n.addService(pg.Execute(shell="bash", command="/local/repository/virtualize.sh"))
    mylink.addInterface(iface)

# Print the generated rspec
pc.printRequestRSpec(request)
