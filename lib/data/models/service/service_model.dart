class ServiceModel {
  final String serviceId;
  final String providerId;
  final String categoryId;
  final String title;
  final String? description;
  final double price;
  final String unitType;
  final int? baseUnit;
  final String? images;
  final double averageRating;
  final int totalReviews;
  final String categoryName;

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
    required this.averageRating,
    required this.totalReviews,
    required this.categoryName,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['serviceId'],
      providerId: json['providerId'],
      categoryId: json['categoryId'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      unitType: json['unitType'],
      baseUnit: json['baseUnit'],
      images: json['images'],
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'],
      categoryName: json['categoryName'],
    );
  }
}
