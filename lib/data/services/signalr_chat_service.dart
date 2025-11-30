import 'dart:async';
import 'dart:convert';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/chat/message_model.dart';
import 'package:vhs_mobile_user/data/models/chat/conversation_model.dart';

class SignalRChatService {
  HubConnection? _connection;
  final String _baseUrl;
  String? _currentAccountId;
  
  // Stream controllers
  final _messageController = StreamController<MessageModel>.broadcast();
  final _conversationListController = StreamController<ConversationListItemModel>.broadcast();
  final _readReceiptController = StreamController<Map<String, dynamic>>.broadcast();
  
  SignalRChatService({String? baseUrl}) 
      : _baseUrl = baseUrl ?? 'http://apivhs.cuahangkinhdoanh.com';

  // Getters for streams
  Stream<MessageModel> get messageStream => _messageController.stream;
  Stream<ConversationListItemModel> get conversationListStream => _conversationListController.stream;
  Stream<Map<String, dynamic>> get readReceiptStream => _readReceiptController.stream;

  // Check if connected
  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  // Connect to SignalR hub
  Future<void> connect(String accountId) async {
    if (_connection != null && _connection!.state == HubConnectionState.Connected) {
      if (_currentAccountId == accountId) {
        return; // Already connected with same account
      }
      await disconnect();
    }

    _currentAccountId = accountId;

    // Backend SignalR hub endpoint
    final hubUrl = '$_baseUrl/chatcustomerhub';
    
    _connection = HubConnectionBuilder()
        .withUrl(hubUrl)
        .withAutomaticReconnect()
        .build();

    // Register event handlers
    _connection!.on('message:created', (arguments) {
      _handleMessageCreated(arguments);
    });

    _connection!.on('conversationList:update', (arguments) {
      _handleConversationListUpdate(arguments);
    });

    _connection!.on('conversation:readUpTo', (arguments) {
      _handleReadReceipt(arguments);
    });

    // Handle connection state changes
    _connection!.onclose(({Exception? error}) {
      // Connection closed
    });

    try {
      await _connection!.start();
      
      // Register with accountId
      await _connection!.invoke('Register', args: <Object>[accountId]);
    } catch (e) {
      rethrow;
    }
  }

  void _handleMessageCreated(List<dynamic>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final arg = arguments[0];
      Map<String, dynamic> messageData;
      if (arg is Map) {
        messageData = Map<String, dynamic>.from(arg);
      } else if (arg is String) {
        messageData = jsonDecode(arg) as Map<String, dynamic>;
      } else {
        return;
      }
      final message = MessageModel.fromJson(messageData);
      _messageController.add(message);
    } catch (e) {
      // Ignore parsing errors
    }
  }

  void _handleConversationListUpdate(List<dynamic>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final arg = arguments[0];
      Map<String, dynamic> itemData;
      if (arg is Map) {
        itemData = Map<String, dynamic>.from(arg);
      } else if (arg is String) {
        itemData = jsonDecode(arg) as Map<String, dynamic>;
      } else {
        return;
      }
      final item = ConversationListItemModel.fromJson(itemData);
      _conversationListController.add(item);
    } catch (e) {
      // Ignore parsing errors
    }
  }

  void _handleReadReceipt(List<dynamic>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final arg = arguments[0];
      Map<String, dynamic> data;
      if (arg is Map) {
        data = Map<String, dynamic>.from(arg);
      } else if (arg is String) {
        data = jsonDecode(arg) as Map<String, dynamic>;
      } else {
        return;
      }
      _readReceiptController.add(data);
    } catch (e) {
      // Ignore parsing errors
    }
  }

  // Disconnect from SignalR
  Future<void> disconnect() async {
    if (_connection != null) {
      if (_currentAccountId != null) {
        try {
          await _connection!.invoke('Unregister', args: <Object>[_currentAccountId!]);
        } catch (e) {
          // Ignore errors
        }
      }
      
      await _connection!.stop();
      _connection = null;
      _currentAccountId = null;
    }
  }

  // Listen to new messages for a specific conversation
  Stream<MessageModel> listenToMessages(String conversationId) {
    return messageStream.where((message) => message.conversationId == conversationId);
  }

  // Listen to conversation list updates
  Stream<ConversationListItemModel> listenToConversations() {
    return conversationListStream;
  }

  // Listen to read receipts
  Stream<Map<String, dynamic>> listenToReadReceipts(String conversationId) {
    return readReceiptStream.where((data) => 
      data['ConversationId']?.toString() == conversationId ||
      data['conversationId']?.toString() == conversationId
    );
  }

  // Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
    _conversationListController.close();
    _readReceiptController.close();
  }
}

final signalRChatServiceProvider = Provider<SignalRChatService>((ref) {
  final service = SignalRChatService();
  ref.onDispose(() => service.dispose());
  return service;
});
