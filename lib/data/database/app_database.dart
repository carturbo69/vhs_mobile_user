import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/dao/profile_dao.dart';
import 'package:vhs_mobile_user/data/dao/service_dao.dart';
import 'package:vhs_mobile_user/data/dao/user_address_dao.dart';
import 'package:vhs_mobile_user/data/database/auth_table.dart';
import 'package:vhs_mobile_user/data/database/profile_table.dart';
import 'package:vhs_mobile_user/data/database/user_address_table.dart';
import 'service_table.dart';
import 'database_connection.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [ServicesTable, AuthsTable, ProfileTable, UserAddressTable],
  daos: [ServicesDao, AuthDao, ProfileDao, UserAddressDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from == 3) {
        await m.createTable(userAddressTable);
      }
    },
  );
}

// AppDatabase provider (drift) - you must have it in your app
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  return db;
});
