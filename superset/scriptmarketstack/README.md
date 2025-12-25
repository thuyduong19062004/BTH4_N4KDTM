# Hướng dẫn chạy Marketstack ETL

## 🤖 Tự Động Cập Nhật Hàng Ngày (Khuyến nghị)

### Cài đặt một lần
```powershell
.\setup_scheduled_task.ps1
```

Hệ thống sẽ **tự động** cập nhật dữ liệu mỗi ngày lúc 8:00 sáng.

📖 **Chi tiết:** Xem [SCHEDULING_GUIDE.md](SCHEDULING_GUIDE.md)

---

## Phương pháp 1: Chạy ETL đơn lẻ

Đơn giản chỉ cần chạy:
```powershell
.\run_etl.ps1
```

Script này sẽ tự động:
1. Copy file Python vào Docker container
2. Chạy ETL script
3. Hiển thị kết quả và verify dữ liệu

## Phương pháp 2: Chạy thủ công

### Bước 1: Cập nhật API Key
Mở file `marketstack_etl.py` và thay thế:
```python
API_KEY = 'YOUR_MARKETSTACK_API_KEY'
```
với API key thực của bạn.

### Bước 2: Copy script vào Docker
```powershell
docker cp marketstack_etl.py superset_app:/app/
```

### Bước 3: Chạy script trong Docker
```powershell
docker exec superset_app python /app/marketstack_etl.py
```

### Bước 4: Verify dữ liệu
```powershell
docker exec superset_db psql -U superset -d superset -c "SELECT COUNT(*) FROM marketstack_data;"
```

## Lưu ý quan trọng
- ✅ Script chạy **BÊN TRONG** Docker container `superset_app`
- ✅ Kết nối tới database qua hostname `superset_db` (Docker network)
- ✅ Đảm bảo Docker containers đang chạy trước khi thực thi
- ✅ Mỗi lần chạy sẽ **thêm** dữ liệu vào bảng (không xóa dữ liệu cũ)

## Tùy chỉnh

### Thay đổi symbol
Trong file `marketstack_etl.py`, dòng 70:
```python
symbol = 'AAPL'  # Thay thành MSFT, GOOGL, TSLA, etc.
```

### Load nhiều symbols
Sửa phần `if __name__ == "__main__":` thành:
```python
symbols = ['AAPL', 'MSFT', 'GOOGL', 'TSLA']
for symbol in symbols:
    df = fetch_market_data(symbol)
    load_to_postgres(df)
```

## Sử dụng dữ liệu trong Superset

1. Truy cập Superset: `http://localhost:8088`
2. Vào **Data** → **Datasets** → **+ Dataset**
3. Chọn:
   - Database: Examples
   - Schema: public
   - Table: marketstack_data
4. Nhấn **Add** và bắt đầu tạo charts!

