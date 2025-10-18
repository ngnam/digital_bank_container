# Hướng dẫn tạo icon (tiếng Việt)

Mục đích:
- Tự động sinh các file icon đúng kích thước cho Android (mipmap) và iOS (AppIcon.appiconset) từ file gốc `assets/images/lauchIcon.png`.

Yêu cầu:
- Cài ImageMagick (để có `convert`). Trên Ubuntu: `sudo apt update && sudo apt install -y imagemagick`

Sử dụng:
```bash
cd digital_bank_app
./tools/generate_icons.sh
```

Điều script thực hiện:
- Kiểm tra file nguồn `assets/images/lauchIcon.png` tồn tại.
- Sao lưu các file hiện tại (nếu tồn tại) bằng suffix `.bak`.
- Sinh các file kích thước cho Android trong `android/app/src/main/res/mipmap-*` (mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi).
- Sinh các file cho iOS trong `ios/Runner/Assets.xcassets/AppIcon.appiconset` và cập nhật `Contents.json` (gồm các kích thước phổ biến).

Lưu ý:
- iOS thường cần file ở kích thước chính xác để hiển thị tốt trên mọi thiết bị; script dùng một ảnh gốc và resize cho từng kích thước, kết quả có thể cần tinh chỉnh thủ công nếu icon có chi tiết nhỏ.
- Android hiện tại dùng single-layer icons (`ic_launcher.png`). Nếu cần adaptive icons (foreground/background), cần cung cấp 2 layer riêng và/hoặc điều chỉnh script.
- Script tạo backup `.bak` cho các file trước khi ghi đè — nếu cần khôi phục, xóa file mới và rename `.bak` về tên gốc.

Ví dụ khôi phục một file backup:
```bash
mv android/app/src/main/res/mipmap-mdpi/ic_launcher.png.bak android/app/src/main/res/mipmap-mdpi/ic_launcher.png
```

Muốn mình tự động chạy script bây giờ để sinh icon? (Mình có thể chạy và kiểm tra kết quả.)