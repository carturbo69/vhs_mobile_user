import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/network/dio_client.dart';
import 'package:vhs_mobile_user/data/models/cart/add_cart_item_request.dart';
import 'package:vhs_mobile_user/data/models/cart/cart_item_model.dart';

final cartApiProvider = Provider<CartApi>((ref) {
  return CartApi(ref.read(dioClientProvider).instance);
});

class CartApi {
  final Dio _dio;
  CartApi(this._dio);

  // GET /api/carts/account/{accountId}/items
 Future<List<CartItemModel>> getCartItems(String accountId) async {
  final resp = await _dio.get('/api/carts/account/$accountId/items');

  final data = resp.data;

  // Case 1: Backend trả trực tiếp List
  if (data is List) {
    return data.map((e) => CartItemModel.fromJson(e)).toList();
  }

  // Case 2: Backend trả Map có "data": List
  if (data is Map && data['data'] is List) {
    return (data['data'] as List)
        .map((e) => CartItemModel.fromJson(e))
        .toList();
  }

  return [];
}

  // POST /api/carts/addtocart-items
 Future<void> addCartItem({
    required String accountId,
    required AddCartItemRequest request,
  }) async {
    await _dio.post(
      "/api/Carts/addtocart-items",
      queryParameters: {
        "accountId": accountId,
      },
      data: request.toJson(),
    );
  }

  // DELETE single
  Future<void> removeCartItem(String accountId, String cartItemId) async {
    await _dio.delete('/api/carts/account/$accountId/items/$cartItemId');
  }

  // DELETE bulk
  Future<void> removeMany(
    String accountId,
    Map<String, dynamic> payload,
  ) async {
    await _dio.delete(
      '/api/carts/account/$accountId/items:bulk',
      data: payload,
    );
  }

  // DELETE clear
  Future<void> clearCart(String accountId) async {
    await _dio.delete('/api/carts/account/$accountId/items:clear');
  }

  Future<int> getTotalCount(String accountId) async {
    final resp = await _dio.get('/api/carts/account/$accountId/total');
    final raw = resp.data['data'] ?? resp.data['Data'] ?? resp.data;
    if (raw == null) return 0;
    return (raw as int);
  }
}
