import 'package:bloc/bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_with_password.dart';
import '../../domain/usecases/login_with_otp.dart';
import '../../domain/usecases/enable_biometric.dart';
import '../../domain/usecases/disable_biometric.dart';
import '../../domain/usecases/get_trusted_devices.dart';
import '../../domain/usecases/register_device.dart';
import '../../domain/usecases/remove_device.dart';
import '../../data/datasources/auth_remote_datasource.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginWithPassword loginWithPassword;
  final LoginWithOtp loginWithOtp;
  final EnableBiometric enableBiometric;
  final DisableBiometric disableBiometric;
  final GetTrustedDevices getTrustedDevices;
  final RegisterDevice registerDevice;
  final RemoveDevice removeDevice;
  final AuthRemoteDataSource remote;

  AuthCubit({
    required this.loginWithPassword,
    required this.loginWithOtp,
    required this.enableBiometric,
    required this.disableBiometric,
    required this.getTrustedDevices,
    required this.registerDevice,
    required this.removeDevice,
    required this.remote,
  }) : super(AuthInitial());

  Future<void> login(String phone, String password) async {
    emit(AuthLoading());
    try {
      await loginWithPassword(phone, password);
      final user = await remote.fetchUser();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Login failed'));
    }
  }
  void lockSession() {
    emit(AuthLocked());
  }

  Future<void> unlockWithBiometric() async {
    emit(AuthLoading());
    final user = await remote.fetchUser();
    emit(AuthUnlocked(user));
  }

  void logout() {
    emit(AuthInitial());
  }

  Future<void> loginOtp(String phone, String otp) async {
    emit(AuthLoading());
    try {
      await loginWithOtp(phone, otp);
      final user = await remote.fetchUser();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('OTP login failed'));
    }
  }

  Future<void> enableBio() async {
    emit(AuthLoading());
    try {
      await enableBiometric();
      emit(AuthBiometricEnabled());
    } catch (e) {
      emit(AuthError('Enable biometric failed'));
    }
  }

  Future<void> disableBio() async {
    emit(AuthLoading());
    try {
      await disableBiometric();
      emit(AuthBiometricDisabled());
    } catch (e) {
      emit(AuthError('Disable biometric failed'));
    }
  }

  Future<void> fetchTrustedDevices() async {
    emit(AuthLoading());
    try {
      final devices = await getTrustedDevices();
      emit(AuthTrustedDevicesLoaded(devices));
    } catch (e) {
      emit(AuthError('Fetch devices failed'));
    }
  }

  Future<void> registerNewDevice(String name) async {
    emit(AuthLoading());
    try {
      await registerDevice(name);
      emit(AuthDeviceRegistered());
    } catch (e) {
      emit(AuthError('Register device failed'));
    }
  }

  Future<void> removeDeviceById(String id) async {
    emit(AuthLoading());
    try {
      await removeDevice(id);
      emit(AuthDeviceRemoved());
    } catch (e) {
      emit(AuthError('Remove device failed'));
    }
  }
}
