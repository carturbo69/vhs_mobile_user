// service_model.dart
import 'dart:convert';

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

  factory ServiceOption.fromJson(Map<String, dynamic> j) {
    // Bỏ ngoặc tròn ngay khi parse từ JSON
    final rawOptionName = (j['optionName'] ?? '').toString();
    var rawValue = j['value']?.toString();
    
    // Xử lý trường hợp value là string "null" hoặc rỗng
    if (rawValue == null || rawValue.isEmpty || rawValue.toLowerCase() == 'null') {
      rawValue = null;
    }
    
    final cleanOptionName = rawOptionName.replaceAll('(', '').replaceAll(')', '').trim();
    final cleanValue = rawValue?.replaceAll('(', '').replaceAll(')', '').trim();
    
    return ServiceOption(
      serviceOptionId: j['serviceOptionId']?.toString() ?? '',
      optionId: j['optionId']?.toString() ?? '',
      optionName: cleanOptionName,
      tagId: j['tagId']?.toString(),
      type: j['type'] ?? '',
      family: j['family']?.toString(),
      value: cleanValue,
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

class ServiceModel {
  final String serviceId;
  final String providerId;
  final String categoryId;
  final String title;
  final String? description;
  final double price;
  final String unitType;
  final int? baseUnit;
  final String? images; // CSV of image paths or a single string (controller returns csv)
  final DateTime? createdAt;
  final String? status;
  final bool? deleted;
  final double averageRating;
  final int totalReviews;
  final String categoryName;
  final String? providerName;
  final List<ServiceOption> serviceOptions;

  ServiceModel({
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
    this.deleted,
    required this.averageRating,
    required this.totalReviews,
    required this.categoryName,
    this.providerName,
    required this.serviceOptions,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> j) {
    final optionsJson = j['serviceOptions'] as List<dynamic>?;
    return ServiceModel(
      serviceId: j['serviceId']?.toString() ?? '',
      providerId: j['providerId']?.toString() ?? '',
      categoryId: j['categoryId']?.toString() ?? '',
      title: j['title'] ?? '',
      description: j['description'],
      price: (j['price'] is num) ? (j['price'] as num).toDouble() : double.tryParse(j['price']?.toString() ?? '') ?? 0.0,
      unitType: j['unitType'] ?? '',
      baseUnit: j['baseUnit'] != null ? int.tryParse(j['baseUnit'].toString()) : null,
      images: j['images'],
      createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null,
      status: j['status'],
      deleted: j['deleted'] as bool?,
      averageRating: (j['averageRating'] is num) ? (j['averageRating'] as num).toDouble() : double.tryParse(j['averageRating']?.toString() ?? '') ?? 0.0,
      totalReviews: (j['totalReviews'] is int) ? j['totalReviews'] : int.tryParse(j['totalReviews']?.toString() ?? '') ?? 0,
      categoryName: j['categoryName'] ?? '',
      providerName: j['providerName'],
      serviceOptions: optionsJson != null ? optionsJson.map((e) => ServiceOption.fromJson(e as Map<String, dynamic>)).toList() : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'serviceId': serviceId,
        'providerId': providerId,
        'categoryId': categoryId,
        'title': title,
        'description': description,
        'price': price,
        'unitType': unitType,
        'baseUnit': baseUnit,
        'images': images,
        'createdAt': createdAt?.toIso8601String(),
        'status': status,
        'deleted': deleted,
        'averageRating': averageRating,
        'totalReviews': totalReviews,
        'categoryName': categoryName,
        'providerName': providerName,
        'serviceOptions': serviceOptions.map((o) => o.toJson()).toList(),
      };

  // helper to get first image absolute url list if images is CSV
  List<String> get imageList {
    if (images == null || images!.trim().isEmpty) return [];
    return images!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }
}
