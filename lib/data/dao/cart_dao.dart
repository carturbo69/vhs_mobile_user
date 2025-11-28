import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/database/app_database.dart';
import 'package:vhs_mobile_user/data/database/cart_table.dart';
import 'package:vhs_mobile_user/data/models/cart/cart_item_model.dart';

part 'cart_dao.g.dart';

@DriftAccessor(tables: [CartTable])
class CartDao extends DatabaseAccessor<AppDatabase> with _$CartDaoMixin {
  CartDao(AppDatabase db) : super(db);

  Future<List<CartTableData>> getAllCart() => select(cartTable).get();

  Stream<List<CartTableData>> watchCart() => select(cartTable).watch();

  Future<void> upsert(CartTableCompanion data) async {
    await into(cartTable).insertOnConflictUpdate(data);
  }

  Future<void> upsertMany(List<CartTableCompanion> items) async {
    await batch((b) => b.insertAllOnConflictUpdate(cartTable, items));
  }

  Future<void> deleteById(String id) async {
    await (delete(cartTable)..where((t) => t.cartItemId.equals(id))).go();
  }

  Future<void> clearAll() async {
    await delete(cartTable).go();
  }

  CartItemModel _mapRowToModel(CartTableData r) {
  final List<CartOptionModel> parsedOptions =
      r.optionsJson == null ? [] : (jsonDecode(r.optionsJson!) as List)
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

}

final cartDaoProvider = Provider<CartDao>((ref) {
  return CartDao(ref.read(appDatabaseProvider));
});
