import os
import re


# ==========================================================
# =======Update these device IDs as needed====================
DEVICE0 = 'TARGET_DISK_ID0="nvme-DAPUSTOR_DPHV5104T0TA03T2000_HS5U00A23800DTJL"'
DEVICE1 = 'TARGET_DISK_ID1="nvme-MZWLO3T8HCLS-01AGG_S7BUNE0WA01304"'
DEVICE2 = 'TARGET_DISK_ID2="nvme-SAMSUNG_MZQL21T9HCJR-00B7C_S63SNC0T837816"'

DEVICES = '''TARGET_IDS=(
    "nvme-DAPUSTOR_DPHV5104T0TA03T2000_HS5U00A23800DTJL"
    "nvme-MZWLO3T8HCLS-01AGG_S7BUNE0WA01304"
    "nvme-SAMSUNG_MZQL21T9HCJR-00B7C_S63SNC0T837816"
)'''
# ============================================================

SEARCH_DIRS = ["../evaluation", "."]
TARGET_EXTENSIONS = ('.sh')



def update_files():
    regex_id0 = r'TARGET_DISK_ID0="[^"]*"'
    regex_id1 = r'TARGET_DISK_ID1="[^"]*"'
    regex_id2 = r'TARGET_DISK_ID2="[^"]*"'
    regex_ids = r'TARGET_IDS=\([\s\S]*?\)'

    total_count = 0

    for search_dir in SEARCH_DIRS:
        if not os.path.exists(search_dir):
            print(f"Warning: directory does not exist: {search_dir}")
            continue

        print(f"Scanning directory: {os.path.abspath(search_dir)} ...")

        for root, dirs, files in os.walk(search_dir):
            for file in files:
                if file == "update_params.py":
                    continue

                if file.endswith(TARGET_EXTENSIONS):
                    filepath = os.path.join(root, file)
                    
                    try:
                        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                            content = f.read()
                    except Exception as e:
                        print(f"can't read {filepath}: {e}")
                        continue

                    has_id0 = re.search(regex_id0, content)
                    has_id1 = re.search(regex_id1, content)
                    has_id2 = re.search(regex_id2, content)
                    has_ids = re.search(regex_ids, content)

                    if not has_id0 and not has_id1 and not has_id2 and not has_ids:
                        continue

                    new_content = content
                    
                    if has_id0:
                        new_content = re.sub(regex_id0, DEVICE0, new_content)

                    if has_id1:
                        new_content = re.sub(regex_id1, DEVICE1, new_content)

                    if has_id2:
                        new_content = re.sub(regex_id2, DEVICE2, new_content)

                    if has_ids:
                        new_content = re.sub(regex_ids, DEVICES, new_content)

                    if new_content != content:
                        print(f"  [update] {filepath}")
                        try:
                            with open(filepath, 'w', encoding='utf-8') as f:
                                f.write(new_content)
                            total_count += 1
                        except Exception as e:
                            print(f"  [error]  {filepath}: {e}")

    print("-" * 30)

if __name__ == "__main__":
    update_files()