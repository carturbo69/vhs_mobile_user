// service_table.dart
import 'package:drift/drift.dart';

class ServicesTable extends Table {
  TextColumn get serviceId => text()();
  TextColumn get providerId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  RealColumn get price => real().withDefault(const Constant(0.0))();
  TextColumn get unitType => text().nullable()();
  IntColumn get baseUnit => integer().nullable()();
  TextColumn get images => text().nullable()(); // CSV saved as string
  DateTimeColumn get createdAt => dateTime().nullable()();
  TextColumn get status => text().nullable()();
  BoolColumn get deleted => boolean().nullable()();
  RealColumn get averageRating => real().withDefault(const Constant(0.0))();
  IntColumn get totalReviews => integer().withDefault(const Constant(0))();
  TextColumn get categoryName => text().nullable()();
  TextColumn get providerName => text().nullable()();
  TextColumn get jsonOptions => text().nullable()(); // store List<ServiceOption> as JSON

  @override
  Set<Column> get primaryKey => {serviceId};
}
