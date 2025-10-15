import '../repositories/auth_repository.dart';

class DisableBiometric {
  final AuthRepository repository;
  DisableBiometric(this.repository);

  Future<void> call() {
    return repository.disableBiometric();
  }
}
