import '../entities/user_entity.dart';
import '../entities/session_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<SessionEntity?> getSession();
  Future<void> logout();
  Future<void> lockSession();
  Future<void> unlockSession(String pinOrBiometric);
  Future<bool> isSessionLocked();

  Future<SessionEntity> loginWithPassword(String phone, String password);
  Future<SessionEntity> loginWithOtp(String phone, String otp);
  Future<void> enableBiometric();
  Future<void> disableBiometric();
  Future<List<DeviceEntity>> getTrustedDevices();
  Future<void> registerDevice(String deviceName);
  Future<void> removeDevice(String deviceId);
}
