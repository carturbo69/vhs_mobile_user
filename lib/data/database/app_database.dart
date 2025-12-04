import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vhs_mobile_user/data/dao/app_settings_dao.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/dao/booking_history_dao.dart';
import 'package:vhs_mobile_user/data/dao/cart_dao.dart';
import 'package:vhs_mobile_user/data/dao/profile_dao.dart';
import 'package:vhs_mobile_user/data/dao/service_dao.dart';
import 'package:vhs_mobile_user/data/dao/user_address_dao.dart';
import 'package:vhs_mobile_user/data/database/app_settings_table.dart';
import 'package:vhs_mobile_user/data/database/auth_table.dart';
import 'package:vhs_mobile_user/data/database/booking_history_table.dart';
import 'package:vhs_mobile_user/data/database/cart_table.dart';
import 'package:vhs_mobile_user/data/database/profile_table.dart';
import 'package:vhs_mobile_user/data/database/user_address_table.dart';
import 'service_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [ServicesTable, AuthsTable, ProfileTable, UserAddressTable, CartTable, BookingHistoryTable, AppSettingsTable],
  daos: [ServicesDao, AuthDao, ProfileDao, UserAddressDao, CartDao, BookingHistoryDao, AppSettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from == 5) {
        await m.createTable(bookingHistoryTable);
      }
      if (from == 6) {
        await m.createTable(appSettingsTable);
      }
    },
  );

  /// Xóa database file
  static Future<void> deleteDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'VietHomeServiceUsersDatabase.sqlite'));

    if (await file.exists()) {
      await file.delete();
    }
  }
}
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'VietHomeServiceUsersDatabase.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}


// AppDatabase provider (drift) - you must have it in your app
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
