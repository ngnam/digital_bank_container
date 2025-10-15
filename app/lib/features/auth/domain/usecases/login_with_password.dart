import '../entities/session_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithPassword {
  final AuthRepository repository;
  LoginWithPassword(this.repository);

  Future<SessionEntity> call(String phone, String password) {
    return repository.loginWithPassword(phone, password);
  }
}
