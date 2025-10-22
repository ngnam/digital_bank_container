Role: Bạn là AI trợ lý code Flutter.
Goal: Khởi tạo project Flutter 3.24.0 với Clean Architecture, DI (get_it), theming, lints, secure dio, mock Api, sqlite
Constraints:
- Có theming (light/dark) với design tokens cơ bản.
- DI bằng get_it + injectable.
- Dio client có certificate pinning + auth interceptor.
- Không sinh code giả định ngoài scope.

Output:
- pubspec.yaml với dependencies.
- lib/core/ (theme, di, network)
- lib/main.dart khởi tạo MaterialApp với theme.
- analysis_options.yaml với lints.
- build app.apk cho thiết bị android