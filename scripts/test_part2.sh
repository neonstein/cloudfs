#!/bin/bash

## Script to test the part 2 of the class project 

CFS_MNT_POINT=$1
CFS_THRESHOLD=$2
SSD_SIZE="102400"
HDD_SIZE="102400"


s3_server="../s3-server/s3server.pyc"
log_file="disk_stats.log"
disk_stats="vmstat -d | grep 'sd'"
calc_stats="./stat_summarizer"

## unmount and remount CloudFS -- clean operation (removes all data)
./cloudfs_controller.sh u ${CFS_MNT_POINT} ${CFS_THRESHOLD}

# Clean S3 default storage directory
rm -r /tmp/s3/*
# Start S3 Server
python ${s3_server} &
# Wait for S3 Server finishing initialization
sleep 5


./cloudfs_controller.sh m ${CFS_MNT_POINT} ${CFS_THRESHOLD} ${SSD_SIZE} ${HDD_SIZE}

####################
## Run three workloads to CloudFS: stress test, deduplication test, file sharing test
####################

#${disk_stats} > ${log_file} 
vmstat -d | grep 'sd' > ${log_file}

python test_part2_workload.py stress ${CFS_MNT_POINT} 

# Extract Cloud Cost Usage
curl http://localhost:8888/admin/stat

python test_part2_workload.py dedup ${CFS_MNT_POINT} 

# Extract Cloud Cost Usage
curl http://localhost:8888/admin/stat

python test_part2_workload.py fshare ${CFS_MNT_POINT} 

# Extract Cloud Cost Usage
echo "curl http://localhost:8888/admin/stat"

#${disk_stats} >> $log_file 
vmstat -d | grep 'sd' >> ${log_file}

## computing statistics
sed -i 's/sdb/sdb1/g' ${log_file}
sed -i 's/sdc/sdc1/g' ${log_file}
echo "@ part2 results"
${calc_stats} ${log_file}

## unmount CloudFS
./cloudfs_controller.sh u ${CFS_MNT_POINT} ${CFS_THRESHOLD}

# Stop S3 Server
ps -ef | grep 's3server.pyc' | grep -v grep | cut -c 9-15 |xargs kill -9 
