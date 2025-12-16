#!/bin/bash

TEST_DEV=$1
# setup FIO test parameters
block_size=4K
duration=30

declare -a iodepth=("1" "2" "2" "4" "8" "8" "8" "8" "8" "8")
declare -a hitchhike=("1" "2" "4" "4" "4" "8" "16" "32" "64" "125")
for ((i=0; i< ${#iodepth[@]}; i++)); do
        depth="${iodepth[i]}"
        hit="${hitchhike[i]}"
        run_folder="hitchhike"
        mkdir -p "$run_folder"
        log_file="$run_folder/fio_hitchhike${hit}_depth${depth}.log"
        # hitchhike FIO test
        sudo fio --name=test --group_reporting=1 --filename=$TEST_DEV --ioengine=io_uring --rw=randread --ramp_time=10 \
          --norandommap=1 --iodepth=$depth --bs=$block_size --numjobs=1 --thread --direct=1 \
          --hitchhike=$hit --iodepth_batch_submit=1 --iodepth_batch_complete=1  --runtime=$duration > $log_file
done


