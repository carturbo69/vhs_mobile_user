import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/network/dio_client.dart';
import 'package:vhs_mobile_user/data/models/provider/provider_availability_model.dart';


final providerAvailabilityApiProvider = Provider<ProviderAvailabilityApi>((ref) {
  return ProviderAvailabilityApi(ref.read(dioClientProvider).instance);
});

class ProviderAvailabilityApi {
  final Dio _dio;
  ProviderAvailabilityApi(this._dio);

  // GET /api/ProviderAvailability/{providerId}?date=yyyy-MM-dd&time=HH:mm
  Future<ProviderAvailabilityModel> checkAvailability(String providerId, DateTime date, String time) async {
    final dateStr = '${date.year.toString().padLeft(4,'0')}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
    final resp = await _dio.get('/api/ProviderAvailability/$providerId', queryParameters: {'date': dateStr, 'time': time});
    final raw = resp.data['data'] ?? resp.data['Data'] ?? resp.data;
    return ProviderAvailabilityModel.fromJson(raw ?? {});
  }
}
