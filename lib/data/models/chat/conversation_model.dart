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

  // Helper method để parse DateTime và giữ nguyên UTC (sẽ convert sang VN time khi hiển thị)
  static DateTime _parseDateTime(String dateTimeString) {
    try {
      // Parse DateTime từ string
      DateTime parsed = DateTime.parse(dateTimeString);
      
      // Backend trả về UTC time (thường có 'Z' ở cuối hoặc không có timezone)
      // Nếu có 'Z' ở cuối hoặc có timezone offset, DateTime.parse sẽ tự động parse đúng
      // Nếu không có timezone info, giả sử là UTC
      if (!parsed.isUtc) {
        // Kiểm tra xem string có chứa timezone info không
        final hasTimezone = dateTimeString.contains('+') || 
                           dateTimeString.contains('-') || 
                           dateTimeString.endsWith('Z') ||
                           dateTimeString.contains('T') && (dateTimeString.contains('+') || dateTimeString.contains('Z'));
        
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
      
      // Đảm bảo trả về UTC DateTime
      return parsed.isUtc ? parsed : parsed.toUtc();
    } catch (e) {
      // Nếu parse lỗi, trả về thời gian hiện tại (UTC)
      print('Error parsing DateTime: $dateTimeString, error: $e');
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
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      conversationId: json['conversationId']?.toString() ?? json['ConversationId']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? _parseDateTime(json['createdAt'].toString())
          : DateTime.now(),
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
    };
  }

  // Helper method để parse DateTime và giữ nguyên UTC (sẽ convert sang VN time khi hiển thị)
  static DateTime _parseDateTime(String dateTimeString) {
    try {
      // Parse DateTime từ string
      DateTime parsed = DateTime.parse(dateTimeString);
      
      // Backend trả về UTC time (thường có 'Z' ở cuối hoặc không có timezone)
      // Nếu có 'Z' ở cuối hoặc có timezone offset, DateTime.parse sẽ tự động parse đúng
      // Nếu không có timezone info, giả sử là UTC
      if (!parsed.isUtc) {
        // Kiểm tra xem string có chứa timezone info không
        final hasTimezone = dateTimeString.contains('+') || 
                           dateTimeString.contains('-') || 
                           dateTimeString.endsWith('Z') ||
                           dateTimeString.contains('T') && (dateTimeString.contains('+') || dateTimeString.contains('Z'));
        
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
      
      // Đảm bảo trả về UTC DateTime
      return parsed.isUtc ? parsed : parsed.toUtc();
    } catch (e) {
      // Nếu parse lỗi, trả về thời gian hiện tại (UTC)
      print('Error parsing DateTime: $dateTimeString, error: $e');
      return DateTime.now().toUtc();
    }
  }
}

