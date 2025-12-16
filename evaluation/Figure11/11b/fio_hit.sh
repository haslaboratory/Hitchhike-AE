#!/bin/bash


TEST_FILE=$1


# setup fio parameters
block_sizes=("4K")
threads=("1" "2" "3" "4" "5" "6" "7" "8")
duration=30
depth=("8")
hitchhike=("96")
sbatch=("1")
TIMES=1



for ((n=0; n<TIMES; n++)); do
  for block_size in "${block_sizes[@]}"; do
    for iodepth in "${depth[@]}"; do
      for thread in "${threads[@]}"; do
        for hit in "${hitchhike[@]}"; do
          for b in "${sbatch[@]}"; do

            run_folder="hitchhike-uring/"
            mkdir -p "$run_folder"
            log_file="$run_folder/fio_file_hit_T${thread}.log"
            # hitchhike
            sudo fio --name=test  --filename=$TEST_FILE --ioengine=io_uring --rw=randread --ramp_time=10 \
              --norandommap=1 --iodepth=$iodepth --bs=$block_size --numjobs=$thread --thread --direct=1 \
              --hitchhike=$hit --iodepth_batch_submit=$b --iodepth_batch_complete_max=$b --iodepth_batch_complete_min=1 \
              --runtime=$duration > $log_file
          done
        done
      done
    done
  done
done