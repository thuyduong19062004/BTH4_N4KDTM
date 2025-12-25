# ⚡ Quick Start - Tự Động Cập Nhật Data

## 1️⃣ Cài Đặt (Chỉ 1 lần)

Mở PowerShell **AS ADMINISTRATOR**:

```powershell
cd d:\LearningCode\CodeLogic\Hethongthongminh\superset\scriptmarketstack
.\setup_scheduled_task.ps1
```

✅ Done! Hệ thống sẽ tự động cập nhật data lúc **8:00 sáng** mỗi ngày.

## 2️⃣ Test Ngay

```powershell
.\scheduled_etl.ps1
```

Hoặc từ Task Scheduler:
- Win+R → `taskschd.msc` → Tìm **MarketstackETL-Daily-Update** → Right click → **Run**

## 3️⃣ Xem Logs

```powershell
# Xem log mới nhất
Get-ChildItem logs\*.log | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content

# Mở thư mục logs
explorer logs\
```

## 📝 Tùy Chỉnh Thời Gian

```powershell
# Chạy lúc 6:00 sáng
.\setup_scheduled_task.ps1 -Time "06:00"

# Chạy lúc 9:30 sáng
.\setup_scheduled_task.ps1 -Time "09:30"

# Chạy lúc 11:00 tối
.\setup_scheduled_task.ps1 -Time "23:00"
```

## 🗑️ Xóa Task

```powershell
.\remove_scheduled_task.ps1
```

## 📚 Đọc Thêm

- Chi tiết đầy đủ: [SCHEDULING_GUIDE.md](SCHEDULING_GUIDE.md)
- Hướng dẫn Superset: [SUPERSET_GUIDE.md](SUPERSET_GUIDE.md)
- Chạy thủ công: [README.md](README.md)

---

**Lưu ý:**
- ⚡ Phải chạy setup script với quyền Administrator
- 🐳 Docker phải đang chạy khi task thực thi
- 📊 Logs tự động cleanup sau 30 ngày
- 🔄 Task tự động append data (không xóa data cũ)
