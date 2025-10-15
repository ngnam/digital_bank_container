import '../repositories/auth_repository.dart';

class RegisterDevice {
  final AuthRepository repository;
  RegisterDevice(this.repository);

  Future<void> call(String deviceName) {
    return repository.registerDevice(deviceName);
  }
}
