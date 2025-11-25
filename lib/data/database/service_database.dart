import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/dao/service_dao.dart';
import 'package:vhs_mobile_user/data/database/auth_table.dart';
import 'package:vhs_mobile_user/data/models/service/service_model.dart';
import 'service_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'service_database.g.dart';

@DriftDatabase(
  tables: [ServicesTable, AuthsTable],
  daos: [ServicesDao, AuthDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from == 1) {
        await m.createTable(authsTable);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'VHSUserDatabase.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// AppDatabase provider (drift) - you must have it in your app
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  return db;
});
