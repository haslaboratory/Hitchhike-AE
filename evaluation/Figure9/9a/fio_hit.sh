#!/bin/bash

TEST_DEV=$1
INDEX=$2

# setup FIO test parameters
block_sizes=("4K")
threads=("1")
duration=30
depths=("8")
hitchhike=("64")
batch=("1")
TIMES=1


# FIO test execution
for ((n=0; n<TIMES; n++)); do
  for block_size in "${block_sizes[@]}"; do
    for depth in "${depths[@]}"; do
      for thread in "${threads[@]}"; do
        for hit in "${hitchhike[@]}"; do
          for b in "${batch[@]}"; do
            
            run_folder="SSD${INDEX}/hitchhike-aio/"
            mkdir -p "$run_folder"
            log_file="$run_folder/fio_block_hit-aio_T${thread}.log"
            # hitchhike-aio test
            sudo fio --name=test  --group_reporting=1 --filename=$TEST_DEV --ioengine=libaio --rw=randread --ramp_time=10 \
              --norandommap=1 --iodepth=$depth --bs=$block_size --numjobs=$thread --thread --direct=1 \
              --hitchhike=$hit --iodepth_batch_submit=$b --iodepth_batch_complete_min=1 --iodepth_batch_complete_max=$b \
              --runtime=$duration > $log_file
          done
        done
      done
    done
  done
done


for ((n=0; n<TIMES; n++)); do
  for block_size in "${block_sizes[@]}"; do
    for depth in "${depths[@]}"; do
      for thread in "${threads[@]}"; do
        for hit in "${hitchhike[@]}"; do
          for b in "${batch[@]}"; do
            
            run_folder="SSD${INDEX}/hitchhike-uring/"
            mkdir -p "$run_folder"
            log_file="$run_folder/fio_block_hit-uring_T${thread}.log"
            # hitchhike-uring test
            sudo fio --name=test --group_reporting=1 --filename=$TEST_DEV --ioengine=io_uring --rw=randread --ramp_time=10 \
              --norandommap=1 --iodepth=$depth --bs=$block_size --numjobs=$thread --thread --direct=1 \
              --hitchhike=$hit --iodepth_batch_submit=$b --iodepth_batch_complete_min=1 --iodepth_batch_complete_max=$b \
              --runtime=$duration > $log_file
          done
        done
      done
    done
  done
done



