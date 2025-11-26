import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/dao/cart_dao.dart';
import 'package:vhs_mobile_user/data/database/app_database.dart';
import 'package:vhs_mobile_user/data/models/cart/add_cart_item_request.dart';
import 'package:vhs_mobile_user/data/models/cart/cart_item_model.dart';
import 'package:drift/drift.dart';
import 'package:vhs_mobile_user/data/services/cart_api.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(
    api: ref.read(cartApiProvider),
    dao: ref.read(cartDaoProvider),
    authDao: ref.read(authDaoProvider),
  );
});

class CartRepository {
  final CartApi api;
  final CartDao dao;
  final AuthDao authDao;

  CartRepository({
    required this.api,
    required this.dao,
    required this.authDao,
  });

  Future<List<CartItemModel>> fetchRemote() async {
    final saved = await authDao.getSavedAuth();
    final accountId = saved?['accountId'];
    if (accountId == null) return [];
    final list = await api.getCartItems(accountId.toString());
    // cache to drift
    await dao.clear();
    if (list.isNotEmpty) {
      final companions = list.map((e) => CartTableCompanion(
            cartItemId: Value(e.cartItemId),
            serviceId: Value(e.serviceId),
            serviceName: Value(e.serviceName),
            providerId: Value(e.providerId),
            providerName: Value(e.providerName),
            price: Value(e.price),
            quantity: Value(e.quantity),
            imageUrl: Value(e.imageUrl),
            optionsJson: Value(e.cartItemOptionsJson),
          )).toList();
      await dao.upsertMany(companions);
    }
    return list;
  }

  Future<List<CartItemModel>> readLocal() async {
    final rows = await dao.getAllCartItems();
    return rows.map((r) => CartItemModel(
      cartItemId: r.cartItemId,
      serviceId: r.serviceId,
      serviceName: r.serviceName,
      providerId: r.providerId,
      providerName: r.providerName,
      price: r.price,
      quantity: r.quantity,
      imageUrl: r.imageUrl,
      cartItemOptionsJson: r.optionsJson,
    )).toList();
  }

  Stream<List<CartItemModel>> watchLocal() {
    return dao.watchAll().map((rows) => rows.map((r) => CartItemModel(
      cartItemId: r.cartItemId,
      serviceId: r.serviceId,
      serviceName: r.serviceName,
      providerId: r.providerId,
      providerName: r.providerName,
      price: r.price,
      quantity: r.quantity,
      imageUrl: r.imageUrl,
      cartItemOptionsJson: r.optionsJson,
    )).toList());
  }

  Future<void> addToCart(AddCartItemRequest payload) async {
    final saved = await authDao.getSavedAuth();
    final accountId = saved?['accountId'];
    if (accountId == null) throw Exception('No accountId');
    final body = payload.toJson();
    body['accountId'] = accountId;
    await api.addCartItem(body);
    // refresh remote -> update local cache
    await fetchRemote();
  }

  Future<void> removeItem(String id) async {
    final saved = await authDao.getSavedAuth();
    final accountId = saved?['accountId'];
    if (accountId == null) return;
    await api.removeCartItem(accountId.toString(), id);
    await dao.deleteById(id);
  }

  Future<void> clearAll() async {
    final saved = await authDao.getSavedAuth();
    final accountId = saved?['accountId'];
    if (accountId == null) return;
    await api.clearCart(accountId.toString());
    await dao.clear();
  }

  Future<int> totalCount() async {
    final saved = await authDao.getSavedAuth();
    final accountId = saved?['accountId'];
    if (accountId == null) return 0;
    return await api.getTotalCount(accountId.toString());
  }

  Future<void> updateQuantityLocal(String cartItemId, int qty) async {
    final row = await (dao.db.select(dao.db.cartTable)..where((t) => t.cartItemId.equals(cartItemId))).getSingleOrNull();
    if (row == null) return;
    final companion = CartTableCompanion(
      cartItemId: Value(row.cartItemId),
      serviceId: Value(row.serviceId),
      serviceName: Value(row.serviceName),
      providerId: Value(row.providerId),
      providerName: Value(row.providerName),
      price: Value(row.price),
      quantity: Value(qty),
      imageUrl: Value(row.imageUrl),
      optionsJson: Value(row.optionsJson),
    );
    await dao.upsertCartItem(companion);
  }
}
