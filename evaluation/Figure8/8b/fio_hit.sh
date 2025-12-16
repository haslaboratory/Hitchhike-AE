#!/bin/bash

TEST_DEV=$1

# setup FIO test parameters
block_size=4K
thread=1
duration=30

# FIO test execution
declare -a iodepth=("1" "4" "8" "16" "32")
declare -a hitchhike=("1" "2" "4" "8" "16" "32" "64" "96")

for ((i=0; i< ${#iodepth[@]}; i++)); do
  depth="${iodepth[i]}"
  for ((j=0; j< ${#hitchhike[@]}; j++)); do
    hit="${hitchhike[j]}"
    run_folder="D$depth"
    mkdir -p "$run_folder"
    log_file="D$depth/fio_hitchhike${hit}_D${depth}.log"
    # hitchhike FIO test
    sudo fio --name=test  --filename=$TEST_DEV --ioengine=io_uring --rw=randread --ramp_time=10 \
        --norandommap=1 --iodepth=$depth --bs=$block_size --numjobs=$thread --thread --direct=1 \
        --hitchhike=$hit --iodepth_batch_submit=1 --iodepth_batch_complete=1  --runtime=$duration > $log_file
  done
done
