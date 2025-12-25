#!/bin/bash

#1. copy necessary files
cp -r "../9c/iouring-iopoll-fb" "../9c/iouring-sqpoll-fb" "../9c/iouring-cmd-iopoll-fb" "../9c/hitchhike-uring" "../9c/spdk" .

#2. process the results
echo "Processing cpu results..."
result_folder="result/"
# Remove previous results and create a new result folder
rm -rf "$result_folder"
mkdir -p "$result_folder"

for DIRECTORY in iouring-iopoll-fb iouring-sqpoll-fb iouring-cmd-iopoll-fb hitchhike-uring spdk; do

  for FILE in "$DIRECTORY"/*; do
      FILENAME=$(basename "$FILE")
      if [[ $FILENAME =~ T([0-9]+) ]]; then
        thread=${BASH_REMATCH[1]}
      else
          continue
      fi
   total_cpu=$(awk '
    /cpu[ ]*:/ {
        match($0, /usr=([0-9.]+)%/, arr_usr)
        match($0, /sys=([0-9.]+)%/, arr_sys)
        if (arr_usr[1]) {
            total += arr_usr[1]
            # print arr_usr[1]
        }
        if (arr_sys[1]) {
            total += arr_sys[1]
        }
    }
    END {
          printf "%d\n", total
      }' "$FILE")

    DIRECTORY=$(echo "$DIRECTORY" | sed 's/\//_/g')
    echo "$total_cpu" >> result/cpu_$DIRECTORY.out
  done
done


echo "IOPS results are stored in the 'result' folder."

#4. plot the results
echo "Plotting IOPS results..."
python3 plt.py
echo "All tasks completed."