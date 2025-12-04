import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/services/notification_api.dart';
import 'package:vhs_mobile_user/data/models/notification/notification_model.dart';

class NotificationRepository {
  final NotificationApi api;
  NotificationRepository({required this.api});

  Future<NotificationListResponse> getMyNotifications() => api.getMyNotifications();
  Future<NotificationListResponse> getMyUnreadNotifications() => api.getMyUnreadNotifications();
  Future<NotificationModel> getNotificationById(String notificationId) => api.getNotificationById(notificationId);
  Future<bool> markAsRead(String notificationId) => api.markAsRead(notificationId);
  Future<bool> markAllAsRead() => api.markAllAsRead();
  Future<bool> deleteNotification(String notificationId) => api.deleteNotification(notificationId);
  Future<bool> clearAllNotifications() => api.clearAllNotifications();
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final api = ref.read(notificationApiProvider);
  return NotificationRepository(api: api);
});

