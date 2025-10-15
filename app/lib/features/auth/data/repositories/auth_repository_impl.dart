import '../../domain/entities/session_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource local;
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl({required this.local, required this.remote});

  @override
  Future<UserEntity?> getCurrentUser() async {
    return remote.fetchUser();
  }

  @override
  Future<SessionEntity?> getSession() async {
    return local.getSession();
  }

  @override
  Future<void> logout() async {
    await local.clearSession();
  }

  @override
  Future<void> lockSession() async {
    // Implement session lock logic
  }

  @override
  Future<void> unlockSession(String pinOrBiometric) async {
    // Implement unlock logic
  }

  @override
  Future<bool> isSessionLocked() async {
    // Implement check
    return false;
  }

  @override
  Future<SessionEntity> loginWithPassword(String phone, String password) async {
    final session = await remote.loginWithPassword(phone, password);
    await local.saveSession(session);
    return session;
  }

  @override
  Future<SessionEntity> loginWithOtp(String phone, String otp) async {
    final session = await remote.loginWithOtp(phone, otp);
    await local.saveSession(session);
    return session;
  }

  @override
  Future<void> enableBiometric() async {
    await remote.enableBiometric();
  }

  @override
  Future<void> disableBiometric() async {
    await remote.disableBiometric();
  }

  @override
  Future<List<DeviceEntity>> getTrustedDevices() async {
    return remote.getTrustedDevices();
  }

  @override
  Future<void> registerDevice(String deviceName) async {
    await remote.registerDevice(deviceName);
  }

  @override
  Future<void> removeDevice(String deviceId) async {
    await remote.removeDevice(deviceId);
  }
}
