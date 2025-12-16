import matplotlib.pyplot as plt
import numpy as np
import os

# ================= Configuration Area =================
# Directory containing the result files
input_dir = 'result'  # <--- Change this if your folder name is different

# Dataset names
datasets = ['YCSB-A', 'YCSB-B', 'YCSB-C', 'YCSB-D', 'YCSB-F']

# Legend/Method order (Ensure the line order in the files matches this strictly)
methods = [ 'hitchhike-uring-256MB','io_uring-256MB',
           'hitchhike-uring-512MB', 'io_uring-512MB',
           'hitchhike-uring-1GB','io_uring-1GB',
           'hitchhike-uring-2GB','io_uring-2GB']

# ================= Automatic Data Loading =================
data = {} # Initialize data dictionary

for dataset in datasets:
    # Construct full file path: result/YCSB-A.out
    filename = f'{dataset}.out'
    filepath = os.path.join(input_dir, filename)
    
    current_file_values = []
    
    if not os.path.exists(filepath):
        print(f"❌ Error: File {filepath} not found, filling with 0.")
        current_file_values = [0] * len(methods)
    else:
        print(f"Reading {filepath} ...")
        with open(filepath, 'r') as f:
            for line in f:
                parts = line.strip().split()
                # Ensure the line has data (skip empty lines)
                if len(parts) >= 2:
                    # Read data from the second column
                    val_str = parts[1]
                    try:
                        # Unit conversion: assume input is 0.3xxx (Mops), chart shows 3xx (Kops), so * 1000
                        val = float(val_str) * 1000
                        current_file_values.append(val)
                    except ValueError:
                        print(f"  Warning: Cannot parse value '{val_str}' in file {filepath}")
    
    # Check if data row count matches the number of methods
    if len(current_file_values) < len(methods):
        print(f"⚠️ Warning: {filename} row count ({len(current_file_values)}) is less than Methods count ({len(methods)}), bars might be missing.")
    
    # Store in dictionary
    data[dataset] = current_file_values

# ================= Start Plotting (Style unchanged) =================
fig, ax = plt.subplots(figsize=(10, 4), dpi=400)

bar_width = 0.12
index = np.arange(len(datasets))

colors = ['#e3e4e6','#f6dc8d', 
          '#c0c5ce','#fabf2c',
          '#999999','#ff8a36', 
          '#555555','#ff643c']

# Plotting loop
for i, method in enumerate(methods):
    y_values = []
    for dataset in datasets:
        if i < len(data[dataset]):
            y_values.append(data[dataset][i])
        else:
            y_values.append(0)

    bars = ax.bar(index + i * bar_width, y_values, bar_width, label=method, color=colors[i], edgecolor='black')
    
    # Add value labels
    for bar in bars:
        height = bar.get_height()
        if height > 0: # Only show if greater than 0
            plt.text(bar.get_x() + bar.get_width()/2., 0.2*height, '%d' % int(height), ha='center', va='bottom', rotation=90)

# Set axis labels and legend
ax.set_ylabel('KV Operations/Second (K)', fontsize=14)
ax.set_xticks(index + bar_width * (len(methods) // 2))
ax.set_xticklabels(datasets, fontsize=14)
ax.legend(loc='upper left', ncol=2, fontsize=12)

plt.tight_layout()
output_name = 'Figure14.pdf'
plt.savefig(output_name)
print(f"✅ Image saved as {output_name}")