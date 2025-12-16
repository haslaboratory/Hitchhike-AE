#!/bin/bash
# SSD0: /dev/nvme0n1 H5300  SSD1: /dev/nvme4n1  PM1743; SSD2: /dev/nvme2n1 PM9A3; 


#0. copy SPDK evaluation results
SSDS=("SSD0" "SSD1" "SSD2")

for SSD in "${SSDS[@]}"; do
    SRC="../../spdk/$SSD"
    DST="./$SSD"

    if [ ! -d "$SRC" ]; then
        echo "Error: source directory $SRC does not exist"
        exit 1
    fi

    mkdir -p "$DST/spdk"
    cp -a "$SRC"/. "$DST/spdk"/

    echo "[INFO] Copied $SRC to $DST/spdk"
done



#1. check the device

TEST_DEVS="/dev/nvme3n1 /dev/nvme4n1 /dev/nvme0n1"
TEST_DEVS_CMD="/dev/ng3n1 /dev/ng4n1 /dev/ng0n1"

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
idx=0
for i in ${TEST_DEVS}; do
 ./fio_libaio.sh  "$i" "$idx"
 ./fio_iouring.sh "$i" "$idx"
  ./fio_hit.sh     "$i" "$idx"
  idx=$((idx + 1))
done

idx=0
for i in ${TEST_DEVS_CMD}; do
  ./fio_iouring_cmd.sh "$i" "$idx"
  idx=$((idx + 1))
done
echo "FIO tests completed."

#3. process the results
echo "Processing Bandwidth results..."
result_folder="result/"
mkdir -p "$result_folder" 

for SSD in SSD0 SSD1 SSD2; do
  for ENGINE in libaio iouring-fb iouring-cmd-fb spdk; do
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
 for ENGINE in hitchhike-aio hitchhike-uring; do
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
