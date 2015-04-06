#!/bin/bash

## Script to test the part 1 of the class project by extracting a tar file in
## the file system, and performing two kinds of operations: md5sum and ls -laR
##

TEST_SCALE=$1
CFS_MNT_POINT=$2
CFS_THRESHOLD=$3

tar_file="small_test"
if [ "$1" = "b" ]
then
    tar_file="big_test"
elif [ "$1" = "l" ]
then
    tar_file="large_test"
else
    echo "*** Using the default test scale: SMALL\n"
fi

log_file="disk_stats.log"
disk_stats="vmstat -d | grep 'sd'"
calc_stats="./stat_summarizer"

## unmount and remount CloudFS -- clean operation (removes all data)
./cloudfs_controller.sh u ${CFS_MNT_POINT} ${CFS_THRESHOLD}
./cloudfs_controller.sh m ${CFS_MNT_POINT} ${CFS_THRESHOLD}

####################
## Extract a tar file and measure stats before/after the operation
####################

#${disk_stats} > ${log_file} 
vmstat -d | grep 'sd' > ${log_file}
tar xvzf ${tar_file}.tar.gz -C ${CFS_MNT_POINT}
sync
#${disk_stats} >> $log_file 
vmstat -d | grep 'sd' >> ${log_file}

## computing statistics
sed -i 's/sdb/sdb1/g' ${log_file}
sed -i 's/sdc/sdc1/g' ${log_file}
echo "@ untar results"
${calc_stats} ${log_file}

## unmount and remount CloudFS
./cloudfs_controller.sh x ${CFS_MNT_POINT} ${CFS_THRESHOLD}

####################
## Find a md5sum of each file and measure stats before/after the operation
####################

#${disk_stats} > $log_file 
vmstat -d | grep 'sd' > ${log_file}
find ${CFS_MNT_POINT}/${tar_file}/ -type f -exec md5sum {} \;
sync
#${disk_stats} >> $log_file 
vmstat -d | grep 'sd' >> ${log_file}

## computing statistics
sed -i 's/sdb/sdb1/g' ${log_file}
sed -i 's/sdc/sdc1/g' ${log_file}
echo "@ md5sum results"
${calc_stats} ${log_file}

## unmount and remount CloudFS
./cloudfs_controller.sh x ${CFS_MNT_POINT} ${CFS_THRESHOLD}

####################
## Perform "ls -aR" and measure stats before/after the operation
####################

#${disk_stats} > $log_file
vmstat -d | grep 'sd' > ${log_file}
ls -alR ${CFS_MNT_POINT}/${tar_file}
#sync        ## XXX: why should this sync of "ls"?
#${disk_stats} >> $log_file 
vmstat -d | grep 'sd' >> ${log_file}

## computing statistics
sed -i 's/sdb/sdb1/g' ${log_file}
sed -i 's/sdc/sdc1/g' ${log_file}
echo "@ ls results"
${calc_stats} ${log_file}
