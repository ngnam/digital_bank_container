class SessionEntity {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  SessionEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });
}
