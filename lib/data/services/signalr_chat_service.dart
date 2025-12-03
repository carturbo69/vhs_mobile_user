// lib/data/services/signalr_chat_service.dart

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

  // Stream tin nhắn mới
  final _messageStreamController = StreamController<MessageModel>.broadcast();
  // Stream danh sách chat
  final _conversationListStreamController = StreamController<ConversationListItemModel>.broadcast();
  // Stream trạng thái tin nhắn (MỚI THÊM)
  final _messageStatusStreamController = StreamController<Map<String, dynamic>>.broadcast();

  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;
  String? _currentAccountId;

  // Future<void> connect(String accountId) async {
  Future<void> connect(String accountId) async {
    // FIX: Nếu đã kết nối nhưng accountId khác (do đổi tài khoản), phải ngắt và kết nối lại
    if (isConnected && _currentAccountId != accountId) {
      await disconnect();
    }
    if (isConnected) return;

    _hubConnection = HubConnectionBuilder()
        .withUrl(_serverUrl)
        .withAutomaticReconnect()
        .build();

    // ✅ SỬA LẠI NHƯ SAU:
    (_hubConnection as dynamic).onclose(({error}) { // Thêm { }
      print("SignalR Closed. Error: $error");
    });

    (_hubConnection as dynamic).onreconnected(({connectionId}) { // Thêm { }
      print("SignalR Reconnected. ID: $connectionId");
      _register(accountId);
    });

    // Hàm onreconnecting vẫn giữ nguyên hoặc thêm {} tùy version, nhưng thường là lỗi ở onreconnected
    (_hubConnection as dynamic).onreconnecting(({error}) { // Thêm { } cho chắc ăn
      print("SignalR Reconnecting. Error: $error");
    });

    //   try {
    //     await _hubConnection?.start();
    //     print("SignalR Connected!");
    //     await _register(accountId);
    //     _registerEvents();
    //   } catch (e) {
    //     print("SignalR Connection Error: $e");
    //   }
    // }

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

  // void _registerEvents() {
  //   if (_hubConnection == null) return;
  //
  //   // 1. Tin nhắn mới
  //   _hubConnection!.on("message:created", (List<Object?>? args) {
  //     if (args != null && args.isNotEmpty) {
  //       try {
  //         // Ép kiểu an toàn: Map<Object?, Object?> -> Map<String, dynamic>
  //         final rawData = args[0] as Map;
  //         final data = Map<String, dynamic>.from(rawData);
  //
  //         print("SignalR New Message: $data");
  //         final message = MessageModel.fromJson(data);
  //         _messageStreamController.add(message);
  //       } catch (e) {
  //         print("Error parsing message:created - $e");
  //       }
  //     }
  //   });

  void _registerEvents() {
    if (_hubConnection == null) return;

    // // 1. Xử lý sự kiện tin nhắn mới
    // _hubConnection!.on("message:created", (List<Object?>? args) {
    //   if (args != null && args.isNotEmpty) {
    //     try {
    //       // FIX: Cast an toàn từ Map<dynamic, dynamic> sang Map<String, dynamic>
    //       final rawData = args[0] as Map<dynamic, dynamic>;
    //       final data = rawData.map((key, value) => MapEntry(key.toString(), value));
    //
    //       print("SignalR New Message: $data");
    //       final message = MessageModel.fromJson(data);
    //       _messageStreamController.add(message);
    //     } catch (e) {
    //       print("Error parsing message:created - $e");
    //     }
    //   }
    // });

    // 1. Xử lý sự kiện tin nhắn mới
    _hubConnection!.on("message:created", (List<Object?>? args) {
      if (args != null && args.isNotEmpty) {
        try {
          // Cast an toàn
          final rawData = args[0] as Map<dynamic, dynamic>;
          // Convert key sang String để tránh lỗi type
          final data = rawData.map((key, value) => MapEntry(key.toString(), value));

          print("SignalR New Message: $data");
          final message = MessageModel.fromJson(data);
          _messageStreamController.add(message);
        } catch (e) {
          // In lỗi chi tiết để debug
          print("Error parsing message:created - $e");
        }
      }
    });

    // 2. Cập nhật danh sách chat
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

    // 3. (QUAN TRỌNG) Cập nhật trạng thái tin nhắn (Sent -> Delivered -> Seen)
    // Backend thường gửi sự kiện này khi bên kia đã nhận/xem
    //   void handleStatusUpdate(List<Object?>? args) {
    //     if (args != null && args.isNotEmpty) {
    //       try {
    //         final rawData = args[0] as Map;
    //         final data = Map<String, dynamic>.from(rawData);
    //         print("SignalR Status Update: $data");
    //         _messageStatusStreamController.add(data);
    //       } catch (e) {
    //         print("Error parsing message status - $e");
    //       }
    //     }
    //   }
    //
    //   // Lắng nghe nhiều tên sự kiện có thể xảy ra từ Backend
    //   _hubConnection!.on("message:statusChanged", handleStatusUpdate);
    //   _hubConnection!.on("message:updated", handleStatusUpdate);
    //   _hubConnection!.on("conversation:readUpTo", handleStatusUpdate);
    // }

    //   void handleStatusUpdate(List<Object?>? args) {
    //     if (args != null && args.isNotEmpty) {
    //       try {
    //         // FIX: Cast an toàn
    //         final rawData = args[0] as Map<dynamic, dynamic>;
    //         final data = rawData.map((key, value) => MapEntry(key.toString(), value));
    //
    //         print("SignalR Status Update: $data");
    //         _messageStatusStreamController.add(data);
    //       } catch (e) {
    //         print("Error parsing message status - $e");
    //       }
    //     }
    //   }
    //
    //   _hubConnection!.on("message:statusChanged", handleStatusUpdate);
    //   _hubConnection!.on("message:updated", handleStatusUpdate);
    //   _hubConnection!.on("conversation:readUpTo", handleStatusUpdate);
    // }

    // 3. Cập nhật trạng thái
    void handleStatusUpdate(List<Object?>? args) {
      if (args != null && args.isNotEmpty) {
        try {
          final rawData = args[0] as Map<dynamic, dynamic>;
          final data = rawData.map((key, value) => MapEntry(key.toString(), value));

          print("SignalR Status Update: $data");
          _messageStatusStreamController.add(data);
        } catch (e) {
          print("Error parsing message status - $e");
        }
      }
    }

    _hubConnection!.on("message:statusChanged", handleStatusUpdate);
    _hubConnection!.on("message:updated", handleStatusUpdate);
    _hubConnection!.on("conversation:readUpTo", handleStatusUpdate);
  }

  // Stream<MessageModel> listenToMessages(String conversationId) {
  //   return _messageStreamController.stream.where(
  //           (msg) => msg.conversationId.toLowerCase() == conversationId.toLowerCase()
  //   );
  // }

  // Trong SignalRChatService.dart

  // Stream<MessageModel> listenToMessages(String conversationId) {
  //   return _messageStreamController.stream.where(
  //           (msg) {
  //         // Log để kiểm tra nếu tin nhắn không hiện
  //         // print("Socket Msg ID: ${msg.conversationId} - Current Screen ID: $conversationId");
  //         return msg.conversationId.toLowerCase() == conversationId.toLowerCase();
  //       }
  //   );
  // }

  Stream<MessageModel> listenToMessages(String conversationId) {
    return _messageStreamController.stream.where(
            (msg) {
          // FIX: Đảm bảo so sánh không phân biệt hoa thường và trim khoảng trắng
          return msg.conversationId.trim().toLowerCase() == conversationId.trim().toLowerCase();
        }
    );
  }

  Stream<ConversationListItemModel> listenToConversations() {
    return _conversationListStreamController.stream;
  }

  // Stream trạng thái cho ViewModel lắng nghe
  // Stream<Map<String, dynamic>> listenToMessageStatus(String conversationId) {
  //   return _messageStatusStreamController.stream.where((data) {
  //     final cId = (data['conversationId'] ?? data['ConversationId'])?.toString().toLowerCase();
  //     return cId == conversationId.toLowerCase();
  //   });
  // }

  Stream<Map<String, dynamic>> listenToMessageStatus(String conversationId) {
    return _messageStatusStreamController.stream.where((data) {
      // FIX: Lấy ID an toàn từ cả 2 kiểu casing
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