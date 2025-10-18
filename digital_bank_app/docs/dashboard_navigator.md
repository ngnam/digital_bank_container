# Dashboard Navigator (tiếng Việt)

Nội dung:
- `DashboardPage` có AppBar, thẻ thông tin tài khoản (mock), grid chức năng và bottom navigation bar.

Cách tích hợp:
1. Đảm bảo `AccountRepository` được cung cấp (sử dụng `di.init()` hoặc cung cấp MockAccountRepository trực tiếp).
2. `DashboardCubit` được gọi bằng `context.read<DashboardCubit>()` trong `DashboardPage.initState`.
3. Route `/dashboard` đã được thêm trong `lib/main.dart`.

Gợi ý:
- Thay mock repo bằng API thật khi sẵn sàng.
- Thiết kế responsive: điều chỉnh số cột GridView theo kích thước màn hình.

