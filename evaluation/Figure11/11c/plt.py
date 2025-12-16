
import os
import re
import glob
import matplotlib.pyplot as plt
import numpy as np
import itertools


folder_path = 'result' 
file_paths = glob.glob(os.path.join(folder_path, '*.out'))  


all_data = []
label = []

for file_path in file_paths:
    with open(file_path, 'r') as file:
        parts = re.split(r'[_\.]', file_path)
        label.append(f"{parts[1]}") 
        data = file.readlines()
        parsed_data = [(int(line.split()[0]), float(line.split()[1])) for line in data]

        parsed_data.sort(key=lambda x: x[0])
        all_data.append(parsed_data)

all_x_values = sorted(set([d[0] for sublist in all_data for d in sublist]))


plt.figure(figsize=(4.5, 3),dpi=400)


# colors = [ "#c37021", '#e89741']
colors = ['#ff6600','#88b888', '#29599c', '#b5b49c', '#d690ad']
marker = itertools.cycle(('X', 's', 'v', 'o', 'p', 'd'))
color = itertools.cycle(colors)


file_y_values = {file: [d[1] for d in data] for file, data in enumerate(all_data)}

for i, (file, y_values) in enumerate(file_y_values.items()):
    y_positions = [y_values[all_x_values.index(x)] if x in [d[0] for d in all_data[file]] else 0 for x in all_x_values]
    label_file=label[i]
    plt.plot(np.arange(len(all_x_values)), y_positions, color=next(color), label=label_file, marker=next(marker), markersize=9, linewidth=2, linestyle='-')


plt.xticks(np.arange(len(all_x_values)), [str(x) for x in all_x_values])  # rotation=90

plt.xlabel('Queue Depth')
plt.ylabel('Latency (us)')

plt.legend(fontsize=11)
plt.tight_layout()

plt.savefig(f'figure11c.pdf')
plt.close() 