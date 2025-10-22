# FE Flutter 3.24.0 prompt – Module 6: Polish UI

## 🎯 Mục tiêu
- Tinh chỉnh giao diện ứng dụng theo **style Kiên Long Bank**: màu sắc, typography, iconography, spacing.  
- Đảm bảo **accessibility**: hỗ trợ screen reader, contrast, font scaling, focus order.  
- Tạo trải nghiệm người dùng nhất quán, hiện đại, dễ tiếp cận.

---

## 📑 Flows

- **Theme & Branding**  
  - Áp dụng màu chủ đạo: xanh Kiên Long (#007B3A), đỏ Kiên Long (#E30613), trắng.  
  - Typography: sử dụng font chuẩn (Roboto/SF Pro) với weight rõ ràng.  
  - AppBar, Button, Card, ListTile đồng bộ style.  

- **Accessibility**  
  - Hỗ trợ Dynamic Type (font scaling).  
  - Đảm bảo contrast ratio ≥ 4.5:1 cho text.  
  - Thêm `semanticsLabel` cho icon, hình ảnh.  
  - Focus order hợp lý khi dùng bàn phím/assistive tech.  

- **UI Polish**  
  - Spacing theo 4/8px grid system.  
  - Rounded corners consistent (8px).  
  - Shadow/elevation nhẹ cho card, button.  
  - Animation mượt (Hero, Fade, Slide).  

---

## 📲 Implementation Checklist (Flutter 3.24.0)

### Theme
- Tạo `AppTheme` với `ThemeData.light` và `ThemeData.dark`.  
- Định nghĩa `ColorScheme` theo brand Kiên Long.  
- Định nghĩa `TextTheme` với font size, weight chuẩn.  

### Widgets
- **Buttons**: ElevatedButton, OutlinedButton, TextButton → style đồng bộ.  
- **AppBar**: màu brand, title center, icon màu trắng.  
- **Cards/ListTiles**: padding chuẩn, icon leading/trailing consistent.  

### Accessibility
- Dùng `Semantics` widget cho icon quan trọng.  
- Dùng `MediaQuery.textScaleFactor` để hỗ trợ font scaling.  
- Test với TalkBack/VoiceOver.  
- Đảm bảo tất cả button có `tooltip` hoặc `semanticLabel`.  

### Example
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  child: const Text('Xác nhận', style: TextStyle(fontSize: 16)),
)
```