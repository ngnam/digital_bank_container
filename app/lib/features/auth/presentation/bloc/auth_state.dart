part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final SessionEntity session;
  AuthAuthenticated(this.session);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
class AuthBiometricEnabled extends AuthState {}
class AuthBiometricDisabled extends AuthState {}
class AuthTrustedDevicesLoaded extends AuthState {
  final List<DeviceEntity> devices;
  AuthTrustedDevicesLoaded(this.devices);
}
class AuthDeviceRegistered extends AuthState {}
class AuthDeviceRemoved extends AuthState {}
