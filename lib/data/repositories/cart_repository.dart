import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/dao/cart_dao.dart';
import 'package:vhs_mobile_user/data/database/app_database.dart';
import 'package:vhs_mobile_user/data/models/cart/cart_item_model.dart';
import 'package:vhs_mobile_user/data/models/cart/add_cart_item_request.dart';
import 'package:drift/drift.dart';
import 'package:vhs_mobile_user/data/services/cart_api.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(
    api: ref.read(cartApiProvider),
    authDao: ref.read(authDaoProvider),
    dao: ref.read(cartDaoProvider),
  );
});

class CartRepository {
  final CartApi api;
  final AuthDao authDao;
  final CartDao dao;

  CartRepository({
    required this.api,
    required this.authDao,
    required this.dao,
  });

  // ============================================================
  // FETCH REMOTE + CACHE LOCAL
  // ============================================================
  Future<List<CartItemModel>> fetchRemote() async {
    final auth = await authDao.getSavedAuth();
    final accountId = auth?["accountId"];
    if (accountId == null) return [];

    final items = await api.getCartItems(accountId);

    // Convert → drift
    final companions = items.map((i) {
      return CartTableCompanion(
        cartItemId: Value(i.cartItemId),
        cartId: Value(i.cartId),
        serviceId: Value(i.serviceId),
        createdAt: Value(i.createdAt.toIso8601String()),
        serviceName: Value(i.serviceName),
        servicePrice: Value(i.servicePrice),
        serviceImages: Value(i.serviceImages.join(",")),
        providerId: Value(i.providerId),
        providerName: Value(i.providerName),
        providerImages: Value(i.providerImages),

        // ⭐ LƯU OPTIONS DƯỚI DẠNG JSON STRING ⭐
        optionsJson: Value(
          jsonEncode(i.options.map((e) => e.toJson()).toList()),
        ),

        quantity: Value(i.quantity),
      );
    }).toList();

    await dao.clearAll();
    await dao.upsertMany(companions);

    return items;
  }

  // ============================================================
  // READ LOCAL
  // ============================================================
  Future<List<CartItemModel>> readLocal() async {
    final rows = await dao.getAllCart();
    return rows.map(_rowToModel).toList();
  }

  // ============================================================
  // WATCH LOCAL STREAM
  // ============================================================
  Stream<List<CartItemModel>> watchLocal() {
    return dao.watchCart().map(
      (rows) => rows.map(_rowToModel).toList(),
    );
  }

  // ============================================================
  // MAP DRIFT ROW → MODEL
  // ============================================================
  CartItemModel _rowToModel(CartTableData r) {
    final List<CartOptionModel> parsedOptions =
        r.optionsJson == null
            ? []
            : (jsonDecode(r.optionsJson!) as List)
                .map((e) => CartOptionModel.fromJson(e))
                .toList();

    return CartItemModel(
      cartItemId: r.cartItemId,
      cartId: r.cartId,
      serviceId: r.serviceId,
      createdAt: DateTime.parse(r.createdAt),
      serviceName: r.serviceName,
      servicePrice: r.servicePrice,
      serviceImages: r.serviceImages.split(","),
      providerId: r.providerId,
      providerName: r.providerName,
      providerImages: r.providerImages,
      options: parsedOptions,
      quantity: r.quantity,
    );
  }

  // ============================================================
  // ADD TO CART (API)
  // ============================================================
  Future<void> addToCart(AddCartItemRequest req) async {
    final auth = await authDao.getSavedAuth();
    final accountId = auth?["accountId"];
    if (accountId == null) {
      throw Exception("User chưa đăng nhập");
    }

    await api.addCartItem(
      accountId: accountId,
      request: req,
    );

    await fetchRemote();
  }

  // ============================================================
  // REMOVE ONE ITEM
  // ============================================================
  Future<void> removeItem(String id) async {
    final auth = await authDao.getSavedAuth();
    final accountId = auth?["accountId"];

    await api.removeCartItem(accountId, id);
    await dao.deleteById(id);
  }

  // ============================================================
  // CLEAR ALL ITEMS
  // ============================================================
  Future<void> clearAll() async {
    final auth = await authDao.getSavedAuth();
    final accountId = auth?["accountId"];

    await api.clearCart(accountId);
    await dao.clearAll();
  }

  // ============================================================
  // UPDATE QUANTITY LOCAL ONLY
  // ============================================================
  Future<void> updateQuantityLocal(String id, int qty) async {
    final rows = await dao.getAllCart();
    final r = rows.firstWhere((x) => x.cartItemId == id);

    final updated = CartTableCompanion(
      cartItemId: Value(r.cartItemId),
      cartId: Value(r.cartId),
      serviceId: Value(r.serviceId),
      createdAt: Value(r.createdAt),
      serviceName: Value(r.serviceName),
      servicePrice: Value(r.servicePrice),
      serviceImages: Value(r.serviceImages),
      providerId: Value(r.providerId),
      providerName: Value(r.providerName),
      providerImages: Value(r.providerImages),
      optionsJson: Value(r.optionsJson),
      quantity: Value(qty),
    );

    await dao.upsert(updated);
  }
}
