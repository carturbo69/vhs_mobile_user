import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/services/report_api.dart';
import 'package:vhs_mobile_user/data/models/report/report_models.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(
    api: ref.read(reportApiProvider),
    authDao: ref.read(authDaoProvider),
  );
});

class ReportRepository {
  final ReportApi api;
  final AuthDao authDao;

  ReportRepository({required this.api, required this.authDao});

  Future<ReadReportDTO> createReport(CreateReportDTO dto) async {
    final saved = await authDao.getSavedAuth();
    final accountId = saved?['accountId'];
    if (accountId == null) throw Exception("Missing accountId");

    return await api.createReport(
      accountId: accountId,
      dto: dto,
    );
  }

  Future<ReadReportDTO?> getReportByBookingId(String bookingId) async {
    return await api.getReportByBookingId(bookingId);
  }

  Future<ReadReportDTO> getReportById(String reportId) async {
    return await api.getReportById(reportId);
  }
}

