import matplotlib
import matplotlib.pyplot as plt
import os

import numpy as np
import matplotlib.pyplot as plt
import re
import itertools
# Specify the directory containing the files
directories = [
    'result/',
]

# Function to read data from a file
def read_data(filename):
    with open(filename, 'r') as f:
        return [float(line.strip()) for line in f]

colors = ['#d1941c','#ff6600', '#29599c', '#88b888','#b5b49c', '#d690ad']
# Loop through each directory
for directory in directories:
    # Initialize a figure
    plt.figure(figsize=(4.5, 3),dpi=400)
    marker = itertools.cycle(('X', 's', 'v', 'o', 'p', 'd'))
    color = itertools.cycle(colors)
    # Loop through all files in the directory
    sorted_dir = sorted(os.listdir(directory))
    for i, filename in enumerate(sorted_dir):
       
        if filename.endswith(".out"):  # Ensure only files with the .out extension are processed
            # Get the full path of the file
            filepath = os.path.join(directory, filename)
            # Extract the label from the filename
            parts = re.split(r'[_\.]', filename)
            label = f"{parts[1]}" # e.g., 'libaio_batch'
            # Read data from the file
            data = read_data(filepath)
            # Create x-coordinates starting from 1, with a step of 1
            x_values = range(1, len(data) + 1,1)
            # Plot the data with the extracted label
            plt.plot(x_values, data,  label=label,marker=next(marker), markersize=9, linewidth=2, linestyle='-',color=next(color))


    # Set y-axis limits and ticks
    plt.ylim(0)  # Start y-axis at 0
    plt.yticks(range(0, int(max(data)) + 1000, 1000))  

    plt.xlabel('Thread Count',fontsize=11)
    plt.ylabel('Throughput (KIOPS)',fontsize=11)
    # plt.title('io')

    plt.legend(fontsize=11)
    plt.tight_layout()
    plt.grid(True,axis='y')


    plt.savefig(f'figure11b.pdf')
    plt.close() 