import 'package:drift/drift.dart';

class CartTable extends Table {
  TextColumn get cartItemId => text()();
  TextColumn get cartId => text()();
  TextColumn get serviceId => text()();
  TextColumn get createdAt => text()();
  TextColumn get serviceName => text()();
  RealColumn get servicePrice => real()();
  TextColumn get serviceImages => text()();
  TextColumn get providerId => text()();
  TextColumn get providerName => text()();
  TextColumn get providerImages => text()();
  TextColumn get optionsJson => text().nullable()();
  IntColumn get quantity => integer().withDefault(Constant(1))();

  @override
  Set<Column> get primaryKey => {cartItemId};
}
