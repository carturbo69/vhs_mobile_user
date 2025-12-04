import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/network/dio_client.dart';
import 'package:vhs_mobile_user/data/models/notification/notification_model.dart';

class NotificationApi {
  final DioClient _client;
  NotificationApi(this._client);

  Future<NotificationListResponse> getMyNotifications() async {
    final r = await _client.instance.get('/api/Notification');
    return NotificationListResponse.fromJson(r.data as Map<String, dynamic>);
  }

  Future<NotificationListResponse> getMyUnreadNotifications() async {
    final r = await _client.instance.get('/api/Notification/unread');
    return NotificationListResponse.fromJson(r.data as Map<String, dynamic>);
  }

  Future<NotificationModel> getNotificationById(String notificationId) async {
    final r = await _client.instance.get('/api/Notification/$notificationId');
    final data = r.data as Map<String, dynamic>;
    if (data['data'] != null) {
      return NotificationModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    return NotificationModel.fromJson(data);
  }

  Future<bool> markAsRead(String notificationId) async {
    final r = await _client.instance.put('/api/Notification/$notificationId/mark-read');
    if (r.data is Map && r.data['success'] != null) {
      return r.data['success'] == true;
    }
    return r.statusCode == 200;
  }

  Future<bool> markAllAsRead() async {
    final r = await _client.instance.put('/api/Notification/mark-all-read');
    if (r.data is Map && r.data['success'] != null) {
      return r.data['success'] == true;
    }
    return r.statusCode == 200;
  }

  Future<bool> deleteNotification(String notificationId) async {
    final r = await _client.instance.delete('/api/Notification/$notificationId');
    if (r.data is Map && r.data['success'] != null) {
      return r.data['success'] == true;
    }
    return r.statusCode == 200;
  }

  Future<bool> clearAllNotifications() async {
    final r = await _client.instance.delete('/api/Notification/clear-all');
    if (r.data is Map && r.data['success'] != null) {
      return r.data['success'] == true;
    }
    return r.statusCode == 200;
  }
}

final notificationApiProvider = Provider<NotificationApi>((ref) {
  final client = ref.read(dioClientProvider);
  return NotificationApi(client);
});

