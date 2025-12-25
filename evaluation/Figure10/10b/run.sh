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

    if [ "$depth" -eq 512 ]; then

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

        echo "$DIRECTORY $avg_lat" >> result/avg.out


        min_lat=$(awk '
        /clat \(nsec\):/ {
            match($0, /min=([0-9.]+)/, arr)
            if (arr[1]) {
                lat = arr[1]
                total += lat/1000
            }
            next
        }
        /clat \(usec\):/ {
            match($0, /min=([0-9.]+)/, arr)
            if (arr[1]) {
                lat = arr[1]
                total += lat
            }
        }
        END {
            print total
        }' "$FILE")

        echo "$DIRECTORY $min_lat" >> result/min.out

        max_lat=$(awk '
        /clat \(nsec\):/ {
            match($0, /max=([0-9.]+)/, arr)
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

        echo "$DIRECTORY $max_lat" >> result/max.out

    fi
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

    queue=$((depth * hit))
    if [ "$queue" -eq 512 ]; then

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

        echo "$DIRECTORY $avg_lat" >> result/avg.out


        min_lat=$(awk '
        /clat \(nsec\):/ {
            match($0, /min=([0-9.]+)/, arr)
            if (arr[1]) {
                lat = arr[1]
                total += lat/1000
            }
            next
        }
        /clat \(usec\):/ {
            match($0, /min=([0-9.]+)/, arr)
            if (arr[1]) {
                lat = arr[1]
                total += lat
            }
        }
        END {
            print total
        }' "$FILE")

        echo "$DIRECTORY $min_lat" >> result/min.out

        max_lat=$(awk '
        /clat \(nsec\):/ {
            match($0, /max=([0-9.]+)/, arr)
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

        echo "$DIRECTORY $max_lat" >> result/max.out
    fi
done



echo "IOPS results are stored in the 'result' folder."

#4. plot the results
echo "Plotting IOPS results..."
python3 plt.py
echo "All tasks completed."