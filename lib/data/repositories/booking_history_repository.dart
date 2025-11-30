import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/dao/booking_history_dao.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_detail_model.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_item.dart';
import 'package:vhs_mobile_user/data/services/booking_history_api.dart';

final bookingHistoryRepositoryProvider = Provider((ref) {
  return BookingHistoryRepository(
    api: ref.read(bookingHistoryApiProvider),
    dao: ref.read(bookingHistoryDaoProvider),
    authDao: ref.read(authDaoProvider),
  );
});

class BookingHistoryRepository {
  final BookingHistoryApi api;
  final BookingHistoryDao dao;
  final AuthDao authDao;

  BookingHistoryRepository({
    required this.api,
    required this.dao,
    required this.authDao,
  });

  // -------- GET LIST (remote + local) ---------
  Future<List<BookingHistoryItem>> loadHistory(String accountId) async {
    // fetch remote
    final remote = await api.getHistoryByAccount(accountId);
    var items = remote.items;
    // save to local
    await dao.upsertMany(items);

    // read local
    return dao.readAll();
  }

  // -------- GET DETAIL (always remote) ---------
  Future<HistoryBookingDetail> getDetail(String bookingId) async {
    final auth = await authDao.getSavedAuth();
    final accountId = auth?["accountId"];
    return api.getDetail(accountId, bookingId);
  }
}
