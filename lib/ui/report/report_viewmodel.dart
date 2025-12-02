import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:vhs_mobile_user/data/repositories/report_repository.dart';
import 'package:vhs_mobile_user/data/models/report/report_models.dart';

final reportViewModelProvider =
    StateNotifierProvider<ReportViewModel, AsyncValue<void>>((ref) {
  return ReportViewModel(ref.read(reportRepositoryProvider));
});

class ReportViewModel extends StateNotifier<AsyncValue<void>> {
  final ReportRepository _repository;

  ReportViewModel(this._repository) : super(const AsyncData(null));

  Future<ReadReportDTO?> submitReport(CreateReportDTO dto) async {
    state = const AsyncLoading();
    try {
      final result = await _repository.createReport(dto);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

// Provider để lấy report theo bookingId
final reportByBookingIdProvider = FutureProvider.family<ReadReportDTO?, String>((ref, bookingId) async {
  final repository = ref.read(reportRepositoryProvider);
  return await repository.getReportByBookingId(bookingId);
});

// Provider để lấy report theo reportId
final reportByIdProvider = FutureProvider.family<ReadReportDTO, String>((ref, reportId) async {
  final repository = ref.read(reportRepositoryProvider);
  return await repository.getReportById(reportId);
});

