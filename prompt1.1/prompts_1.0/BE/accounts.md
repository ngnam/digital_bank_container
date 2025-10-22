# BE accounts prompt

## Flows

- **Danh sách tài khoản (Account List)**  
  Người dùng lấy danh sách tất cả tài khoản ngân hàng mà họ sở hữu.  
  Hỗ trợ phân trang, sắp xếp, lọc theo loại tài khoản.

- **Chi tiết tài khoản (Account Detail)**  
  Người dùng xem chi tiết một tài khoản cụ thể: số dư, loại tiền tệ, chủ sở hữu, ngày tạo, ngày cập nhật.

- **Lịch sử giao dịch (Transaction History)**  
  Người dùng xem danh sách giao dịch của một tài khoản.  
  Hỗ trợ phân trang, lọc theo ngày, loại giao dịch (DEBIT/CREDIT), khoảng thời gian.

- **Offline cache & đồng bộ**  
  FE lưu cache danh sách/chi tiết/lịch sử vào local DB (SQLite/Room/CoreData).  
  BE hỗ trợ ETag/If-None-Match và Last-Modified/If-Modified-Since để FE sync delta.  
  API sync: `GET /api/v1/accounts/sync?since=timestamp` trả về thay đổi kể từ lần cuối.

---

## API contracts

### Account List
- **GET** `/api/v1/accounts?page=&size=&sort=`
- **Response**:
  ```json
  {
    "items": [
      { "id": 1, "accountNumber": "123456789", "ownerName": "Nguyen Van A", "currency": "VND" }
    ],
    "total": 1,
    "page": 0,
    "size": 20
  }
  ```
- **Headers**: ETag để FE sync cache.

## Account Detail
- **GET** /api/v1/accounts/{id}
- **Response**:
 ```json
 {
  "id": 1,
  "accountNumber": "123456789",
  "ownerName": "Nguyen Van A",
  "currency": "VND",
  "balance": 1000000,
  "updatedAt": "2025-10-15T08:00:00Z"
 }
 ```
- **Headers**: ETag hoặc Last-Modified.

**Account Balance**
**GET** /api/v1/accounts/{id}/balance
**Response**:
 ```json
 { "balance": 1000000, "currency": "VND", "lastUpdated": "2025-10-15T08:00:00Z" }
```
**Transaction History**
**GET** /api/v1/accounts/{id}/transactions?from=&to=&type=&page=&size=
**Response**:
 ```json
 {
  "items": [
    { "id": 101, "type": "DEBIT", "amount": 50000, "description": "Transfer to B", "timestamp": "2025-10-14T10:00:00Z" }
  ],
  "total": 1,
  "page": 0,
 }
 ```
**Headers**: Last-Modified để FE sync delta.

# Statement Export
**GET** /api/v1/accounts/{id}/statements?format=pdf|csv

# Security
- Auth: Bearer JWT (RS256), Authorization: Bearer <token>.
- RBAC: chỉ chủ tài khoản hoặc role có quyền mới được truy cập.
- Rate limiting: áp dụng cho API truy vấn lịch sử và export.
- Idempotency: không bắt buộc cho GET, nhưng áp dụng cho export request nếu cần.

# FE responsibilities
- Cache: lưu danh sách/chi tiết/lịch sử vào local DB.
- Sync: gửi If-None-Match hoặc If-Modified-Since khi gọi API.
- Offline mode: khi mất mạng, đọc cache và hiển thị badge “Offline”.
- Conflict resolution: BE là source of truth, FE chỉ đọc cache.
- Pagination: implement infinite scroll cho lịch sử giao dịch.
- Error handling:
- 304 Not Modified → dùng cache.
- 429 Too Many Requests → hiển thị thông báo retry.
- Network error → fallback sang cache.

# Checklist
[ ] API /api/v1/accounts trả về danh sách với pagination.
[ ] API /api/v1/accounts/{id} trả về chi tiết + ETag.
[ ] API /api/v1/accounts/{id}/transactions hỗ trợ lọc + phân trang.
[ ] API /api/v1/accounts/sync?since= trả về delta.
[ ] FE implement local cache + sync logic.
[ ] FE hiển thị trạng thái offline/online.