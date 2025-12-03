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

      // ✅ FIX: Xử lý cả Int và String cho Status
      status: _parseStatus(json['status'] ?? json['Status']),
    );
  }

  // Hàm chuyển đổi status từ Int sang String
  static String _parseStatus(dynamic status) {
    if (status == null) return 'Sent';

    // Nếu backend trả về số (Enum)
    if (status is int) {
      switch (status) {
        case 0: return 'Pending';
        case 1: return 'Sent';
        case 2: return 'Delivered';
        case 3: return 'Seen';
        default: return 'Sent';
      }
    }

    // Nếu backend trả về String
    return status.toString();
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

  // 👇 Dán đoạn này vào trong class MessageModel
  MessageModel copyWith({
    String? messageId,
    String? conversationId,
    String? senderAccountId,
    String? body,
    String? messageType,
    String? replyToMessageId,
    String? imageUrl,
    String? metadata,
    DateTime? createdAt,
    DateTime? editedAt,
    DateTime? deletedAt,
    MessageAccountModel? sender,
    MessageModel? replyTo,
    bool? isMine,
    String? status,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      senderAccountId: senderAccountId ?? this.senderAccountId,
      body: body ?? this.body,
      messageType: messageType ?? this.messageType,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      sender: sender ?? this.sender,
      replyTo: replyTo ?? this.replyTo, // 👈 Đây là chỗ chúng ta cần thay đổi
      isMine: isMine ?? this.isMine,
      status: status ?? this.status,
    );
  }

  // Cập nhật hàm _parseDateTime trong MessageModel
  static DateTime _parseDateTime(String dateTimeString) {
    try {
      final s = dateTimeString.trim();

      // Kiểm tra chuỗi có timezone info (Z hoặc +HH:MM / -HH:MM) ở cuối không
      final tzPattern = RegExp(r'(Z|[+\-]\d{2}:\d{2})$', caseSensitive: false);

      // Parse ban đầu (DateTime.parse sẽ parse timezone nếu có)
      final parsed = DateTime.parse(s);

      if (tzPattern.hasMatch(s)) {
        // Chuỗi có timezone info -> convert về UTC (an toàn)
        return parsed.toUtc();
      } else {
        // Không có timezone -> GIẢ SỬ server gửi UTC -> tạo DateTime UTC từ components
        return DateTime.utc(
          parsed.year,
          parsed.month,
          parsed.day,
          parsed.hour,
          parsed.minute,
          parsed.second,
          parsed.millisecond,
          parsed.microsecond,
        );
      }
    } catch (e) {
      // Nếu parse lỗi thì fallback về now UTC
      print('Error parsing DateTime: $dateTimeString, error: $e');
      return DateTime.now().toUtc();
    }
  }
}

