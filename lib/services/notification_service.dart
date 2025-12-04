import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/notification/notification_model.dart';
import 'package:vhs_mobile_user/data/services/signalr_notification_service.dart';
import 'package:vhs_mobile_user/data/services/signalr_chat_service.dart';
import 'package:vhs_mobile_user/data/models/chat/message_model.dart';
import 'package:vhs_mobile_user/data/models/chat/conversation_model.dart';
import 'package:vhs_mobile_user/helper/jwt_helper.dart';
import 'package:vhs_mobile_user/ui/notification/notification_viewmodel.dart';
import 'package:vhs_mobile_user/ui/chat/chat_list_viewmodel.dart';

final notificationServiceProvider = Provider<GlobalNotificationService>((ref) {
  return GlobalNotificationService(ref);
});

class GlobalNotificationService {
  final Ref _ref;
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _notificationListSubscription;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  Set<String> _knownNotificationIds = <String>{};

  GlobalNotificationService(this._ref);

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle notification tap
          print('Notification tapped: ${details.payload}');
        },
      );

      if (initialized != null && initialized) {
        // Request permissions
        await _requestPermissions();
        _isInitialized = true;
        print('✅ Local notifications initialized successfully');
      } else {
        print('⚠️ Local notifications initialization returned false');
      }
    } catch (e) {
      print('❌ Error initializing local notifications: $e');
      // Continue without local notifications - app should still work
    }
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> connectSignalR() async {
    try {
      final authDao = _ref.read(authDaoProvider);
      final auth = await authDao.getSavedAuth();
      String? accountId = auth?['accountId'] as String?;

      if (accountId == null || accountId.isEmpty) {
        final token = await authDao.getToken();
        if (token != null) {
          accountId = JwtHelper.getAccountIdFromToken(token);
        }
      }

      if (accountId != null && accountId.isNotEmpty) {
        final signalRService = _ref.read(signalRNotificationServiceProvider);
        await signalRService.connect(accountId);

        // Listen to new notifications from SignalR
        _notificationSubscription?.cancel();
        _notificationSubscription = signalRService.listenToNotifications().listen((notification) {
          print("🔔 Global nhận thông báo mới từ SignalR: ${notification.content}");
          
          // Update UI state immediately
          final notifier = _ref.read(notificationListProvider.notifier);
          final currentList = notifier.state.value;
          
          List<NotificationModel> newList;
          if (currentList != null) {
            // Remove duplicate if exists
            final otherItems = currentList.where(
              (item) => item.notificationId != notification.notificationId
            ).toList();
            // Add new notification at the top (ensure isRead is false for new notifications)
            final newNotification = NotificationModel(
              notificationId: notification.notificationId,
              accountReceivedId: notification.accountReceivedId,
              receiverRole: notification.receiverRole,
              notificationType: notification.notificationType,
              content: notification.content,
              isRead: false, // New notifications are always unread
              createdAt: notification.createdAt,
              receiverName: notification.receiverName,
              receiverEmail: notification.receiverEmail,
            );
            newList = [newNotification, ...otherItems];
            notifier.state = AsyncValue.data(newList);
            
            // Calculate unread count immediately
            final unreadCount = newList.where((n) => n.isRead != true).length;
            print("✅ Đã cập nhật danh sách thông báo, tổng: ${newList.length}, chưa đọc: $unreadCount");
          } else {
            // If state is null, refresh to get full list
            print("⚠️ State is null, refreshing notification list...");
            notifier.refresh();
            newList = [];
          }
          
          // Invalidate unread count provider to force immediate recalculation
          // This ensures the badge updates immediately
          _ref.invalidate(notificationUnreadCountProvider);
          print("🔄 Đã invalidate notificationUnreadCountProvider để cập nhật badge");
          
          // Show local notification (non-blocking)
          _showLocalNotification(notification).catchError((error) {
            print("❌ Error in _showLocalNotification: $error");
          });
        }, onError: (error) {
          print("❌ Error listening to SignalR notifications: $error");
        });

        // Initialize known notification IDs from current state
        final currentList = _ref.read(notificationListProvider).value;
        if (currentList != null) {
          _knownNotificationIds = currentList.map((n) => n.notificationId).toSet();
          print("📋 Đã khởi tạo ${_knownNotificationIds.length} notification IDs đã biết");
        }
      }
    } catch (e) {
      print('❌ Error connecting SignalR NotificationHub: $e');
    }
  }

  Future<void> _showLocalNotification(NotificationModel notification) async {
    try {
      print('🔔 Attempting to show local notification: ${notification.content}');
      
      if (!_isInitialized) {
        print('⚠️ Not initialized, initializing now...');
        await initialize();
        // If still not initialized after trying, skip showing notification
        if (!_isInitialized) {
          print('❌ Local notifications not initialized, skipping system notification');
          return;
        }
      }

      // Check permissions before showing notification
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.areNotificationsEnabled();
        if (granted == false) {
          print('⚠️ Android notifications not enabled, requesting permission...');
          await androidPlugin.requestNotificationsPermission();
          // Check again after requesting
          final grantedAgain = await androidPlugin.areNotificationsEnabled();
          if (grantedAgain == false) {
            print('❌ Android notifications permission denied, cannot show notification');
            return;
          }
        }
        print('✅ Android notifications permission granted');
      }

      // Create notification channel for Android
      const androidDetails = AndroidNotificationDetails(
        'vhs_notifications',
        'VHS Thông báo',
        channelDescription: 'Thông báo từ ứng dụng VHS',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        channelShowBadge: true,
        autoCancel: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notificationId = notification.notificationId.hashCode.abs();
      await _localNotifications.show(
        notificationId,
        notification.notificationType ?? 'Thông báo',
        notification.content,
        details,
        payload: notification.notificationId,
      );
      print('✅ Local notification shown successfully (ID: $notificationId): ${notification.content}');
    } catch (e, stackTrace) {
      print('❌ Error showing local notification: $e');
      print('Stack trace: $stackTrace');
      // Don't throw - app should continue working even if notification fails
    }
  }

  /// Check for new notifications and show them
  Future<void> checkAndShowNewNotifications() async {
    try {
      final currentList = _ref.read(notificationListProvider).value;
      if (currentList == null || currentList.isEmpty) return;
      
      // Find new unread notifications
      final newUnreadNotifications = currentList.where((n) => 
        !_knownNotificationIds.contains(n.notificationId) && n.isRead != true
      ).toList();
      
      if (newUnreadNotifications.isNotEmpty) {
        print("📬 Phát hiện ${newUnreadNotifications.length} thông báo mới, sẽ hiển thị notification");
        // Show notification for the most recent one
        final latestNotification = newUnreadNotifications.first;
        await _showLocalNotification(latestNotification);
        
        // Update known IDs
        for (final notification in newUnreadNotifications) {
          _knownNotificationIds.add(notification.notificationId);
        }
      }
      
      // Update known IDs for all notifications (in case list was refreshed)
      _knownNotificationIds = currentList.map((n) => n.notificationId).toSet();
    } catch (e) {
      print("❌ Error checking new notifications: $e");
    }
  }

  /// Show notification for chat message
  Future<void> showChatMessageNotification({
    required String senderName,
    required String? messageBody,
    required String conversationId,
    String? imageUrl,
  }) async {
    try {
      print('💬 Attempting to show chat notification from $senderName');
      
      if (!_isInitialized) {
        print('⚠️ Not initialized, initializing now...');
        await initialize();
        if (!_isInitialized) {
          print('❌ Local notifications not initialized, skipping chat notification');
          return;
        }
      }

      // Check permissions before showing notification
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.areNotificationsEnabled();
        if (granted == false) {
          print('⚠️ Android notifications not enabled, requesting permission...');
          await androidPlugin.requestNotificationsPermission();
          final grantedAgain = await androidPlugin.areNotificationsEnabled();
          if (grantedAgain == false) {
            print('❌ Android notifications permission denied, cannot show chat notification');
            return;
          }
        }
      }

      // Create notification channel for chat messages
      const androidDetails = AndroidNotificationDetails(
        'vhs_chat_messages',
        'VHS Tin nhắn',
        channelDescription: 'Thông báo tin nhắn từ ứng dụng VHS',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        channelShowBadge: true,
        autoCancel: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Create notification content
      final title = senderName;
      final body = imageUrl != null && imageUrl.isNotEmpty
          ? '[Hình ảnh]'
          : (messageBody ?? '[Tin nhắn]');

      // Use conversationId + timestamp as unique ID to avoid duplicates
      final notificationId = 'chat_${conversationId}_${DateTime.now().millisecondsSinceEpoch}'.hashCode.abs();
      
      await _localNotifications.show(
        notificationId,
        title,
        body,
        details,
        payload: conversationId, // Pass conversationId as payload for navigation
      );
      print('✅ Chat notification shown successfully (ID: $notificationId): $senderName - $body');
    } catch (e, stackTrace) {
      print('❌ Error showing chat notification: $e');
      print('Stack trace: $stackTrace');
      // Don't throw - app should continue working even if notification fails
    }
  }

  /// Setup global chat message listeners to show notifications
  Future<void> setupChatListeners() async {
    try {
      print('🔔 Setting up global chat listeners...');
      final chatSignalRService = _ref.read(signalRChatServiceProvider);
      
      if (!chatSignalRService.isConnected) {
        print('⚠️ Chat SignalR not connected, cannot setup listeners');
        return;
      }
      
      // Listen to all messages (not filtered by conversationId)
      // We need to listen to the raw stream from SignalR
      // Since listenToMessages requires conversationId, we'll need a different approach
      // For now, we'll setup listeners in chat_list_screen, but we can also listen to conversationList:update
      
      print('✅ Global chat listeners setup completed');
    } catch (e) {
      print('❌ Error setting up chat listeners: $e');
    }
  }

  void dispose() {
    _notificationSubscription?.cancel();
    _notificationListSubscription?.cancel();
  }
}

