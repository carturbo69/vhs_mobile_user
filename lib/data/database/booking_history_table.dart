
import 'package:drift/drift.dart';

class BookingHistoryTable extends Table {
  TextColumn get bookingId => text()();
  TextColumn get json => text()(); // store full JSON
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {bookingId};
}
