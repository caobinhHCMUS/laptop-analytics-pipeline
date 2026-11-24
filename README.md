# Laptop Analytics Pipeline

Đồ án xây dựng pipeline phân tích dữ liệu laptop: nạp dữ liệu thô, chuẩn hóa
và kết hợp thông tin cấu hình/benchmark, sau đó tạo các view phục vụ truy vấn
phân tích.

## Trạng thái nguồn dữ liệu

ClickHouse từng là nguồn để trích xuất dữ liệu. Hiện tại máy chủ ClickHouse
từ chối kết nối và chủ sở hữu không còn cấp quyền truy cập, vì vậy pipeline
**không kết nối hoặc trích xuất dữ liệu trực tiếp từ ClickHouse**.

Thay vào đó, đồ án sử dụng các file Parquet đã được trích xuất trước đó và đang
có trong `data/`:

| File | Nội dung | Số dòng hiện có |
| --- | --- | ---: |
| `brand.parquet` | Thương hiệu | 20 |
| `cpu_model.parquet` | Dòng CPU | 90 |
| `gpu_model.parquet` | Dòng GPU | 57 |
| `laptop_model.parquet` | Mẫu laptop và thông số | 164 |
| `laptop_benchmark_result.parquet` | Kết quả benchmark | 6 |
| `user_event_tracking_sample.parquet` | Mẫu sự kiện người dùng | 50.000 |

Các file trong `data/` bị Git ignore; cần có sẵn các file trên ở máy chạy
pipeline. DAG hiện tại không gọi script trích xuất ClickHouse.

## Kiến trúc

```text
Parquet snapshot trong data/
          ↓
scripts/load_to_sqlserver.py
          ↓
SQL Server: dbo.raw_*
          ↓
dbt staging views
          ↓
dbt intermediate views
```

Airflow chạy trong Docker và điều phối hai bước:

1. Nạp các file Parquet vào sáu bảng `raw_*` trên SQL Server.
2. Chạy `dbt build` để tạo/cập nhật model và chạy kiểm tra chất lượng dữ liệu.

Các model staging chuẩn hóa tên, kiểu dữ liệu và timestamp. Tầng intermediate
hiện có `int_laptop_specifications` (kết hợp laptop, brand, CPU, GPU) và
`int_laptop_benchmarks_summary` (tổng hợp pin và điểm benchmark).

## Yêu cầu

- Docker Desktop đã khởi động.
- SQL Server cài trên máy đang chạy, bật TCP/IP và lắng nghe cổng `1433`.
- Database `LaptopAnalytics` tồn tại.
- `.env` có `SQL_DATABASE`, `SQL_USER`, `SQL_PASSWORD`. SQL login cần quyền
  đọc/ghi dữ liệu và tạo/cập nhật bảng, view trong `LaptopAnalytics`.
- Các file Parquet trong `data/` như bảng trên.

Airflow container kết nối SQL Server qua `host.docker.internal`. Thông tin
đăng nhập nằm trong `.env`; không commit hoặc chia sẻ file này. Các biến
ClickHouse có thể còn trong `.env` từ lần trích xuất trước, nhưng DAG hiện tại
không sử dụng chúng và Compose không chuyển chúng vào container Airflow.

## Chạy Airflow

Chạy các lệnh từ thư mục gốc của repository:

```powershell
docker compose up --build -d
docker compose ps
```

Mở [http://localhost:8082](http://localhost:8082). Airflow Standalone tạo
tài khoản quản trị ở lần khởi động đầu; xem thông tin đăng nhập trong log:

```powershell
docker compose logs airflow
```

Trong giao diện:

1. Tìm DAG `laptop_analytics_pipeline`.
2. Bỏ pause DAG nếu đang bị pause.
3. Chọn **Trigger DAG** để chạy thủ công.
4. Theo dõi trạng thái các task `load_raw_sqlserver` và `dbt_build`.

DAG không có lịch tự chạy. Task nạp dữ liệu dùng `if_exists="replace"`, nghĩa là
các bảng `raw_*` sẽ bị thay thế bằng nội dung từ Parquet mỗi lần trigger. Hãy
đảm bảo snapshot trong `data/` là dữ liệu muốn dùng trước khi chạy.

Nếu chỉ muốn chạy lại dbt trên các bảng raw đang có mà không nạp lại Parquet:

```powershell
docker compose exec airflow /home/airflow/project-venv/bin/dbt build `
  --project-dir /opt/airflow/project/dbt_project `
  --profiles-dir /opt/airflow/project/dbt_project
```

## Dừng dịch vụ

```powershell
docker compose down
```

Lệnh trên giữ lại volume metadata của Airflow. Không thêm `-v` trừ khi muốn
xóa volume đó và lịch sử chạy Airflow.
