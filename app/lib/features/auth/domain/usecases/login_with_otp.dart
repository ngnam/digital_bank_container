import '../entities/session_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithOtp {
  final AuthRepository repository;
  LoginWithOtp(this.repository);

  Future<SessionEntity> call(String phone, String otp) {
    return repository.loginWithOtp(phone, otp);
  }
}
