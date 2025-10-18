abstract class AuthRepository {
  Future<bool> login(String username, String password);
}

/// A mock implementation for demo / testing
class MockAuthRepository implements AuthRepository {
  @override
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Accept any non-empty credentials for demo
    return username.isNotEmpty && password.isNotEmpty;
  }
}
