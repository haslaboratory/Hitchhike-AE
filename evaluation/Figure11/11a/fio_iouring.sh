#!/bin/bash


TEST_FILE=$1
INDEX=$2

# setup fio parameters
block_sizes=("4k")
threads=("1")
duration=30
depth=("256")
sbatch=("32")
TIMES=1

# # batch
for ((n=0; n<TIMES; n++)); do
  for block_size in "${block_sizes[@]}"; do
    for iodepth in "${depth[@]}"; do
      for thread in "${threads[@]}"; do
        for b in "${sbatch[@]}"; do

          run_folder="SSD${INDEX}/iouring"
          mkdir -p "$run_folder"
          log_file="$run_folder/fio_file_iouring.log"
          sudo fio --name=test --group_reporting=1 --filename=$TEST_FILE --ioengine=io_uring --rw=randread \
          --iodepth=$iodepth --bs=$block_size --norandommap=1 --ramp_time=10 --numjobs=$thread --thread \
          --direct=1 --iodepth_batch_submit=$b --iodepth_batch_complete_max=$b \
          --iodepth_batch_complete_min=1 --time_based --runtime=$duration \
            > $log_file
        done
      done
    done
  done
done


# batch fb
for ((n=0; n<TIMES; n++)); do
  for block_size in "${block_sizes[@]}"; do
    for iodepth in "${depth[@]}"; do
      for b in "${sbatch[@]}"; do
        for thread in "${threads[@]}"; do

          run_folder="SSD${INDEX}/iouring-fb"
          mkdir -p "$run_folder"
          log_file="$run_folder/fio_file_iouring-fb.log"
          sudo fio --name=test --group_reporting=1 --filename=$TEST_FILE --ioengine=io_uring --rw=randread --iodepth=$iodepth --bs=$block_size --norandommap=1 \
            --numjobs=$thread --thread --direct=1 --iodepth_batch_submit=$b --iodepth_batch_complete_max=$b --iodepth_batch_complete_min=1 \
            --fixedbufs --ramp_time=10 --time_based --runtime=$duration >> $log_file
        done
      done
    done
  done
done


# batch fb iopoll
for ((n=0; n<TIMES; n++)); do
  for block_size in "${block_sizes[@]}"; do
    for iodepth in "${depth[@]}"; do
      for thread in "${threads[@]}"; do
        for b in "${sbatch[@]}"; do

          run_folder="SSD${INDEX}/iouring-iopoll-fb"
          mkdir -p "$run_folder"
          log_file="$run_folder/fio_file_iouring-fb-iopoll.log"
          sudo fio --name=test --group_reporting=1 --filename=$TEST_FILE --ioengine=io_uring --rw=randread --iodepth=$iodepth \
            --bs=$block_size --norandommap=1 --numjobs=$thread --thread --direct=1 --iodepth_batch_submit=$b \
            --iodepth_batch_complete_max=$b --iodepth_batch_complete_min=1 \
            --hipri --ramp_time=10 --fixedbufs --time_based  --runtime=$duration >> $log_file
        done
      done
    done
  done
done