import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetTrustedDevices {
  final AuthRepository repository;
  GetTrustedDevices(this.repository);

  Future<List<DeviceEntity>> call() {
    return repository.getTrustedDevices();
  }
}
