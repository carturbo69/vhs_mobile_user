
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:vhs_mobile_user/data/models/chat/conversation_model.dart';
import 'package:vhs_mobile_user/data/models/chat/message_model.dart';

final signalRChatServiceProvider = Provider<SignalRChatService>((ref) {
  return SignalRChatService();
});

class SignalRChatService {
  HubConnection? _hubConnection;
  final String _serverUrl = "http://apivhs.cuahangkinhdoanh.com/chathub";

  final _messageStreamController = StreamController<MessageModel>.broadcast();
  final _conversationListStreamController = StreamController<ConversationListItemModel>.broadcast();
  final _messageStatusStreamController = StreamController<Map<String, dynamic>>.broadcast();

  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;
  String? _currentAccountId;

  Future<void> connect(String accountId) async {
    if (isConnected && _currentAccountId != accountId) {
      await disconnect();
    }
    if (isConnected) return;

    _hubConnection = HubConnectionBuilder()
        .withUrl(_serverUrl)
        .withAutomaticReconnect()
        .build();

    (_hubConnection as dynamic).onclose(({error}) {
      print("SignalR Closed. Error: $error");
    });

    (_hubConnection as dynamic).onreconnected(({connectionId}) {
      print("SignalR Reconnected. ID: $connectionId");
      _register(accountId);
    });

    (_hubConnection as dynamic).onreconnecting(({error}) {
      print("SignalR Reconnecting. Error: $error");
    });

    try {
      await _hubConnection?.start();
      print("SignalR Connected!");

      // Lưu lại accountId
      _currentAccountId = accountId;

      await _register(accountId);
      _registerEvents();
    } catch (e) {
      print("SignalR Connection Error: $e");
    }
  }

  Future<void> _register(String accountId) async {
    try {
      if (_hubConnection?.state == HubConnectionState.Connected) {
        await _hubConnection?.invoke("Register", args: [accountId]);
        print("SignalR Registered: $accountId");
      }
    } catch (e) {
      print("SignalR Register Failed: $e");
    }
  }


  void _registerEvents() {
    if (_hubConnection == null) return;

    _hubConnection!.on("message:created", (List<Object?>? args) {
      if (args != null && args.isNotEmpty) {
        try {
          final rawData = args[0] as Map<dynamic, dynamic>;
          final data = rawData.map((key, value) =>
              MapEntry(key.toString(), value));
          print("SignalR New Message: $data");
          final message = MessageModel.fromJson(data);
          _messageStreamController.add(message);
        } catch (e) {
          print("Error parsing message:created - $e");
        }
      }
    });

    _hubConnection!.on("conversationList:update", (List<Object?>? args) {
      if (args != null && args.isNotEmpty) {
        try {
          final rawData = args[0] as Map;
          final data = Map<String, dynamic>.from(rawData);

          final conversation = ConversationListItemModel.fromJson(data);
          _conversationListStreamController.add(conversation);
        } catch (e) {
          print("Error parsing conversationList:update - $e");
        }
      }
    });

    _hubConnection!.on("message:statusChanged", (List<Object?>? args) {
      _handleStatusUpdate(args, "statusChanged");
    });

    _hubConnection!.on("conversation:readUpTo", (List<Object?>? args) {
      _handleStatusUpdate(args, "readUpTo");
    });
  }

  void _handleStatusUpdate(List<Object?>? args, String eventType) {
    if (args != null && args.isNotEmpty) {
      try {
        final rawData = args[0] as Map<dynamic, dynamic>;
        final data = rawData.map((key, value) => MapEntry(key.toString(), value));
        data['eventType'] = eventType;
        print("SignalR Status ($eventType): $data");
        _messageStatusStreamController.add(data);
      } catch (e) {
        print("Error parsing status update: $e");
      }
    }
  }

  Stream<MessageModel> listenToMessages(String conversationId) {
    return _messageStreamController.stream.where(
            (msg) {
          return msg.conversationId.trim().toLowerCase() == conversationId.trim().toLowerCase();
        }
    );
  }

  Stream<ConversationListItemModel> listenToConversations() {
    return _conversationListStreamController.stream;
  }

  Stream<Map<String, dynamic>> listenToMessageStatus(String conversationId) {
    return _messageStatusStreamController.stream.where((data) {
      final cIdRaw = data['conversationId'] ?? data['ConversationId'];
      final cId = cIdRaw?.toString().trim().toLowerCase() ?? '';
      return cId == conversationId.trim().toLowerCase();
    });
  }

  Future<void> disconnect() async {
    await _hubConnection?.stop();
    _hubConnection = null;
  }
}