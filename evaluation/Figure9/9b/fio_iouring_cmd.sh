#!/bin/bash

TEST_DEV=$1
# setup FIO test parameters
block_sizes=("4K")
threads=("1" "2" "3" "4" "5" "6" "7" "8")
duration=30
depths=("512")
batch=("32")
TIMES=1


#  batch32 + FB
for ((n=0; n<TIMES; n++)); do
  for depth in "${depths[@]}"; do
    for block_size in "${block_sizes[@]}"; do
      for b in "${batch[@]}"; do
        for thread in "${threads[@]}"; do
          run_folder="iouring-cmd-fb"
          mkdir -p "$run_folder"
          log_file="$run_folder/fio_block_cmd_T${thread}_FB.log"
          sudo fio --name=test --group_reporting=1 --filename=$TEST_DEV --ioengine=io_uring_cmd --rw=randread --iodepth=$depth \
          --bs=$block_size --norandommap=1 --ramp_time=10 --numjobs=$thread --thread --iodepth_batch_submit=$b \
          --iodepth_batch_complete_max=$b --iodepth_batch_complete_min=1 --cmd_type=nvme --time_based --runtime=$duration \
          --fixedbufs > $log_file
        done
      done
    done
  done
done