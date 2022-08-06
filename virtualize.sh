#!/bin/bash
#
# This runs as geniuser in /.

# All output and commands go to logfile in /tmp
set -x
exec 1>/tmp/virtualize.log 2>&1

echo "virtualize.sh credentials:"
echo $PWD
echo $USER
echo $GROUP

HOSTNAME=`hostname -s`

case $HOSTNAME in
    server*)
	# Install virtual machine, plus some tools
	sudo apt-get update
	sudo apt-get install --yes snapd libxml-xpath-perl joe
	sudo snap install lxd
	;;

    client*)
	# Install the client tools
	/local/repository/start_client.sh
	;;

    *)
	echo "Unknown hostname $HOSTNAME!"
	;;
esac

echo "virtualize.sh done"
