import '../entities/user.dart';

/// Authentication repository contract
abstract class AuthRepository {
  Future<bool> login(String username, String password);
  Future<bool> verifyOtp(String code);
  Future<User?> getCurrentUser();
  Future<void> logout();
}

/// A mock implementation used for demo and tests
class MockAuthRepository implements AuthRepository {
  User? _user;

  @override
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (username.isNotEmpty && password.isNotEmpty) {
      _user = User(id: 'u1', name: username, phone: '0912345678');
      return true;
    }
    return false;
  }

  @override
  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return code == '123456';
  }

  @override
  Future<User?> getCurrentUser() async {
    return _user;
  }

  @override
  Future<void> logout() async {
    // simulate network / local cleanup
    await Future.delayed(const Duration(milliseconds: 200));
    _user = null;
  }
}
