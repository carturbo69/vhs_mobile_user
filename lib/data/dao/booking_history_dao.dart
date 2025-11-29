import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/database/app_database.dart';
import 'package:vhs_mobile_user/data/database/booking_history_table.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_item.dart';

part 'booking_history_dao.g.dart';

@DriftAccessor(tables: [BookingHistoryTable])
class BookingHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$BookingHistoryDaoMixin {
  BookingHistoryDao(AppDatabase db) : super(db);

  Future<void> upsertMany(List<BookingHistoryItem> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        bookingHistoryTable,
        items.map((e) {
          return BookingHistoryTableCompanion(
            bookingId: Value(e.bookingId),
            json: Value(jsonEncode(e.toJson())),
            createdAt: Value(
              e.createdAt ?? DateTime.now().add(Duration(hours: 7)),
            ),
          );
        }).toList(),
      );
    });
  }

  Future<List<BookingHistoryItem>> readAll() async {
    final rows = await select(bookingHistoryTable).get();
    return rows.map((r) {
      return BookingHistoryItem.fromJson(jsonDecode(r.json));
    }).toList();
  }
}

final bookingHistoryDaoProvider = Provider<BookingHistoryDao>((ref) {
  return BookingHistoryDao(ref.read(appDatabaseProvider));
});
