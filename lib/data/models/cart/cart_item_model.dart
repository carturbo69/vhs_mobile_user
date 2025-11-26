import 'dart:convert';

class CartItemModel {
  final String cartItemId;
  final String serviceId;
  final String serviceName;
  final String? providerId;
  final String? providerName;
  final double price;
  int quantity;
  final String? imageUrl;
  final String? cartItemOptionsJson; // options (if any) as JSON string

  CartItemModel({
    required this.cartItemId,
    required this.serviceId,
    required this.serviceName,
    this.providerId,
    this.providerName,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.cartItemOptionsJson,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: json['cartItemId'].toString(),
      serviceId: json['serviceId'].toString(),
      serviceName: json['serviceName'] ?? '',
      providerId: json['providerId']?.toString(),
      providerName: json['providerName'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as int?) ?? (json['qty'] as int?) ?? 1,
      imageUrl: json['imageUrl'] as String?,
      cartItemOptionsJson: json['options'] != null ? jsonEncode(json['options']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartItemId': cartItemId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'providerId': providerId,
      'providerName': providerName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'options': cartItemOptionsJson != null ? jsonDecode(cartItemOptionsJson!) : null,
    };
  }

  double get subtotal => price * quantity;
}
