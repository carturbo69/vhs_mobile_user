import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/database/app_database.dart';
import 'package:vhs_mobile_user/data/database/cart_table.dart';

part 'cart_dao.g.dart';

@DriftAccessor(tables: [CartTable])
class CartDao extends DatabaseAccessor<AppDatabase> with _$CartDaoMixin {
  CartDao(AppDatabase db) : super(db);

  Future<List<CartTableData>> getAllCartItems() {
    return select(cartTable).get();
  }

  Stream<List<CartTableData>> watchAll() {
    return select(cartTable).watch();
  }

  Future<void> upsertCartItem(CartTableCompanion companion) async {
    await into(cartTable).insertOnConflictUpdate(companion);
  }

  Future<void> upsertMany(List<CartTableCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(cartTable, items);
    });
  }

  Future<void> deleteById(String id) async {
    await (delete(cartTable)..where((t) => t.cartItemId.equals(id))).go();
  }

  Future<void> clear() async {
    await delete(cartTable).go();
  }
}

final cartDaoProvider = Provider<CartDao>((ref) {
  final db = ref.read(appDatabaseProvider);
  return CartDao(db);
});
