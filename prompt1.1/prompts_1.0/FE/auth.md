Role: Bạn là AI trợ lý code Flutter.
Goal: Sinh code Auth module theo Clean Architecture (Presentation → Domain → Data) với BLoC/Cubit, dio, flutter_secure_storage, local_auth, Mock api
Scope:
- Trang đăng nhập tên đăng nhập bằng số điện thoại + mật khẩu 
- Hiện popup xác nhận OTP (bao gồm 6 digital number) -> Xác nhận OTP xong thì điều hướng tới màn hình dashboard navigation
- Biometric (FaceID/TouchID) opt-in.
- Device trust management (register/remove/list).
- Session lock (timeout, app lock).
Constraints:
- Tokens lưu trong flutter_secure_storage.
- Network qua dio + interceptors (refresh token).
- Không log PII.
- Chặn chụp màn hình trên màn hình nhạy cảm.
Output:
- Domain: entities, repositories, use cases.
- Data: datasources, repository impl.
- Presentation: Cubit/BLoC, screens, states.
