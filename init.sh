#!/bin/bash
#
# This runs as geniuser in /.

# All output and commands go to logfile in /tmp
set -x
exec 1>/tmp/init.log 2>&1

HOSTNAME=`hostname -s`
export MAKEFLAGS=-j

echo "init.sh credentials:"
echo PWD=$PWD
echo USER=$USER
echo GROUP=$GROUP
echo HOSTNAME=$HOSTNAME

. /local/repository/config.sh

# Install a bunch of useful tools
sudo apt-get update
sudo apt-get install --yes libxml-xpath-perl joe nfs-kernel-server

case $HOSTNAME in
    server*)
	# Install virtual machine
	sudo apt-get install --yes snapd
	sudo snap install lxd

	# If mode == passthru and not on c6525 machines, need to reboot with IOMMU enabled
	mode=`geni_get_parameter mode`
	node_type=`geni_get_parameter node_type`
	if [ x$mode = xpassthru -a x${node_type:0:5} != xc6525 ]; then
	    sudo sed -i -e 's/^GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on"/' /etc/default/grub
	    sudo update-grub
	    echo "Rebooting..."
	    sudo reboot
	fi
	;;

    client*)
	# Build wrk2
	cd /local/repository/DeathStarBench
	sudo apt-get install --yes python3-aiohttp libssl-dev libz-dev luarocks lua-socket
	sudo luarocks install luasocket
	make -C hotelReservation/wrk2
	;;

    *)
	echo "Unknown hostname $HOSTNAME!"
	;;
esac

echo "init.sh done"
