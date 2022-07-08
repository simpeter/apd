"""DeathStarBench"""

import geni.portal as portal
import geni.rspec.pg as pg
import geni.rspec.emulab as emulab

n_vms = 3

pc = portal.Context()
request = pc.makeRequestRSpec()

# Create starfish network topology
mylink = request.Link('mylink')
mylink.Site('undefined')

for i in range(n_vms):
    # Create node
    n = request.RawPC('machine%u' % i)
    n.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU20-64-STD'
    iface = n.addInterface('interface-%u' % i)
    n.addService(pg.Execute(shell="bash", command="/local/repository/virtualize.sh"))
    mylink.addInterface(iface)

# Print the generated rspec
pc.printRequestRSpec(request)
