#!/bin/bash

## Script to mount the SSD and the HDD in the VirtualBox machine
##

SSD=$1
HDD=$2

SSD_DEV="/dev/sdb1/"
HDD_DEV="/dev/sdc1/"

echo "*** Mounting the SDD ... \n"
sudo mkdir -p ${SSD}
sudo /bin/mount -t ext2 -o user_xattr ${SSD_DEV} ${SSD}
sudo chown guest ${SSD}
sudo chgrp guest ${SSD}
sudo chmod a+rwx ${SSD}

echo "*** Mounting the HDD ... \n"
sudo mkdir -p ${HDD}
sudo /bin/mount -t ext2 -o user_xattr ${HDD_DEV} ${HDD}
sudo chown guest ${HDD}
sudo chgrp guest ${HDD}
sudo chmod a+rwx ${HDD}

echo "*** Check if MOUNT succeeded (you SHOULD see two lines of output from /proc/mounts):\n"
echo "***\n"
cat /proc/mounts | grep 'sd'

