#!/bin/bash

TEST_FILE=$1


# setup fio parameters
block_sizes=("4K")
threads=("1" "2" "3" "4" "5" "6" "7" "8")
duration=10
depth=("256")
sbatch=("32")
TIMES=1


# batch
for ((n=0; n<TIMES; n++)); do
  for iodepth in "${depth[@]}"; do
    for block_size in "${block_sizes[@]}"; do
      for b in "${sbatch[@]}"; do
        for thread in "${threads[@]}"; do

          run_folder="libaio"
          mkdir -p "$run_folder"
          log_file="$run_folder/fio_file_libaio_T${thread}.log"
          sudo fio --name=test  --group_reporting=1 --filename=$TEST_FILE --ioengine=libaio --rw=randread --iodepth=$iodepth \
            --bs=$block_size --norandommap=1 --numjobs=$thread --thread --direct=1 --iodepth_batch_submit=$b \
            --iodepth_batch_complete_max=$b --iodepth_batch_complete_min=1 --time_based  \
            --runtime=$duration --ramp_time=10 > $log_file
        done
      done
    done
  done
done