#!/bin/bash

TEST_DEV=$1

# setup FIO test parameters
block_sizes=("4K")
threads=("1")
duration=30
depth=("256")
sbatch=("4" "8" "16" "32" "64" "128")
TIMES=1


# FIO test execution
for ((n=0; n<TIMES; n++)); do
  for iodepth in "${depth[@]}"; do
    for block_size in "${block_sizes[@]}"; do
      for b in "${sbatch[@]}"; do
        for thread in "${threads[@]}"; do
        
          # directory check and create if not exist
          run_folder="iouring/"
          mkdir -p "$run_folder"
          log_file="$run_folder/fio_block_iouring_batch${b}.log"
          sudo fio --name=test  --group_reporting=1 --filename=$TEST_DEV --ioengine=io_uring --rw=randread \
          --iodepth=$iodepth --bs=$block_size --norandommap=1 --numjobs=$thread --thread --direct=1 \
          --iodepth_batch_submit=$b --iodepth_batch_complete=$b  --runtime=$duration --ramp_time=10 > $log_file
        done
      done
    done
  done
done