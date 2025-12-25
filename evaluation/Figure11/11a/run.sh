#!/bin/bash

TEST_FILES="/mnt/SSD0/testfile /mnt/SSD1/testfile /mnt/SSD2/testfile"

#1. run
echo "FIO tests started..."
idx=0
for i in ${TEST_FILES}; do
  ./fio_libaio.sh ${i} "$idx"
  ./fio_iouring.sh ${i} "$idx"
  ./fio_hit.sh ${i} "$idx"
  idx=$((idx + 1))
done


#2. process the results
echo "Processing Bandwidth results..."
result_folder="result/"
# Remove previous results and create a new result folder
rm -rf "$result_folder"
mkdir -p "$result_folder" 

for SSD in SSD0 SSD1 SSD2; do
  for ENGINE in libaio iouring iouring-fb iouring-iopoll-fb; do
    DIRECTORY="$SSD/$ENGINE"
    [ -d "$DIRECTORY" ] || continue

    for FILE in "$DIRECTORY"/*; do
        total_iops=$(awk '
        / read: IOPS=/ {
            match($0, / read: IOPS=([0-9]+(\.[0-9]+)?)(k?)/, arr)
            if (arr[1]) {
                iops = arr[1]
                if (arr[3] == "k") {
                    iops *= 1000
                }
                total += (iops/1000)
            }
        }
        END {
            printf "%d\n", total
        }' "$FILE")

      echo "$ENGINE $total_iops" >> result/iops_$SSD.out
    done
  done
done


for SSD in SSD0 SSD1 SSD2; do
 for ENGINE in hitchhike-uring; do
    DIRECTORY="$SSD/$ENGINE"
    [ -d "$DIRECTORY" ] || continue

    for FILE in "$DIRECTORY"/*; do
      total_iops=$(awk '
      /Hitchhike  read: IOPS=/ {
          match($0, /read: IOPS=([0-9]+(\.[0-9]+)?)(k?)/, arr)
          if (arr[1]) {
              iops = arr[1]
              if (arr[3] == "k") {
                  iops *= 1000
              }
              total += (iops/1000)
          }
      }
      END {
          printf "%d\n", total
      }' "$FILE")

      echo "$ENGINE $total_iops" >> result/iops_$SSD.out
    done
  done
done

echo "IOPS results are stored in the 'result' folder."

#4. plot the results
echo "Plotting IOPS results..."
python3 plt.py
echo "All tasks completed."
