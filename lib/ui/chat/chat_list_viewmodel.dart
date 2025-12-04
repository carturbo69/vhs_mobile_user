import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/chat/conversation_model.dart';
import 'package:vhs_mobile_user/data/repositories/chat_repository.dart';
import 'package:vhs_mobile_user/data/services/signalr_chat_service.dart';
import 'package:vhs_mobile_user/helper/jwt_helper.dart';

final chatListProvider =
AsyncNotifierProvider<ChatListNotifier, List<ConversationListItemModel>>(
  ChatListNotifier.new,
);

final unreadTotalProvider = FutureProvider.autoDispose<int>((ref) async {
  return ref.read(chatListProvider.notifier).getUnreadTotal();
});


class ChatListNotifier extends AsyncNotifier<List<ConversationListItemModel>> {
  late ChatRepository _repo;
  String? _accountId;

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
  Future<List<ConversationListItemModel>> build() async {
    _repo = ref.read(chatRepositoryProvider);

    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) {
      return [];
    }

    _accountId = accountId;
    return await _repo.getConversations(accountId);
  }

  Future<void> refresh() async {
    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    _accountId = accountId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getConversations(accountId));
  }

  Future<String?> startConversationWithProvider(String providerId) async {
    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) return null;

    _accountId = accountId;
    try {
      final conversationId = await _repo.startConversationWithProvider(
        myAccountId: accountId,
        providerId: providerId,
      );
      await refresh();
      return conversationId;
    } catch (e) {
      return null;
    }
  }

  Future<String?> startConversationWithAdmin() async {
    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) return null;

    _accountId = accountId;
    try {
      final conversationId = await _repo.startConversationWithAdmin(accountId);
      await refresh();
      return conversationId;
    } catch (e) {
      return null;
    }
  }

  Future<int> getUnreadTotal() async {
    final accountId = await _getAccountId();
    if (accountId == null || accountId.isEmpty) return 0;

    _accountId = accountId;
    try {
      return await _repo.getUnreadTotal(accountId);
    } catch (e) {
      return 0;
    }
  }

  void handleRealtimeUpdate(ConversationListItemModel updatedItem) {
    final currentList = state.value;
    if (currentList != null) {
      final otherItems = currentList.where((item) => item.conversationId != updatedItem.conversationId).toList();

      final newList = [updatedItem, ...otherItems];

      state = AsyncValue.data(newList);
    } else {
      refresh();
    }
  }

  Stream<ConversationListItemModel> listenToConversations() {
    final signalRService = ref.read(signalRChatServiceProvider);
    return signalRService.listenToConversations();
  }
}

