import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/notification/notification_model.dart';
import 'package:vhs_mobile_user/data/repositories/notification_repository.dart';
import 'package:vhs_mobile_user/data/services/signalr_notification_service.dart';
import 'package:vhs_mobile_user/helper/jwt_helper.dart';
import 'package:vhs_mobile_user/services/notification_service.dart';

final notificationListProvider =
    AsyncNotifierProvider<NotificationListNotifier, List<NotificationModel>>(
  NotificationListNotifier.new,
);

final notificationUnreadCountProvider = Provider.autoDispose<int>((ref) {
  // Watch the notification list to rebuild when it changes
  final notificationListAsync = ref.watch(notificationListProvider);
  
  // If we have data, calculate from state (real-time)
  return notificationListAsync.when(
    data: (currentList) {
      final unreadCount = currentList.where((n) => n.isRead != true).length;
      print("📊 Unread count from state: $unreadCount (total: ${currentList.length})");
      return unreadCount;
    },
    loading: () {
      // While loading, return 0 (will update when data arrives)
      return 0;
    },
    error: (error, stack) {
      // On error, return 0
      print("❌ Error in notification list: $error");
      return 0;
    },
  );
});

class NotificationListNotifier extends AsyncNotifier<List<NotificationModel>> {
  late NotificationRepository _repo;
  String? _accountId;

  Future<String?> _getAccountId() async {
    if (_accountId != null && _accountId!.isNotEmpty) {
      return _accountId;
    }

    final authDao = ref.read(authDaoProvider);
    final auth = await authDao.getSavedAuth();
    _accountId = auth?['accountId'] as String?;

    if (_accountId == null || _accountId!.isEmpty) {
      final token = await authDao.getToken();
      if (token != null) {
        _accountId = JwtHelper.getAccountIdFromToken(token);
      }
    }

    return _accountId;
  }

  @override
  Future<List<NotificationModel>> build() async {
    _repo = ref.read(notificationRepositoryProvider);

    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) {
      print('⚠️ [NotificationViewModel] No accountId found');
      return [];
    }

    _accountId = accountId;
    print('📋 [NotificationViewModel] Loading notifications for accountId: $accountId');

    final response = await _repo.getMyNotifications();
    final notifications = response.data ?? [];
    
    // Log all notification types received
    final notificationTypes = notifications.map((n) => n.notificationType).toSet();
    print('📋 [NotificationViewModel] Loaded ${notifications.length} notifications');
    print('📋 [NotificationViewModel] Notification types: ${notificationTypes.join(", ")}');
    
    // Check for system notifications
    final systemNotifications = notifications.where((n) => 
      n.notificationType.toLowerCase().contains('system') || 
      n.notificationType.toLowerCase().contains('hệ thống')
    ).toList();
    if (systemNotifications.isNotEmpty) {
      print('✅ [NotificationViewModel] Found ${systemNotifications.length} system notification(s)');
    } else {
      print('⚠️ [NotificationViewModel] No system notifications found');
    }
    
    return notifications;
  }

  Future<void> refresh() async {
    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    _accountId = accountId;
    final previousList = state.value;
    state = const AsyncLoading();
    try {
      final response = await _repo.getMyNotifications();
      final newList = response.data ?? [];
      
      // Check if there are new unread notifications
      if (previousList != null && newList.isNotEmpty) {
        final previousIds = previousList.map((n) => n.notificationId).toSet();
        final newNotifications = newList.where((n) => 
          !previousIds.contains(n.notificationId) && n.isRead != true
        ).toList();
        
        if (newNotifications.isNotEmpty) {
          print("📬 Phát hiện ${newNotifications.length} thông báo mới sau refresh");
          
          // Trigger GlobalNotificationService to show local notifications
          // This ensures system notifications and all other notifications are shown
          try {
            final notificationService = ref.read(notificationServiceProvider);
            // Show notification for each new notification (especially system notifications)
            for (final notification in newNotifications) {
              print("🔔 [NotificationViewModel] Triggering local notification for: ${notification.notificationType}");
              await notificationService.showNotificationForNewItem(notification);
            }
          } catch (e) {
            print("❌ [NotificationViewModel] Error showing notifications: $e");
          }
        }
      }
      
      state = AsyncValue.data(newList);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<int> getUnreadCount() async {
    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) return 0;

    _accountId = accountId;
    try {
      final response = await _repo.getMyUnreadNotifications();
      return response.unreadCount;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final success = await _repo.markAsRead(notificationId);
      if (success) {
        // Update local state
        final currentList = state.value;
        if (currentList != null) {
          final updatedList = currentList.map((item) {
            if (item.notificationId == notificationId) {
              return NotificationModel(
                notificationId: item.notificationId,
                accountReceivedId: item.accountReceivedId,
                receiverRole: item.receiverRole,
                notificationType: item.notificationType,
                content: item.content,
                isRead: true,
                createdAt: item.createdAt,
                receiverName: item.receiverName,
                receiverEmail: item.receiverEmail,
              );
            }
            return item;
          }).toList();
          state = AsyncValue.data(updatedList);
        }
        // Refresh unread count
        ref.invalidate(notificationUnreadCountProvider);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final success = await _repo.markAllAsRead();
      if (success) {
        // Update local state
        final currentList = state.value;
        if (currentList != null) {
          final updatedList = currentList.map((item) {
            return NotificationModel(
              notificationId: item.notificationId,
              accountReceivedId: item.accountReceivedId,
              receiverRole: item.receiverRole,
              notificationType: item.notificationType,
              content: item.content,
              isRead: true,
              createdAt: item.createdAt,
              receiverName: item.receiverName,
              receiverEmail: item.receiverEmail,
            );
          }).toList();
          state = AsyncValue.data(updatedList);
        }
        // Refresh unread count
        ref.invalidate(notificationUnreadCountProvider);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final success = await _repo.deleteNotification(notificationId);
      if (success) {
        // Remove from local state
        final currentList = state.value;
        if (currentList != null) {
          final updatedList = currentList.where(
            (item) => item.notificationId != notificationId
          ).toList();
          state = AsyncValue.data(updatedList);
        }
        // Refresh unread count
        ref.invalidate(notificationUnreadCountProvider);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearAllNotifications() async {
    try {
      final success = await _repo.clearAllNotifications();
      if (success) {
        state = const AsyncValue.data([]);
        // Refresh unread count
        ref.invalidate(notificationUnreadCountProvider);
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}

