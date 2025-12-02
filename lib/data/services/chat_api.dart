import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/network/dio_client.dart';
import 'package:vhs_mobile_user/data/models/chat/conversation_model.dart';
import 'package:vhs_mobile_user/data/models/chat/message_model.dart';

class ChatApi {
  final DioClient _client;

  ChatApi(this._client);

  // Lấy danh sách hội thoại
  Future<List<ConversationListItemModel>> getConversations(String accountId) async {
    final resp = await _client.instance.get(
      '/api/messages/conversations',
      queryParameters: {'accountId': accountId},
    );
    return (resp.data as List)
        .map((json) => ConversationListItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Lấy chi tiết hội thoại
  Future<ConversationModel> getConversationDetail({
    required String conversationId,
    required String accountId,
    int take = 50,
    DateTime? before,
    bool markAsRead = true,
  }) async {
    final queryParams = {
      'accountId': accountId,
      'take': take,
      'markAsRead': markAsRead,
    };
    if (before != null) {
      queryParams['before'] = before.toIso8601String();
    }

    final resp = await _client.instance.get(
      '/api/messages/$conversationId',
      queryParameters: queryParams,
    );
    return ConversationModel.fromJson(resp.data as Map<String, dynamic>);
  }

  // Bắt đầu chat với Provider
  Future<String> startConversationWithProvider({
    required String myAccountId,
    required String providerId,
  }) async {
    final resp = await _client.instance.post(
      '/api/messages/start',
      data: {
        'myAccountId': myAccountId,
        'providerId': providerId,
      },
    );
    return resp.data.toString();
  }

  // Bắt đầu chat với Admin
  Future<String> startConversationWithAdmin(String myAccountId) async {
    final resp = await _client.instance.post(
      '/api/messages/start-with-admin',
      queryParameters: {'myAccountId': myAccountId},
    );
    return resp.data.toString();
  }

  // Gửi tin nhắn (text hoặc image)
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String accountId,
    String? body,
    File? image,
    String? replyToMessageId,
  }) async {
    final formData = FormData.fromMap({
      'conversationId': conversationId,
      'accountId': accountId,
      if (body != null) 'body': body,
      if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
      if (image != null)
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
    });

    final resp = await _client.instance.post(
      '/api/messages',
      data: formData,
    );
    final messageData = resp.data as Map<String, dynamic>;
    
    // Chuyển đổi imageUrl từ relative path sang absolute URL nếu cần
    if (messageData['imageUrl'] != null && 
        messageData['imageUrl'] is String &&
        !messageData['imageUrl'].toString().startsWith('http')) {
      final baseUrl = _client.instance.options.baseUrl;
      final imagePath = messageData['imageUrl'].toString().replaceFirst(RegExp(r'^/+'), '');
      messageData['imageUrl'] = '$baseUrl/$imagePath';
    }
    
    // Cũng xử lý imageUrl trong replyTo nếu có
    if (messageData['replyTo'] != null && messageData['replyTo'] is Map) {
      final replyTo = messageData['replyTo'] as Map<String, dynamic>;
      if (replyTo['imageUrl'] != null && 
          replyTo['imageUrl'] is String &&
          !replyTo['imageUrl'].toString().startsWith('http')) {
        final baseUrl = _client.instance.options.baseUrl;
        final imagePath = replyTo['imageUrl'].toString().replaceFirst(RegExp(r'^/+'), '');
        replyTo['imageUrl'] = '$baseUrl/$imagePath';
      }
    }
    
    return MessageModel.fromJson(messageData);
  }

  // Đánh dấu hội thoại đã đọc
  Future<void> markConversationRead({
    required String conversationId,
    required String viewerAccountId,
  }) async {
    await _client.instance.post(
      '/api/messages/conversations/$conversationId/read',
      queryParameters: {'viewerAccountId': viewerAccountId},
    );
  }

  // Lấy tổng số tin nhắn chưa đọc
  Future<int> getUnreadTotal(String accountId) async {
    final resp = await _client.instance.get(
      '/api/messages/unread/total',
      queryParameters: {'accountId': accountId},
    );
    return resp.data['total'] as int? ?? 0;
  }

  // Xóa/Ẩn hội thoại
  Future<void> clearConversation({
    required String conversationId,
    required String accountId,
    bool hide = false,
  }) async {
    await _client.instance.delete(
      '/api/messages/conversations/$conversationId/me',
      queryParameters: {
        'accountId': accountId,
        'hide': hide,
      },
    );
  }

  // Xóa tất cả tin nhắn của người dùng trong conversation
  Future<void> deleteAllMyMessages({
    required String conversationId,
    required String accountId,
  }) async {
    await _client.instance.delete(
      '/api/messages/conversations/$conversationId/messages/me',
      queryParameters: {
        'accountId': accountId,
      },
    );
  }

  // Xóa một tin nhắn cụ thể
  Future<void> deleteMessage({
    required String messageId,
    required String accountId,
  }) async {
    await _client.instance.delete(
      '/api/messages/$messageId',
      queryParameters: {
        'accountId': accountId,
      },
    );
  }
}

final chatApiProvider = Provider<ChatApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChatApi(dioClient);
});

