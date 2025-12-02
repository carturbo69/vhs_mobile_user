class ServiceShopViewModel {
  final String providerId;
  final ShopInfo shopInfo;
  final List<ServiceShopItem> bestsellingServices;
  final List<ServiceCategory> shopCategories;
  final List<ServiceCategory> allCategories;
  final List<ServiceShopItem> services;
  final int currentPage;
  final int totalPages;
  final int? selectedCategoryId;
  final String? selectedTagId;
  final String sortBy;

  ServiceShopViewModel({
    required this.providerId,
    required this.shopInfo,
    required this.bestsellingServices,
    required this.shopCategories,
    required this.allCategories,
    required this.services,
    required this.currentPage,
    required this.totalPages,
    this.selectedCategoryId,
    this.selectedTagId,
    this.sortBy = 'popular',
  });

  factory ServiceShopViewModel.fromJson(Map<String, dynamic> json) {
    return ServiceShopViewModel(
      providerId: json['providerId']?.toString() ?? '',
      shopInfo: ShopInfo.fromJson(json['shopInfo'] ?? {}),
      bestsellingServices: (json['bestsellingServices'] as List?)
              ?.map((e) => ServiceShopItem.fromJson(e))
              .toList() ??
          [],
      shopCategories: (json['shopCategories'] as List?)
              ?.map((e) => ServiceCategory.fromJson(e))
              .toList() ??
          [],
      allCategories: (json['allCategories'] as List?)
              ?.map((e) => ServiceCategory.fromJson(e))
              .toList() ??
          [],
      services: (json['services'] as List?)
              ?.map((e) => ServiceShopItem.fromJson(e))
              .toList() ??
          [],
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      selectedCategoryId: json['selectedCategoryId'],
      selectedTagId: json['selectedTagId']?.toString(),
      sortBy: json['sortBy'] ?? 'popular',
    );
  }
}

class ShopInfo {
  final int id;
  final String name;
  final String logo;
  final String status;
  final String lastOnline;
  final int totalServices;
  final int following;
  final int followers;
  final double responseRate;
  final double rating;
  final int totalRatings;
  final String joinDate;
  final bool isFollowed;

  ShopInfo({
    required this.id,
    required this.name,
    required this.logo,
    required this.status,
    required this.lastOnline,
    required this.totalServices,
    required this.following,
    required this.followers,
    required this.responseRate,
    required this.rating,
    required this.totalRatings,
    required this.joinDate,
    required this.isFollowed,
  });

  factory ShopInfo.fromJson(Map<String, dynamic> json) {
    return ShopInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      status: json['status'] ?? 'Offline',
      lastOnline: json['lastOnline'] ?? '',
      totalServices: json['totalServices'] ?? 0,
      following: json['following'] ?? 0,
      followers: json['followers'] ?? 0,
      responseRate: (json['responseRate'] is num)
          ? (json['responseRate'] as num).toDouble()
          : 0.0,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
      totalRatings: json['totalRatings'] ?? 0,
      joinDate: json['joinDate'] ?? '',
      isFollowed: json['isFollowed'] ?? false,
    );
  }
}

class ServiceShopItem {
  final String serviceId;
  final String providerId;
  final String categoryId;
  final String categoryName;
  final String name;
  final String? description;
  final double price;
  final String unitType;
  final int baseUnit;
  final String? imageUrl;
  final String? image;
  final String? status;
  final DateTime? createdAt;
  final List<String>? tags;
  final List<ServiceOptionItem>? serviceOptions;
  final double rating;
  final int ratingCount;

  ServiceShopItem({
    required this.serviceId,
    required this.providerId,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    this.description,
    required this.price,
    required this.unitType,
    required this.baseUnit,
    this.imageUrl,
    this.image,
    this.status,
    this.createdAt,
    this.tags,
    this.serviceOptions,
    required this.rating,
    required this.ratingCount,
  });

  factory ServiceShopItem.fromJson(Map<String, dynamic> json) {
    return ServiceShopItem(
      serviceId: json['serviceId']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName'] ?? '',
      name: json['name'] ?? json['title'] ?? '',
      description: json['description'],
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      unitType: json['unitType'] ?? '',
      baseUnit: json['baseUnit'] ?? 0,
      imageUrl: json['imageUrl'],
      image: json['image'],
      status: json['status'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      tags: json['tags'] != null
          ? (json['tags'] as List).map((e) => e.toString()).toList()
          : null,
      serviceOptions: json['serviceOptions'] != null
          ? (json['serviceOptions'] as List)
              .map((e) => ServiceOptionItem.fromJson(e))
              .toList()
          : null,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
      ratingCount: json['ratingCount'] ?? 0,
    );
  }

  String? get firstImage {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      final images = imageUrl!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (images.isNotEmpty) return images[0];
    }
    if (image != null && image!.isNotEmpty) {
      final images = image!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (images.isNotEmpty) return images[0];
    }
    return null;
  }
}

class ServiceOptionItem {
  final String optionId;
  final String optionName;
  final String? type;
  final String? value;

  ServiceOptionItem({
    required this.optionId,
    required this.optionName,
    this.type,
    this.value,
  });

  factory ServiceOptionItem.fromJson(Map<String, dynamic> json) {
    return ServiceOptionItem(
      optionId: json['optionId']?.toString() ?? '',
      optionName: json['optionName'] ?? '',
      type: json['type'],
      value: json['value'],
    );
  }
}

class ServiceCategory {
  final int id;
  final String categoryId; // Thêm categoryId string để so sánh
  final String name;
  final String icon;
  final int serviceCount;
  final List<ServiceCategory> subCategories;
  final List<CategoryTag> tags;

  ServiceCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.serviceCount,
    required this.subCategories,
    required this.tags,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? 0,
      categoryId: json['categoryId']?.toString() ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      serviceCount: json['serviceCount'] ?? 0,
      subCategories: (json['subCategories'] as List?)
              ?.map((e) => ServiceCategory.fromJson(e))
              .toList() ??
          [],
      tags: (json['tags'] as List?)
              ?.map((e) => CategoryTag.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CategoryTag {
  final String tagId;
  final String name;
  final int serviceCount;

  CategoryTag({
    required this.tagId,
    required this.name,
    required this.serviceCount,
  });

  factory CategoryTag.fromJson(Map<String, dynamic> json) {
    return CategoryTag(
      tagId: json['tagId']?.toString() ?? '',
      name: json['name'] ?? '',
      serviceCount: json['serviceCount'] ?? 0,
    );
  }
}

