import 'package:drift/drift.dart';

class ProfileTable extends Table {
  TextColumn get userId => text()();
  TextColumn get accountId => text()();
  TextColumn get accountName => text()();
  TextColumn get email => text()();
  TextColumn get role => text()();
  TextColumn get fullName => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get images => text().nullable()();
  TextColumn get address => text().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}
