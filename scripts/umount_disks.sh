#!/bin/bash

## Script to unmount the SSD and the HDD in the VirtualBox machine
##

SSD=$1
HDD=$2

SSD_DEV="/dev/sdb1/"
HDD_DEV="/dev/sdc1/"

echo "*** Unmount the SDD and the HDD ... \n"
sudo /bin/umount ${SSD_DEV}
sudo /bin/umount ${HDD_DEV}

echo "*** Check if UNMOUNT succeeded (you SHOULD NOT see any output from /proc/mounts):\n"
echo "***\n"
cat /proc/mounts | grep 'sd'

