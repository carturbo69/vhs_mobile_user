import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/chat/conversation_model.dart';
import 'package:vhs_mobile_user/data/models/chat/message_model.dart';
import 'package:vhs_mobile_user/data/repositories/chat_repository.dart';
import 'package:vhs_mobile_user/data/services/signalr_chat_service.dart';
import 'package:vhs_mobile_user/helper/jwt_helper.dart';
import 'package:vhs_mobile_user/ui/chat/chat_list_viewmodel.dart';

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

    final signalRService = ref.read(signalRChatServiceProvider);

    final subscription = signalRService.listenToMessages(_conversationId).listen((message) {
      addMessage(message);
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) {
      throw Exception('Chưa đăng nhập');
    }

    _accountId = accountId;
    final conversation = await _repo.getConversationDetail(
      conversationId: _conversationId,
      accountId: accountId,
    );

    ConversationModel finalConversation = conversation;
    if (conversation.avatarUrl == null || conversation.avatarUrl!.trim().isEmpty) {
      try {
        final listAsync = ref.read(chatListProvider);
        if (listAsync.hasValue) {
          final listItems = listAsync.value!;
          final listItem = listItems.firstWhere(
            (item) => item.conversationId == _conversationId,
            orElse: () => throw Exception('Not found'),
          );

          if (listItem.avatarUrl != null && listItem.avatarUrl!.trim().isNotEmpty) {
            return conversation.copyWith(avatarUrl: listItem.avatarUrl);
          }
        }
      } catch (e) {

      }
    }

    final visibleMessages = finalConversation.getVisibleMessages(accountId);

    return finalConversation.copyWith(messages: visibleMessages);
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

      final messageFromServer = await _repo.sendMessage(
        conversationId: _conversationId,
        accountId: accountId,
        body: body,
        image: image,
        replyToMessageId: replyToMessageId,
      );

      final current = state.value;
      if (current != null) {
        MessageModel finalMessage = messageFromServer;

        if (finalMessage.replyToMessageId != null && finalMessage.replyTo == null) {
          try {
            final originalMessage = current.messages.firstWhere(
                  (m) => m.messageId == finalMessage.replyToMessageId,
            );
            finalMessage = finalMessage.copyWith(replyTo: originalMessage);
          } catch (e) {

          }
        }

        final index = current.messages.indexWhere((m) => m.messageId == finalMessage.messageId);

        List<MessageModel> updatedMessages;

        if (index != -1) {

          final existingMessage = current.messages[index];

          if (existingMessage.status == 'Seen') {
            finalMessage = finalMessage.copyWith(status: 'Seen');
          } else if (existingMessage.status == 'Delivered' && finalMessage.status == 'Sent') {
            finalMessage = finalMessage.copyWith(status: 'Delivered');
          }

          updatedMessages = [...current.messages];
          updatedMessages[index] = finalMessage;
          print("API: Đã cập nhật message (giữ status: ${finalMessage.status})");
        } else {
          // Nếu chưa có thì thêm mới
          updatedMessages = [...current.messages, finalMessage];
          updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        }

        state = AsyncValue.data(
          current.copyWith(messages: updatedMessages),
        );
      } else {
        await refresh();
      }

      return true;
    } catch (e, st) {
      print('Error sending message: $e');
      return false;
    }
  }

  Future<void> markAsRead({bool skipRefresh = false}) async {
    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) return;
    _accountId = accountId;
    try {
      await _repo.markConversationRead(
        conversationId: _conversationId,
        viewerAccountId: accountId,
      );
      if (!skipRefresh) {
        await refresh();
      }
    } catch (e) {
      print("Lỗi markAsRead: $e");
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
        final visibleIncomingMessages = conversation.getVisibleMessages(accountId);
        final existingIds = current.messages.map((m) => m.messageId).toSet();
        final newMessages = visibleIncomingMessages
            .where((m) => !existingIds.contains(m.messageId))
            .toList();
        final mergedMessages = [...current.messages, ...newMessages];
        mergedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        state = AsyncValue.data(
          current.copyWith(messages: mergedMessages),
        );
      }
    } catch (e) {
    }
  }


  void addMessage(MessageModel message) {
    final current = state.value;
    if (current != null && message.conversationId.toLowerCase() == _conversationId.toLowerCase()) {
      final index = current.messages.indexWhere((m) => m.messageId == message.messageId);
      if (index != -1) return;
      MessageModel finalMessage = message;
      if (finalMessage.replyToMessageId != null && finalMessage.replyTo == null) {
        try {
          final originalMessage = current.messages.firstWhere(
                (m) => m.messageId == finalMessage.replyToMessageId,
          );
          finalMessage = finalMessage.copyWith(replyTo: originalMessage);
        } catch (e) {
        }
      }

      DateTime? updatedClearA = current.clearBeforeAtByA;
      DateTime? updatedClearB = current.clearBeforeAtByB;
      bool needUpdateClearTime = false;

      if (_accountId != null) {
        if (_accountId == current.participantA.accountId) {

          if (updatedClearA != null && !finalMessage.createdAt.isAfter(updatedClearA)) {
            updatedClearA = finalMessage.createdAt.subtract(const Duration(milliseconds: 1));
            needUpdateClearTime = true;
          }
        } else if (_accountId == current.participantB.accountId) {

          if (updatedClearB != null && !finalMessage.createdAt.isAfter(updatedClearB)) {
            updatedClearB = finalMessage.createdAt.subtract(const Duration(milliseconds: 1));
            needUpdateClearTime = true;
          }
        }
      }

      final newMessages = [...current.messages, finalMessage];
      newMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      state = AsyncValue.data(
        current.copyWith(
          messages: newMessages,
          clearBeforeAtByA: needUpdateClearTime ? updatedClearA : current.clearBeforeAtByA,
          clearBeforeAtByB: needUpdateClearTime ? updatedClearB : current.clearBeforeAtByB,
        ),
      );
    }
  }

  void updateMessageStatus(String messageId, String newStatus) {
    final current = state.value;
    if (current != null) {
      final updatedMessages = current.messages.map((m) {
        if (m.messageId == messageId) {
          return MessageModel(
            messageId: m.messageId,
            conversationId: m.conversationId,
            senderAccountId: m.senderAccountId,
            body: m.body,
            messageType: m.messageType,
            replyToMessageId: m.replyToMessageId,
            imageUrl: m.imageUrl,
            metadata: m.metadata,
            createdAt: m.createdAt,
            editedAt: m.editedAt,
            deletedAt: m.deletedAt,
            sender: m.sender,
            replyTo: m.replyTo,
            isMine: m.isMine,
            status: newStatus,
          );
        }
        return m;
      }).toList();
      state = AsyncValue.data(
        current.copyWith(messages: updatedMessages),
      );
    }
  }

  // void markMessagesAsSeenUntil(DateTime lastReadAt) {
  //   final current = state.value;
  //   if (current != null) {
  //     final cutoffTime = lastReadAt.add(const Duration(seconds: 1));
  //     final updatedMessages = current.messages.map((m) {
  //       if (m.isMine && m.status != 'Seen') {
  //         if (m.createdAt.isBefore(cutoffTime) || m.createdAt.isAtSameMomentAs(cutoffTime)) {
  //           return m.copyWith(status: 'Seen');
  //         }
  //       }
  //       return m;
  //     }).toList();
  //     if (current.messages != updatedMessages) {
  //       state = AsyncValue.data(current.copyWith(messages: updatedMessages));
  //     }
  //   }
  // }

  void markMessagesAsSeenUntil(DateTime lastReadAt, {String? lastReadMessageId}) {
    final current = state.value;
    if (current != null) {
      final cutoffTime = lastReadAt.add(const Duration(seconds: 1));
      final updatedMessages = current.messages.map((m) {
        if (m.isMine && m.status != 'Seen') {
          if (m.messageId == lastReadMessageId ||
              m.createdAt.isBefore(cutoffTime) ||
              m.createdAt.isAtSameMomentAs(cutoffTime)) {
            return m.copyWith(status: 'Seen');
          }
        }
        return m;
      }).toList();

      state = AsyncValue.data(current.copyWith(messages: updatedMessages));
    }
  }

  Stream<MessageModel> listenToMessages() {
    final signalRService = ref.read(signalRChatServiceProvider);
    return signalRService.listenToMessages(_conversationId);
  }

  Future<bool> deleteConversation() async {
    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) return false;

    _accountId = accountId;
    try {
      try {
        await _repo.deleteAllMyMessages(
          conversationId: _conversationId,
          accountId: accountId,
        );
      } catch (e) {
        final current = state.value;
        if (current != null) {
          for (final message in current.messages) {
            if (message.isMine && message.senderAccountId == accountId) {
              try {
                await _repo.deleteMessage(messageId: message.messageId, accountId: accountId);
              } catch (e) { }
            }
          }
        }
      }

      await _repo.clearConversation(
        conversationId: _conversationId,
        accountId: accountId,
        hide: true,
      );
      ref.invalidate(unreadTotalProvider);

      final current = state.value;
      if (current != null) {
        DateTime safeClearTime;
        if (current.messages.isNotEmpty) {
          final sortedMsgs = [...current.messages];
          sortedMsgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          safeClearTime = sortedMsgs.last.createdAt.add(const Duration(milliseconds: 1));
        } else {
          safeClearTime = DateTime.now().toUtc();
        }
        DateTime? newClearA = current.clearBeforeAtByA;
        DateTime? newClearB = current.clearBeforeAtByB;

        if (accountId == current.participantA.accountId) {
          newClearA = safeClearTime;
        } else if (accountId == current.participantB.accountId) {
          newClearB = safeClearTime;
        }

        state = AsyncValue.data(
          current.copyWith(
            messages: [],
            clearBeforeAtByA: newClearA,
            clearBeforeAtByB: newClearB,
          ),
        );
      }

      return true;
    } catch (e) {
      print('Error deleting conversation: $e');
      return false;
    }
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
    DateTime? clearBeforeAtByA,
    DateTime? clearBeforeAtByB,
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
      clearBeforeAtByA: clearBeforeAtByA ?? this.clearBeforeAtByA,
      clearBeforeAtByB: clearBeforeAtByB ?? this.clearBeforeAtByB,
    );
  }
}

