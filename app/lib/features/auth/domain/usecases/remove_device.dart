import '../repositories/auth_repository.dart';

class RemoveDevice {
  final AuthRepository repository;
  RemoveDevice(this.repository);

  Future<void> call(String deviceId) {
    return repository.removeDevice(deviceId);
  }
}
