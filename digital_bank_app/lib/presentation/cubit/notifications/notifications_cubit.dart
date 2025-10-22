// lib/presentation/notifications/notifications_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository repository;

  NotificationsCubit(this.repository) : super(const NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(const NotificationsLoading());
    try {
      final list = await repository.fetchNotifications();
      emit(NotificationsLoaded(list));
    } catch (e) {
      emit(const NotificationsError('Không thể tải danh sách thông báo'));
    }
  }

  Future<void> markAsRead(String id) async {
    // Optimistic update
    final current = state;
    if (current is NotificationsLoaded) {
      final updated = current.notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList();
      emit(NotificationsLoaded(updated));
    }
    try {
      await repository.markAsRead(id);
    } catch (_) {
      // Nếu cần, có thể rollback ở đây
    }
  }

  Future<void> markAllAsRead() async {
    // Optimistic update
    final current = state;
    if (current is NotificationsLoaded) {
      final updated =
          current.notifications.map((n) => n.copyWith(isRead: true)).toList();
      emit(NotificationsLoaded(updated));
    }
    try {
      await repository.markAllAsRead();
    } catch (_) {
      // Nếu cần, rollback
    }
  }
}
