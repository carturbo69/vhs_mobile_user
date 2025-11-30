import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/chat/conversation_model.dart';
import 'package:vhs_mobile_user/data/models/chat/message_model.dart';
import 'package:vhs_mobile_user/data/repositories/chat_repository.dart';
import 'package:vhs_mobile_user/data/services/signalr_chat_service.dart';
import 'package:vhs_mobile_user/helper/jwt_helper.dart';

final chatDetailProvider = AsyncNotifierProvider.family<
    ChatDetailNotifier, ConversationModel, String>(
  ChatDetailNotifier.new,
);

class ChatDetailNotifier extends AsyncNotifier<ConversationModel> {
  late String _conversationId;
  late ChatRepository _repo;
  String? _accountId;

  ChatDetailNotifier(this._conversationId);

  Future<String?> _getAccountId() async {
    if (_accountId != null && _accountId!.isNotEmpty) {
      return _accountId;
    }

    final authDao = ref.read(authDaoProvider);
    final auth = await authDao.getSavedAuth();
    _accountId = auth?['accountId'] as String?;

    // Nếu accountId từ database rỗng, thử lấy từ JWT token
    if (_accountId == null || _accountId!.isEmpty) {
      final token = await authDao.getToken();
      if (token != null) {
        _accountId = JwtHelper.getAccountIdFromToken(token);
      }
    }

    return _accountId;
  }

  @override
  Future<ConversationModel> build() async {
    _repo = ref.read(chatRepositoryProvider);
    
    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) {
      throw Exception('Chưa đăng nhập');
    }

    _accountId = accountId;
    return await _repo.getConversationDetail(
      conversationId: _conversationId,
      accountId: accountId,
    );
  }

  Future<void> refresh() async {
    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) return;

    _accountId = accountId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getConversationDetail(
      conversationId: _conversationId,
      accountId: accountId,
    ));
  }

  Future<bool> sendMessage({
    String? body,
    File? image,
    String? replyToMessageId,
  }) async {
    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) return false;

    _accountId = accountId;

    try {
      // Cập nhật UI ngay lập tức với message đang gửi (optimistic update)
      final current = state.value;
      String? tempMessageId;
      if (current != null) {
        // Tạo message tạm thời để hiển thị ngay
        tempMessageId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
        // Nếu có ảnh, dùng file:// để hiển thị ảnh local
        final tempImageUrl = image != null ? 'file://${image.path}' : null;
        final tempMessage = MessageModel(
          messageId: tempMessageId,
          conversationId: _conversationId,
          senderAccountId: accountId,
          body: body,
          messageType: image != null ? 'Image' : 'Text',
          replyToMessageId: replyToMessageId,
          imageUrl: tempImageUrl,
          metadata: null,
          createdAt: DateTime.now().toUtc(), // Dùng UTC để consistent
          editedAt: null,
          deletedAt: null,
          sender: MessageAccountModel(
            accountId: accountId,
            accountName: 'Bạn',
            avatarUrl: null, email: '', role: '',
          ),
          replyTo: null,
          isMine: true,
          status: 'Sending',
        );
        // Thêm message và sort lại từ cũ đến mới
        final updatedMessages = [...current.messages, tempMessage];
        updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        state = AsyncValue.data(
          current.copyWith(messages: updatedMessages),
        );
      }

      // Gửi message thực tế
      final message = await _repo.sendMessage(
        conversationId: _conversationId,
        accountId: accountId,
        body: body,
        image: image,
        replyToMessageId: replyToMessageId,
      );

      // Cập nhật lại với message thực tế từ server
      final updated = state.value;
      if (updated != null) {
        // Xóa message tạm và thêm message thực tế
        final filteredMessages = updated.messages
            .where((m) => !m.messageId.startsWith('temp-'))
            .toList();
        // Thêm message thực tế và sort lại từ cũ đến mới
        final finalMessages = [...filteredMessages, message];
        finalMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        state = AsyncValue.data(
          updated.copyWith(messages: finalMessages),
        );
      } else {
        await refresh();
      }

      return true;
    } catch (e, st) {
      // Nếu có lỗi, rollback optimistic update
      final updated = state.value;
      if (updated != null) {
        final filteredMessages = updated.messages
            .where((m) => !m.messageId.startsWith('temp-'))
            .toList();
        state = AsyncValue.data(
          updated.copyWith(messages: filteredMessages),
        );
      }
      print('Error sending message: $e');
      return false;
    }
  }

  Future<void> markAsRead() async {
    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) return;

    _accountId = accountId;
    try {
      await _repo.markConversationRead(
        conversationId: _conversationId,
        viewerAccountId: accountId,
      );
      await refresh();
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> loadMoreMessages(DateTime before) async {
    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) return;

    _accountId = accountId;
    try {
      final conversation = await _repo.getConversationDetail(
        conversationId: _conversationId,
        accountId: accountId,
        take: 50,
        before: before,
        markAsRead: false,
      );

      final current = state.value;
      if (current != null) {
        // Merge messages, tránh duplicate
        final existingIds = current.messages.map((m) => m.messageId).toSet();
        final newMessages = conversation.messages
            .where((m) => !existingIds.contains(m.messageId))
            .toList();
        // Merge và sort lại từ cũ đến mới
        final mergedMessages = [...current.messages, ...newMessages];
        mergedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        state = AsyncValue.data(
          current.copyWith(messages: mergedMessages),
        );
      }
    } catch (e) {
      // Ignore errors
    }
  }

  void addMessage(MessageModel message) {
    final current = state.value;
    if (current != null && message.conversationId == _conversationId) {
      // Check if message already exists
      final exists = current.messages.any((m) => m.messageId == message.messageId);
      if (!exists) {
        // Thêm message mới vào list
        final updatedMessages = [...current.messages, message];
        // Sắp xếp lại từ cũ đến mới (theo UTC để so sánh chính xác)
        updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        state = AsyncValue.data(
          current.copyWith(messages: updatedMessages),
        );
      }
    }
  }

  // Setup SignalR listener for real-time messages
  Stream<MessageModel> listenToMessages() {
    final signalRService = ref.read(signalRChatServiceProvider);
    return signalRService.listenToMessages(_conversationId);
  }
}

extension ConversationModelExtension on ConversationModel {
  ConversationModel copyWith({
    String? conversationId,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    MessageAccountModel? participantA,
    MessageAccountModel? participantB,
    bool? isHiddenForMe,
    bool? isMutedForMe,
    String? title,
    String? avatarUrl,
    String? lastMessageSnippet,
    int? unreadCount,
    bool? isOnline,
    bool? isPinned,
    List<MessageModel>? messages,
  }) {
    return ConversationModel(
      conversationId: conversationId ?? this.conversationId,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      participantA: participantA ?? this.participantA,
      participantB: participantB ?? this.participantB,
      isHiddenForMe: isHiddenForMe ?? this.isHiddenForMe,
      isMutedForMe: isMutedForMe ?? this.isMutedForMe,
      title: title ?? this.title,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessageSnippet: lastMessageSnippet ?? this.lastMessageSnippet,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isPinned: isPinned ?? this.isPinned,
      messages: messages ?? this.messages,
    );
  }
}

