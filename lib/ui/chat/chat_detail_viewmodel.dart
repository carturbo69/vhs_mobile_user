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

    // 1. Lắng nghe tin nhắn mới từ SignalR ngay khi màn hình chat được khởi tạo
    // Lưu ý: dùng ref.read để lấy service, và listen vào stream
    final signalRService = ref.read(signalRChatServiceProvider);

    // Tạo subscription
    final subscription = signalRService.listenToMessages(_conversationId).listen((message) {
      // Khi có tin nhắn tới -> Gọi hàm addMessage để cập nhật UI
      addMessage(message);
    });

    // Quan trọng: Hủy lắng nghe khi màn hình này bị đóng (dispose)
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

    // Nếu conversation không có avatarUrl, lấy từ list item
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

          // Nếu list item có avatarUrl, dùng nó
          if (listItem.avatarUrl != null && listItem.avatarUrl!.trim().isNotEmpty) {
            return conversation.copyWith(avatarUrl: listItem.avatarUrl);
          }
        }
      } catch (e) {
        // Nếu không tìm thấy trong list, giữ nguyên conversation
      }
    }

    // return conversation;
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



  // Future<bool> sendMessage({
  //   String? body,
  //   File? image,
  //   String? replyToMessageId,
  // }) async {
  //   final accountId = await _getAccountId();
  //   if (accountId == null || accountId.isEmpty) return false;
  //
  //   _accountId = accountId;
  //
  //   try {
  //     // Cập nhật UI ngay lập tức với message đang gửi (optimistic update)
  //     final current = state.value;
  //     String? tempMessageId;
  //     if (current != null) {
  //       // Tạo message tạm thời để hiển thị ngay
  //       tempMessageId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
  //       // Nếu có ảnh, dùng file:// để hiển thị ảnh local
  //       final tempImageUrl = image != null ? 'file://${image.path}' : null;
  //       final tempMessage = MessageModel(
  //         messageId: tempMessageId,
  //         conversationId: _conversationId,
  //         senderAccountId: accountId,
  //         body: body,
  //         messageType: image != null ? 'Image' : 'Text',
  //         replyToMessageId: replyToMessageId,
  //         imageUrl: tempImageUrl,
  //         metadata: null,
  //         createdAt: DateTime.now().toUtc(), // Dùng UTC để consistent
  //         editedAt: null,
  //         deletedAt: null,
  //         sender: MessageAccountModel(
  //           accountId: accountId,
  //           accountName: 'Bạn',
  //           avatarUrl: null, email: '', role: '',
  //         ),
  //         replyTo: null,
  //         isMine: true,
  //         status: 'Sending',
  //       );
  //       // Thêm message và sort lại từ cũ đến mới
  //       final updatedMessages = [...current.messages, tempMessage];
  //       updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  //       state = AsyncValue.data(
  //         current.copyWith(messages: updatedMessages),
  //       );
  //     }
  //
  //     // Gửi message thực tế
  //     final message = await _repo.sendMessage(
  //       conversationId: _conversationId,
  //       accountId: accountId,
  //       body: body,
  //       image: image,
  //       replyToMessageId: replyToMessageId,
  //     );
  //
  //     // Cập nhật lại với message thực tế từ server
  //     final updated = state.value;
  //     if (updated != null) {
  //       // Xóa message tạm và thêm message thực tế
  //       final filteredMessages = updated.messages
  //           .where((m) => !m.messageId.startsWith('temp-'))
  //           .toList();
  //       // Thêm message thực tế và sort lại từ cũ đến mới
  //       final finalMessages = [...filteredMessages, message];
  //       finalMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  //       state = AsyncValue.data(
  //         updated.copyWith(messages: finalMessages),
  //       );
  //     } else {
  //       await refresh();
  //     }
  //
  //     return true;
  //   } catch (e, st) {
  //     // Nếu có lỗi, rollback optimistic update
  //     final updated = state.value;
  //     if (updated != null) {
  //       final filteredMessages = updated.messages
  //           .where((m) => !m.messageId.startsWith('temp-'))
  //           .toList();
  //       state = AsyncValue.data(
  //         updated.copyWith(messages: filteredMessages),
  //       );
  //     }
  //     print('Error sending message: $e');
  //     return false;
  //   }
  // }

  // Mở file chat_detail_viewmodel.dart và thay thế hàm sendMessage

  // Future<bool> sendMessage({
  //   String? body,
  //   File? image,
  //   String? replyToMessageId,
  // }) async {
  //   final accountId = await _getAccountId();
  //   if (accountId == null || accountId.isEmpty) return false;
  //   _accountId = accountId;
  //
  //   try {
  //     // 1. Vẫn gọi API như bình thường và hứng kết quả trả về
  //     final messageFromServer = await _repo.sendMessage(
  //       conversationId: _conversationId,
  //       accountId: accountId,
  //       body: body,
  //       image: image,
  //       replyToMessageId: replyToMessageId,
  //     );
  //
  //     // 2. Khi API trả về thành công, cập nhật vào State
  //     final current = state.value;
  //     if (current != null) {
  //       // Kiểm tra xem SignalR đã thêm tin nhắn này chưa (tránh trùng)
  //       final alreadyExists = current.messages.any((m) => m.messageId == messageFromServer.messageId);
  //
  //       if (!alreadyExists) {
  //         MessageModel finalMessage = messageFromServer;
  //
  //         // ✅ LOGIC MỚI: TỰ ĐIỀN DỮ LIỆU `replyTo`
  //         // Nếu tin nhắn trả về là tin nhắn reply nhưng đối tượng `replyTo` lại null...
  //         if (finalMessage.replyToMessageId != null && finalMessage.replyTo == null) {
  //           try {
  //             // ...thì tìm tin nhắn gốc trong danh sách tin nhắn hiện có.
  //             final originalMessage = current.messages.firstWhere(
  //                   (m) => m.messageId == finalMessage.replyToMessageId,
  //             );
  //             // "Vá" lại tin nhắn trả về từ server bằng cách gán đối tượng `replyTo`
  //             finalMessage = finalMessage.copyWith(replyTo: originalMessage);
  //           } catch (e) {
  //             // Không tìm thấy tin nhắn gốc (rất hiếm, có thể đã bị xóa), bỏ qua
  //             print("Original message for reply not found locally.");
  //           }
  //         }
  //         // ✅ KẾT THÚC LOGIC MỚI
  //
  //         final updatedMessages = [...current.messages, finalMessage];
  //         // Sắp xếp lại
  //         updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  //
  //         state = AsyncValue.data(
  //           current.copyWith(messages: updatedMessages),
  //         );
  //       }
  //     } else {
  //       await refresh();
  //     }
  //
  //     return true;
  //   } catch (e, st) {
  //     print('Error sending message: $e');
  //     return false;
  //   }
  // }

