#!/bin/bash

TEST_FILE=$1

# setup FIO test parameters
threads=("1")
duration=10
sbatch=("1")
TIMES=1
declare -a depth=("1" "2" "2" "4" "8" "8" "8" "8" "8" "8")
declare -a hitchhike=("1" "2" "4" "4" "4" "8" "16" "32" "64" "125")


for ((n=0; n<TIMES; n++)); do
    for b in "${sbatch[@]}"; do
        for ((i=0; i< ${#depth[@]}; i++)); do
            iodepth="${depth[i]}"
            hit="${hitchhike[i]}"
            run_folder="hitchhike-uring/"
            mkdir -p "$run_folder"
            log_file="$run_folder/fio_file_hitchhike${hit}_depth${iodepth}.log"
            # hitchhike
            sudo fio --name=test  --filename=$TEST_FILE --ioengine=io_uring --rw=randread --ramp_time=10 \
              --norandommap=1 --iodepth=$iodepth --bs=4k --numjobs=$threads --thread --direct=1 \
              --hitchhike=$hit --iodepth_batch_submit=$b --iodepth_batch_complete_max=$b --iodepth_batch_complete_min=1 \
              --runtime=$duration > $log_file
          done
    done
done