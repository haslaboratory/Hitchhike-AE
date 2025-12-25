#!/bin/bash

#1. copy necessary files
cp -r "../../Figure8/8c/iouring" "../../Figure8/8c/iouring-cmd" "../../Figure8/8c/libaio" "../../Figure8/8c/hitchhike" "../../Figure8/8c/spdk" .

#2. process the results
echo "Processing cpu results..."
result_folder="result/"
# Remove previous results and create a new result folder
rm -rf "$result_folder"
mkdir -p "$result_folder"

for DIRECTORY in iouring iouring-cmd libaio spdk; do

  for FILE in "$DIRECTORY"/*; do
    FILENAME=$(basename "$FILE")
    if [[ $FILENAME =~ D([0-9]+) ]]; then
      depth=${BASH_REMATCH[1]}
    else
        continue
    fi
    lat99=$(awk '
        /clat percentiles/ {
            if (index($0, "nsec") > 0) {
                unit = "nsec"
            } else if (index($0, "usec") > 0) {
                unit = "usec"
            }
            next
        }
        /99.00th/ {
            if (match($0, /99.00th=\[ *([0-9.]+)\]/, arr)) {
                value = arr[1]
                if (unit == "usec") {
                    print value
                } else if (unit == "nsec") {
                    print value/1000
                }
            }
        }' "$FILE")

    DIRECTORY=$(echo "$DIRECTORY" | sed 's/\//_/g')
    echo "$depth $lat99" >> result/lat_$DIRECTORY.out
  done
done

# process hitchhike results
DIRECTORY="hitchhike"

for FILE in "$DIRECTORY"/*; do
    FILENAME=$(basename "$FILE")
    if [[ $FILENAME =~ hitchhike([0-9]+).*depth([0-9]+) ]]; then
        hit=${BASH_REMATCH[1]}
        depth=${BASH_REMATCH[2]}
    else
          continue
    fi

    lat99=$(awk '
        /clat percentiles/ {
            if (index($0, "nsec") > 0) {
                unit = "nsec"
            } else if (index($0, "usec") > 0) {
                unit = "usec"
            }
            next
        }
        /99.00th/ {
            if (match($0, /99.00th=\[ *([0-9.]+)\]/, arr)) {
                value = arr[1]
                if (unit == "usec") {
                    print value
                } else if (unit == "nsec") {
                    print value/1000
                }
            }
        }' "$FILE")

    queue=$((depth * hit))
    if [ "$queue" -eq 1000 ]; then
      queue=1024
    fi
    echo "$queue $lat99" >> result/lat_$DIRECTORY.out

done



echo "IOPS results are stored in the 'result' folder."

#4. plot the results
echo "Plotting IOPS results..."
python3 plt.py
echo "All tasks completed."