import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/chat/conversation_model.dart';
import 'package:vhs_mobile_user/data/models/chat/message_model.dart';
import 'package:vhs_mobile_user/data/services/chat_api.dart';
import 'package:vhs_mobile_user/data/services/signalr_chat_service.dart';

class ChatRepository {
  final ChatApi api;
  final SignalRChatService? signalRService;

  ChatRepository({required this.api, this.signalRService});

  Future<List<ConversationListItemModel>> getConversations(String accountId) async {
    return await api.getConversations(accountId);
  }

  Future<ConversationModel> getConversationDetail({
    required String conversationId,
    required String accountId,
    int take = 50,
    DateTime? before,
    bool markAsRead = true,
  }) async {
    return await api.getConversationDetail(
      conversationId: conversationId,
      accountId: accountId,
      take: take,
      before: before,
      markAsRead: markAsRead,
    );
  }

  Future<String> startConversationWithProvider({
    required String myAccountId,
    required String providerId,
  }) async {
    return await api.startConversationWithProvider(
      myAccountId: myAccountId,
      providerId: providerId,
    );
  }

  Future<String> startConversationWithAdmin(String myAccountId) async {
    return await api.startConversationWithAdmin(myAccountId);
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String accountId,
    String? body,
    File? image,
    String? replyToMessageId,
  }) async {
    final message = await api.sendMessage(
      conversationId: conversationId,
      accountId: accountId,
      body: body,
      image: image,
      replyToMessageId: replyToMessageId,
    );

    // SignalR will handle real-time updates via backend push
    // No need to manually sync here as backend will push via SignalR

    return message;
  }

  Future<void> markConversationRead({
    required String conversationId,
    required String viewerAccountId,
  }) async {
    await api.markConversationRead(
      conversationId: conversationId,
      viewerAccountId: viewerAccountId,
    );
  }

  Future<int> getUnreadTotal(String accountId) async {
    return await api.getUnreadTotal(accountId);
  }

  Future<void> clearConversation({
    required String conversationId,
    required String accountId,
    bool hide = false,
  }) async {
    await api.clearConversation(
      conversationId: conversationId,
      accountId: accountId,
      hide: hide,
    );
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final api = ref.read(chatApiProvider);
  final signalRService = ref.read(signalRChatServiceProvider);
  return ChatRepository(api: api, signalRService: signalRService);
});

