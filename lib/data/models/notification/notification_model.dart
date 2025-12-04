class NotificationModel {
  final String notificationId;
  final String accountReceivedId;
  final String receiverRole;
  final String notificationType;
  final String content;
  final bool? isRead;
  final DateTime? createdAt;
  final String? receiverName;
  final String? receiverEmail;

  NotificationModel({
    required this.notificationId,
    required this.accountReceivedId,
    required this.receiverRole,
    required this.notificationType,
    required this.content,
    this.isRead,
    this.createdAt,
    this.receiverName,
    this.receiverEmail,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json["notificationId"] ?? json["NotificationId"] ?? "",
      accountReceivedId: json["accountReceivedId"] ?? json["AccountReceivedId"] ?? "",
      receiverRole: json["receiverRole"] ?? json["ReceiverRole"] ?? "",
      notificationType: json["notificationType"] ?? json["NotificationType"] ?? "",
      content: json["content"] ?? json["Content"] ?? "",
      isRead: json["isRead"] ?? json["IsRead"],
      createdAt: json["createdAt"] != null || json["CreatedAt"] != null
          ? DateTime.parse(json["createdAt"] ?? json["CreatedAt"])
          : null,
      receiverName: json["receiverName"] ?? json["ReceiverName"],
      receiverEmail: json["receiverEmail"] ?? json["ReceiverEmail"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "notificationId": notificationId,
      "accountReceivedId": accountReceivedId,
      "receiverRole": receiverRole,
      "notificationType": notificationType,
      "content": content,
      "isRead": isRead,
      "createdAt": createdAt?.toIso8601String(),
      "receiverName": receiverName,
      "receiverEmail": receiverEmail,
    };
  }
}

class NotificationListResponse {
  final bool success;
  final String message;
  final List<NotificationModel>? data;
  final int totalCount;
  final int unreadCount;

  NotificationListResponse({
    required this.success,
    required this.message,
    this.data,
    required this.totalCount,
    required this.unreadCount,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    List<NotificationModel>? notifications;
    
    final dataList = json["data"] ?? json["Data"];
    if (dataList != null && dataList is List) {
      notifications = dataList
          .map((item) {
            try {
              return NotificationModel.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              print("Error parsing notification item: $e");
              return null;
            }
          })
          .whereType<NotificationModel>()
          .toList();
    }
    
    return NotificationListResponse(
      success: json["success"] ?? json["Success"] ?? false,
      message: json["message"] ?? json["Message"] ?? "",
      data: notifications,
      totalCount: json["totalCount"] ?? json["TotalCount"] ?? 0,
      unreadCount: json["unreadCount"] ?? json["UnreadCount"] ?? 0,
    );
  }
}

