#!/bin/bash


TEST_FILE=$1

# setup fio parameters
block_sizes=("4k")
threads=("1")
duration=10
depth=("1" "4" "8" "16" "32" "64" "128" "256" "512" "1024")
sbatch=("32")
TIMES=1

# # batch
for ((n=0; n<TIMES; n++)); do
    for iodepth in "${depth[@]}"; do
        for b in "${sbatch[@]}"; do
          run_folder="iouring"
          mkdir -p "$run_folder"
          log_file="$run_folder/fio_file_iouring_D${iodepth}.log"
          sudo fio --name=test --group_reporting=1 --filename=$TEST_FILE --ioengine=io_uring --rw=randread \
          --iodepth=$iodepth --bs=4k --norandommap=1 --ramp_time=0 --numjobs=$threads --thread --direct=1 \
          --iodepth_batch_submit=$b --iodepth_batch_complete_max=$b \
          --iodepth_batch_complete_min=1 --time_based --runtime=$duration \
            > $log_file
        done
    done
done


# batch fb
for ((n=0; n<TIMES; n++)); do
    for iodepth in "${depth[@]}"; do
        for b in "${sbatch[@]}"; do
          run_folder="iouring-fb"
          mkdir -p "$run_folder"
          log_file="$run_folder/fio_file_iouring_D${iodepth}.log"
          sudo fio --name=test --group_reporting=1 --filename=$TEST_FILE --ioengine=io_uring --rw=randread \
          --iodepth=$iodepth --bs=4k --norandommap=1 --ramp_time=0 --numjobs=$threads --thread --direct=1 \
          --iodepth_batch_submit=$b --iodepth_batch_complete_max=$b \
          --iodepth_batch_complete_min=1 --time_based --runtime=$duration --fixedbufs \
            > $log_file
        done
    done
done




# batch fb iopoll
for ((n=0; n<TIMES; n++)); do
    for iodepth in "${depth[@]}"; do
        for b in "${sbatch[@]}"; do
          run_folder="iouring-iopoll-fb"
          mkdir -p "$run_folder"
          log_file="$run_folder/fio_file_iouring_D${iodepth}.log"
          sudo fio --name=test --group_reporting=1 --filename=$TEST_FILE --ioengine=io_uring --rw=randread \
          --iodepth=$iodepth --bs=4k --norandommap=1 --ramp_time=10 --numjobs=$threads --thread --direct=1 \
          --iodepth_batch_submit=$b --iodepth_batch_complete_max=$b \
          --iodepth_batch_complete_min=1 --time_based --runtime=$duration --fixedbufs --hipri \
            > $log_file
        done
    done
done

