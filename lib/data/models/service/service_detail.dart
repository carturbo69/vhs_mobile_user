import 'dart:convert';

class ProviderSummary {
  final String providerId;
  final String providerName;
  final String? phoneNumber;
  final String? description;
  final String? images;
  final String status;
  final DateTime? joinedAt;

  final int totalServices;
  final double averageRatingAllServices;

  ProviderSummary({
    required this.providerId,
    required this.providerName,
    this.phoneNumber,
    this.description,
    this.images,
    required this.status,
    this.joinedAt,
    required this.totalServices,
    required this.averageRatingAllServices,
  });

  factory ProviderSummary.fromJson(Map<String, dynamic> j) {
    return ProviderSummary(
      providerId: j['providerId']?.toString() ?? '',
      providerName: j['providerName'] ?? '',
      phoneNumber: j['phoneNumber'],
      description: j['description'],
      images: j['images'],
      status: j['status'] ?? '',
      joinedAt: j['joinedAt'] != null ? DateTime.tryParse(j['joinedAt']) : null,
      totalServices: j['totalServices'] ?? 0,
      averageRatingAllServices:
          (j['averageRatingAllServices'] is num)
              ? (j['averageRatingAllServices'] as num).toDouble()
              : 0,
    );
  }
}

class ServiceOptionDetail {
  final String serviceOptionId;
  final String optionId;
  final String optionName;
  final String? tagId;
  final String type;
  final String? family;
  final String? value;

  ServiceOptionDetail({
    required this.serviceOptionId,
    required this.optionId,
    required this.optionName,
    this.tagId,
    required this.type,
    this.family,
    this.value,
  });

  factory ServiceOptionDetail.fromJson(Map<String, dynamic> j) {
    // Bỏ ngoặc tròn ngay khi parse từ JSON
    final rawOptionName = (j['optionName'] ?? '').toString();
    var rawValue = j['value']?.toString();
    
    // Xử lý trường hợp value là string "null" hoặc rỗng
    if (rawValue == null || rawValue.isEmpty || rawValue.toLowerCase() == 'null') {
      rawValue = null;
    }
    
    final cleanOptionName = rawOptionName.replaceAll('(', '').replaceAll(')', '').trim();
    final cleanValue = rawValue?.replaceAll('(', '').replaceAll(')', '').trim();
    
    return ServiceOptionDetail(
      serviceOptionId: j['serviceOptionId'].toString(),
      optionId: j['optionId'].toString(),
      optionName: cleanOptionName,
      tagId: j['tagId']?.toString(),
      type: j['type'],
      family: j['family']?.toString(),
      value: cleanValue,
    );
  }
}

class ReviewItem {
  final String reviewId;
  final String userId;
  final int rating;
  final String? comment;
  final List<String> images;
  final String? reply;
  final DateTime? createdAt;
  final String? fullName;
  final String? avatar;

  ReviewItem({
    required this.reviewId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.images,
    this.reply,
    this.createdAt,
    this.fullName,
    this.avatar,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> j) {
    return ReviewItem(
      reviewId: j['reviewId'].toString(),
      userId: j['userId'].toString(),
      rating: j['rating'] ?? 0,
      comment: j['comment'],
      images: (j['images'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      reply: j['reply'],
      createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null,
      fullName: j['fullName'],
      avatar: j['avatar'],
    );
  }
}

class ServiceTag {
  final String tagId;
  final String name;

  ServiceTag({required this.tagId, required this.name});

  factory ServiceTag.fromJson(Map<String, dynamic> j) {
    return ServiceTag(
      tagId: j['tagId'].toString(),
      name: j['name'],
    );
  }
}

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
  final List<ServiceOptionDetail> serviceOptions;
  final List<ReviewItem> reviews;
  final List<ServiceTag> tags;

  // Helpers
  List<String> get imageList {
    if (images == null || images!.isEmpty) return [];
    return images!.split(',').map((e) => e.trim()).toList();
  }

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

  factory ServiceDetail.fromJson(Map<String, dynamic> j) {
    return ServiceDetail(
      serviceId: j['serviceId'].toString(),
      providerId: j['providerId'].toString(),
      categoryId: j['categoryId'].toString(),
      title: j['title'],
      description: j['description'],
      price: (j['price'] is num) ? (j['price'] as num).toDouble() : 0,
      unitType: j['unitType'],
      baseUnit: j['baseUnit'],
      images: j['images'],
      createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null,
      status: j['status'],
      categoryName: j['categoryName'],
      totalReviews: j['totalReviews'] ?? 0,
      averageRating: (j['averageRating'] is num)
          ? (j['averageRating'] as num).toDouble()
          : 0,
      provider: ProviderSummary.fromJson(j['provider']),
      serviceOptions: (j['serviceOptions'] as List?)
              ?.map((e) => ServiceOptionDetail.fromJson(e))
              .toList() ??
          [],
      reviews:
          (j['reviews'] as List?)?.map((e) => ReviewItem.fromJson(e)).toList() ?? [],
      tags:
          (j['tags'] as List?)?.map((e) => ServiceTag.fromJson(e)).toList() ?? [],
    );
  }
}
