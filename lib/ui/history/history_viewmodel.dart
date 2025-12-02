// history_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_item.dart';
import 'package:vhs_mobile_user/data/repositories/booking_history_repository.dart';
import 'package:vhs_mobile_user/data/repositories/booking_repository.dart';
import 'package:vhs_mobile_user/helper/jwt_helper.dart';

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<BookingHistoryItem>>(
      HistoryNotifier.new,
    );

class HistoryNotifier extends AsyncNotifier<List<BookingHistoryItem>> {
  @override
  Future<List<BookingHistoryItem>> build() async {
    return []; // UI sẽ gọi loadHistory()
  }

  Future<void> loadHistory() async {
    state = const AsyncLoading();
    try {
      final authDao = ref.read(authDaoProvider);
      final saved = await authDao.getSavedAuth();
      final accountId = saved?["accountId"];

      if (accountId == null || accountId.isEmpty) {
        state = const AsyncData([]);
        return;
      }

      final repo = ref.read(bookingHistoryRepositoryProvider);
      final items = await repo.loadHistory(accountId);

      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    await loadHistory();
  }

  Future<Map<String, dynamic>> cancelBooking(String bookingId, String reason) async {
    try {
      final authDao = ref.read(authDaoProvider);
      final saved = await authDao.getSavedAuth();
      final accountId = saved?["accountId"];

      if (accountId == null || accountId.isEmpty) {
        return {'success': false, 'message': 'Không tìm thấy thông tin tài khoản'};
      }

      final bookingRepo = ref.read(bookingRepositoryProvider);
      await bookingRepo.cancelBooking(bookingId, accountId, reason);
      
      // Refresh history after canceling - chỉ refresh 1 lần
      // Sử dụng loadHistory() trực tiếp thay vì refresh() để tránh duplicate calls
      try {
        final repo = ref.read(bookingHistoryRepositoryProvider);
        final items = await repo.loadHistory(accountId);
        state = AsyncData(items);
      } catch (e) {
        // Nếu refresh lỗi, vẫn trả về success vì đã hủy thành công
        print('Error refreshing history after cancel: $e');
      }
      
      return {'success': true, 'message': 'Đã hủy đơn hàng thành công'};
    } catch (e) {
      print('Error canceling booking: $e');
      String errorMessage = 'Không thể hủy đơn hàng';
      
      if (e.toString().contains('404')) {
        errorMessage = 'Không tìm thấy endpoint hủy đơn hàng. Vui lòng liên hệ hỗ trợ.';
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMessage = 'Bạn không có quyền hủy đơn hàng này';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Dữ liệu không hợp lệ. Vui lòng thử lại.';
      } else if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        errorMessage = 'Kết nối timeout. Vui lòng kiểm tra mạng và thử lại.';
      }
      
      return {'success': false, 'message': errorMessage};
    }
  }
}
