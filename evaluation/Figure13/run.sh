#!/bin/bash

# need to set the dataset path in blaze-aio.sh and blaze-hit.sh
DATASET_DIR="/mnt/SSD1/mnt/nvme/sc22"

#1. create result directories
LEVEL1_DIRS="bfs pagerank wcc bc"
LEVEL2_DIRS="rmat27 uran27 twitter sk2005 friendster rmat30"

for l1 in $LEVEL1_DIRS; do
    for l2 in $LEVEL2_DIRS; do
        mkdir -p "$l1/$l2"
    done
done

#2. run blaze-aio.sh and blaze-hit.sh
echo "Blaze tests started..."
for i in ${DATASET_DIR}; do
  ./blaze-aio.sh  "$i"
  ./blaze-hit.sh "$i"
done
echo "Blaze tests completed."

#3. process the results
echo "Processing cpu results..."

# define arrays for L1 and L2 directories
L1_DIRS=("bfs" "pagerank" "wcc" "bc")
L2_DIRS=("rmat27" "uran27" "twitter" "sk2005" "friendster" "rmat30")

RESULT_FOLDER="./result"
TEMP_DIR="./tmp_columns" 
FILE_PATTERN="*.txt"

# Remove previous results and create a new result folder
rm -rf "$RESULT_FOLDER"
mkdir -p "$RESULT_FOLDER"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

for DIR_L1 in "${L1_DIRS[@]}"; do
    
    OUTPUT_FILE="${RESULT_FOLDER}/${DIR_L1}_results.txt"
    echo "L1 DIR: $DIR_L1 -> $OUTPUT_FILE"
    
    # echo: rmat27  uran27  twitter ...
    echo -e "${L2_DIRS[*]}" | tr ' ' '\t' > "$OUTPUT_FILE"

    # temporary directory for column files
    COL_FILES=()

    # traverse (rmat27, uran27...)
    for DIR_L2 in "${L2_DIRS[@]}"; do
        
        # tmp file for this column
        COL_FILE="${TEMP_DIR}/${DIR_L1}_${DIR_L2}.col"
        > "$COL_FILE" 
        
        TARGET_PATH="${DIR_L1}/${DIR_L2}"
        
        if [ -d "$TARGET_PATH" ]; then
            # =======================================================
            # sort -V : natural version number sort
            # =======================================================
            find "$TARGET_PATH" -maxdepth 1 -name "$FILE_PATTERN" | sort -V | while read FILE; do
                
                # extract value
                VAL=$(grep "^# IO SUMMARY" "$FILE" | sed -n 's/.*bytes, \{0,\}\([0-9.]\{1,\}\) \{0,\}sec.*/\1/p')

                if [ -z "$VAL" ]; then
                    VAL="0"
                fi

                echo "$VAL" >> "$COL_FILE"
            done
        else
            echo "Warning: directory does not exist $TARGET_PATH"
            echo "0" >> "$COL_FILE" 
        fi
        
        # collect column file
        COL_FILES+=("$COL_FILE")
    done

    # 3. paste the column files into the output file
    # paste file1 file2 file3 > output_file
    paste "${COL_FILES[@]}" >> "$OUTPUT_FILE"
    
    echo "  -> Completed."

done
# remove temporary directory
rm -rf "$TEMP_DIR"
echo "done."



#4. plot the results
echo "Plotting IOPS results..."
python3 plt.py
echo "All tasks completed."