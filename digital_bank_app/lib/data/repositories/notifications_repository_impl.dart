import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  // Mock storage in-memory
  final List<NotificationEntity> _store = [
    NotificationEntity(
      id: '1',
      title: 'Chuyển tiền thành công',
      message: 'Bạn đã chuyển 2.000.000đ tới Nguyễn Văn A.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      type: NotificationType.transferSuccess,
    ),
    NotificationEntity(
      id: '2',
      title: 'OTP đăng nhập',
      message: 'Mã OTP của bạn là 482913. Vui lòng không chia sẻ.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
      type: NotificationType.otpLogin,
    ),
    NotificationEntity(
      id: '3',
      title: 'Khuyến mãi tháng 10',
      message: 'Giảm 20% phí chuyển khoản liên ngân hàng trong tuần này.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      type: NotificationType.promotion,
    ),
    NotificationEntity(
      id: '4',
      title: 'Nhắc nhở hóa đơn',
      message: 'Hóa đơn điện đến hạn thanh toán ngày 25/10.',
      timestamp: DateTime.now().subtract(const Duration(hours: 20)),
      isRead: false,
      type: NotificationType.billReminder,
    ),
    NotificationEntity(
      id: '5',
      title: 'Thông báo hệ thống',
      message: 'Ứng dụng sẽ bảo trì từ 01:00–02:00 sáng mai.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      type: NotificationType.system,
    ),
  ];

  @override
  Future<List<NotificationEntity>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400)); // simulate delay
    // return copy để tránh mutate original
    return _store.map((n) => n.copyWith()).toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    final idx = _store.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _store[idx] = _store[idx].copyWith(isRead: true);
    }
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _store.length; i++) {
      _store[i] = _store[i].copyWith(isRead: true);
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
