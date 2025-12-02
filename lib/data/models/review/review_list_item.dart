class ReviewListItem {
  final String reviewId;
  final String serviceId;
  final String userId;
  final String fullName;
  final String userAvatarUrl;
  final int? rating;
  final String comment;
  final String reply;
  final String serviceTitle;
  final String serviceThumbnailUrl;
  final DateTime? createdAt;
  final int likeCount;
  final int editCount;
  final bool canEdit;
  final bool canDelete;
  final List<String> reviewImageUrls;

  ReviewListItem({
    required this.reviewId,
    required this.serviceId,
    required this.userId,
    required this.fullName,
    required this.userAvatarUrl,
    this.rating,
    required this.comment,
    required this.reply,
    required this.serviceTitle,
    required this.serviceThumbnailUrl,
    this.createdAt,
    required this.likeCount,
    required this.editCount,
    required this.canEdit,
    required this.canDelete,
    required this.reviewImageUrls,
  });

  factory ReviewListItem.fromJson(Map<String, dynamic> json) {
    return ReviewListItem(
      reviewId: json['reviewId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      userAvatarUrl: json['userAvatarUrl'] ?? '',
      rating: json['rating'],
      comment: json['comment'] ?? '',
      reply: json['reply'] ?? '',
      serviceTitle: json['serviceTitle'] ?? '',
      serviceThumbnailUrl: json['serviceThumbnailUrl'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      likeCount: json['likeCount'] ?? 0,
      editCount: json['editCount'] ?? 0,
      canEdit: json['canEdit'] ?? false,
      canDelete: json['canDelete'] ?? false,
      reviewImageUrls: (json['reviewImageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

