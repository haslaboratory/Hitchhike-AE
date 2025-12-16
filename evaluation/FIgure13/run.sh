#!/bin/bash


# 1. run the experiments

# need to set the dataset path in blaze-aio.sh and blaze-hit.sh
DATASET_DIR="/mnt/"

echo "FIO tests started..."
for i in ${DATASET_DIR}; do
  ./blaze-aio.sh  "$i"
  ./blaze-hit.sh "$i"
done
echo "Blaze tests completed."


  
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