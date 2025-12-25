#!/bin/bash

TEST_FILES="/mnt/SSD0/testfile"

#1. run
echo "FIO tests started..."
for i in ${TEST_FILES}; do
  ./fio_libaio.sh ${i} 
  ./fio_iouring.sh ${i}
  ./fio_hit.sh ${i}
done


#2. process the results
echo "Processing Bandwidth results..."
result_folder="result/"
# Remove previous results and create a new result folder
rm -rf "$result_folder"
mkdir -p "$result_folder" 

for DIRECTORY in libaio iouring iouring-fb iouring-iopoll-fb; do

  for FILE in "$DIRECTORY"/*; do
      FILENAME=$(basename "$FILE")
      if [[ $FILENAME =~ T([0-9]+) ]]; then
        thread=${BASH_REMATCH[1]}
      else
          continue
      fi

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

    DIRECTORY=$(echo "$DIRECTORY" | sed 's/\//_/g')
    echo "$total_iops" >> result/iops_$DIRECTORY.out
  done
done

for DIRECTORY in hitchhike-uring; do
  for FILE in "$DIRECTORY"/*; do
      FILENAME=$(basename "$FILE")
      if [[ $FILENAME =~ T([0-9]+) ]]; then
          thread=${BASH_REMATCH[1]}
      else
            continue
      fi


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

    DIRECTORY=$(echo "$DIRECTORY" | sed 's/\//_/g')
    echo "$total_iops" >> result/iops_$DIRECTORY.out
  done
done

echo "IOPS results are stored in the 'result' folder."

#4. plot the results
echo "Plotting IOPS results..."
python3 plt.py
echo "All tasks completed."
