class MessageAccountModel {
  final String accountId;
  final String accountName;
  final String email;
  final String role;
  final String? avatarUrl;
  final bool? isDeleted;

  MessageAccountModel({
    required this.accountId,
    required this.accountName,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.isDeleted,
  });

  factory MessageAccountModel.fromJson(Map<String, dynamic> json) {
    return MessageAccountModel(
      accountId: json['accountId']?.toString() ?? json['AccountId']?.toString() ?? '',
      accountName: json['accountName'] ?? json['AccountName'] ?? '',
      email: json['email'] ?? json['Email'] ?? '',
      role: json['role'] ?? json['Role'] ?? '',
      avatarUrl: json['avatarUrl'] ?? json['AvatarUrl'],
      isDeleted: json['isDeleted'] ?? json['IsDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'accountName': accountName,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'isDeleted': isDeleted,
    };
  }
}

class MessageModel {
  final String messageId;
  final String conversationId;
  final String senderAccountId;
  final String? body;
  final String messageType;
  final String? replyToMessageId;
  final String? imageUrl;
  final String? metadata;
  final DateTime createdAt;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final MessageAccountModel sender;
  final MessageModel? replyTo;
  final bool isMine;
  final String status; // Pending, Sent, Delivered, Seen

  MessageModel({
    required this.messageId,
    required this.conversationId,
    required this.senderAccountId,
    this.body,
    this.messageType = 'Text',
    this.replyToMessageId,
    this.imageUrl,
    this.metadata,
    required this.createdAt,
    this.editedAt,
    this.deletedAt,
    required this.sender,
    this.replyTo,
    required this.isMine,
    this.status = 'Sent',
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['messageId']?.toString() ?? json['MessageId']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? json['ConversationId']?.toString() ?? '',
      senderAccountId: json['senderAccountId']?.toString() ?? json['SenderAccountId']?.toString() ?? '',
      body: json['body'] ?? json['Body'],
      messageType: json['messageType'] ?? json['MessageType'] ?? 'Text',
      replyToMessageId: json['replyToMessageId']?.toString() ?? json['ReplyToMessageId']?.toString(),
      imageUrl: json['imageUrl'] ?? json['ImageUrl'],
      metadata: json['metadata'] ?? json['Metadata'],
      createdAt: json['createdAt'] != null
          ? _parseDateTime(json['createdAt'].toString())
          : DateTime.now().toUtc(),
      editedAt: json['editedAt'] != null
          ? _parseDateTime(json['editedAt'].toString())
          : null,
      deletedAt: json['deletedAt'] != null
          ? _parseDateTime(json['deletedAt'].toString())
          : null,
      sender: MessageAccountModel.fromJson(
        json['sender'] ?? json['Sender'] ?? {},
      ),
      replyTo: json['replyTo'] != null || json['ReplyTo'] != null
          ? MessageModel.fromJson(json['replyTo'] ?? json['ReplyTo'])
          : null,
      isMine: json['isMine'] ?? json['IsMine'] ?? false,
      status: json['status'] ?? json['Status'] ?? 'Sent',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'senderAccountId': senderAccountId,
      'body': body,
      'messageType': messageType,
      'replyToMessageId': replyToMessageId,
      'imageUrl': imageUrl,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'sender': sender.toJson(),
      'replyTo': replyTo?.toJson(),
      'isMine': isMine,
      'status': status,
    };
  }

  // Helper method để parse DateTime và convert sang giờ Việt Nam (UTC+7) để lưu vào model
  static DateTime _parseDateTime(String dateTimeString) {
    try {
      // Parse DateTime từ string
      DateTime parsed = DateTime.parse(dateTimeString);
      
      // Backend trả về UTC time (thường có 'Z' ở cuối hoặc không có timezone)
      // Convert sang UTC nếu chưa phải UTC
      if (!parsed.isUtc) {
        // Kiểm tra xem string có chứa timezone info không
        final hasTimezone = dateTimeString.contains('+') || 
                           dateTimeString.contains('-') || 
                           dateTimeString.endsWith('Z') ||
                           (dateTimeString.contains('T') && (dateTimeString.contains('+') || dateTimeString.contains('Z')));
        
        if (!hasTimezone) {
          // Không có timezone info, giả sử là UTC và tạo UTC DateTime
          parsed = DateTime.utc(
            parsed.year,
            parsed.month,
            parsed.day,
            parsed.hour,
            parsed.minute,
            parsed.second,
            parsed.millisecond,
            parsed.microsecond,
          );
        } else {
          // Có timezone info, convert sang UTC
          parsed = parsed.toUtc();
        }
      }
      
      // Convert UTC sang giờ Việt Nam (UTC+7) để lưu vào model
      final vietnamTime = parsed.add(const Duration(hours: 7));
      return vietnamTime;
    } catch (e) {
      // Nếu parse lỗi, trả về thời gian hiện tại ở giờ Việt Nam
      print('Error parsing DateTime: $dateTimeString, error: $e');
      return DateTime.now().toUtc().add(const Duration(hours: 7));
    }
  }
}

