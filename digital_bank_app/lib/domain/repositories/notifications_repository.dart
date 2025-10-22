import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<List<NotificationEntity>> fetchNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}
