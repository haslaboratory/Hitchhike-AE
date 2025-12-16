#!/bin/bash

#1. copy necessary files
cp -r "../11c/iouring" "../11c/iouring-fb" "../11c/libaio" "../11c/iouring-iopoll-fb" "../11c/hitchhike-uring" .

#2. process the results
echo "Processing cpu results..."
result_folder="result/"
mkdir -p "$result_folder"

for DIRECTORY in iouring iouring-fb iouring-iopoll-fb libaio; do

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


    avg_lat=$(awk '
    /clat \(nsec\):/ {
        match($0, /avg *= *([0-9.]+)/, arr)
        if (arr[1]) {
            lat = arr[1]
            total += lat/1000
        }
        next
    }
    /clat \(usec\):/ {
        match($0, /avg *= *([0-9.]+)/, arr)
        if (arr[1]) {
            lat = arr[1]
            total += lat
        }
    }
    END {
        print total
    }' "$FILE")


    echo "$total_iops $avg_lat" >> result/iops-lat_$DIRECTORY.out

  done
done

# process hitchhike results
DIRECTORY="hitchhike-uring"

for FILE in "$DIRECTORY"/*; do
    FILENAME=$(basename "$FILE")

    total_iops=$(awk '
    /Hitchhike  read: IOPS=/ {
        match($0, /Hitchhike  read: IOPS=([0-9]+(\.[0-9]+)?)(k?)/, arr)
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


    avg_lat=$(awk '
    /clat \(nsec\):/ {
        match($0, /avg=([0-9.]+)/, arr)
        if (arr[1]) {
            lat = arr[1]
            total += lat/1000
        }
        next
    }
    /clat \(usec\):/ {
        match($0, /avg=([0-9.]+)/, arr)
        if (arr[1]) {
            lat = arr[1]
            total += lat
        }
    }
    END {
        print total
    }' "$FILE")

    echo "$total_iops $avg_lat" >> result/iops-lat_$DIRECTORY.out
done



echo "IOPS results are stored in the 'result' folder."

#4. plot the results
echo "Plotting IOPS results..."
python3 plt.py
echo "All tasks completed."