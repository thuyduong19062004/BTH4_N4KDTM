# Hướng dẫn tạo Dataset và Visualization trong Superset

## Bước 1: Truy cập Superset

1. Mở trình duyệt và truy cập: **http://localhost:8088**
2. Đăng nhập với:
   - Username: `admin`
   - Password: `admin`

## Bước 2: Tạo Database Connection (Nếu chưa có)

### Cách 1: Sử dụng SQL Lab để kiểm tra

1. Click **SQL** → **SQL Lab** ở menu trên cùng
2. Chọn database **"Examples"** 
3. Nhập query test:
   ```sql
   SELECT * FROM marketstack_data LIMIT 10;
   ```
4. Click **Run** để xem kết quả

> **Lưu ý:** Nếu query chạy thành công, database đã kết nối đúng. Bỏ qua Cách 2.

### Cách 2: Tạo Database Connection mới (Nếu Examples không hoạt động)

1. Click **Settings** (biểu tượng bánh răng) → **Database Connections**
2. Click nút **+ Database**
3. Chọn **PostgreSQL** từ danh sách
4. Điền thông tin:
   - **Display Name**: `Superset PostgreSQL`
   - **SQLAlchemy URI**: 
     ```
     postgresql://superset:superset@superset_db:5432/superset
     ```
5. Click **Test Connection**
6. Nếu thành công, click **Connect**

## Bước 3: Tạo Dataset từ marketstack_data

### Phương pháp A: Tạo từ UI (Khuyến nghị)

1. Click **Data** → **Datasets** ở menu trên cùng
2. Click nút **+ Dataset**
3. Điền form:
   - **Database**: Chọn `Examples` hoặc `Superset PostgreSQL` (database vừa tạo)
   - **Schema**: Chọn `public`
   - **Table**: 
     - Nhập `marketstack_data`
     - Nếu không thấy trong dropdown, click nút **refresh** (🔄) bên cạnh
     - Sau khi refresh, gõ lại `marketstack_data` và chọn
4. Click **Create Dataset and Create Chart**

### Phương pháp B: Tạo từ SQL Lab

1. Vào **SQL Lab**
2. Viết query:
   ```sql
   SELECT 
       date,
       symbol,
       open,
       high,
       low,
       close,
       volume
   FROM marketstack_data
   WHERE symbol = 'AAPL'
   ORDER BY date DESC
   LIMIT 100;
   ```
3. Click **Run**
4. Sau khi có kết quả, click **Save** → **Save as Dataset**
5. Đặt tên: `Marketstack Data - AAPL`

## Bước 4: Tạo Chart đầu tiên

Sau khi tạo dataset, bạn sẽ được chuyển đến trang tạo chart:

### Chart 1: Stock Price Time Series

**Configuration:**
- **Visualization Type**: Line Chart
- **Time Column**: `date`
- **Metrics**: 
  - `AVG(close)` hoặc chỉ `close`
- **Filters** (Optional):
  - `symbol = AAPL`

**Run Query** để xem chart!

### Chart 2: Volume Bar Chart

1. Tạo chart mới: **Charts** → **+ Chart**
2. Chọn dataset: `marketstack_data`
3. **Configuration:**
   - **Visualization Type**: Bar Chart
   - **Time Column**: `date`
   - **Metric**: `SUM(volume)`
   - **Time Grain**: `Day`

### Chart 3: OHLC Combined

1. Tạo chart mới
2. **Configuration:**
   - **Visualization Type**: Line Chart (Multiple Metrics)
   - **Time Column**: `date`
   - **Metrics**:
     - `AVG(open)` - Màu xanh
     - `AVG(high)` - Màu xanh lá
     - `AVG(low)` - Màu đỏ
     - `AVG(close)` - Màu cam

## Bước 5: Tạo Dashboard

1. Click **Dashboards** → **+ Dashboard**
2. Đặt tên: `Stock Market Analysis - AAPL`
3. Drag & drop các charts đã tạo vào dashboard
4. Arrange layout theo ý thích
5. Click **Save**

## Queries Hữu ích cho SQL Lab

### Query 1: Xem tất cả symbols
```sql
SELECT DISTINCT symbol 
FROM marketstack_data 
ORDER BY symbol;
```

### Query 2: Latest stock prices
```sql
SELECT 
    symbol,
    MAX(date) as latest_date,
    close as latest_close,
    volume as latest_volume
FROM marketstack_data
GROUP BY symbol, close, volume
ORDER BY latest_date DESC
LIMIT 10;
```

### Query 3: Price change analysis
```sql
SELECT 
    date,
    symbol,
    open,
    close,
    (close - open) AS price_change,
    ((close - open) / open * 100) AS price_change_pct,
    volume
FROM marketstack_data
WHERE symbol = 'AAPL'
ORDER BY date DESC
LIMIT 30;
```

### Query 4: High/Low comparison
```sql
SELECT 
    date::date,
    symbol,
    high - low AS daily_range,
    volume
FROM marketstack_data
WHERE symbol = 'AAPL'
ORDER BY daily_range DESC
LIMIT 20;
```

### Query 5: Moving average (7-day)
```sql
SELECT 
    date,
    close,
    AVG(close) OVER (
        ORDER BY date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7day
FROM marketstack_data
WHERE symbol = 'AAPL'
ORDER BY date DESC
LIMIT 30;
```

## Troubleshooting

### ❌ Table không hiện trong dropdown

**Giải pháp:**
1. Click nút **refresh** (🔄) bên cạnh Table field
2. Đợi vài giây
3. Gõ lại `marketstack_data`
4. Nếu vẫn không có, kiểm tra lại database connection

### ❌ Database connection failed

**Kiểm tra:**
```powershell
# Verify containers đang chạy
docker ps

# Test database connection
docker exec superset_db psql -U superset -d superset -c "\dt"
```

### ❌ Query timeout

**Giải pháp:**
- Giảm LIMIT trong query
- Thêm filter WHERE để giảm data
- Check database performance

## Tips & Best Practices

✅ **Đặt tên rõ ràng** cho datasets và charts
✅ **Sử dụng filters** để giảm tải data
✅ **Cache results** cho query lớn
✅ **Tạo virtual datasets** từ SQL phức tạp
✅ **Dùng Time Grain** để aggregate data theo ngày/tuần/tháng

## Next Steps

1. ✅ Load thêm symbols (MSFT, GOOGL, TSLA...)
2. ✅ Setup scheduled refresh cho data
3. ✅ Tạo dashboard comparison giữa các stocks
4. ✅ Add calculated columns (price change %, moving averages)
5. ✅ Export dashboard as PDF/Image
