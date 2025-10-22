mình muốn viết bộ prompt templates chi tiết để viết app flutter 3.24.0 cho android 

khởi tạo project flutter 3.24.0 Pattern: BLoC/Cubit cho state management Architecture: Clean Architecture (Presentation → Domain → Data) 

Giao diện trang login: 
- Header là logo + Digital Bank nằm giữa 
- Main form đăng nhập Tên tài khoản + mật khẩu, LInk quên mật khẩu đăng ký, button đăng nhập 
- Bottom Navigation: eToken, QR scan, hỗ trợ, mạng lưới 
- Sau khi nhập thông tin tên tài khoản + mật khẩu -> click button đăng nhập thì hiện thị bottom popup xác thực OTP, 
    - popup bao gồm 6 digital number box, cho phép gửi lại mã xác nhận OTP -> Sau khi xác nhận OTP thì điều hướng tới trang dashboard navigator 
    
Giao diện trang dashboard navigator: 
- Header: Logo + title Digital bank nằm ở giữa, bên phải header là icon Thông báo 
    - Sub Header: là thông tin tài khoản bao gồm tên tài khoản, số tài khoản, tổng số tiền, có toggle ẩn hiện số tiền của tài khoản. bên phải là icon (v) cho phép pick tài khoản từ danh sách Accounts (dữ liệu được mock) 
- Main body: là các menu chức năng (button + icon + menu title): Chuyển tiền, tiết kiệm, thanh toán, nạp tiền, Các menu hiện thị kiểu card 4 cols x 3 rows 
- Bottom Navigation: bao gồm các menu: (button + icon + menu title): Trang chủ, tài khoản, quét QR (to nhất) nằm giữa, Hộp thư, Cá nhân