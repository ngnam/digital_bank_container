class UserEntity {
  final String id;
  final String phoneNumber;
  final String? displayName;
  final bool isBiometricEnabled;
  final List<DeviceEntity> trustedDevices;

  UserEntity({
    required this.id,
    required this.phoneNumber,
    this.displayName,
    this.isBiometricEnabled = false,
    this.trustedDevices = const [],
  });
}

class DeviceEntity {
  final String deviceId;
  final String deviceName;
  final DateTime registeredAt;

  DeviceEntity({
    required this.deviceId,
    required this.deviceName,
    required this.registeredAt,
  });
}
