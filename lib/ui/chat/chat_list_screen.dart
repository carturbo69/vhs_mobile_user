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
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';

const Color primaryBlue = Color(0xFF0284C7); // Sky-600

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
        await signalRService.connect(accountId);
        signalRService.listenToConversations().listen((updatedItem) {
          if (!mounted) return;
          ref.read(chatListProvider.notifier).handleRealtimeUpdate(updatedItem);
          ref.refresh(unreadTotalProvider);
        });
      }
    } catch (e) {
      print('Error connecting SignalR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatListAsync = ref.watch(chatListProvider);
    final unreadTotalAsync = ref.watch(unreadTotalProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        title: const Text(
          'Tin nhắn',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(chatListProvider.notifier).refresh();
                // Refresh unread total when manually refreshing
                ref.invalidate(unreadTotalProvider);
              },
              tooltip: 'Làm mới',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatListAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              ThemeHelper.getPrimaryColor(context),
            ),
          ),
        ),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lỗi: $e',
                style: TextStyle(color: ThemeHelper.getTextColor(context)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                      onPressed: () {
                        ref.read(chatListProvider.notifier).refresh();
                        ref.invalidate(unreadTotalProvider);
                      },
                child: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeHelper.getPrimaryColor(context),
                ),
              ),
            ],
          ),
        ),
        data: (conversations) {
          final isDark = ThemeHelper.isDarkMode(context);
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: ThemeHelper.getLightBlueBackgroundColor(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: ThemeHelper.getPrimaryColor(context),
                          ),
                        ),
                        const SizedBox(height: 24),
                  Text(
                    'Chưa có tin nhắn nào',
                          style: TextStyle(
                            color: ThemeHelper.getSecondaryTextColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                  ),
                  const SizedBox(height: 8),
                        Text(
                          'Bắt đầu trò chuyện với chúng tôi',
                          style: TextStyle(
                            color: ThemeHelper.getTertiaryTextColor(context),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Chat với Admin'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeHelper.getPrimaryColor(context),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
                    ref.invalidate(unreadTotalProvider);
            },
                  child: ListView.builder(
              itemCount: conversations.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
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
          ),
        ],
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
    String? avatarUrl;
    final rawAvatarUrl = conversation.avatarUrl;
    if (rawAvatarUrl != null && rawAvatarUrl.trim().isNotEmpty) {
      final trimmed = rawAvatarUrl.trim();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        avatarUrl = trimmed;
      } else {
        final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
        avatarUrl = '$baseUrl$path';
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ThemeHelper.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeHelper.getBorderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(ThemeHelper.isDarkMode(context) ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ThemeHelper.getBorderColor(context),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeHelper.getShadowColor(context),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: avatarUrl != null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: avatarUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: ThemeHelper.getLightBackgroundColor(context),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ThemeHelper.getPrimaryColor(context),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: ThemeHelper.getLightBackgroundColor(context),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: ThemeHelper.getSecondaryIconColor(context),
                                size: 28,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: ThemeHelper.getLightBackgroundColor(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            color: ThemeHelper.getSecondaryIconColor(context),
                            size: 28,
                          ),
                        ),
                ),
                if (conversation.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ThemeHelper.getCardBackgroundColor(context),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: ThemeHelper.getTextColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessageAt != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(conversation.lastMessageAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeHelper.getTertiaryTextColor(context),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessageSnippet ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeHelper.getSecondaryTextColor(context),
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (conversation.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeHelper.getPrimaryColor(context),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {

    final vnTime = time.toUtc().add(const Duration(hours: 7));
    final nowVn = DateTime.now().toUtc().add(const Duration(hours: 7));

    if (vnTime.year == nowVn.year && vnTime.month == nowVn.month && vnTime.day == nowVn.day) {
      return '${vnTime.hour.toString().padLeft(2, '0')}:${vnTime.minute.toString().padLeft(2, '0')}';
    }

    final yesterdayVn = nowVn.subtract(const Duration(days: 1));
    if (vnTime.year == yesterdayVn.year && vnTime.month == yesterdayVn.month && vnTime.day == yesterdayVn.day) {
      return 'Hôm qua';
    }

    final diff = nowVn.difference(vnTime);
    if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    }
    return '${vnTime.day}/${vnTime.month}/${vnTime.year}';

  }
}

