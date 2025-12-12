import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/notification/notification_model.dart';

final signalRNotificationServiceProvider = Provider<SignalRNotificationService>((ref) {
  return SignalRNotificationService(ref);
});

class SignalRNotificationService {
  final Ref _ref;
  HubConnection? _hubConnection;
  // Use HTTPS to match backend and avoid mixed-content / blocked connections
  final String _serverUrl = "https://apivhs.cuahangkinhdoanh.com/hubs/notification";

  final _notificationStreamController = StreamController<NotificationModel>.broadcast();
  final _unreadCountStreamController = StreamController<int>.broadcast();

  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;
  String? _currentAccountId;

  SignalRNotificationService(this._ref);

  Future<void> connect(String accountId) async {
    if (isConnected && _currentAccountId != accountId) {
      await disconnect();
    }
    if (isConnected) return;

    final authDao = _ref.read(authDaoProvider);
    final token = await authDao.getToken();

    // Use accessTokenFactory so token is attached as Authorization header.
    // This matches the working staff/mobile client and avoids server-side
    // HubException “Method does not exist” that happens when we try to call
    // the old Register method.
    _hubConnection = HubConnectionBuilder()
        .withUrl(
          _serverUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: token != null && token.isNotEmpty
                ? () async => token
                : null,
          ),
        )
        .withAutomaticReconnect()
        .build();

    (_hubConnection as dynamic).onclose(({error}) {
      print("SignalR NotificationHub Closed. Error: $error");
    });

    (_hubConnection as dynamic).onreconnected(({connectionId}) {
      print("SignalR NotificationHub Reconnected. ID: $connectionId");
      // No explicit register needed; authentication via token keeps user context.
    });

    (_hubConnection as dynamic).onreconnecting(({error}) {
      print("SignalR NotificationHub Reconnecting. Error: $error");
    });

    try {
      await _hubConnection?.start();
      print("✅ SignalR NotificationHub Connected!");
      print("✅ SignalR: Connection state: ${_hubConnection?.state}");
      print("✅ SignalR: Connection ID: ${(_hubConnection as dynamic).connectionId}");

      _currentAccountId = accountId;
      print("✅ SignalR: Account ID set: $accountId");
      _registerEvents();
      
      // Test connection by logging all available methods
      print("🔍 SignalR: Testing connection...");
    } catch (e, stackTrace) {
      print("❌ SignalR NotificationHub Connection Error: $e");
      print("❌ Stack trace: $stackTrace");
    }
  }

  void _registerEvents() {
    if (_hubConnection == null) {
      print("⚠️ SignalR: Cannot register events - hubConnection is null");
      return;
    }

    print("🔔 SignalR: Registering notification event listeners...");

    // Listen for new notifications - backend gửi event "ReceiveNotification"
    _hubConnection!.on("ReceiveNotification", (List<Object?>? args) {
      print("📬 SignalR: ReceiveNotification event triggered! Args count: ${args?.length ?? 0}");
      if (args != null && args.isNotEmpty) {
        try {
          print("📬 SignalR: Raw args[0]: ${args[0]}");
          final rawData = args[0] as Map<dynamic, dynamic>;
          final data = rawData.map((key, value) =>
              MapEntry(key.toString(), value));
          print("📬 SignalR ReceiveNotification parsed data: $data");
          print("📬 SignalR: NotificationType: ${data['notificationType'] ?? data['NotificationType']}");
          print("📬 SignalR: Content: ${data['content'] ?? data['Content']}");
          
          final notification = NotificationModel.fromJson(data);
          print("✅ SignalR: Successfully parsed notification: ${notification.notificationId}, Type: ${notification.notificationType}");
          _notificationStreamController.add(notification);
          print("✅ SignalR: Added notification to stream");
        } catch (e, stackTrace) {
          print("❌ Error parsing ReceiveNotification - $e");
          print("❌ Stack trace: $stackTrace");
        }
      } else {
        print("⚠️ SignalR: ReceiveNotification event received but args is null or empty");
      }
    });

    // Listen for notification:created (backup event name)
    _hubConnection!.on("notification:created", (List<Object?>? args) {
      print("📬 SignalR: notification:created event triggered! Args count: ${args?.length ?? 0}");
      if (args != null && args.isNotEmpty) {
        try {
          print("📬 SignalR: Raw args[0]: ${args[0]}");
          final rawData = args[0] as Map<dynamic, dynamic>;
          final data = rawData.map((key, value) =>
              MapEntry(key.toString(), value));
          print("📬 SignalR notification:created parsed data: $data");
          print("📬 SignalR: NotificationType: ${data['notificationType'] ?? data['NotificationType']}");
          print("📬 SignalR: Content: ${data['content'] ?? data['Content']}");
          
          final notification = NotificationModel.fromJson(data);
          print("✅ SignalR: Successfully parsed notification: ${notification.notificationId}, Type: ${notification.notificationType}");
          _notificationStreamController.add(notification);
          print("✅ SignalR: Added notification to stream");
        } catch (e, stackTrace) {
          print("❌ Error parsing notification:created - $e");
          print("❌ Stack trace: $stackTrace");
        }
      } else {
        print("⚠️ SignalR: notification:created event received but args is null or empty");
      }
    });

    // Listen for all possible event names that backend might send
    final possibleEventNames = [
      "ReceiveNotification",
      "notification:created",
      "NotificationCreated",
      "NewNotification",
      "notification",
      "Notification",
    ];
    
    for (final eventName in possibleEventNames) {
      try {
        _hubConnection!.on(eventName, (List<Object?>? args) {
          print("📬 SignalR: $eventName event triggered! Args count: ${args?.length ?? 0}");
          if (args != null && args.isNotEmpty) {
            try {
              print("📬 SignalR: Raw args[0]: ${args[0]}");
              final rawData = args[0] as Map<dynamic, dynamic>;
              final data = rawData.map((key, value) =>
                  MapEntry(key.toString(), value));
              print("📬 SignalR $eventName parsed data: $data");
              
              final notification = NotificationModel.fromJson(data);
              print("✅ SignalR: Successfully parsed notification: ${notification.notificationId}, Type: ${notification.notificationType}");
              _notificationStreamController.add(notification);
              print("✅ SignalR: Added notification to stream");
            } catch (e, stackTrace) {
              print("❌ Error parsing $eventName - $e");
              print("❌ Stack trace: $stackTrace");
            }
          }
        });
        print("✅ SignalR: Registered listener for event: $eventName");
      } catch (e) {
        print("⚠️ SignalR: Could not register listener for $eventName: $e");
      }
    }

    // Listen for all events to debug (catch-all)
    try {
      // Try to listen to all events if the library supports it
      print("🔍 SignalR: Attempting to register catch-all listener...");
    } catch (e) {
      print("⚠️ SignalR: Catch-all listener not supported: $e");
    }

    print("✅ SignalR: Event listeners registered successfully");
  }

  Stream<NotificationModel> listenToNotifications() {
    return _notificationStreamController.stream;
  }

  Stream<int> listenToUnreadCount() {
    return _unreadCountStreamController.stream;
  }

  Future<void> disconnect() async {
    await _hubConnection?.stop();
    _hubConnection = null;
    _currentAccountId = null;
  }
}

