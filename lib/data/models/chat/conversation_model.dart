import 'package:vhs_mobile_user/data/models/chat/message_model.dart';

class ConversationListItemModel {
  final String conversationId;
  final String title;
  final String? avatarUrl;
  final String? lastMessageSnippet;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isOnline;
  final bool isPinned;

  ConversationListItemModel({
    required this.conversationId,
    required this.title,
    this.avatarUrl,
    this.lastMessageSnippet,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isPinned = false,
  });

  factory ConversationListItemModel.fromJson(Map<String, dynamic> json) {
    return ConversationListItemModel(
      conversationId: json['conversationId']?.toString() ?? json['ConversationId']?.toString() ?? '',
      title: json['title'] ?? json['Title'] ?? '',
      avatarUrl: json['avatarUrl'] ?? json['AvatarUrl'],
      lastMessageSnippet: json['lastMessageSnippet'] ?? json['LastMessageSnippet'],
      lastMessageAt: json['lastMessageAt'] != null
          ? ConversationListItemModel._parseDateTime(json['lastMessageAt'].toString())
          : null,
      unreadCount: json['unreadCount'] ?? json['UnreadCount'] ?? 0,
      isOnline: json['isOnline'] ?? json['IsOnline'] ?? false,
      isPinned: json['isPinned'] ?? json['IsPinned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'title': title,
      'avatarUrl': avatarUrl,
      'lastMessageSnippet': lastMessageSnippet,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'isPinned': isPinned,
    };
  }

  static DateTime _parseDateTime(String dateTimeString) {
    try {
      final s = dateTimeString.trim();
      final tzPattern = RegExp(r'(Z|[+\-]\d{2}:\d{2})$', caseSensitive: false);

      final parsed = DateTime.parse(s);

      if (tzPattern.hasMatch(s)) {
        return parsed.toUtc();
      } else {
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
      print('Error parsing DateTime in ConversationListItemModel: $dateTimeString, error: $e');
      return DateTime.now().toUtc();
    }
  }
}

class ConversationModel {
  final String conversationId;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final MessageAccountModel participantA;
  final MessageAccountModel participantB;
  final bool isHiddenForMe;
  final bool isMutedForMe;
  final String title;
  final String? avatarUrl;
  final String? lastMessageSnippet;
  final int unreadCount;
  final bool isOnline;
  final bool isPinned;
  final List<MessageModel> messages;

  // 👇 1. THÊM 2 TRƯỜNG NÀY ĐỂ BIẾT MỐC XÓA
  final DateTime? clearBeforeAtByA;
  final DateTime? clearBeforeAtByB;

  ConversationModel({
    required this.conversationId,
    required this.createdAt,
    this.lastMessageAt,
    required this.participantA,
    required this.participantB,
    this.isHiddenForMe = false,
    this.isMutedForMe = false,
    required this.title,
    this.avatarUrl,
    this.lastMessageSnippet,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isPinned = false,
    this.messages = const [],
    // 👇 Thêm vào constructor
    this.clearBeforeAtByA,
    this.clearBeforeAtByB,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      conversationId: json['conversationId']?.toString() ?? json['ConversationId']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? _parseDateTime(json['createdAt'].toString())
          : DateTime.now().toUtc(),
      lastMessageAt: json['lastMessageAt'] != null
          ? _parseDateTime(json['lastMessageAt'].toString())
          : null,
      participantA: MessageAccountModel.fromJson(
        json['participantA'] ?? json['ParticipantA'] ?? {},
      ),
      participantB: MessageAccountModel.fromJson(
        json['participantB'] ?? json['ParticipantB'] ?? {},
      ),
      isHiddenForMe: json['isHiddenForMe'] ?? json['IsHiddenForMe'] ?? false,
      isMutedForMe: json['isMutedForMe'] ?? json['IsMutedForMe'] ?? false,
      title: json['title'] ?? json['Title'] ?? '',
      avatarUrl: json['avatarUrl'] ?? json['AvatarUrl'],
      lastMessageSnippet: json['lastMessageSnippet'] ?? json['LastMessageSnippet'],
      unreadCount: json['unreadCount'] ?? json['UnreadCount'] ?? 0,
      isOnline: json['isOnline'] ?? json['IsOnline'] ?? false,
      isPinned: json['isPinned'] ?? json['IsPinned'] ?? false,
      messages: json['messages'] != null
          ? (json['messages'] as List)
          .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
          .toList()
          : [],
      // 👇 Map dữ liệu từ JSON (Backend trả về PascalCase hoặc camelCase)
      clearBeforeAtByA: (json['clearBeforeAtByA'] ?? json['ClearBeforeAtByA']) != null
          ? _parseDateTime((json['clearBeforeAtByA'] ?? json['ClearBeforeAtByA']).toString())
          : null,
      clearBeforeAtByB: (json['clearBeforeAtByB'] ?? json['ClearBeforeAtByB']) != null
          ? _parseDateTime((json['clearBeforeAtByB'] ?? json['ClearBeforeAtByB']).toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'participantA': participantA.toJson(),
      'participantB': participantB.toJson(),
      'isHiddenForMe': isHiddenForMe,
      'isMutedForMe': isMutedForMe,
      'title': title,
      'avatarUrl': avatarUrl,
      'lastMessageSnippet': lastMessageSnippet,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'isPinned': isPinned,
      'messages': messages.map((m) => m.toJson()).toList(),
      // 👇 Thêm vào toJson
      'clearBeforeAtByA': clearBeforeAtByA?.toIso8601String(),
      'clearBeforeAtByB': clearBeforeAtByB?.toIso8601String(),
    };
  }

  // 👇 2. HÀM QUAN TRỌNG: Lọc tin nhắn hiển thị
  // Hàm này được gọi từ UI để lấy danh sách tin nhắn đã loại bỏ tin cũ
  List<MessageModel> getVisibleMessages(String myAccountId) {
    DateTime? clearTime;

    // So sánh ID để biết mình là A hay B
    // (Dùng toLowerCase để tránh lỗi do chữ hoa/thường của GUID)
    if (myAccountId.toLowerCase() == participantA.accountId.toLowerCase()) {
      clearTime = clearBeforeAtByA;
    } else if (myAccountId.toLowerCase() == participantB.accountId.toLowerCase()) {
      clearTime = clearBeforeAtByB;
    }

    // Nếu chưa xóa lần nào -> trả về hết
    if (clearTime == null) return messages;

    // Lọc: Chỉ giữ lại tin nhắn có thời gian tạo > thời gian xóa
    return messages.where((m) => m.createdAt.isAfter(clearTime!)).toList();
  }



  static DateTime _parseDateTime(String dateTimeString) {
    try {
      final s = dateTimeString.trim();
      final tzPattern = RegExp(r'(Z|[+\-]\d{2}:\d{2})$', caseSensitive: false);

      final parsed = DateTime.parse(s);

      if (tzPattern.hasMatch(s)) {
        return parsed.toUtc();
      } else {
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
      print('Error parsing DateTime in ConversationModel: $dateTimeString, error: $e');
      return DateTime.now().toUtc();
    }
  }
}