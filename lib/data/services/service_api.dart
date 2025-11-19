// lib/data/service_api.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/provider/provider.dart';

final serviceApiProvider = Provider<ServiceApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ServiceApi(dio);
});

class ServiceApi {
  final Dio _dio;
  ServiceApi(this._dio);

  /// Fetch raw list from backend
  Future<List<Map<String, dynamic>>> fetchHomeServicesRaw() async {
    final resp = await _dio.get('/Services/services-homepage');
    // assume backend returns JSON array
    if (resp.statusCode == 200) {
      final data = resp.data;
      if (data is List) {
        // ensure each item is Map<String,dynamic>
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } else {
        throw Exception('Unexpected payload: ${data.runtimeType}');
      }
    } else {
      throw Exception('Http ${resp.statusCode}: ${resp.statusMessage}');
    }
  }

  /// You can add other endpoints (create/update/delete) here...
}
