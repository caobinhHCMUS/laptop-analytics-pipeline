import clickhouse_connect
import pandas as pd
import pyodbc
from dotenv import load_dotenv
import os 
load_dotenv()


# 1. Kết nối ClickHouse từ xa
ch_client = clickhouse_connect.get_client(
    host=os.getenv("CH_HOST"),
    port=int(os.getenv("CH_PORT", 80)),
    username=os.getenv("CH_USER"),
    password=os.getenv("CH_PASSWORD"),
    database=os.getenv("CH_DATABASE")
)

print(f"Đã kết nối thành công tới ClickHouse {os.getenv('CH_HOST')}")

# 2. Kết nối SQL Server Local (Dùng Windows Auth hoặc SQL Auth)
# Chuỗi kết nối Windows Authentication:
conn_str = (
    "Driver={ODBC Driver 17 for SQL Server};"
    "Server=localhost;"  # Hoặc .\SQLEXPRESS
    "Database=LaptopAnalytics;"
    "Trusted_Connection=yes;"
)
sql_conn = pyodbc.connect(conn_str)
cursor = sql_conn.cursor()

# Danh sách bảng kích thước nhỏ cần kéo về (Dimension)
tables = ['brand', 'cpu_model', 'gpu_model', 'laptop_model', 'laptop_benchmark_result']

print("Bắt đầu kéo dữ liệu dimension...")
for table in tables:
    df = ch_client.query_df(f"SELECT * FROM laplaptech.{table}")
    print(f"Đã lấy {len(df)} dòng từ {table}")
    
    # Lưu tạm thành file Parquet trong thư mục data/ hoặc insert thẳng vào SQL Server
    df.to_parquet(f"data/{table}.parquet", index=False)

# Riêng với bảng 12M dòng user_event_tracking: chỉ nên lấy mẫu (sample/limit) để test
print("Đang lấy mẫu bảng user_event_tracking...")
df_events = ch_client.query_df("SELECT * FROM laplaptech.user_event_tracking LIMIT 50000")
df_events.to_parquet("data/user_event_tracking_sample.parquet", index=False)
print("Hoàn tất trích xuất dữ liệu!")