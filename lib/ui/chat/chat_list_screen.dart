import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/chat/conversation_model.dart';
import 'package:vhs_mobile_user/data/services/signalr_chat_service.dart';
import 'package:vhs_mobile_user/helper/jwt_helper.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/chat/chat_list_viewmodel.dart';
import 'package:vhs_mobile_user/ui/chat/chat_detail_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    _connectSignalR();
  }

  Future<void> _connectSignalR() async {
    try {
      final authDao = ref.read(authDaoProvider);
      final auth = await authDao.getSavedAuth();
      String? accountId = auth?['accountId'] as String?;
      
      if (accountId == null || accountId.isEmpty) {
        final token = await authDao.getToken();
        if (token != null) {
          accountId = JwtHelper.getAccountIdFromToken(token);
        }
      }
      
      if (accountId != null && accountId.isNotEmpty) {
        final signalRService = ref.read(signalRChatServiceProvider);
        if (!signalRService.isConnected) {
          await signalRService.connect(accountId);
        }
        
        // Listen to conversation list updates
        signalRService.listenToConversations().listen((updatedItem) {
          ref.read(chatListProvider.notifier).updateConversationListItem(updatedItem);
        });
      }
    } catch (e) {
      print('Error connecting SignalR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatListAsync = ref.watch(chatListProvider);
    final unreadTotalAsync = ref.watch(
      FutureProvider((ref) => ref.read(chatListProvider.notifier).getUnreadTotal()),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(chatListProvider.notifier).refresh();
            },
          ),
          if (unreadTotalAsync.hasValue && unreadTotalAsync.value! > 0)
            Badge(
              label: Text('${unreadTotalAsync.value}'),
              child: const Icon(Icons.chat),
            ),
        ],
      ),
      body: chatListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(chatListProvider.notifier).refresh(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có tin nhắn nào',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Chat với Admin'),
                    onPressed: () async {
                      final conversationId = await ref
                          .read(chatListProvider.notifier)
                          .startConversationWithAdmin();
                      if (conversationId != null && context.mounted) {
                        context.push(Routes.chatDetailPath(conversationId));
                      }
                    },
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(chatListProvider.notifier).refresh();
            },
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return _ConversationListItem(
                  conversation: conversation,
                  onTap: () {
                    context.push(Routes.chatDetailPath(conversation.conversationId));
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final conversationId = await ref
              .read(chatListProvider.notifier)
              .startConversationWithAdmin();
          if (conversationId != null && context.mounted) {
            context.push(Routes.chatDetailPath(conversationId));
          }
        },
        child: const Icon(Icons.chat),
        tooltip: 'Chat với Admin',
      ),
    );
  }
}

class _ConversationListItem extends StatelessWidget {
  final ConversationListItemModel conversation;
  final VoidCallback onTap;

  const _ConversationListItem({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseUrl = 'http://apivhs.cuahangkinhdoanh.com';
    final avatarUrl = conversation.avatarUrl != null &&
            !conversation.avatarUrl!.startsWith('http')
        ? '$baseUrl${conversation.avatarUrl}'
        : conversation.avatarUrl;

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: avatarUrl != null
                ? CachedNetworkImageProvider(avatarUrl)
                : null,
            child: avatarUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          if (conversation.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        conversation.title,
        style: TextStyle(
          fontWeight: conversation.unreadCount > 0
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        conversation.lastMessageSnippet ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (conversation.lastMessageAt != null)
            Text(
              _formatTime(conversation.lastMessageAt!),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          if (conversation.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime time) {
    // Convert UTC sang timezone Việt Nam (UTC+7)
    DateTime vietnamTime;
    if (time.isUtc) {
      // Nếu là UTC, thêm 7 giờ để có giờ Việt Nam
      vietnamTime = time.add(const Duration(hours: 7));
    } else {
      // Nếu không phải UTC, giả sử nó đã là UTC và convert
      final utcTime = time.toUtc();
      vietnamTime = utcTime.add(const Duration(hours: 7));
    }
    
    // Lấy thời gian hiện tại ở VN (UTC+7)
    final nowUtc = DateTime.now().toUtc();
    final nowVietnam = nowUtc.add(const Duration(hours: 7));
    final difference = nowVietnam.difference(vietnamTime);

    if (difference.inDays == 0) {
      // Hôm nay: chỉ hiển thị giờ:phút
      return '${vietnamTime.hour.toString().padLeft(2, '0')}:${vietnamTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${vietnamTime.day}/${vietnamTime.month}/${vietnamTime.year}';
    }
  }
}

