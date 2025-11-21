// lib/data/service_api.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/provider/provider.dart';
import 'package:vhs_mobile_user/data/models/service/service_detail.dart';

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
   Future<ServiceDetail> getServiceDetail(String id) async {
    try {
      final response = await _dio.get('/api/Services/$id');

      return ServiceDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  Future<List<ServiceOption>> getServiceOptions(String id) async {
    try {
      final response = await _dio.get('/api/Services/$id/options-cart');

      return (response.data as List)
          .map((x) => ServiceOption.fromJson(x))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  /// You can add other endpoints (create/update/delete) here...
}
