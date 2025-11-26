import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/database/user_address_table.dart';
import 'package:vhs_mobile_user/data/database/app_database.dart';
import 'package:drift/drift.dart';

part 'user_address_dao.g.dart';

@DriftAccessor(tables: [UserAddressTable])
class UserAddressDao extends DatabaseAccessor<AppDatabase>
    with _$UserAddressDaoMixin {
  UserAddressDao(AppDatabase db) : super(db);

  Future<List<UserAddressTableData>> getAll() {
    return select(userAddressTable).get();
  }

  Future<void> saveAll(List<UserAddressTableCompanion> items) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(userAddressTable, items);
    });
  }

  Future<void> deleteById(String id) async {
    await (delete(userAddressTable)
          ..where((tbl) => tbl.addressId.equals(id)))
        .go();
  }

  Future<void> clear() async {
    await delete(userAddressTable).go();
  }
}
final userAddressDaoProvider = Provider<UserAddressDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UserAddressDao(db);
});