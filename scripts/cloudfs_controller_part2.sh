#!/bin/bash

##
## Script to start the CloudFS file system
##

MOUNT_OR_UMOUNT_FLAG=$1     ## "m" for mount, "u" for unmount, "x" for both
CFS_MNT_POINT=$2
CFS_THRESHOLD=$3
SSD_SIZE=$4
HDD_SIZE=$5

cfs_process="../build/bin/cloudfs"
cfs_ssd_mount="/mnt/ssd/"
cfs_hdd_mount="/mnt/hdd/"

mkdir -p ${CFS_MNT_POINT}

if [ "$1" = "m" ]
then
    ${cfs_process} -t ${CFS_THRESHOLD} -s ${cfs_ssd_mount} -d ${cfs_hdd_mount} -f ${CFS_MNT_POINT} -a ${SSD_SIZE} -b ${HDD_SIZE}
elif [ "$1" = "u" ]
then
    fusermount -u ${CFS_MNT_POINT}
    rm -rf ${cfs_ssd_mount}/*
    rm -rf ${cfs_hdd_mount}/*
elif [ "$1" = "x" ]
then
    fusermount -u ${CFS_MNT_POINT}
    ./umount_disks.sh ${cfs_ssd_mount} ${cfs_hdd_mount} 
    ./mount_disks.sh ${cfs_ssd_mount} ${cfs_hdd_mount}
    ${cfs_process} -t ${CFS_THRESHOLD} -s ${cfs_ssd_mount} -d ${cfs_hdd_mount} -f ${CFS_MNT_POINT} -a ${SSD_SIZE} -b ${HDD_SIZE}
else
    echo "***ERROR"
    echo "\tUsage: ./scriptName <MODE> <CLOUDFS_MOUNT> <CLOUDFS_THRESHOLD> <SSD_SIZE> <HDD_SIZE>\n"
    echo "\n"
    echo "\twhere, MODE is one of the following ..."
    echo "\tm for mount, u for unmount, x for (unmount+mount) to drop caches\n"
fi
