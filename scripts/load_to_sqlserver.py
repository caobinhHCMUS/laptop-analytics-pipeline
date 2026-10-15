import os
import urllib
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, event

# 1. Đọc biến môi trường từ .env
load_dotenv()

SQL_SERVER = os.getenv("SQL_SERVER", "localhost")
SQL_DATABASE = os.getenv("SQL_DATABASE", "LaptopAnalytics")
SQL_DRIVER = os.getenv("SQL_DRIVER", "ODBC Driver 17 for SQL Server")

# 2. Xây dựng chuỗi kết nối SQLAlchemy với SQL Server
# Dùng Windows Authentication (Trusted Connection)
connection_string = (
    f"Driver={{{SQL_DRIVER}}};"
    f"Server={SQL_SERVER};"
    f"Database={SQL_DATABASE};"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

params = urllib.parse.quote_plus(connection_string)
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

# Bật tính năng fast_executemany để nạp dữ liệu với tốc độ cực nhanh
@event.listens_for(engine, "before_cursor_execute")
def receive_before_cursor_execute(conn, cursor, statement, params, context, executemany):
    if executemany:
        cursor.fast_executemany = True

# 3. Danh sách các bảng cần nạp từ thư mục data/
# Tên file tương ứng với tên bảng đích tiền tố raw_
tables_to_load = [
    ("brand", "raw_brand"),
    ("cpu_model", "raw_cpu_model"),
    ("gpu_model", "raw_gpu_model"),
    ("laptop_model", "raw_laptop_model"),
    ("laptop_benchmark_result", "raw_laptop_benchmark_result"),
    ("user_event_tracking_sample", "raw_user_event_tracking")
]

print("=== BẮT ĐẦU NẠP DỮ LIỆU VÀO SQL SERVER ===")

for file_name, target_table in tables_to_load:
    file_path = f"data/{file_name}.parquet"
    
    if not os.path.exists(file_path):
        print(f"⚠️ Bỏ qua: Không tìm thấy file {file_path}")
        continue
    
    print(f"-> Đang đọc file: {file_path} ...")
    df = pd.read_parquet(file_path)
    
    # Nạp vào SQL Server:
    # if_exists='replace': Tự động tạo bảng hoặc ghi đè nếu bảng đã tồn tại
    # chunksize=10000: Nạp theo từng block 10,000 dòng để tránh nghẽn bộ nhớ
    print(f"   Đang nạp {len(df):,} dòng vào bảng [{target_table}] ...")
    df.to_sql(
        name=target_table,
        con=engine,
        schema="dbo",
        if_exists="replace",
        index=False,
        chunksize=10000
    )
    print(f"   ✓ Đã nạp thành công vào [{target_table}]!")

print("=== HOÀN TẤT NẠP DỮ LIỆU VÀO SQL SERVER ===")