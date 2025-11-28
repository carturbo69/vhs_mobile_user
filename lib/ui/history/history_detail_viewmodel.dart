import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_detail_model.dart';
import 'package:vhs_mobile_user/data/repositories/booking_history_repository.dart';

final historyDetailProvider = FutureProvider.family<
    HistoryBookingDetail, String>((ref, bookingId) async {
  final repo = ref.read(bookingHistoryRepositoryProvider);
  return repo.getDetail(bookingId);
});