#!/bin/bash

TEST_DEV=$1
# setup FIO test parameters
block_size=4K
duration=30
iodepth=("1" "4" "8" "16" "32" "64" "128" "256" "512" "1024")
batch=32

# FIO test execution (batch=32)
    for depth in "${iodepth[@]}"; do
          run_folder="iouring-fb"
          mkdir -p "$run_folder"
          log_file="$run_folder/fio_iouring_D${depth}.log"
          sudo fio --name=test --group_reporting=1 --filename=$TEST_DEV --ioengine=io_uring --rw=randread --iodepth=$depth \
          --bs=$block_size --norandommap=1 --ramp_time=10 --numjobs=1 --thread --direct=1 --iodepth_batch_submit=$batch \
          --iodepth_batch_complete_max=$batch --iodepth_batch_complete_min=1 --time_based --runtime=$duration --fixedbufs \
            > $log_file
    done