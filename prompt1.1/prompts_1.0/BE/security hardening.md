# BE security hardening prompt

## Flows

- **Certificate Pinning**  
  Ứng dụng FE khi gọi API tới BE phải kiểm tra chứng chỉ TLS khớp với public key/CA đã pin.  
  BE cần cung cấp endpoint health check và chứng chỉ chuẩn để FE verify.  
  Nếu pinning thất bại → chặn request, hiển thị cảnh báo bảo mật.

- **Jailbreak / Root Detection**  
  FE cần phát hiện thiết bị đã jailbreak (iOS) hoặc root (Android).  
  Nếu phát hiện → cảnh báo người dùng, hạn chế tính năng nhạy cảm (thanh toán, thay đổi thông tin).  
  BE có thể nhận flag từ FE (`isJailbroken: true/false`) để log và áp dụng policy.

- **Secure Logging**  
  BE log mọi hành động quan trọng: login, logout, tạo giao dịch, thay đổi mật khẩu, 2FA.  
  Log phải:
  - Không chứa dữ liệu nhạy cảm (mật khẩu, OTP, token).  
  - Có timestamp, userId, IP, deviceId.  
  - Gửi về hệ thống tập trung (ELK, Splunk, CloudWatch).  
  - Hỗ trợ audit trail để điều tra sự cố.

---

## API contracts

### Health check (cho pinning)
- **GET** `/api/v1/health`
- **Response**:
  ```json
  { "status": "UP", "timestamp": "2025-10-16T08:00:00Z" }
TLS: FE verify certificate pinning khi gọi endpoint này.

Jailbreak flag
FE gửi thêm header X-Device-Jailbroken: true|false trong mọi request.

BE log lại và có thể từ chối giao dịch nhạy cảm nếu true.

Logging
BE ghi log theo chuẩn JSON:

json
{
  "timestamp": "2025-10-16T08:00:00Z",
  "level": "INFO",
  "event": "PAYMENT_CREATED",
  "userId": "u123",
  "ip": "192.168.1.10",
  "deviceId": "abc-xyz-123"
}
Security
Transport: HTTPS bắt buộc, TLS 1.2+.

Pinning: FE pin public key/CA, BE rotate chứng chỉ có kế hoạch.

Jailbreak detection: FE thực hiện, BE nhận flag để log.

Logs: không log dữ liệu nhạy cảm, chỉ log metadata.

Audit: logs phải immutable, lưu trữ tối thiểu 90 ngày.

FE responsibilities
Thực hiện certificate pinning khi gọi API.

Phát hiện jailbreak/root, gửi flag về BE.

Khi phát hiện thiết bị không an toàn → cảnh báo user, hạn chế tính năng.

Không lưu log nhạy cảm trên thiết bị.

Checklist
[ ] BE cung cấp endpoint /health để FE verify pinning.

[ ] FE implement certificate pinning.

[ ] FE implement jailbreak/root detection.

[ ] BE nhận và log header X-Device-Jailbroken.

[ ] BE log sự kiện quan trọng theo chuẩn JSON, không chứa dữ liệu nhạy cảm.

[ ] Logs được gửi về hệ thống tập trung, hỗ trợ audit trail.