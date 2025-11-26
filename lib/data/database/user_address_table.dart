import 'package:drift/drift.dart';

class UserAddressTable extends Table {
  TextColumn get addressId => text()();
  TextColumn get provinceName => text()();
  TextColumn get districtName => text()();
  TextColumn get wardName => text()();
  TextColumn get streetAddress => text()();

  TextColumn get recipientName => text().nullable()();
  TextColumn get recipientPhone => text().nullable()();

  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  DateTimeColumn get createdAt => dateTime().nullable()();

  TextColumn get fullAddress => text()();

  @override
  Set<Column> get primaryKey => {addressId};
}
