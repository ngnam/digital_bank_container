// lib/presentation/notifications/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/notification_entity.dart';
import '../../cubit/notifications/notifications_cubit.dart';
import '../../cubit/notifications/notifications_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.transferSuccess:
        return Icons.check_circle;
      case NotificationType.otpLogin:
        return Icons.lock;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.billReminder:
        return Icons.receipt_long;
      case NotificationType.system:
        return Icons.info;
    }
  }

  String _relativeTime(DateTime ts) {
    final now = DateTime.now();
    final diff = now.difference(ts);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Thông báo'),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'Đánh dấu tất cả đã đọc',
                icon: const Icon(Icons.done_all),
                onPressed: state is NotificationsLoaded &&
                        state.notifications.any((n) => !n.isRead)
                    ? () => context.read<NotificationsCubit>().markAllAsRead()
                    : null,
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, NotificationsState state) {
    if (state is NotificationsInitial) {
      final notifyCubit = context.read<NotificationsCubit>();
      // Lần đầu vào trang: trigger load
      Future.microtask(() => notifyCubit.loadNotifications());
      return const Center(child: CircularProgressIndicator());
    }
    if (state is NotificationsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is NotificationsError) {
      return Center(child: Text(state.message));
    }
    if (state is NotificationsLoaded) {
      final notifications = state.notifications;
      if (notifications.isEmpty) {
        return const Center(child: Text('Không có thông báo'));
      }
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final n = notifications[index];
          final isUnread = !n.isRead;

          return InkWell(
            onTap: () => context.read<NotificationsCubit>().markAsRead(n.id),
            child: Container(
              color: isUnread ? const Color(0xFFF5F7FB) : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _iconForType(n.type),
                    color: isUnread ? Colors.blue : Colors.grey.shade600,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: TextStyle(
                            fontWeight:
                                isUnread ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n.message,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight:
                                isUnread ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _relativeTime(n.timestamp),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
