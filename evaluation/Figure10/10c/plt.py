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
        parts = re.split(r'[/\.\_]', file_path)
        label.append(f"{parts[2]}")  
        data = file.readlines()
        parsed_data = [(int(line.split()[0]), float(line.split()[1])) for line in data]

        parsed_data.sort(key=lambda x: x[0])
        all_data.append(parsed_data)

all_x_values = sorted(set([d[0] for sublist in all_data for d in sublist]))


max_x_value = max(all_x_values)

x_ticks = np.arange(0, max_x_value + 500, 500)


plt.figure(figsize=(4.5, 3), dpi=400)


colors =  ['#ff6600','#29599c','#88b888',  '#b5b49c', '#d690ad']
marker = itertools.cycle(('X', 's', 'v', 'o', 'p', 'd'))
color = itertools.cycle(colors)


for i, data in enumerate(all_data):
    file_x_values = [d[0] for d in data]
    file_y_values = [d[1] for d in data]
    
    plt.plot(file_x_values, file_y_values, color=next(color), label=label[i], 
             marker=next(marker), markersize=9, linewidth=2, linestyle='-')

plt.xticks(x_ticks, [str(x) for x in x_ticks], fontsize=10)


plt.xlabel('Throughput (KIOPS)', fontsize=11)
plt.ylabel('Latency (us)',fontsize=11)


plt.legend(fontsize=11)


plt.tight_layout()
plt.savefig('figure10c.pdf')
plt.close()
