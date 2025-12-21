import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import os

INPUT_DIR = './result'


LEGEND_LABELS = [
    'libaio', 
    'Hit-32', 
    'Hit-96', 
    'Hit-128'
]
COLORS = ['#e3e4e6','#f6dc8d', '#fabf2c', '#ff643c']
Y_LABEL = 'Time (seconds)'

# ===========================================
files = [f for f in os.listdir(INPUT_DIR) if f.endswith('_results.txt')]

if not files:
    print(f"在 {INPUT_DIR} no _results.txt。")
    exit()

for filename in files:
    filepath = os.path.join(INPUT_DIR, filename)
    algorithm_name = filename.replace('_results.txt', '')
    
    print(f"figure: {filename} ...")

    try:

        df = pd.read_csv(filepath, delim_whitespace=True)
   
        if df.empty:
            print(f" skip: {filename}")
            continue

      
        datasets = df.columns.tolist() 
        n_datasets = len(datasets)
        n_configs = len(df) 

        current_labels = LEGEND_LABELS
        if len(LEGEND_LABELS) < n_configs:
            current_labels = [f'Config {i}' for i in range(n_configs)]
        

        fig, ax = plt.subplots(figsize=(10, 5), dpi=300)

    
        x = np.arange(n_datasets) 
        total_width = 0.8          
        bar_width = total_width / n_configs 
        
        for i in range(n_configs):
    
            values = df.iloc[i].values
            

            offset = -total_width/2 + (i * bar_width) + (bar_width/2)
            
        
            c = COLORS[i % len(COLORS)] 
            bars = ax.bar(x + offset, values, bar_width, label=current_labels[i], color=c, edgecolor='black', linewidth=0.5)
            
            # add value labels
            # for bar in bars:
            #     height = bar.get_height()
            #     if height > 0:
            #         ax.annotate(f'{height:.1f}',
            #                     xy=(bar.get_x() + bar.get_width() / 2, height),
            #                     xytext=(0, 3),  # 3 points vertical offset
            #                     textcoords="offset points",
            #                     ha='center', va='bottom', fontsize=6, rotation=90)

        ax.set_ylabel(Y_LABEL, fontsize=12)
        ax.set_title(f'Performance: {algorithm_name.upper()}', fontsize=14)
        ax.set_xticks(x)
        ax.set_xticklabels(datasets, fontsize=12)
        
        
        ax.legend(loc='upper left', ncol=2, fontsize=10)
        
    
        ax.yaxis.grid(True, linestyle='--', alpha=0.3)
        ax.set_axisbelow(True) 


        plt.tight_layout()
        plt.savefig(f'{algorithm_name}.pdf')
        plt.close() 
        

    except Exception as e:
        print(f"  error: {filename}: {e}")

print("completed.")