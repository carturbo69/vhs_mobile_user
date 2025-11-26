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
  /// Lấy danh sách lịch sử đơn hàng theo accountId
  Future<BookingHistoryListResponse> getHistoryByAccount(String accountId) async {
    try {
      final url = '/api/Bookings/by-account/$accountId';
      print('[BookingApi] Calling URL: $url');
      print('[BookingApi] AccountId: $accountId');
      
      final resp = await _dio.get(url);
      print('[BookingApi] Response status: ${resp.statusCode}');
      
      if (resp.statusCode == 200) {
        print('[BookingApi] Response data type: ${resp.data.runtimeType}');
        final data = resp.data as Map<String, dynamic>;
        print('[BookingApi] Response has items: ${data.containsKey('items')}');
        if (data.containsKey('items')) {
          print('[BookingApi] Items count: ${(data['items'] as List?)?.length ?? 0}');
        }
        return BookingHistoryListResponse.fromJson(data);
      } else {
        throw Exception('Failed to load booking history: ${resp.statusCode}');
      }
    } on DioException catch (e) {
      print('[BookingApi] DioException: ${e.type}');
      print('[BookingApi] Status code: ${e.response?.statusCode}');
      print('[BookingApi] Error message: ${e.message}');
      if (e.response != null) {
        print('[BookingApi] Response data: ${e.response?.data}');
      }
      
      if (e.response?.statusCode == 404) {
        // Nếu 404, có thể là chưa có đơn hàng nào, trả về danh sách rỗng
        print('[BookingApi] 404 - No bookings found, returning empty list');
        return BookingHistoryListResponse(items: []);
      }
      rethrow;
    } catch (e, st) {
      print('[BookingApi] Unexpected error: $e');
      print('[BookingApi] Stack trace: $st');
      rethrow;
    }
  }
}
