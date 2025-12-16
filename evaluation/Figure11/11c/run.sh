#!/bin/bash

# SSD0: /dev/nvme0n1 H5300
# change it according to your test device (H5300 PCIe 5.0 NVMe SSD is recommended)


#1. check the device
TEST_FILES="/mnt/SSD0/testfile"

# 2. run FIO tests
echo "FIO tests started..."
for i in ${TEST_FILES}; do
  ./fio_libaio.sh ${i}
  ./fio_iouring.sh ${i}
  ./fio_hit.sh ${i}
done

echo "FIO tests completed."

#3. process the results
echo "Processing Bandwidth results..."
result_folder="result/"
mkdir -p "$result_folder"

for DIRECTORY in iouring iouring-iopoll-fb iouring-fb libaio; do

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
DIRECTORY="hitchhike-uring"

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