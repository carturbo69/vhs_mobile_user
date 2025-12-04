import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/chat/conversation_model.dart';
import 'package:vhs_mobile_user/data/models/chat/message_model.dart';
import 'package:vhs_mobile_user/data/services/signalr_chat_service.dart';
import 'package:vhs_mobile_user/helper/jwt_helper.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/chat/chat_detail_viewmodel.dart';
import 'package:vhs_mobile_user/ui/chat/chat_list_viewmodel.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/services/translation_cache_provider.dart';
import 'package:vhs_mobile_user/services/notification_service.dart';

const Color primaryBlue = Color(0xFF0284C7); // Sky-600

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  MessageModel? _replyToMessage;

  StreamSubscription? _signalRSubscription;
  StreamSubscription? _statusSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      _connectSignalR();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _signalRSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _connectSignalR() async {
    try {
      final signalRService = ref.read(signalRChatServiceProvider);
      
      // Ensure connection (should already be connected from app startup, but check just in case)
      if (!signalRService.isConnected) {
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
          await signalRService.connect(accountId);
        }
      }

      ref.read(chatDetailProvider(widget.conversationId).notifier).markAsRead(skipRefresh: true);

      // Setup listeners (connection should already be established from app startup)

        _signalRSubscription = signalRService.listenToMessages(widget.conversationId).listen((message) {
          if (!mounted) return;

          print("UI nhận tin nhắn: ${message.body}");

          final notifier = ref.read(chatDetailProvider(widget.conversationId).notifier);

          notifier.addMessage(message);

          // Show system notification if message is not from current user
          if (!message.isMine) {
            // Show notification (non-blocking)
            final notificationService = ref.read(notificationServiceProvider);
            notificationService.showChatMessageNotification(
              senderName: message.sender.accountName,
              messageBody: message.body,
              conversationId: message.conversationId,
              imageUrl: message.imageUrl,
            ).catchError((error) {
              print("❌ Error showing chat notification: $error");
            });

            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                notifier.markAsRead(skipRefresh: true);
              }
            });
          }

          _scrollToBottom();
        });

        _statusSubscription = signalRService.listenToMessageStatus(widget.conversationId).listen((data) {
          if (!mounted) return;
          final notifier = ref.read(chatDetailProvider(widget.conversationId).notifier);

          if (data['eventType'] == 'readUpTo' || data.containsKey('lastReadAt') || data.containsKey('LastReadAt')) {
            final dateStr = (data['lastReadAt'] ?? data['LastReadAt'])?.toString();

            if (dateStr != null) {
              try {
                DateTime date;
                if (dateStr.endsWith('Z') || dateStr.contains('+')) {
                  date = DateTime.parse(dateStr).toUtc();
                } else {
                  date = DateTime.parse(dateStr + 'Z').toUtc();
                }
                print("UI Update: Mark Seen Until $date");
                notifier.markMessagesAsSeenUntil(date);
              } catch(e) {
                print("Date parse error: $e");
              }
            }
          }
          if (data.containsKey('status') || data.containsKey('Status')) {
            final msgId = (data['messageId'] ?? data['MessageId'])?.toString();
            var statusRaw = data['status'] ?? data['Status'];

            String statusStr = 'Sent';
            if (statusRaw is int) {
              if (statusRaw == 2) statusStr = 'Delivered';
              if (statusRaw == 3) statusStr = 'Seen';
            } else {
              statusStr = statusRaw.toString();
            }
            if (msgId != null) {
              notifier.updateMessageStatus(msgId, statusStr);
            }
          }
        });
    } catch (e) {
      print('Error connecting SignalR: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          _scrollController.animateTo(
            maxScroll,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (_scrollController.hasClients) {
              final maxScroll2 = _scrollController.position.maxScrollExtent;
              if (maxScroll2 > 0) {
                _scrollController.jumpTo(maxScroll2);
              }
            }
          });
        }
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _replyToMessage == null) return;

    final messageText = text;
    final replyToId = _replyToMessage?.messageId;
    _messageController.clear();
    setState(() => _replyToMessage = null);

    final notifier = ref.read(chatDetailProvider(widget.conversationId).notifier);
    final success = await notifier.sendMessage(
      body: messageText.isEmpty ? null : messageText,
      replyToMessageId: replyToId,
    );

    if (success) {
      _scrollToBottom();
    } else {
      if (messageText.isNotEmpty) {
        _messageController.text = messageText;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('failed_to_send_message')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(context.tr('take_photo')),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(context.tr('choose_from_gallery')),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: Text(context.tr('cancel')),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final notifier = ref.read(chatDetailProvider(widget.conversationId).notifier);
        final success = await notifier.sendMessage(image: file);

        if (!mounted) return;

        if (success) {
          _scrollToBottom();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('failed_to_send_image')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.tr('error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
    final conversationAsync = ref.watch(chatDetailProvider(widget.conversationId));
    final notifier = ref.read(chatDetailProvider(widget.conversationId).notifier);

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
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.chatList);
            }
          },
        ),
        title: conversationAsync.when(
          data: (conversation) => _AppBarTitleWidget(conversation: conversation),
          loading: () => Text(
            context.tr('loading'),
            style: const TextStyle(color: Colors.white),
          ),
          error: (_, __) => Text(
            context.tr('chat'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
            onSelected: (value) async {
              if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(context.tr('delete_conversation')),
                    content: Text(context.tr('confirm_delete_conversation')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(context.tr('cancel')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Text(context.tr('delete')),
                      ),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  final notifier = ref.read(chatDetailProvider(widget.conversationId).notifier);
                  final success = await notifier.deleteConversation();

                  if (mounted) {
                    if (success) {
                      ref.read(chatListProvider.notifier).refresh();
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(Routes.chatList);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.tr('cannot_delete_conversation')),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(context.tr('delete_conversation')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: conversationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${context.tr('error')}: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(chatDetailProvider(widget.conversationId).notifier).refresh();
                },
                child: Text(context.tr('try_again')),
              ),
            ],
          ),
        ),
        data: (conversation) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
          return Column(
            children: [
              Expanded(
                child: _MessageList(
                  conversation: conversation,
                  scrollController: _scrollController,
                  onReply: (message) => setState(() => _replyToMessage = message),
                ),
              ),
              if (_replyToMessage != null)
                _ReplyToBanner(
                  message: _replyToMessage!,
                  onCancel: () => setState(() => _replyToMessage = null),
                ),
              _MessageInput(
                controller: _messageController,
                onSend: _sendMessage,
                onPickImage: _pickAndSendImage,
              ),
            ],
          );
        },
      ),
    );
  }

}

