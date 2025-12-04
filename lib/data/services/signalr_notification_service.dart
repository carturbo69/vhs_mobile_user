import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/notification/notification_model.dart';

final signalRNotificationServiceProvider = Provider<SignalRNotificationService>((ref) {
  return SignalRNotificationService(ref);
});

class SignalRNotificationService {
  final Ref _ref;
  HubConnection? _hubConnection;
  final String _serverUrl = "http://apivhs.cuahangkinhdoanh.com/hubs/notification";

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

    // Add token to URL as query parameter for authentication
    final urlWithToken = token != null && token.isNotEmpty
        ? '$_serverUrl?access_token=$token'
        : _serverUrl;

    _hubConnection = HubConnectionBuilder()
        .withUrl(urlWithToken)
        .withAutomaticReconnect()
        .build();

    (_hubConnection as dynamic).onclose(({error}) {
      print("SignalR NotificationHub Closed. Error: $error");
    });

    (_hubConnection as dynamic).onreconnected(({connectionId}) {
      print("SignalR NotificationHub Reconnected. ID: $connectionId");
      // NotificationHub automatically adds user to group based on JWT token
    });

    (_hubConnection as dynamic).onreconnecting(({error}) {
      print("SignalR NotificationHub Reconnecting. Error: $error");
    });

    try {
      await _hubConnection?.start();
      print("SignalR NotificationHub Connected!");

      _currentAccountId = accountId;
      _registerEvents();
    } catch (e) {
      print("SignalR NotificationHub Connection Error: $e");
    }
  }

  void _registerEvents() {
    if (_hubConnection == null) return;

    // Listen for new notifications - backend gửi event "ReceiveNotification"
    _hubConnection!.on("ReceiveNotification", (List<Object?>? args) {
      if (args != null && args.isNotEmpty) {
        try {
          final rawData = args[0] as Map<dynamic, dynamic>;
          final data = rawData.map((key, value) =>
              MapEntry(key.toString(), value));
          print("📬 SignalR ReceiveNotification: $data");
          final notification = NotificationModel.fromJson(data);
          _notificationStreamController.add(notification);
        } catch (e) {
          print("❌ Error parsing ReceiveNotification - $e");
        }
      }
    });

    // Listen for notification:created (backup event name)
    _hubConnection!.on("notification:created", (List<Object?>? args) {
      if (args != null && args.isNotEmpty) {
        try {
          final rawData = args[0] as Map<dynamic, dynamic>;
          final data = rawData.map((key, value) =>
              MapEntry(key.toString(), value));
          print("📬 SignalR notification:created: $data");
          final notification = NotificationModel.fromJson(data);
          _notificationStreamController.add(notification);
        } catch (e) {
          print("❌ Error parsing notification:created - $e");
        }
      }
    });
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

