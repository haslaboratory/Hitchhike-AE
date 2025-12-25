#!/bin/bash

# SSD0 H5300 
TARGET_DISK_ID0="nvme-DAPUSTOR_DPHV5104T0TA03T2000_HS5U00A23800DTJL"
TEST_DEVS=$(readlink -f /dev/disk/by-id/${TARGET_DISK_ID0})
if [ -z "$TEST_DEVS" ]; then
    echo "Error: can't find device $TARGET_DISK_ID0"
    exit 1
fi
echo "Block Devices (TEST_DEVS):"
echo "$TEST_DEVS"

#1. check the device
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


#2. run FIO tests
echo "FIO tests started..."
for i in ${TEST_DEVS}; do
echo "libaio test on ${i}"
  ./fio_libaio.sh ${i}
echo "iouring test on ${i}"
  ./fio_iouring.sh ${i}
done
echo "FIO tests completed."


#3. process the results
echo "Processing IOPS results..."
result_folder="result/"
# Remove previous results and create a new result folder
rm -rf "$result_folder"
mkdir -p "$result_folder"

for DIRECTORY in libaio iouring; do

  for FILE in "$DIRECTORY"/*; do
      FILENAME=$(basename "$FILE")
      if [[ $FILENAME =~ batch([0-9]+) ]]; then
          BATCH=${BASH_REMATCH[1]}
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
          print total
      }' "$FILE")

      DIRECTORY=$(echo "$DIRECTORY" | sed 's/\//_/g')
      echo "$BATCH $total_iops" >> ${result_folder}/IOPS_${DIRECTORY}.out
  done
done
echo "IOPS results are stored in the 'result' folder."

#4. plot the results
echo "Plotting IOPS results..."
python3 plt.py


