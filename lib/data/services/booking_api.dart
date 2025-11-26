import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/network/dio_client.dart';
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
}
