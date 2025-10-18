# Hướng dẫn: Tạo màn hình Login (Clean Architecture + BLoC/Cubit)

Mô tả: Module `auth` gồm UI + Cubit + mock repository.

Các file chính đã tạo:
- `lib/presentation/pages/auth/login_page.dart` – UI màn hình đăng nhập và bottom OTP sheet.
- `lib/presentation/cubit/auth/login_cubit.dart` – Cubit chứa logic đăng nhập, gửi OTP, verify.
- `lib/presentation/cubit/auth/login_state.dart` – Trạng thái Cubit.
- `lib/domain/repositories/auth_repository.dart` – Interface và `MockAuthRepository`.

Luồng:
1. Người dùng nhập `Tên tài khoản` và `Mật khẩu` rồi nhấn `Đăng nhập`.
2. `LoginCubit.login` được gọi, mock repo trả về `true` nếu không rỗng.
3. Cubit emit `LoginStatus.success` và bắt đầu đếm ngược OTP.
4. Màn hình hiển thị bottom sheet để nhập OTP (6 chữ số).
5. Nếu nhập đúng mã `123456`, Cubit emit `otpVerified` và điều hướng tới `/dashboard`.

Lưu ý triển khai thực tế:
- Thay `MockAuthRepository` bằng implement kết nối API thật.
- Thêm xử lý lỗi chi tiết (mã lỗi, hiển thị snackbars).
- OTP: triển khai resend, countdown, validate server-side.

Hướng dẫn chạy nhanh:
1. Mở project Flutter.
2. Đăng ký `LoginCubit` ở trên cùng (ví dụ trong `main.dart`):

```dart
final repo = MockAuthRepository();
runApp(
  MultiBlocProvider(
    providers: [BlocProvider(create: (_) => LoginCubit(repo))],
    child: const MyApp(),
  ),
);
```

2. Thêm route `/dashboard` tới màn hình Dashboard (hiện tại là placeholder).
```dart
routes: {
  '/': (_) => const LoginPage(),
  '/dashboard': (_) => const Scaffold(body: Center(child: Text('Dashboard (placeholder)'))),
}
```

3. Chạy: `flutter run -t lib/main.dart` và thử đăng nhập.

File về mặt thiết kế UI:
- Header: logo `assets/images/lauchIcon.png` và text `Digital Bank` căn giữa.
- Form: 2 TextField, 2 link, button.
- Bottom nav: 4 icon + text.

Nếu cần, mình sẽ:
- Viết test cho `LoginCubit` (happy path + wrong OTP).
- Thêm style/theme match design (màu, font).
- Kết nối API thật và xử lý lỗi.
