#!/bin/bash

# Directory to store downloaded datasets, modify it as needed
TARGET_DIR="mnt/SSD1/"

DATASETS=(
    "rmat27"
    "rmat30"
    "uran27"
    "twitter"
    "sk2005"
    "friendster"
)


BASE_URL="https://storage.googleapis.com/nvsl-aepdata/graphdata/sc22"


if ! command -v wget &> /dev/null || ! command -v unzip &> /dev/null; then
    echo "Error: install 'wget' and 'unzip' to run this script."
    echo "Ubuntu/Debian: sudo apt install wget unzip"
    echo "CentOS/RHEL:   sudo yum install wget unzip"
    exit 1
fi

mkdir -p "$TARGET_DIR"
echo "dataset directory: $(readlink -f $TARGET_DIR)"

for name in "${DATASETS[@]}"; do
    zip_filename="${name}.zip"
    url="${BASE_URL}/${zip_filename}"
    local_filepath="${TARGET_DIR}/${zip_filename}"

    echo "--------------------------------------------------------"
    echo "processing: $name"
    echo "--------------------------------------------------------"

    echo "[1/2] downloading $zip_filename ..."
    wget -c --progress=bar:force "$url" -P "$TARGET_DIR"

    if [ $? -ne 0 ]; then
        echo "Error: download $name failed!"
        continue
    fi


    echo "[2/2] unzipping $zip_filename ..."
    unzip -j -n "$local_filepath" -d "$TARGET_DIR"

    if [ $? -eq 0 ]; then
        echo "Success: $name"
    else
        echo "Warning: failed to unzip $name"
    fi

done

echo "--------------------------------------------------------"
echo "completed all datasets."
ls -lh "$TARGET_DIR"