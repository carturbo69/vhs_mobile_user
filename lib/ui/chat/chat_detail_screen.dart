import 'dart:io';
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

// Màu xanh theo web - Sky blue palette
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
    super.dispose();
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
        
        // Listen to new messages
        signalRService.listenToMessages(widget.conversationId).listen((message) {
          final notifier = ref.read(chatDetailProvider(widget.conversationId).notifier);
          notifier.addMessage(message);
          // Refresh unread total if message is from other user
          if (!message.isMine) {
            ref.invalidate(unreadTotalProvider);
          }
          // Scroll đến cuối khi có tin nhắn mới
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        });
      }
    } catch (e) {
      print('Error connecting SignalR: $e');
    }
  }

  void _scrollToBottom() {
    // Delay một chút để đảm bảo ListView đã render xong
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        // Khi reverse: false, scroll đến maxScrollExtent (cuối list) để hiển thị tin nhắn mới nhất
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          _scrollController.animateTo(
            maxScroll,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          // Nếu maxScrollExtent = 0, có thể ListView chưa render xong, thử lại sau
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

    // Clear text field ngay lập tức (optimistic)
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
      // Refresh ngầm conversation và chat list để cập nhật tin nhắn mới
      await notifier.silentRefresh();
      ref.read(chatListProvider.notifier).silentRefresh();
      _scrollToBottom();
    } else {
      // Nếu gửi thất bại, khôi phục lại text
      if (messageText.isNotEmpty) {
        _messageController.text = messageText;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gửi tin nhắn thất bại'),
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
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Hủy'),
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
          // Refresh ngầm conversation và chat list để cập nhật tin nhắn mới
          await notifier.silentRefresh();
          ref.read(chatListProvider.notifier).silentRefresh();
          _scrollToBottom();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gửi ảnh thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Nếu không có route để pop, quay về chat list hoặc trang chủ
              context.go(Routes.chatList);
            }
          },
        ),
        title: conversationAsync.when(
          data: (conversation) => _AppBarTitleWidget(conversation: conversation),
          loading: () => const Text(
            'Đang tải...',
            style: TextStyle(color: Colors.white),
          ),
          error: (_, __) => const Text(
            'Chat',
            style: TextStyle(color: Colors.white),
          ),
        ),
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
                ref.read(chatDetailProvider(widget.conversationId).notifier).refresh();
              },
              tooltip: 'Làm mới',
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
            onSelected: (value) async {
              if (value == 'delete') {
                // Hiển thị dialog xác nhận xóa
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xóa cuộc trò chuyện'),
                    content: const Text('Bạn có chắc chắn muốn xóa cuộc trò chuyện này?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  // Xóa conversation
                  final notifier = ref.read(chatDetailProvider(widget.conversationId).notifier);
                  final success = await notifier.deleteConversation();

                  if (mounted) {
                    if (success) {
                      // Refresh chat list để cập nhật danh sách
                      ref.read(chatListProvider.notifier).refresh();
                      // Quay về chat list
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(Routes.chatList);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không thể xóa cuộc trò chuyện'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Xóa cuộc trò chuyện'),
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
              Text('Lỗi: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(chatDetailProvider(widget.conversationId).notifier).refresh();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (conversation) {
          // Scroll đến cuối khi conversation được load hoặc update
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
          return Column(
            children: [
              if (_replyToMessage != null)
                _ReplyToBanner(
                  message: _replyToMessage!,
                  onCancel: () => setState(() => _replyToMessage = null),
                ),
              Expanded(
                child: _MessageList(
                  conversation: conversation,
                  scrollController: _scrollController,
                  onReply: (message) => setState(() => _replyToMessage = message),
                ),
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

class _ReplyToBanner extends StatelessWidget {
  final MessageModel message;
  final VoidCallback onCancel;

  const _ReplyToBanner({
    required this.message,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
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
                  'Trả lời ${message.sender.accountName}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.body ?? '[Ảnh]',
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

class _MessageList extends StatelessWidget {
  final ConversationModel conversation;
  final ScrollController scrollController;
  final Function(MessageModel) onReply;

  const _MessageList({
    required this.conversation,
    required this.scrollController,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
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
              'Chưa có tin nhắn nào',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bắt đầu cuộc trò chuyện',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Sắp xếp messages từ cũ đến mới (oldest first) - mới nhất sẽ ở cuối list
    // KHÔNG dùng reverse để mới nhất hiển thị ở dưới cùng
    final sortedMessages = List<MessageModel>.from(conversation.messages);
    // Sort từ cũ đến mới (oldest first) - mới nhất sẽ ở cuối list
    sortedMessages.sort((a, b) {
      // So sánh theo millisecondSinceEpoch để đảm bảo chính xác
      return a.createdAt.millisecondsSinceEpoch.compareTo(b.createdAt.millisecondsSinceEpoch);
    });
    
    return ListView.builder(
      controller: scrollController,
      reverse: false, // KHÔNG reverse - mới nhất (ở cuối list) sẽ tự động ở dưới cùng
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

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final VoidCallback onReply;

  const _MessageBubble({
    required this.message,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMine;
    final baseUrl = 'http://apivhs.cuahangkinhdoanh.com';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
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
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.shade300,
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
                      message.replyTo!.body ?? '[Ảnh]',
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
            GestureDetector(
              onLongPress: onReply,
              child: Container(
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
                                  // Xử lý URL
                                  String imageUrl;
                                  if (message.imageUrl!.startsWith('http')) {
                                    imageUrl = message.imageUrl!;
                                  } else {
                                    // Đảm bảo có dấu / ở đầu nếu chưa có
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
                                            'Không thể tải ảnh',
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
                          _formatTime(message.createdAt),
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
              ),
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

  String _formatTime(DateTime time) {
    // Convert từ UTC sang giờ Việt Nam (UTC+7) - giống logic FE
    // Đảm bảo time là UTC trước khi convert
    final utcTime = time.isUtc ? time : time.toUtc();
    final vietnamTime = utcTime.add(const Duration(hours: 7));
    
    // Lấy thời gian hiện tại ở giờ Việt Nam để so sánh
    final nowUtc = DateTime.now().toUtc();
    final nowVietnam = nowUtc.add(const Duration(hours: 7));
    
    // So sánh ngày tháng (chỉ lấy phần date, bỏ qua time)
    final timeDate = DateTime(vietnamTime.year, vietnamTime.month, vietnamTime.day);
    final nowDate = DateTime(nowVietnam.year, nowVietnam.month, nowVietnam.day);
    final daysDiff = nowDate.difference(timeDate).inDays;

    // Cùng ngày: chỉ hiển thị giờ:phút
    if (daysDiff == 0) {
      return '${vietnamTime.hour.toString().padLeft(2, '0')}:${vietnamTime.minute.toString().padLeft(2, '0')}';
    }

      // Hôm qua
    if (daysDiff == 1) {
      return 'Hôm qua ${vietnamTime.hour.toString().padLeft(2, '0')}:${vietnamTime.minute.toString().padLeft(2, '0')}';
    }
    
    // Trong 7 ngày: hiển thị thứ và giờ (giống FE: Thứ 2-7, CN)
    if (daysDiff < 7) {
      final dayOfWeek = vietnamTime.weekday; // 1=Monday, 7=Sunday
      final weekdays = ['', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
      return '${weekdays[dayOfWeek]} ${vietnamTime.hour.toString().padLeft(2, '0')}:${vietnamTime.minute.toString().padLeft(2, '0')}';
    }
    
    // Trong cùng năm: hiển thị ngày/tháng và giờ
    if (vietnamTime.year == nowVietnam.year) {
      return '${vietnamTime.day.toString().padLeft(2, '0')}/${vietnamTime.month.toString().padLeft(2, '0')} ${vietnamTime.hour.toString().padLeft(2, '0')}:${vietnamTime.minute.toString().padLeft(2, '0')}';
    }
    
    // Khác năm: hiển thị đầy đủ
    return '${vietnamTime.day.toString().padLeft(2, '0')}/${vietnamTime.month.toString().padLeft(2, '0')}/${vietnamTime.year} ${vietnamTime.hour.toString().padLeft(2, '0')}:${vietnamTime.minute.toString().padLeft(2, '0')}';
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
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
                tooltip: 'Gửi ảnh',
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
                    hintText: 'Nhập tin nhắn...',
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
                tooltip: 'Gửi',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget riêng để hiển thị AppBar title với thông tin người đối diện
class _AppBarTitleWidget extends ConsumerWidget {
  final ConversationModel conversation;

  const _AppBarTitleWidget({required this.conversation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String?>(
      future: _getCurrentAccountId(ref),
      builder: (context, snapshot) {
        // Xác định người đối diện (không phải current user)
        MessageAccountModel otherParticipant;
        final currentAccountId = snapshot.data;
        
        if (currentAccountId != null && 
            conversation.participantA.accountId == currentAccountId) {
          // Nếu current user là participantA, thì người đối diện là participantB
          otherParticipant = conversation.participantB;
        } else if (currentAccountId != null && 
                   conversation.participantB.accountId == currentAccountId) {
          // Nếu current user là participantB, thì người đối diện là participantA
          otherParticipant = conversation.participantA;
        } else {
          // Fallback: dùng participantB nếu không xác định được
          otherParticipant = conversation.participantB;
        }
        
        final baseUrl = 'http://apivhs.cuahangkinhdoanh.com';
        String? avatarUrl;
        
        // Ưu tiên dùng avatarUrl từ conversation (giống như trong list)
        // Nếu không có thì mới dùng từ participant
        String? rawAvatarUrl = conversation.avatarUrl;
        if (rawAvatarUrl == null || rawAvatarUrl.trim().isEmpty) {
          rawAvatarUrl = otherParticipant.avatarUrl;
        }
        
        // Xử lý avatarUrl giống như trong chat_list_screen
        if (rawAvatarUrl != null && rawAvatarUrl.trim().isNotEmpty) {
          final trimmed = rawAvatarUrl.trim();
          // Nếu đã là absolute URL (backend đã xử lý), dùng trực tiếp
          if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
            avatarUrl = trimmed;
          } else {
            // Nếu là relative path, thêm base URL
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
                    const Text(
                      'Đang hoạt động',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
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
    
    // Nếu accountId từ database rỗng, thử lấy từ JWT token
    if (accountId == null || accountId.isEmpty) {
      final token = await authDao.getToken();
      if (token != null) {
        accountId = JwtHelper.getAccountIdFromToken(token);
      }
    }
    
    return accountId;
  }
}

