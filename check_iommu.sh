#!/bin/bash -x

. /local/repository/config.sh

mode=`geni_get_parameter mode`
node_type=`geni_get_parameter node_type`

# If mode == passthru and not on c6525 machines, need to reboot with IOMMU enabled
if [ x$mode = xpassthru -a x${node_type:0:5} != xc6525 ]; then
    grep 'intel_iommu=on' /proc/cmdline && exit 0

    echo "IOMMU disabled, need to reboot `hostname`..."
    sudo sed -i -e 's/^GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on"/' /etc/default/grub
    sudo update-grub
    echo "Rebooting..."
    sudo reboot
fi
