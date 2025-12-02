import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/network/dio_client.dart';
import 'package:vhs_mobile_user/data/models/report/report_models.dart';

final reportApiProvider = Provider<ReportApi>((ref) {
  return ReportApi(ref.read(dioClientProvider).instance);
});

class ReportApi {
  final Dio _dio;
  ReportApi(this._dio);

  // POST /api/Reports với multipart/form-data
  Future<ReadReportDTO> createReport({
    required String accountId,
    required CreateReportDTO dto,
  }) async {
    try {
      final formData = FormData.fromMap({
        'BookingId': dto.bookingId,
        'ReportType': dto.reportType.value,
        'Title': dto.title,
        if (dto.description != null && dto.description!.isNotEmpty) 'Description': dto.description,
        if (dto.providerId != null) 'ProviderId': dto.providerId,
        // Thông tin ngân hàng cho yêu cầu hoàn tiền
        if (dto.bankName != null && dto.bankName!.isNotEmpty) 'BankName': dto.bankName,
        if (dto.accountHolderName != null && dto.accountHolderName!.isNotEmpty) 'AccountHolderName': dto.accountHolderName,
        if (dto.bankAccountNumber != null && dto.bankAccountNumber!.isNotEmpty) 'BankAccountNumber': dto.bankAccountNumber,
      });

      // Thêm ảnh nếu có
      if (dto.imagePaths != null && dto.imagePaths!.isNotEmpty) {
        for (var path in dto.imagePaths!) {
          formData.files.add(MapEntry(
            'Attachments',
            await MultipartFile.fromFile(path),
          ));
        }
      }

      final resp = await _dio.post(
        '/api/Reports',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return ReadReportDTO.fromJson(resp.data);
    } on DioException catch (e) {
      debugPrint("Error creating report: $e");
      rethrow;
    }
  }

  // GET /api/Reports/by-booking/{bookingId}
  Future<ReadReportDTO?> getReportByBookingId(String bookingId) async {
    try {
      final resp = await _dio.get('/api/Reports/by-booking/$bookingId');
      
      if (resp.data['hasReport'] == true && resp.data['report'] != null) {
        return ReadReportDTO.fromJson(resp.data['report']);
      }
      
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      debugPrint("Error getting report by booking ID: $e");
      rethrow;
    }
  }

  // GET /api/Reports/{id}
  Future<ReadReportDTO> getReportById(String reportId) async {
    try {
      final resp = await _dio.get('/api/Reports/$reportId');
      return ReadReportDTO.fromJson(resp.data);
    } on DioException catch (e) {
      debugPrint("Error getting report by ID: $e");
      rethrow;
    }
  }
}

