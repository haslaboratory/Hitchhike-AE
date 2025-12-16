
import os
import re
import glob
import matplotlib.pyplot as plt
import numpy as np

folder_path = 'result'  
file_paths = glob.glob(os.path.join(folder_path, '*.out')) 

all_data = []
label = []

for file_path in file_paths:
    with open(file_path, 'r') as file:
        parts = re.split(r'[_\.]', file_path)
        label.append(f"{parts[1]}") 
        data = file.readlines()
        data = [list(map(int, line.split())) for line in data]
        data.sort(key=lambda x: x[0])
        all_data.append(data)

all_x_values = sorted(set([d[0] for sublist in all_data for d in sublist]))


plt.figure(figsize=(4.5, 3),dpi=400)
colors = [ "#c37021", '#e89741']
offset = 0.3 
width = 0.3 


file_y_values = {file: [d[1] for d in data] for file, data in enumerate(all_data)}

for i, (file, y_values) in enumerate(file_y_values.items()):
    y_positions = [y_values[all_x_values.index(x)] if x in [d[0] for d in all_data[file]] else 0 for x in all_x_values]
    plt.bar(np.arange(len(all_x_values)) + offset * i, y_positions, width, color=colors[i % len(colors)], label=label[i],edgecolor='black')

plt.xticks(np.arange(len(all_x_values)), [str(x) for x in all_x_values])  # rotation=90

plt.xlabel('Batch Size')
plt.ylabel('IOPS(K)')

plt.legend(fontsize=11)
plt.tight_layout()
    
plt.savefig(f'Figure8a.pdf')
plt.close() 