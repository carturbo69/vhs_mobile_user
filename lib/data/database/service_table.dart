import 'package:drift/drift.dart';

@DataClassName('ServiceEntity')
class Services extends Table {
  TextColumn get serviceId => text()();
  TextColumn get providerId => text()();
  TextColumn get categoryId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  RealColumn get price => real()();
  TextColumn get unitType => text()();
  IntColumn get baseUnit => integer().nullable()();
  TextColumn get images => text().nullable()();
  RealColumn get averageRating => real().withDefault(const Constant(0.0))();
  IntColumn get totalReviews => integer().withDefault(const Constant(0))();
  TextColumn get categoryName => text().nullable()();

  @override
  Set<Column> get primaryKey => {serviceId};
}
