#!/bin/bash

#1. copy necessary files
cp -r "../8c/libaio" "../8c/iouring" "../8c/iouring-cmd" "../8c/hitchhike" "../8c/spdk" .

#2. process the results
echo "Processing cpu results..."
result_folder="result/"
# Remove previous results and create a new result folder
rm -rf "$result_folder"
mkdir -p "$result_folder"

for DIRECTORY in libaio iouring iouring-cmd spdk; do

  for FILE in "$DIRECTORY"/*; do
      FILENAME=$(basename "$FILE")
      if [[ $FILENAME =~ D([0-9]+) ]]; then
        depth=${BASH_REMATCH[1]}
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
    echo "$depth $total_cpu" >> result/cpu_$DIRECTORY.out
  done
done

#3 process hitchhike results
DIRECTORY="hitchhike"

for FILE in "$DIRECTORY"/*; do
    FILENAME=$(basename "$FILE")
    if [[ $FILENAME =~ hitchhike([0-9]+).*depth([0-9]+) ]]; then
        hit=${BASH_REMATCH[1]}
        depth=${BASH_REMATCH[2]}
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
    queue=$((depth * hit))
    if [ "$queue" -eq 1000 ]; then
      queue=1024
    fi
    echo "$queue $total_cpu" >> result/cpu_$DIRECTORY.out

done

echo "IOPS results are stored in the 'result' folder."

#4. plot the results
echo "Plotting IOPS results..."
python3 plt.py
echo "All tasks completed."