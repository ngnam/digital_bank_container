# FE Flutter 3.24.0 prompt – Module 4: Payments

## 🎯 Mục tiêu
- Xây dựng module thanh toán trong ứng dụng Flutter 3.24.0.  
- Bao gồm: **chuyển tiền nội bộ**, **chuyển tiền liên ngân hàng**, **templates (mẫu người nhận)**, **schedules (lịch thanh toán)**, và **2FA (OTP/biometric)**.  
- Đảm bảo trải nghiệm người dùng mượt mà, an toàn, hỗ trợ offline/pending khi mất mạng.

---

## 📑 Flows

- **Internal Payment (Nội bộ)**  
  - Người dùng chọn tài khoản nguồn, nhập tài khoản đích (cùng ngân hàng), số tiền, mô tả.  
  - Gửi request `/api/v1/payments/internal`. 
  - Nhận trạng thái `PENDING_2FA`.  
  - Hiển thị màn hình nhập OTP hoặc biometric để xác thực.  

- **External Payment (Liên ngân hàng)**  
  - Người dùng nhập thông tin ngân hàng đích, số tài khoản, tên người nhận.  
  - Gửi request `/api/v1/payments/external`. 
  - Nhận trạng thái `PENDING_2FA`.  
  - Xác thực 2FA trước khi hoàn tất.  

- **Templates (Mẫu thanh toán)**  
  - Người dùng lưu thông tin người nhận thường xuyên.  
  - FE gọi API `/api/v1/payments/templates` để CRUD. 
  - Khi tạo giao dịch mới, có thể chọn template để điền nhanh.  

- **Schedules (Lịch thanh toán)**  
  - Người dùng tạo lịch thanh toán định kỳ (ngày/tuần/tháng).  
  - FE gọi API `/api/v1/payments/schedules` để CRUD.  
  - BE thực thi tự động, FE hiển thị danh sách lịch đã tạo.  

- **2FA Flow**  
  - Sau khi tạo giao dịch, FE hiển thị màn hình nhập OTP hoặc xác thực biometric.  
  - Gọi API `/api/v1/payments/{id}/confirm` với OTP/biometric token.  
  - Nếu thành công → hiển thị trạng thái `SUCCESS`.  

---

## 📲 Implementation Checklist (Flutter 3.24.0)

### Data Layer
- **Repository pattern**:  
  - `PaymentRepository` quản lý API call và cache.  
  - Sử dụng `dio` để call API.  
  - Sử dụng `sqflite` hoặc `hive` để lưu templates/schedules offline.  

- **Models**:  
  - `PaymentRequest`, `PaymentResponse`, `Template`, `Schedule`.  
  - Mapping JSON → Dart model.  

### State Management
- Dùng `flutter_bloc` hoặc `riverpod`.  
- States: `Idle`, `Submitting`, `Pending2FA`, `Success`, `Error`.  

### UI
- **PaymentFormScreen**: form nhập thông tin giao dịch.  
- **TemplateListScreen**: danh sách mẫu người nhận.  
- **ScheduleListScreen**: danh sách lịch thanh toán.  
- **OtpScreen**: nhập OTP/biometric để xác thực.  
- **Offline badge**: hiển thị khi không có mạng.  

---

## API Integration

- **Tạo giao dịch nội bộ**  
  ```dart
  final response = await dio.post('/api/v1/payments/internal', data: {
    'fromAccountId': fromId,
    'toAccountId': toId,
    'amount': amount,
    'description': desc,
  });
  ```

## Tạo giao dịch liên ngân hàng

```dart
final response = await dio.post('/api/v1/payments/external', data: {
  'fromAccountId': fromId,
  'toBankCode': bankCode,
  'toAccountNumber': accountNumber,
  'toName': toName,
  'amount': amount,
  'description': desc,
});
```

## Xác thực 2FA

```dart
final response = await dio.post('/api/v1/payments/$paymentId/confirm', data: {
  'otp': otpCode,
});
```

## Templates
```dart
await dio.get('/api/v1/payments/templates');
await dio.post('/api/v1/payments/templates', data: {...});
Schedules
```

```dart
await dio.get('/api/v1/payments/schedules');
await dio.post('/api/v1/payments/schedules', data: {...});
```

# FE responsibilities
- Validate input trước khi gửi API.
- Hiển thị màn hình OTP/biometric khi nhận trạng thái PENDING_2FA.
- Lưu templates/schedules offline để user có thể xem khi mất mạng.
- Retry giao dịch pending khi online trở lại.

# Xử lý lỗi:

- OTP sai → hiển thị thông báo retry.
- 429 Too Many Requests → hiển thị thông báo chờ.
- Network error → lưu pending, retry sau.

# Checklist
[ ] Tạo PaymentRepository quản lý API + cache.
[ ] Tạo models PaymentRequest, PaymentResponse, Template, Schedule.
[ ] Implement PaymentFormScreen cho nội bộ/liên ngân hàng.
[ ] Implement TemplateListScreen CRUD templates.
[ ] Implement ScheduleListScreen CRUD schedules.
[ ] Implement OtpScreen cho 2FA.
[ ] Hỗ trợ offline cache cho templates/schedules.
[ ] Xử lý pending payments khi offline.
[ ] không viết unit test cho repository và bloc.