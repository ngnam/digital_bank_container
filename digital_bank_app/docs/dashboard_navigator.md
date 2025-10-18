# Dashboard Navigator (tiếng Việt)

Nội dung:
- `DashboardPage` có AppBar, thẻ thông tin tài khoản (mock), grid chức năng và bottom navigation bar.

Tính năng quan trọng:
- Chuyển đổi tài khoản: `DashboardPage` hiển thị dropdown để chọn tài khoản hiện tại. Khi chọn, số dư và thông tin liên quan được cập nhật ngay trong UI.
- Định dạng tiền: Sử dụng `package:intl` (`NumberFormat`) để format tiền theo locale (ví dụ `vi_VN` cho VND).

Cách tích hợp:
1. Đảm bảo `AccountRepository` được cung cấp (sử dụng `di.init()` hoặc cung cấp MockAccountRepository trực tiếp).
	- Mặc định mã nguồn đã đăng ký `MockAccountRepository` và `MockAuthRepository` trong `lib/core/di.dart` để tiện chạy demo.
2. `DashboardCubit` được gọi bằng `context.read<DashboardCubit>()` trong `DashboardPage.initState`.
3. Route `/dashboard` đã được thêm trong `lib/main.dart`.

Gợi ý:
- Thay mock repo bằng API thật khi sẵn sàng.
- Thiết kế responsive: điều chỉnh số cột GridView theo kích thước màn hình.

Ví dụ thay thế:

1. Trong `lib/core/di.dart`, thay registration của `MockAccountRepository` bằng `AccountRepositoryImpl` (có sử dụng `AccountRemoteDataSource`) khi backend sẵn sàng.

2. `DashboardCubit.loadAccounts()` gọi `AccountRepository.getAccounts()` và cập nhật state. UI lắng nghe thay đổi và cập nhật dropdown + số dư.

