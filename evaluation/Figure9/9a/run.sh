#!/bin/bash

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
TARGET_IDS=(
    "nvme-DAPUSTOR_DPHV5104T0TA03T2000_HS5U00A23800DTJL"
    "nvme-MZWLO3T8HCLS-01AGG_S7BUNE0WA01304"
    "nvme-SAMSUNG_MZQL21T9HCJR-00B7C_S63SNC0T837816"
)
TEST_DEVS=""
TEST_DEVS_CMD=""

for id in "${TARGET_IDS[@]}"; do
    real_dev=$(readlink -f "/dev/disk/by-id/$id")
    if [ -z "$real_dev" ] || [ ! -e "$real_dev" ]; then
        echo "Error: can't find device ID: $id"
        exit 1
    fi
    ng_dev=${real_dev/nvme/ng}

    if [ -z "$TEST_DEVS" ]; then
        TEST_DEVS="$real_dev"
        TEST_DEVS_CMD="$ng_dev"
    else
        TEST_DEVS="$TEST_DEVS $real_dev"
        TEST_DEVS_CMD="$TEST_DEVS_CMD $ng_dev"
    fi
done

echo "Block Devices (TEST_DEVS):"
echo "$TEST_DEVS"
echo ""
echo "Char Devices (TEST_DEVS_CMD):"
echo "$TEST_DEVS_CMD"

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
# Remove previous results and create a new result folder
rm -rf "$result_folder"
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
