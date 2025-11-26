// history_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_item.dart';
import 'package:vhs_mobile_user/data/repositories/booking_repository.dart';
import 'package:vhs_mobile_user/helper/jwt_helper.dart';

final historyProvider = AsyncNotifierProvider<HistoryNotifier, List<BookingHistoryItem>>(() {
  return HistoryNotifier();
});

class HistoryNotifier extends AsyncNotifier<List<BookingHistoryItem>> {
  @override
  Future<List<BookingHistoryItem>> build() async {
    // Trả về empty list ban đầu, load sẽ được gọi từ screen
    return [];
  }

  Future<void> loadHistory() async {
    print('[HistoryNotifier] loadHistory() called');
    state = const AsyncLoading();
    try {
      // Lấy accountId từ auth
      final authDao = ref.read(authDaoProvider);
      final savedAuth = await authDao.getSavedAuth();
      
      print('[HistoryNotifier] savedAuth: ${savedAuth != null}');
      if (savedAuth != null) {
        print('[HistoryNotifier] savedAuth keys: ${savedAuth.keys}');
        print('[HistoryNotifier] savedAuth full content: $savedAuth');
        // Debug từng giá trị
        savedAuth.forEach((key, value) {
          print('[HistoryNotifier] $key: $value (type: ${value.runtimeType})');
        });
      }
      
      if (savedAuth == null) {
        print('[HistoryNotifier] No saved auth');
        state = const AsyncData([]);
        return;
      }

      // Lấy accountId từ savedAuth
      String? accountId = savedAuth['accountId'] as String?;
      print('[HistoryNotifier] accountId from savedAuth: "$accountId" (isNull: ${accountId == null}, isEmpty: ${accountId?.isEmpty ?? true})');
      
      // Nếu không có accountId trong database, thử lấy từ JWT token
      if (accountId == null || accountId.trim().isEmpty) {
        final token = savedAuth['token'] as String?;
        if (token != null && token.isNotEmpty) {
          print('[HistoryNotifier] Trying to get accountId from JWT token...');
          accountId = JwtHelper.getAccountIdFromToken(token);
          print('[HistoryNotifier] accountId from JWT: "$accountId"');
          
          // Nếu lấy được từ JWT, cập nhật lại database
          if (accountId != null && accountId.isNotEmpty) {
            print('[HistoryNotifier] Updating accountId in database...');
            final authDao = ref.read(authDaoProvider);
            await authDao.upsertLogin(
              token: token,
              role: savedAuth['role'] as String?,
              accountId: accountId,
            );
            print('[HistoryNotifier] Updated accountId in database');
          }
        }
      }
      
      if (accountId == null || accountId.trim().isEmpty) {
        print('[HistoryNotifier] AccountId is still null or empty - cannot load history');
        print('[HistoryNotifier] Please login again to save accountId');
        state = const AsyncData([]);
        return;
      }
      
      print('[HistoryNotifier] Loading history for accountId: $accountId');

      final repository = ref.read(bookingRepositoryProvider);
      print('[HistoryNotifier] Calling repository.getHistoryByAccount with accountId: $accountId');
      final items = await repository.getHistoryByAccount(accountId);
      print('[HistoryNotifier] Loaded ${items.length} items');
      
      if (items.isNotEmpty) {
        print('[HistoryNotifier] First item: ${items.first.serviceTitle}');
      }
      
      state = AsyncData(items);
    } catch (e, st) {
      print('[HistoryNotifier] Error loading history: $e');
      print('[HistoryNotifier] Error type: ${e.runtimeType}');
      print('[HistoryNotifier] Stack trace: $st');
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    await loadHistory();
  }
}

