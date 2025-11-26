// booking_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_item.dart';
import 'package:vhs_mobile_user/data/services/booking_api.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final api = ref.read(bookingApiProvider);
  return BookingRepository(api);
});

class BookingRepository {
  final BookingApi _api;

  BookingRepository(this._api);

  /// Lấy danh sách lịch sử đơn hàng
  Future<List<BookingHistoryItem>> getHistoryByAccount(String accountId) async {
    final response = await _api.getHistoryByAccount(accountId);
    return response.items;
  }
}

