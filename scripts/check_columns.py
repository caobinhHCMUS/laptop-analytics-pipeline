import pandas as pd
import glob

# Đọc thử 1 dòng từ các file parquet trong thư mục data/
for file_path in glob.glob("data/*.parquet"):
    df = pd.read_parquet(file_path)
    table_name = file_path.replace("data\\", "").replace(".parquet", "")
    print(f"\nBảng [{table_name}] gồm các cột:")
    print(list(df.columns))