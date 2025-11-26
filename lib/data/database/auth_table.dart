// lib/data/local/auth_table.dart
import 'package:drift/drift.dart';

class AuthsTable extends Table {
  TextColumn get id => text().clientDefault(() => 'auth')(); // single row
  TextColumn get token => text().nullable()();
  TextColumn get role => text().nullable()();
  TextColumn get accountId => text().nullable()();
  DateTimeColumn get savedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
