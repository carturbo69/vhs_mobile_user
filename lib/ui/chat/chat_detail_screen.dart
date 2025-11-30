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
          loading: () => const Text('Đang tải...'),
          error: (_, __) => const Text('Chat'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(chatDetailProvider(widget.conversationId).notifier).refresh();
            },
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
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Trả lời ${message.sender.accountName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  message.body ?? '[Ảnh]',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: onCancel,
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
      return const Center(
        child: Text('Chưa có tin nhắn nào'),
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
                  bottom: 4,
                  left: isMe ? 0 : 8,
                  right: isMe ? 8 : 0,
                ),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.replyTo!.sender.accountName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message.replyTo!.body ?? '[Ảnh]',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            GestureDetector(
              onLongPress: onReply,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
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
    // Convert UTC sang timezone Việt Nam (UTC+7)
    // Đảm bảo time là UTC trước khi convert
    DateTime utcTime;
    if (time.isUtc) {
      utcTime = time;
    } else {
      // Nếu không phải UTC, convert sang UTC
      // Sử dụng toUtc() để đảm bảo convert đúng
      utcTime = time.toUtc();
    }
    
    // Debug: In ra để kiểm tra
    print('FormatTime - Input: $time (isUtc: ${time.isUtc}), UTC: $utcTime');
    
    // Thêm 7 giờ để có giờ Việt Nam
    final vietnamTime = utcTime.add(const Duration(hours: 7));
    
    print('FormatTime - Vietnam time: $vietnamTime (hour: ${vietnamTime.hour}, minute: ${vietnamTime.minute})');
    
    // Lấy thời gian hiện tại ở VN (UTC+7)
    final nowUtc = DateTime.now().toUtc();
    final nowVietnam = nowUtc.add(const Duration(hours: 7));
    final difference = nowVietnam.difference(vietnamTime);

    // Nếu thời gian trong tương lai (do timezone conversion sai), chỉ hiển thị giờ:phút
    if (difference.isNegative) {
      return '${vietnamTime.hour.toString().padLeft(2, '0')}:${vietnamTime.minute.toString().padLeft(2, '0')}';
    }

    if (difference.inDays == 0) {
      // Hôm nay: chỉ hiển thị giờ:phút
      return '${vietnamTime.hour.toString().padLeft(2, '0')}:${vietnamTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Hôm qua
      return 'Hôm qua ${vietnamTime.hour.toString().padLeft(2, '0')}:${vietnamTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      // Trong tuần: hiển thị thứ
      final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
      return '${weekdays[vietnamTime.weekday % 7]} ${vietnamTime.hour.toString().padLeft(2, '0')}:${vietnamTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Quá 1 tuần: hiển thị ngày/tháng
      return '${vietnamTime.day}/${vietnamTime.month} ${vietnamTime.hour.toString().padLeft(2, '0')}:${vietnamTime.minute.toString().padLeft(2, '0')}';
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: onPickImage,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => onSend(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: onSend,
            color: Colors.blue,
          ),
        ],
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
        
        // Ưu tiên dùng avatarUrl từ conversation (đã được backend xử lý)
        // Nếu không có thì dùng từ participant
        final conversationAvatar = conversation.avatarUrl;
        final participantAvatar = otherParticipant.avatarUrl;
        
        // Chọn avatarUrl từ conversation hoặc participant
        String? rawAvatarUrl = conversationAvatar;
        if (rawAvatarUrl == null || rawAvatarUrl.trim().isEmpty) {
          rawAvatarUrl = participantAvatar;
        }
        
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
            avatarUrl != null && avatarUrl.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: avatarUrl,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        radius: 16,
                        child: Icon(Icons.person, size: 16),
                      ),
                    ),
                  )
                : const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 16),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    otherParticipant.accountName,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (conversation.isOnline)
                    const Text(
                      'Đang hoạt động',
                      style: TextStyle(fontSize: 12, color: Colors.green),
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

