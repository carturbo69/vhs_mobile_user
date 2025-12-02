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
    
    // Sắp xếp theo thời gian tạo (createdAt) từ mới nhất đến cũ nhất
    // Nếu createdAt null thì dùng bookingTime
    items.sort((a, b) {
      final aTime = a.createdAt ?? a.bookingTime;
      final bTime = b.createdAt ?? b.bookingTime;
      return bTime.compareTo(aTime); // Giảm dần (mới nhất trước)
    });
    
    // save to local
    await dao.upsertMany(items);

    // read local và sắp xếp lại
    final localItems = await dao.readAll();
    localItems.sort((a, b) {
      final aTime = a.createdAt ?? a.bookingTime;
      final bTime = b.createdAt ?? b.bookingTime;
      return bTime.compareTo(aTime); // Giảm dần (mới nhất trước)
    });
    
    return localItems;
  }

  // -------- GET DETAIL (always remote) ---------
  Future<HistoryBookingDetail> getDetail(String bookingId) async {
    final auth = await authDao.getSavedAuth();
    final accountId = auth?["accountId"];
    return api.getDetail(accountId, bookingId);
  }
}