// 2. SỬA HÀM sendMessage
  Future<bool> sendMessage({
    String? body,
    File? image,
    String? replyToMessageId,
  }) async {
    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) return false;
    _accountId = accountId;

    try {
      // Gọi API
      final messageFromServer = await _repo.sendMessage(
        conversationId: _conversationId,
        accountId: accountId,
        body: body,
        image: image,
        replyToMessageId: replyToMessageId,
      );

      // Cập nhật State
      final current = state.value;
      if (current != null) {
        MessageModel finalMessage = messageFromServer;

        // 🔥 FIX 1: Tự điền Reply cho API Response (vì API cũng trả về null)
        if (finalMessage.replyToMessageId != null && finalMessage.replyTo == null) {
          try {
            final originalMessage = current.messages.firstWhere(
                  (m) => m.messageId == finalMessage.replyToMessageId,
            );
            finalMessage = finalMessage.copyWith(replyTo: originalMessage);
            print("API: Đã vá replyTo cho tin nhắn ${finalMessage.body}");
          } catch (e) {
            print("Original message for reply not found locally.");
          }
        }

        // 🔥 FIX 2: Xử lý xung đột với SignalR
        // Kiểm tra xem tin nhắn này đã được SignalR thêm vào chưa
        final index = current.messages.indexWhere((m) => m.messageId == finalMessage.messageId);

        List<MessageModel> updatedMessages;

        if (index != -1) {
          // TRƯỜNG HỢP QUAN TRỌNG:
          // Nếu SignalR đã thêm tin nhắn trước đó (thường là thiếu replyTo),
          // Ta phải GHI ĐÈ nó bằng tin nhắn 'finalMessage' (đã được vá replyTo ở trên).
          updatedMessages = [...current.messages];
          updatedMessages[index] = finalMessage;
          print("API: Đã cập nhật lại tin nhắn từ SignalR để hiện Reply");
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
      // Ignore errors
    }
  }


  void addMessage(MessageModel message) {
    final current = state.value;
    // Kiểm tra đúng hội thoại
    if (current != null && message.conversationId.toLowerCase() == _conversationId.toLowerCase()) {

      // 1. Kiểm tra trùng
      final index = current.messages.indexWhere((m) => m.messageId == message.messageId);
      if (index != -1) return;

      // 2. Logic vá lỗi Reply (như cũ)
      MessageModel finalMessage = message;
      if (finalMessage.replyToMessageId != null && finalMessage.replyTo == null) {
        try {
          final originalMessage = current.messages.firstWhere(
                (m) => m.messageId == finalMessage.replyToMessageId,
          );
          finalMessage = finalMessage.copyWith(replyTo: originalMessage);
        } catch (e) {
          // Ignore
        }
      }

      // 🔥 FIX LỖI TIME SKEW (Giờ máy > Giờ server):
      // Nếu tin nhắn mới đến có thời gian "nhỏ hơn" mốc xóa hiện tại -> Cần lùi mốc xóa lại
      // để tin nhắn này không bị ẩn.
      DateTime? updatedClearA = current.clearBeforeAtByA;
      DateTime? updatedClearB = current.clearBeforeAtByB;
      bool needUpdateClearTime = false;

      // Logic kiểm tra xem mình là A hay B để lấy mốc xóa tương ứng
      // (Lưu ý: _accountId phải đảm bảo đã có giá trị)
      if (_accountId != null) {
        if (_accountId == current.participantA.accountId) {
          // Nếu tin mới <= mốc xóa của A -> Lùi mốc xóa về trước tin mới 1 mili giây
          if (updatedClearA != null && !finalMessage.createdAt.isAfter(updatedClearA)) {
            updatedClearA = finalMessage.createdAt.subtract(const Duration(milliseconds: 1));
            needUpdateClearTime = true;
          }
        } else if (_accountId == current.participantB.accountId) {
          // Tương tự cho B
          if (updatedClearB != null && !finalMessage.createdAt.isAfter(updatedClearB)) {
            updatedClearB = finalMessage.createdAt.subtract(const Duration(milliseconds: 1));
            needUpdateClearTime = true;
          }
        }
      }

      // 3. Thêm tin mới vào list
      final newMessages = [...current.messages, finalMessage];
      newMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // 4. Cập nhật State với danh sách mới VÀ mốc xóa đã điều chỉnh (nếu cần)
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


  void markMessagesAsSeenUntil(DateTime lastReadAt) {
    final current = state.value;
    if (current != null) {
      final updatedMessages = current.messages.map((m) {
        if (m.isMine && (m.createdAt.isBefore(lastReadAt) || m.createdAt.isAtSameMomentAs(lastReadAt))) {
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
            status: 'Seen',
          );
        }
        return m;
      }).toList();
      state = AsyncValue.data(current.copyWith(messages: updatedMessages));
    }
  }

  // Setup SignalR listener for real-time messages
  Stream<MessageModel> listenToMessages() {
    final signalRService = ref.read(signalRChatServiceProvider);
    return signalRService.listenToMessages(_conversationId);
  }

//   // Xóa cuộc trò chuyện (xóa tất cả tin nhắn của người dùng trước)
//   Future<bool> deleteConversation() async {
//     final accountId = await _getAccountId();
//     if (accountId == null || accountId.isEmpty) return false;
//
//     _accountId = accountId;
//     try {
//       // Bước 1: Xóa tất cả tin nhắn của người dùng trong conversation
//       try {
//         await _repo.deleteAllMyMessages(
//           conversationId: _conversationId,
//           accountId: accountId,
//         );
//       } catch (e) {
//         // Nếu API xóa tất cả tin nhắn không tồn tại, thử xóa từng tin nhắn
//         print('Warning: Could not delete all messages at once, trying individual deletion: $e');
//         final current = state.value;
//         if (current != null) {
//           // Xóa từng tin nhắn của người dùng
//           for (final message in current.messages) {
//             if (message.isMine && message.senderAccountId == accountId) {
//               try {
//                 await _repo.deleteMessage(
//                   messageId: message.messageId,
//                   accountId: accountId,
//                 );
//               } catch (e) {
//                 print('Warning: Could not delete message ${message.messageId}: $e');
//                 // Tiếp tục xóa các tin nhắn khác
//               }
//             }
//           }
//         }
//       }
//
//       // Bước 2: Xóa/ẩn conversation
//       await _repo.clearConversation(
//         conversationId: _conversationId,
//         accountId: accountId,
//         hide: true, // Xóa hoàn toàn (ẩn khỏi danh sách)
//       );
//       // Refresh unread total when deleting conversation
//       ref.invalidate(unreadTotalProvider);
//
//       final current = state.value;
//       if (current != null) {
//         final now = DateTime.now().toUtc();
//
//         // Xác định mình là A hay B để cập nhật mốc thời gian (Client-side simulation)
//         DateTime? newClearA = current.clearBeforeAtByA;
//         DateTime? newClearB = current.clearBeforeAtByB;
//
//         if (accountId == current.participantA.accountId) {
//           newClearA = now;
//         } else if (accountId == current.participantB.accountId) {
//           newClearB = now;
//         }
//
//         // Cập nhật State: Xóa sạch list messages và set mốc thời gian mới
//         state = AsyncValue.data(
//           current.copyWith(
//             messages: [], // Xóa sạch tin nhắn trên màn hình ngay lập tức
//             clearBeforeAtByA: newClearA,
//             clearBeforeAtByB: newClearB,
//           ),
//         );
//       }
//       // 🔥 KẾT THÚC ĐOẠN THÊM MỚI
//
//       return true;
//     } catch (e) {
//       print('Error deleting conversation: $e');
//       return false;
//     }
//   }
// }
//

// 🔥 SỬA HÀM NÀY: Dùng thời gian tin nhắn cuối cùng làm mốc xóa an toàn
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
        // 🔥 LOGIC MỚI BẮT ĐẦU
        DateTime safeClearTime;

        // Nếu có tin nhắn, lấy thời gian của tin mới nhất + 1ms làm mốc xóa.
        // Điều này đảm bảo mốc xóa luôn nằm SAU tin cuối cùng, nhưng TRƯỚC tin nhắn tương lai.
        if (current.messages.isNotEmpty) {
          final sortedMsgs = [...current.messages];
          sortedMsgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          safeClearTime = sortedMsgs.last.createdAt.add(const Duration(milliseconds: 1));
        } else {
          // Nếu không có tin thì dùng giờ hiện tại (ít rủi ro hơn vì list đang rỗng)
          safeClearTime = DateTime.now().toUtc();
        }
        // 🔥 LOGIC MỚI KẾT THÚC

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