/// Global Chat Service to handle chat messages and notifications
final globalChatServiceProvider = Provider<GlobalChatService>((ref) {
  return GlobalChatService(ref);
});

class GlobalChatService {
  final Ref _ref;
  StreamSubscription? _conversationUpdateSubscription;
  final Map<String, DateTime?> _lastNotifiedMessageTime = {};

  GlobalChatService(this._ref);

  /// Setup global listeners for chat messages
  Future<void> setupListeners() async {
    try {
      print('💬 Setting up global chat message listeners...');
      final chatSignalRService = _ref.read(signalRChatServiceProvider);
      
      if (!chatSignalRService.isConnected) {
        print('⚠️ Chat SignalR not connected, waiting...');
        // Wait a bit and retry
        await Future.delayed(const Duration(seconds: 2));
        if (!chatSignalRService.isConnected) {
          print('❌ Chat SignalR still not connected, cannot setup listeners');
          return;
        }
      }
      
      // Listen to conversation list updates (this fires when new messages arrive)
      _conversationUpdateSubscription?.cancel();
      _conversationUpdateSubscription = chatSignalRService.listenToConversations().listen(
        (updatedItem) {
          _handleConversationUpdate(updatedItem);
        },
        onError: (error) {
          print('❌ Error in conversation update stream: $error');
        },
      );
      
      print('✅ Global chat listeners setup completed');
    } catch (e, stackTrace) {
      print('❌ Error setting up global chat listeners: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _handleConversationUpdate(ConversationListItemModel updatedItem) {
    try {
      // Check if there's a new message
      if (updatedItem.lastMessageAt == null || updatedItem.unreadCount == 0) {
        return;
      }
      
      // Get the last notified time for this conversation
      final lastNotifiedTime = _lastNotifiedMessageTime[updatedItem.conversationId];
      
      // Show notification if:
      // 1. There's a new message (lastMessageAt is newer than last notified time)
      // 2. unreadCount > 0 (there are unread messages)
      // 3. The message is actually new (not already notified)
      final hasNewMessage = updatedItem.unreadCount > 0 &&
          (lastNotifiedTime == null ||
              updatedItem.lastMessageAt!.isAfter(lastNotifiedTime));
      
      if (hasNewMessage) {
        // Update last notified time
        _lastNotifiedMessageTime[updatedItem.conversationId] = updatedItem.lastMessageAt;
        
        // Show notification (non-blocking)
        final notificationService = _ref.read(notificationServiceProvider);
        notificationService.showChatMessageNotification(
          senderName: updatedItem.title,
          messageBody: updatedItem.lastMessageSnippet,
          conversationId: updatedItem.conversationId,
          imageUrl: updatedItem.lastMessageSnippet?.contains('[Hình ảnh]') == true ||
                   updatedItem.lastMessageSnippet?.contains('[Image]') == true
              ? 'has_image'
              : null,
        ).catchError((error) {
          print("❌ Error showing chat notification in global service: $error");
        });
        
        // Also update the chat list provider if it's being watched
        try {
          _ref.read(chatListProvider.notifier).handleRealtimeUpdate(updatedItem);
          _ref.invalidate(unreadTotalProvider);
        } catch (e) {
          // Provider might not be initialized yet, that's okay
        }
      }
    } catch (e) {
      print('❌ Error handling conversation update: $e');
    }
  }

  void dispose() {
    _conversationUpdateSubscription?.cancel();
  }
}