class _ReplyToBanner extends ConsumerWidget {
  final MessageModel message;
  final VoidCallback onCancel;

  const _ReplyToBanner({
    required this.message,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          left: BorderSide(color: Colors.blue, width: 4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${context.tr('reply_to')} ${message.sender.accountName}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.body ?? '[${context.tr('image_label')}]',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20, color: Colors.grey.shade600),
            onPressed: onCancel,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends ConsumerWidget {
  final ConversationModel conversation;
  final ScrollController scrollController;
  final Function(MessageModel) onReply;

  const _MessageList({
    required this.conversation,
    required this.scrollController,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    if (conversation.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.blue.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.tr('no_messages_yet'),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('start_conversation'),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    final sortedMessages = List<MessageModel>.from(conversation.messages);
    sortedMessages.sort((a, b) {
      return a.createdAt.millisecondsSinceEpoch.compareTo(b.createdAt.millisecondsSinceEpoch);
    });
    return ListView.builder(
      controller: scrollController,
      reverse: false,
      padding: const EdgeInsets.all(16),
      itemCount: sortedMessages.length,
      itemBuilder: (context, index) {
        final message = sortedMessages[index];
        return _MessageBubble(
          message: message,
          onReply: () => onReply(message),
        );
      },
    );
  }
}

class _MessageBubble extends ConsumerWidget {
  final MessageModel message;
  final VoidCallback onReply;

  const _MessageBubble({
    required this.message,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    final isMe = message.isMine;
    final baseUrl = 'http://apivhs.cuahangkinhdoanh.com';

    Widget messageContent = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue.shade600 : Colors.grey.shade100,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isMe ? 20 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: (isMe ? Colors.blue : Colors.grey).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: message.imageUrl!.startsWith('file://')
                  ? Image.file(
                File(message.imageUrl!.replaceFirst('file://', '')),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.error),
                  );
                },
              )
                  : Builder(
                builder: (context) {
                  String imageUrl;
                  if (message.imageUrl!.startsWith('http')) {
                    imageUrl = message.imageUrl!;
                  } else {
                    final path = message.imageUrl!.startsWith('/')
                        ? message.imageUrl!
                        : '/${message.imageUrl!}';
                    imageUrl = '$baseUrl$path';
                  }

                  return CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey.shade300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('cannot_load_image'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (message.body != null) ...[
            if (message.imageUrl != null)
              const SizedBox(height: 8),
            Text(
              message.body!,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(context, message.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: isMe
                      ? Colors.white70
                      : Colors.grey.shade600,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  _getStatusIcon(message.status),
                  size: 12,
                  color: Colors.white70,
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 8),
                child: Text(
                  message.sender.accountName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (message.replyTo != null)
              Container(
                margin: EdgeInsets.only(
                  bottom: 6,
                  left: isMe ? 0 : 8,
                  right: isMe ? 8 : 0,
                ),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.black.withOpacity(0.15)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(
                      color: isMe ? Colors.white70 : Colors.blue,
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.replyTo!.sender.accountName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isMe ? Colors.white : Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message.replyTo!.body ?? '[${context.tr('image_label')}]',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              verticalDirection: VerticalDirection.down,
              children: [
                if (!isMe) Flexible(child: GestureDetector(onLongPress: onReply, child: messageContent)),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.reply,
                      size: 18,
                      color: Colors.grey.shade500,
                    ),
                    onPressed: onReply,
                    tooltip: context.tr('reply'),
                  ),
                ),

                if (isMe) Flexible(child: GestureDetector(onLongPress: onReply, child: messageContent)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Sent':
        return Icons.check;
      case 'Delivered':
        return Icons.done_all;
      case 'Seen':
        return Icons.done_all;
      default:
        return Icons.schedule;
    }
  }

  String _formatTime(BuildContext context, DateTime time) {
    final vietnamTime = time.toUtc().add(const Duration(hours: 7));
    final nowVn = DateTime.now().toUtc().add(const Duration(hours: 7));

    // Check same day
    final sameDay = vietnamTime.year == nowVn.year &&
        vietnamTime.month == nowVn.month &&
        vietnamTime.day == nowVn.day;

    if (sameDay) {
      return '${vietnamTime.hour.toString().padLeft(2, '0')}:${vietnamTime.minute.toString().padLeft(2, '0')}';
    }

    final yesterday = nowVn.subtract(const Duration(days: 1));
    if (vietnamTime.year == yesterday.year &&
        vietnamTime.month == yesterday.month &&
        vietnamTime.day == yesterday.day) {
      return '${context.tr('yesterday')} ${vietnamTime.hour.toString().padLeft(2, '0')}:${vietnamTime.minute.toString().padLeft(2, '0')}';
    }

    final diff = nowVn.difference(vietnamTime);
    if (diff.inDays < 7) {
      final weekdayKeys = [
        'weekday_sun',
        'weekday_mon',
        'weekday_tue',
        'weekday_wed',
        'weekday_thu',
        'weekday_fri',
        'weekday_sat',
      ];
      final weekdayLabel = context.tr(weekdayKeys[vietnamTime.weekday % 7]);
      return '$weekdayLabel ${vietnamTime.hour.toString().padLeft(2, '0')}:${vietnamTime.minute.toString().padLeft(2, '0')}';
    }

    final dateStr = '${vietnamTime.day}/${vietnamTime.month}';
    final timeStr = '${vietnamTime.hour.toString().padLeft(2, '0')}:${vietnamTime.minute.toString().padLeft(2, '0')}';
    return '$timeStr $dateStr';
  }
}

class _MessageInput extends ConsumerWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.image_outlined, color: Colors.grey.shade700),
                onPressed: onPickImage,
                tooltip: context.tr('send_image'),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: context.tr('type_a_message'),
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: onSend,
                tooltip: context.tr('send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarTitleWidget extends ConsumerWidget {
  final ConversationModel conversation;

  const _AppBarTitleWidget({required this.conversation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
    return FutureBuilder<String?>(
      future: _getCurrentAccountId(ref),
      builder: (context, snapshot) {
        MessageAccountModel otherParticipant;
        final currentAccountId = snapshot.data;
        if (currentAccountId != null &&
            conversation.participantA.accountId == currentAccountId) {
          otherParticipant = conversation.participantB;
        } else if (currentAccountId != null &&
            conversation.participantB.accountId == currentAccountId) {
          otherParticipant = conversation.participantA;
        } else {
          otherParticipant = conversation.participantB;
        }

        final baseUrl = 'http://apivhs.cuahangkinhdoanh.com';
        String? avatarUrl;

        String? rawAvatarUrl = conversation.avatarUrl;
        if (rawAvatarUrl == null || rawAvatarUrl.trim().isEmpty) {
          rawAvatarUrl = otherParticipant.avatarUrl;
        }

        if (rawAvatarUrl != null && rawAvatarUrl.trim().isNotEmpty) {
          final trimmed = rawAvatarUrl.trim();

          if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
            avatarUrl = trimmed;
          } else {

            final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
            avatarUrl = '$baseUrl$path';
          }
        }

        return Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: avatarUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              )
                  : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    otherParticipant.accountName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (conversation.isOnline)
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('online'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _getCurrentAccountId(WidgetRef ref) async {
    final authDao = ref.read(authDaoProvider);
    final auth = await authDao.getSavedAuth();
    var accountId = auth?['accountId'] as String?;
    if (accountId == null || accountId.isEmpty) {
      final token = await authDao.getToken();
      if (token != null) {
        accountId = JwtHelper.getAccountIdFromToken(token);
      }
    }
    return accountId;
  }
}
