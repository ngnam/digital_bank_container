import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/session_entity.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession(SessionEntity session);
  Future<SessionEntity?> getSession();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _expiresAtKey = 'expires_at';

  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> saveSession(SessionEntity session) async {
    await storage.write(key: _accessTokenKey, value: session.accessToken);
    await storage.write(key: _refreshTokenKey, value: session.refreshToken);
    await storage.write(key: _expiresAtKey, value: session.expiresAt.toIso8601String());
  }

  @override
  Future<SessionEntity?> getSession() async {
    final accessToken = await storage.read(key: _accessTokenKey);
    final refreshToken = await storage.read(key: _refreshTokenKey);
    final expiresAtStr = await storage.read(key: _expiresAtKey);
    if (accessToken == null || refreshToken == null || expiresAtStr == null) return null;
    return SessionEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.parse(expiresAtStr),
    );
  }

  @override
  Future<void> clearSession() async {
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
    await storage.delete(key: _expiresAtKey);
  }
}
