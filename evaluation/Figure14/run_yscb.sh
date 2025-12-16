#!/bin/bash


# 1. run the experiments
caches=("0.25" "0.5" "1" "2")
threads=("1")

mkdir -p YCSB-A YCSB-B YCSB-C YCSB-D YCSB-E YCSB-F

  for cache in "${caches[@]}"; do
    for thread in "${threads[@]}"; do

      # YCSB A
      ./../../Leanstore/build/frontend/ycsb --ssd_path="/dev/nvme3n1" --ioengine=io_uring --partition_bits=12 \
      --target_gib=1 --ycsb_read_ratio=50 --ycsb_type=1  --optimistic_parent_pointer=1 --xmerge=1 --contention_split=1 \
      --run_for_seconds=10 --dram_gib=$cache --worker_tasks=126 \
      --worker_threads=$thread --pp_threads=$thread  --hitchhike >> YCSB-A/C${cache}-hitchhike.out

      ./../../Leanstore/build/frontend/ycsb --ssd_path="/dev/nvme3n1" --ioengine=io_uring --partition_bits=12 \
      --target_gib=1 --ycsb_read_ratio=50 --ycsb_type=1  --optimistic_parent_pointer=1 --xmerge=1 --contention_split=1 \
      --run_for_seconds=10 --dram_gib=$cache --worker_tasks=126 \
      --worker_threads=$thread --pp_threads=$thread  >> YCSB-A/C${cache}-iouring.out

      # YCSB B
      ./../../Leanstore/build/frontend/ycsb --ssd_path="/dev/nvme3n1" --ioengine=io_uring --partition_bits=12 \
      --target_gib=1 --ycsb_read_ratio=95 --ycsb_type=1  --optimistic_parent_pointer=1 --xmerge=1 --contention_split=1 \
      --run_for_seconds=10 --dram_gib=$cache --worker_tasks=126 \
      --worker_threads=$thread --pp_threads=$thread  --hitchhike >> YCSB-B/C${cache}-hitchhike.out

      ./../../Leanstore/build/frontend/ycsb --ssd_path="/dev/nvme3n1" --ioengine=io_uring --partition_bits=12 \
      --target_gib=1 --ycsb_read_ratio=95 --ycsb_type=1  --optimistic_parent_pointer=1 --xmerge=1 --contention_split=1 \
      --run_for_seconds=10 --dram_gib=$cache --worker_tasks=126 \
      --worker_threads=$thread --pp_threads=$thread  >> YCSB-B/C${cache}-iouring.out

      # YCSB C
      ./../../Leanstore/build/frontend/ycsb --ssd_path="/dev/nvme3n1" --ioengine=io_uring --partition_bits=12 \
      --target_gib=1 --ycsb_read_ratio=100 --ycsb_type=1 --optimistic_parent_pointer=1 --xmerge=1 --contention_split=1  \
      --run_for_seconds=10 --dram_gib=$cache --worker_tasks=126 \
      --worker_threads=$thread --pp_threads=$thread  --hitchhike >> YCSB-C/C${cache}-hitchhike.out

      ./../../Leanstore/build/frontend/ycsb --ssd_path="/dev/nvme3n1" --ioengine=io_uring --partition_bits=12 \
      --target_gib=1 --ycsb_read_ratio=100 --ycsb_type=1 --optimistic_parent_pointer=1 --xmerge=1 --contention_split=1  \
      --run_for_seconds=10 --dram_gib=$cache --worker_tasks=126 \
      --worker_threads=$thread --pp_threads=$thread  >> YCSB-C/C${cache}-iouring.out


      # YCSB D
      ./../../Leanstore/build/frontend/ycsb --ssd_path="/dev/nvme3n1" --ioengine=io_uring --partition_bits=12 \
      --target_gib=1 --ycsb_read_ratio=95 --ycsb_type=2 --optimistic_parent_pointer=1 --xmerge=1 --contention_split=1  \
      --run_for_seconds=10 --dram_gib=$cache --worker_tasks=126 \
      --worker_threads=$thread --pp_threads=$thread  --hitchhike >> YCSB-D/C${cache}-hitchhike.out

      ./../../Leanstore/build/frontend/ycsb --ssd_path="/dev/nvme3n1" --ioengine=io_uring --partition_bits=12 \
      --target_gib=1 --ycsb_read_ratio=95 --ycsb_type=2 --optimistic_parent_pointer=1 --xmerge=1 --contention_split=1  \
      --run_for_seconds=10 --dram_gib=$cache --worker_tasks=126 \
      --worker_threads=$thread --pp_threads=$thread  >> YCSB-D/C${cache}-iouring.out

      # # YCSB E
      # ./../../Leanstore/build/frontend/ycsb --ssd_path="/dev/nvme3n1" --ioengine=io_uring --partition_bits=12 \
      # --target_gib=1 --ycsb_scan_ratio=95 --ycsb_type=3 --optimistic_parent_pointer=1 --xmerge=1 --contention_split=1  \
      # --run_for_seconds=10 --dram_gib=$cache --worker_tasks=126 \
      # --worker_threads=$thread --pp_threads=$thread  --hitchhike >> YCSB-E/C${cache}-hitchhike.out

      # ./../../Leanstore/build/frontend/ycsb --ssd_path="/dev/nvme3n1" --ioengine=io_uring --partition_bits=12 \
      # --target_gib=1 --ycsb_scan_ratio=95 --ycsb_type=3 --optimistic_parent_pointer=1 --xmerge=1 --contention_split=1 \
      # --run_for_seconds=10 --dram_gib=$cache --worker_tasks=126 \
      # --worker_threads=$thread --pp_threads=$thread  >> YCSB-E/C${cache}-iouring.out


      # YCSB F
      ./../../Leanstore/build/frontend/ycsb --ssd_path="/dev/nvme3n1" --ioengine=io_uring --partition_bits=12 \
      --target_gib=1 --ycsb_read_ratio=50 --ycsb_type=4 --optimistic_parent_pointer=1 --xmerge=1 --contention_split=1 \
      --run_for_seconds=10 --dram_gib=$cache --worker_tasks=126 \
      --worker_threads=$thread --pp_threads=$thread  --hitchhike >> YCSB-F/C${cache}-hitchhike.out

      ./../../Leanstore/build/frontend/ycsb --ssd_path="/dev/nvme3n1" --ioengine=io_uring --partition_bits=12 \
      --target_gib=1 --ycsb_read_ratio=50 --ycsb_type=4 --optimistic_parent_pointer=1 --xmerge=1 --contention_split=1 \
      --run_for_seconds=10 --dram_gib=$cache --worker_tasks=126 \
      --worker_threads=$thread --pp_threads=$thread  >> YCSB-F/C${cache}-iouring.out

    done
  done



  
#2. process the results
echo "Processing cpu results..."
result_folder="result/"
mkdir -p "$result_folder"

for DIRECTORY in YCSB-A YCSB-B YCSB-C YCSB-D YCSB-F; do

  for FILE in "$DIRECTORY"/*; do
        [ -f "$FILE" ] || continue

        value=$(awk -F'|' '
        {
            for (i = 1; i <= NF; i++) {
                gsub(/^[ \t]+|[ \t]+$/, "", $i)
            }

            if ($2 == "10") {
                print $4
                exit
            }
        }' "$FILE")

        [ -z "$value" ] && continue

        echo "$FILE $value" >> "result/${DIRECTORY}.out"
  done
done



echo "IOPS results are stored in the 'result' folder."

#3. plot the results
echo "Plotting IOPS results..."
python3 plt.py
echo "All tasks completed."