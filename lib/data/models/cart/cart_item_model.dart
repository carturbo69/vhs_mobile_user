class CartItemModel {
  final String cartItemId;
  final String cartId;
  final String serviceId;
  final DateTime createdAt;

  final String serviceName;
  final double servicePrice;
  final List<String> serviceImages;

  final String providerId;
  final String providerName;
  final String providerImages;

  final List<CartOptionModel> options;

  int quantity;

  CartItemModel({
    required this.cartItemId,
    required this.cartId,
    required this.serviceId,
    required this.createdAt,
    required this.serviceName,
    required this.servicePrice,
    required this.serviceImages,
    required this.providerId,
    required this.providerName,
    required this.providerImages,
    required this.options,
    this.quantity = 1,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: json["cartItemId"],
      cartId: json["cartId"],
      serviceId: json["serviceId"],
      createdAt: DateTime.parse(json["createdAt"]),
      serviceName: json["serviceName"],
      servicePrice: (json["servicePrice"] as num).toDouble(),
      serviceImages: (json["serviceImage"] as String)
          .split(",")
          .map((e) => e.trim())
          .toList(),
      providerId: json["providerId"],
      providerName: json["providerName"],
      providerImages: json["providerImages"],
      options: (json["options"] as List<dynamic>)
          .map((e) => CartOptionModel.fromJson(e))
          .toList(),
      quantity: 1,
    );
  }

  double get subtotal => servicePrice * quantity;
}


class CartOptionModel {
  final String cartItemOptionId;
  final String optionId;
  final String optionName;
  final String tagId;
  final String type;
  final String family;
  final String value;

  CartOptionModel({
    required this.cartItemOptionId,
    required this.optionId,
    required this.optionName,
    required this.tagId,
    required this.type,
    required this.family,
    required this.value,
  });

  factory CartOptionModel.fromJson(Map<String, dynamic> json) {
    return CartOptionModel(
      cartItemOptionId: json["cartItemOptionId"] ?? "",
      optionId: json["optionId"] ?? "",
      optionName: json["optionName"] ?? "",
      tagId: json["tagId"] ?? "",
      type: json["type"] ?? "",
      family: json["family"] ?? "",
      value: json["value"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "cartItemOptionId": cartItemOptionId,
        "optionId": optionId,
        "optionName": optionName,
        "tagId": tagId,
        "type": type,
        "family": family,
        "value": value,
      };
}
