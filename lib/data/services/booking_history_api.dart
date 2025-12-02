import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/network/dio_client.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_detail_model.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_item.dart';

final bookingHistoryApiProvider = Provider<BookingHistoryApi>((ref) {
  return BookingHistoryApi(ref.read(dioClientProvider).instance);
});


class BookingHistoryApi {
  final Dio _dio;
  BookingHistoryApi(this._dio);

  /// Lấy danh sách lịch sử đơn hàng theo accountId
  Future<BookingHistoryListResponse> getHistoryByAccount(
    String accountId,
  ) async {
    try {
      final url = '/api/Bookings/by-account/$accountId';
      print('[BookingApi] Calling URL: $url');
      print('[BookingApi] AccountId: $accountId');

      final resp = await _dio.get(url);
      print('[BookingApi] Response status: ${resp.statusCode}');

      if (resp.statusCode == 200) {
        print('[BookingApi] Response data type: ${resp.data.runtimeType}');
        
        // Xử lý nhiều định dạng response
        List<dynamic>? itemsList;
        
        if (resp.data is List) {
          // Trường hợp 1: Response là List trực tiếp
          print('[BookingApi] Response is a List directly');
          itemsList = resp.data as List<dynamic>;
        } else if (resp.data is Map<String, dynamic>) {
          // Trường hợp 2: Response là Map
          final data = resp.data as Map<String, dynamic>;
          print('[BookingApi] Response is a Map');
          print('[BookingApi] Response keys: ${data.keys.toList()}');
          
          // Thử lấy từ field "Items" (PascalCase - theo backend DTO)
          if (data.containsKey('Items') && data['Items'] is List) {
            print('[BookingApi] Found Items field (PascalCase)');
            itemsList = data['Items'] as List<dynamic>;
          }
          // Thử lấy từ field "items" (camelCase)
          else if (data.containsKey('items') && data['items'] is List) {
            print('[BookingApi] Found items field (camelCase)');
            itemsList = data['items'] as List<dynamic>;
          }
          // Thử lấy từ field "data"
          else if (data.containsKey('data') && data['data'] is List) {
            print('[BookingApi] Found data field');
            itemsList = data['data'] as List<dynamic>;
          }
          // Thử lấy từ field "Data" (PascalCase)
          else if (data.containsKey('Data') && data['Data'] is List) {
            print('[BookingApi] Found Data field (PascalCase)');
            itemsList = data['Data'] as List<dynamic>;
          }
          // Nếu không có field nào, có thể toàn bộ Map là một item duy nhất
          else {
            print('[BookingApi] No items/data field found, treating entire response as single item');
            itemsList = [data];
          }
        }
        
        if (itemsList != null) {
          print('[BookingApi] Items count: ${itemsList.length}');
          
          // Parse từng item
          final parsedItems = <BookingHistoryItem>[];
          for (var i = 0; i < itemsList.length; i++) {
            try {
              final item = itemsList[i] as Map<String, dynamic>;
              final parsed = BookingHistoryItem.fromJson(item);
              parsedItems.add(parsed);
              print('[BookingApi] Item $i: bookingId=${parsed.bookingId}, status=${parsed.status}');
            } catch (e, st) {
              print('[BookingApi] Error parsing item $i: $e');
              print('[BookingApi] Item data: ${itemsList[i]}');
              // Bỏ qua item lỗi và tiếp tục với item khác
            }
          }
          
          print('[BookingApi] Successfully parsed ${parsedItems.length} out of ${itemsList.length} items');
          return BookingHistoryListResponse(items: parsedItems);
        } else {
          print('[BookingApi] Could not parse response, returning empty list');
          print('[BookingApi] Response data: ${resp.data}');
          return BookingHistoryListResponse(items: []);
        }
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
   Future<HistoryBookingDetail> getDetail(String accountId, String bookingId) async {
    final res = await _dio.get(
      "/api/bookings/by-account/$accountId/bookings/$bookingId",
    );
    return HistoryBookingDetail.fromJson(res.data);
  }

}
