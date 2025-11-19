import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:vhs_mobile_user/data/dao/service_dao.dart';
import 'service_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'service_database.g.dart';

@DriftDatabase(tables: [Services], daos: [ServiceDao])
class ServiceDatabase extends _$ServiceDatabase {
  ServiceDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'service_cache.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
