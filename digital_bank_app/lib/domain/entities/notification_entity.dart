// lib/domain/entities/notification_entity.dart
enum NotificationType {
  transferSuccess,
  otpLogin,
  promotion,
  billReminder,
  system,
}

class NotificationEntity {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}
