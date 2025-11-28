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
}
