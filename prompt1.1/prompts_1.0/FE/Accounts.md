# FE Flutter 3.24.0 prompt – Module 3: Accounts

## 🎯 Mục tiêu
- Xây dựng màn hình quản lý tài khoản ngân hàng trong ứng dụng Flutter 3.24.0.  
- Bao gồm: danh sách tài khoản, chi tiết tài khoản, lịch sử giao dịch.  
- Hỗ trợ **offline cache** để người dùng vẫn xem được dữ liệu khi mất mạng.  

---

## 📑 Flows

- **Account List Screen**  
  - Hiển thị danh sách tài khoản của user.  
  - Gọi API `/api/v1/accounts` với phân trang.  
  - Lưu cache vào local DB (sqflite/hive).  

- **Account Detail Screen**  
  - Hiển thị thông tin chi tiết: số dư, loại tiền, ngày cập nhật.  
  - Gọi API `/api/v1/accounts/{id}`.  
  - Sử dụng ETag/If-None-Match để sync dữ liệu.  

- **Transaction History Screen**  
  - Hiển thị danh sách giao dịch của tài khoản.  
  - Gọi API `/api/v1/accounts/{id}/transactions?from=&to=&page=&size=`.  
  - Hỗ trợ infinite scroll, filter theo ngày/loại.  
  - Cache lịch sử giao dịch, sync delta bằng `If-Modified-Since`.  

- **Offline Cache**  
  - FE lưu dữ liệu vào local DB.  
  - Khi offline: đọc cache, hiển thị badge “Offline”.  
  - Khi online: sync lại với BE, merge dữ liệu mới.  

---

## 📲 Implementation Checklist (Flutter 3.24.0)

### Data Layer
- **Repository pattern**:  
  - `AccountRepository` gọi API và quản lý cache.  
  - Sử dụng `dio` hoặc `http` để call API.  
  - Sử dụng `sqflite` hoặc `hive` để lưu cache.  

- **Models**:  
  - `AccountSummary`, `AccountDetail`, `Transaction`.  
  - Mapping từ JSON → Dart model.  

### State Management
- Dùng `flutter_bloc` hoặc `riverpod` để quản lý state.  
- States: `Loading`, `Loaded`, `Error`, `Offline`.  

### UI
- **AccountListScreen**: `ListView.builder` hiển thị danh sách.  
- **AccountDetailScreen**: `Card` hiển thị số dư, thông tin chi tiết.  
- **TransactionHistoryScreen**: `ListView` + `Pagination`.  
- **Offline badge**: `Banner` hoặc `SnackBar` khi offline.  

---

# FE responsibilities
Lưu cache vào local DB.

Sync dữ liệu khi online bằng ETag/Last-Modified.

Hiển thị dữ liệu cache khi offline.

Xử lý lỗi:

304 Not Modified → dùng cache.

Network error → fallback sang cache.

429 Too Many Requests → hiển thị thông báo retry.

✅ Checklist
[ ] Tạo AccountRepository quản lý API + cache.

[ ] Tạo models AccountSummary, AccountDetail, Transaction.

[ ] Implement AccountListScreen với cache.

[ ] Implement AccountDetailScreen với ETag sync.

[ ] Implement TransactionHistoryScreen với pagination + filter.

[ ] Hiển thị badge “Offline” khi mất mạng.