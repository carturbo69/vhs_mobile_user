import 'package:drift/drift.dart';

class CartTable extends Table {
  TextColumn get cartItemId => text()();
  TextColumn get serviceId => text()();
  TextColumn get serviceName => text()();
  TextColumn get providerId => text().nullable()();
  TextColumn get providerName => text().nullable()();
  RealColumn get price => real()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get optionsJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {cartItemId};
}
