# BE payments prompt

## Flows

- **Thanh toán nội bộ (Internal Payments)**  
  Người dùng chuyển tiền giữa các tài khoản trong cùng ngân hàng.  
  Yêu cầu xác thực 2FA (OTP/SMS/biometric) trước khi hoàn tất.

- **Thanh toán liên ngân hàng (External Payments)**  
  Người dùng chuyển tiền tới tài khoản ở ngân hàng khác.  
  Cần nhập thông tin ngân hàng đích, số tài khoản, tên người nhận.  
  Áp dụng hạn mức, phí giao dịch, và xác thực 2FA.

- **Templates (Mẫu thanh toán)**  
  Người dùng lưu lại thông tin người nhận thường xuyên (số tài khoản, ngân hàng, alias).  
  Có thể chọn template để tạo nhanh giao dịch mới.

- **Schedules (Lịch thanh toán)**  
  Người dùng lên lịch thanh toán định kỳ (hàng ngày, hàng tuần, hàng tháng).  
  BE lưu job schedule, thực thi tự động, gửi thông báo khi thành công/thất bại.

- **2FA (Two-Factor Authentication)**  
  Mọi giao dịch thanh toán cần xác thực 2FA: OTP qua SMS/email, hoặc xác thực biometric.  
  BE phát OTP, lưu trạng thái pending, chỉ khi xác thực thành công mới ghi nhận giao dịch.

---

## API contracts

### Tạo giao dịch nội bộ
- **POST** `/api/v1/payments/internal`
- **Body**:
  ```json
  {
    "fromAccountId": 1,
    "toAccountId": 2,
    "amount": 500000,
    "description": "Chuyển tiền tiết kiệm"
  }
- **Response**:
 ```json
 { "paymentId": "abc123", "status": "PENDING_2FA" }
 ```

### Tạo giao dịch liên ngân hàng
**POST** /api/v1/payments/external
**Body**:

 ```json
    {
    "fromAccountId": 1,
    "toBankCode": "VCB",
    "toAccountNumber": "123456789",
    "toName": "Nguyen Van B",
    "amount": 1000000,
    "description": "Thanh toán hóa đơn"
    }
 ```
**Response**:

 ```json
 { "paymentId": "xyz789", "status": "PENDING_2FA" }
 ```

# Xác thực 2FA cho giao dịch
**POST** /api/v1/payments/{paymentId}/confirm
**Body**:
```json
{ "otp": "123456" }
```
**Response**:
```json
{ "paymentId": "abc123", "status": "SUCCESS" }
```
# Templates
**POST** /api/v1/payments/templates
**GET** /api/v1/payments/templates
**DELETE** /api/v1/payments/templates/{id}

# Schedules
**POST** /api/v1/payments/schedules
**GET** /api/v1/payments/schedules
**DELETE** /api/v1/payments/schedules/{id}

# Security
**Auth**: Bearer JWT (RS256).
**2FA**: OTP hoặc biometric bắt buộc cho mọi giao dịch.
**Idempotency**: sử dụng header Idempotency-Key để tránh double payment.
**RBAC**: chỉ chủ tài khoản mới được phép tạo giao dịch từ tài khoản đó.
**Rate limiting**: giới hạn số lần gửi OTP và số lần thử sai.

# FE responsibilities
**UI**: form nhập thông tin giao dịch, chọn template, chọn lịch.
**2FA flow**: sau khi tạo giao dịch, hiển thị màn hình nhập OTP/biometric.
**Templates**: cho phép lưu và chọn nhanh người nhận.
**Schedules**: cho phép tạo/lưu lịch thanh toán định kỳ.
**Error handling**:
- OTP sai → hiển thị thông báo retry.
- 429 Too Many Requests → hiển thị thông báo chờ.
- Network error → retry hoặc lưu giao dịch pending để gửi lại khi online.

# Checklist
[ ] API /payments/internal tạo giao dịch nội bộ.
[ ] API /payments/external tạo giao dịch liên ngân hàng.
[ ] API /payments/{id}/confirm xác thực 2FA.
[ ] API /payments/templates CRUD templates.
[ ] API /payments/schedules CRUD schedules.
[ ] FE implement flow 2FA (OTP/biometric).
[ ] FE hỗ trợ templates và schedules.
[ ] FE xử lý offline/pending payments.