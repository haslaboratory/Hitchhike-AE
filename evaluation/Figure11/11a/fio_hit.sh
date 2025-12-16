#!/bin/bash

# /dev/nvme2n1 X2900P; /dev/nvme3n1 PM9A3; /dev/nvme7n1 PM1743

TEST_FILE=$1
INDEX=$2

# setup fio parameters
block_sizes=("4K")
threads=("1")
duration=30
depth=("8")
hitchhike=("96")
sbatch=("1")
TIMES=1



for iodepth in "${depth[@]}"; do
  for thread in "${threads[@]}"; do
    for hit in "${hitchhike[@]}"; do
      for b in "${sbatch[@]}"; do

        run_folder="SSD${INDEX}/hitchhike-uring/"
        mkdir -p "$run_folder"
        log_file="$run_folder/fio_file_hit.log"
        # hitchhike
        sudo fio --name=test  --filename=$TEST_FILE --ioengine=io_uring --rw=randread --ramp_time=10 \
          --norandommap=1 --iodepth=$iodepth --bs=4K --numjobs=$thread --thread --direct=1 \
          --hitchhike=$hit --iodepth_batch_submit=$b --iodepth_batch_complete_max=$b --iodepth_batch_complete_min=1 \
          --runtime=$duration > $log_file
      done
    done
  done
done