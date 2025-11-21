/// Represents detailed information about a service, including provider summary,
/// options, reviews, and tags.
/// Why? Ask the one who write the backend
class ServiceDetail {
  final String serviceId;
  final String providerId;
  final String categoryId;
  final String title;
  final String? description;
  final double price;
  final String unitType;
  final int? baseUnit;
  final String? images;
  final DateTime? createdAt;
  final String? status;

  final String categoryName;
  final int totalReviews;
  final double averageRating;

  final ProviderSummary provider;
  final List<ServiceOption> serviceOptions;
  final List<ReviewItem> reviews;
  final List<ServiceTag> tags;

  ServiceDetail({
    required this.serviceId,
    required this.providerId,
    required this.categoryId,
    required this.title,
    this.description,
    required this.price,
    required this.unitType,
    this.baseUnit,
    this.images,
    this.createdAt,
    this.status,
    required this.categoryName,
    required this.totalReviews,
    required this.averageRating,
    required this.provider,
    required this.serviceOptions,
    required this.reviews,
    required this.tags,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      serviceId: json['serviceId'],
      providerId: json['providerId'],
      categoryId: json['categoryId'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      unitType: json['unitType'],
      baseUnit: json['baseUnit'],
      images: json['images'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      status: json['status'],
      categoryName: json['categoryName'],
      totalReviews: json['totalReviews'],
      averageRating: (json['averageRating'] as num).toDouble(),
      provider: ProviderSummary.fromJson(json['provider']),
      serviceOptions: (json['serviceOptions'] as List)
          .map((x) => ServiceOption.fromJson(x))
          .toList(),
      reviews: (json['reviews'] as List)
          .map((x) => ReviewItem.fromJson(x))
          .toList(),
      tags: (json['tags'] as List)
          .map((x) => ServiceTag.fromJson(x))
          .toList(),
    );
  }
}


class ProviderSummary {
  final String providerId;
  final String providerName;
  final String? phoneNumber;
  final String? description;
  final String? images; // CSV list
  final String? status;
  final DateTime? joinedAt;
  final int totalServices;
  final double averageRatingAllServices;

  ProviderSummary({
    required this.providerId,
    required this.providerName,
    this.phoneNumber,
    this.description,
    this.images,
    this.status,
    this.joinedAt,
    required this.totalServices,
    required this.averageRatingAllServices,
  });

  factory ProviderSummary.fromJson(Map<String, dynamic> json) {
    return ProviderSummary(
      providerId: json['providerId'],
      providerName: json['providerName'],
      phoneNumber: json['phoneNumber'],
      description: json['description'],
      images: json['images'],
      status: json['status'],
      joinedAt:
          json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : null,
      totalServices: json['totalServices'],
      averageRatingAllServices:
          (json['averageRatingAllServices'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'providerId': providerId,
        'providerName': providerName,
        'phoneNumber': phoneNumber,
        'description': description,
        'images': images,
        'status': status,
        'joinedAt': joinedAt?.toIso8601String(),
        'totalServices': totalServices,
        'averageRatingAllServices': averageRatingAllServices,
      };
}



class ServiceOption {
  final String serviceOptionId;
  final String optionId;
  final String optionName;
  final String? tagId;
  final String type;
  final String? family;
  final String? value;

  ServiceOption({
    required this.serviceOptionId,
    required this.optionId,
    required this.optionName,
    this.tagId,
    required this.type,
    this.family,
    this.value,
  });

  factory ServiceOption.fromJson(Map<String, dynamic> json) {
    return ServiceOption(
      serviceOptionId: json['serviceOptionId'],
      optionId: json['optionId'],
      optionName: json['optionName'],
      tagId: json['tagId'],
      type: json['type'],
      family: json['family'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
        'serviceOptionId': serviceOptionId,
        'optionId': optionId,
        'optionName': optionName,
        'tagId': tagId,
        'type': type,
        'family': family,
        'value': value,
      };
}


class ReviewItem {
  final String reviewId;
  final String serviceId;
  final String userId;
  final int rating;
  final String? comment;
  final List<String> images;
  final String? reply;
  final DateTime? createdAt;
  final String? avatar;
  final String? fullName;

  ReviewItem({
    required this.reviewId,
    required this.serviceId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.images,
    this.reply,
    this.createdAt,
    this.avatar,
    this.fullName,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      reviewId: json['reviewId'],
      serviceId: json['serviceId'],
      userId: json['userId'],
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      images: (json['images'] ?? []).cast<String>(),
      reply: json['reply'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      avatar: json['avatar'],
      fullName: json['fullName'],
    );
  }

  Map<String, dynamic> toJson() => {
        'reviewId': reviewId,
        'serviceId': serviceId,
        'userId': userId,
        'rating': rating,
        'comment': comment,
        'images': images,
        'reply': reply,
        'createdAt': createdAt?.toIso8601String(),
        'avatar': avatar,
        'fullName': fullName,
      };
}


class ServiceTag {
  final String tagId;
  final String name;

  ServiceTag({
    required this.tagId,
    required this.name,
  });

  factory ServiceTag.fromJson(Map<String, dynamic> json) {
    return ServiceTag(
      tagId: json['tagId'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'tagId': tagId,
        'name': name,
      };
}
