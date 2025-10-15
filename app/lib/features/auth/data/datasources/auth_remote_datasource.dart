import '../../domain/entities/session_entity.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<SessionEntity> loginWithPassword(String phone, String password);
  Future<SessionEntity> loginWithOtp(String phone, String otp);
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
    // Mock API response
    return SessionEntity(
      accessToken: 'mock_access_token',
      refreshToken: 'mock_refresh_token',
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
  Future<UserEntity> fetchUser() async {
    return UserEntity(
      id: '1',
      phoneNumber: '0123456789',
      displayName: 'Mock User',
      isBiometricEnabled: true,
      trustedDevices: [
        DeviceEntity(
          deviceId: 'dev1',
          deviceName: 'iPhone 15',
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
