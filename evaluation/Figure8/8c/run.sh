#!/bin/bash

# SSD0: /dev/nvme3n1 H5300
# change it according to your test device (H5300 PCIe 5.0 NVMe SSD is recommended)

#0. copy SPDK evaluation results
SRC="../../spdk/depth"
DST="./spdk"

if [ ! -d "$SRC" ]; then
    echo "Error: source directory $SRC does not exist"
    exit 1
fi

mkdir -p "$DST"
cp -r "$SRC"/. "$DST"/



#1. check the device
TEST_DEVS="/dev/nvme3n1"
TEST_DEVS_CMD="/dev/ng3n1"

for dev in ${TEST_DEVS}; do
  # 1. block device?
  if [ ! -b "$dev" ]; then
    echo "Error! $dev is not a block device."
    exit 1
  fi

  # 2. No filesystem?
  fstype=$(lsblk -dn -o FSTYPE "$dev")
  if [ -n "$fstype" ]; then
    echo "Error! $dev has filesystem: $fstype"
    exit 1
  fi

  # 3. Not mounted?
  mountpoint=$(lsblk -dn -o MOUNTPOINT "$dev")
  if [ -n "$mountpoint" ]; then
    echo "Error! $dev is mounted at $mountpoint"
    exit 1
  fi
done

# 2. run FIO tests
echo "FIO tests started..."
for i in ${TEST_DEVS}; do
  ./fio_libaio.sh ${i}
  ./fio_iouring.sh ${i}
  ./fio_hit.sh ${i}
done
for i in ${TEST_DEVS_CMD}; do
  ./fio_iouring_cmd.sh ${i}
done
echo "FIO tests completed."

#3. process the results
echo "Processing Bandwidth results..."
result_folder="result/"
mkdir -p "$result_folder"

for DIRECTORY in libaio iouring-fb iouring-cmd-fb spdk; do

  for FILE in "$DIRECTORY"/*; do
      FILENAME=$(basename "$FILE")
      if [[ $FILENAME =~ D([0-9]+) ]]; then
        depth=${BASH_REMATCH[1]}
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
    echo "$depth $total_iops" >> result/iops_$DIRECTORY.out
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

    queue=$((depth * hit))
    if [ "$queue" -eq 1000 ]; then
      queue=1024
    fi
    DIRECTORY=$(echo "$DIRECTORY" | sed 's/\//_/g')
    echo "$queue $total_iops" >> result/iops_$DIRECTORY.out

done

echo "IOPS results are stored in the 'result' folder."

#4. plot the results
echo "Plotting IOPS results..."
python3 plt.py
echo "All tasks completed."