import 'package:drift/drift.dart';

class AppSettingsTable extends Table {
  TextColumn get id => text().clientDefault(() => 'settings')(); // single row
  TextColumn get themeMode => text().withDefault(const Constant('light'))(); // 'light', 'dark', 'system'
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

