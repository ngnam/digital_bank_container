import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/auth/domain/usecases/login_with_password.dart';
import 'package:app/features/auth/domain/entities/session_entity.dart';
import 'package:mockito/mockito.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginWithPassword usecase;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    usecase = LoginWithPassword(mockRepo);
  });

  test('should call repository and return session', () async {
    final session = SessionEntity(
      accessToken: 'token',
      refreshToken: 'refresh',
      expiresAt: DateTime.now(),
    );
    when(mockRepo.loginWithPassword('0123', 'pass')).thenAnswer((_) async => session);
    final result = await usecase('0123', 'pass');
    expect(result, session);
    verify(mockRepo.loginWithPassword('0123', 'pass')).called(1);
  });
}
