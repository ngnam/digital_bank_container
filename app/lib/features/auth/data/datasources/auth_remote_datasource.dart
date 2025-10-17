import '../../domain/entities/session_entity.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<SessionEntity> loginWithPassword(String phone, String password);
  Future<SessionEntity> loginWithOtp(String phone, String otp);
  Future<void> resendOtp(String phone);
  Future<UserEntity> fetchUser();
  Future<void> enableBiometric();
  Future<void> disableBiometric();
  Future<List<DeviceEntity>> getTrustedDevices();
  Future<void> registerDevice(String deviceName);
  Future<void> removeDevice(String deviceId);
}

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<SessionEntity> loginWithPassword(String phone, String password) async {
    // Giả lập đăng nhập, trả về user khác nhau theo số điện thoại
    String userId = '1';
    if (phone == '0123456789') {
      userId = '1';
    } else if (phone == '0987654321') {
      userId = '2';
    } else {
      userId = '3';
    }
    return SessionEntity(
      accessToken: 'mock_access_token_$userId',
      refreshToken: 'mock_refresh_token_$userId',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<SessionEntity> loginWithOtp(String phone, String otp) async {
    return SessionEntity(
      accessToken: 'mock_access_token',
      refreshToken: 'mock_refresh_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<void> resendOtp(String phone) async {
    // mock: pretend to send OTP
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<UserEntity> fetchUser() async {
    // Giả lập trả về user tương ứng với accessToken
    // (Thực tế nên lưu session, ở đây mock đơn giản)
    // Ví dụ: lấy userId từ accessToken nếu cần
    // Ở đây trả về userId=1
    return UserEntity(
      id: '1',
      phoneNumber: '0123456789',
      displayName: 'Nguyen Van A',
      isBiometricEnabled: true,
      trustedDevices: [
        DeviceEntity(
          deviceId: 'dev1',
          deviceName: 'Samsung S24',
          registeredAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ],
    );
  }

  @override
  Future<void> enableBiometric() async {}

  @override
  Future<void> disableBiometric() async {}

  @override
  Future<List<DeviceEntity>> getTrustedDevices() async {
    return [
      DeviceEntity(
        deviceId: 'dev1',
        deviceName: 'iPhone 15',
        registeredAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  @override
  Future<void> registerDevice(String deviceName) async {}

  @override
  Future<void> removeDevice(String deviceId) async {}
}
