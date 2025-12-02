import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/network/dio_client.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_item.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_result_model.dart';

final bookingApiProvider = Provider<BookingApi>((ref) {
  return BookingApi(ref.read(dioClientProvider).instance);
});

class BookingApi {
  final Dio _dio;
  BookingApi(this._dio);

  // POST /api/bookings/create-many
  Future<BookingResultModel> createMany(Map<String, dynamic> payload) async {
    final resp = await _dio.post('/api/bookings/create-many', data: payload);
    final raw = resp.data['data'] ?? resp.data['Data'] ?? resp.data;
    // map response to BookingResultModel (assume backend returns bookingIds and breakdown)
    return BookingResultModel.fromJson(raw);
  }

  // GET /api/Bookings/provider/{providerId}/term-of-service
  Future<Map<String, dynamic>?> getTermOfServiceByProviderId(String providerId) async {
    try {
      final resp = await _dio.get('/api/Bookings/provider/$providerId/term-of-service');
      if (resp.statusCode == 200) {
        return resp.data as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      // 404 hoặc lỗi khác - trả về null
      return null;
    }
  }

  // Confirm service completed - POST /api/Bookings/{bookingId}/confirm-completed?accountId={accountId}
  Future<bool> confirmServiceCompleted(String bookingId, String accountId) async {
    try {
      final resp = await _dio.post(
        '/api/Bookings/$bookingId/confirm-completed',
        queryParameters: {'accountId': accountId},
      );
      return resp.data['success'] == true || resp.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  // Cancel booking - sử dụng endpoint giống frontend: POST /api/Bookings/cancel-with-refund
  Future<void> cancelBooking(String bookingId, String accountId, String reason) async {
    // Endpoint giống frontend: POST /api/Bookings/cancel-with-refund
    // Request body cần có: BookingId, CancelReason/Reason, BankName, BankAccount/BankAccountNumber, AccountHolderName
    final payload = {
      'BookingId': bookingId,
      'CancelReason': reason,
      'Reason': reason, // Gửi cả 2 field để đảm bảo backend nhận được
      'BankName': 'N/A', // Giá trị mặc định (frontend cũng dùng 'N/A' cho hủy đơn đơn giản)
      'BankAccount': 'N/A', // Giá trị mặc định
      'BankAccountNumber': 'N/A', // Giá trị mặc định
      'AccountHolderName': 'N/A', // Giá trị mặc định
    };

    try {
      await _dio.post(
        '/api/Bookings/cancel-with-refund',
        data: payload,
      );
      return; // Thành công
    } on DioException catch (e) {
      // Nếu có lỗi, throw với message rõ ràng
      if (e.response?.statusCode == 404) {
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          error: 'Không tìm thấy endpoint để hủy đơn hàng. Vui lòng liên hệ hỗ trợ.',
        );
      }
      rethrow;
    }
  }
 
}
