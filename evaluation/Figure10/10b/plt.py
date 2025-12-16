import os
import re
import glob
import matplotlib.pyplot as plt
import numpy as np
import itertools


folder_path = 'result' 
file_paths = glob.glob(os.path.join(folder_path, '*.out')) 


all_data = []
file_labels = []
colors = ['#ff6600','#29599c','#88b888',  '#b5b49c', '#d690ad']
# '#d1941c'


for file_path in file_paths:
    with open(file_path, 'r') as file:

        parts = re.split(r'[_\.]', os.path.basename(file_path))
        file_labels.append(parts[0])   
        data = file.readlines()
 
        data = [list(map(str, line.split())) for line in data]
       
        data.sort(key=lambda x: x[0])
        all_data.append(data)


batch_sizes = sorted(set([d[0] for sublist in all_data for d in sublist]))


n_files = len(file_labels)  
n_batches = len(batch_sizes)  

y_values = np.zeros((n_files, n_batches))


for i, data in enumerate(all_data):
    for x, y in data:
        batch_idx = batch_sizes.index(x)
        y_values[i, batch_idx] = y


plt.figure(figsize=(4.5, 3), dpi=400)

bar_width = 0.15 
x_positions = np.arange(n_files) 


color = itertools.cycle(colors)
for i, batch_size in enumerate(batch_sizes):
    bars = plt.bar(x_positions + i * bar_width, y_values[:, i], bar_width, label=f"{batch_size}", color=next(color),edgecolor='black')
    for bar in bars:
        height = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2, 1*height, '%d' % int(height), ha='center', va='bottom',rotation=0)

plt.xticks(x_positions + (n_batches - 1) * bar_width / 2, file_labels, fontsize=10)
plt.xlabel('Different Latency')
plt.ylabel('Latency (usec)')


plt.legend(fontsize=9,ncol=1)


plt.tight_layout()
plt.savefig('figure10b.pdf')
plt.close()
