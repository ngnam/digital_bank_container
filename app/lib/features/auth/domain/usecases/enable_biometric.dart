import '../repositories/auth_repository.dart';

class EnableBiometric {
  final AuthRepository repository;
  EnableBiometric(this.repository);

  Future<void> call() {
    return repository.enableBiometric();
  }
}
