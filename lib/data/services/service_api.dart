// lib/data/service_api.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/provider/provider.dart';
import 'package:vhs_mobile_user/data/models/service/service_detail.dart';
import 'package:vhs_mobile_user/data/models/service/service_model.dart';

final serviceApiProvider = Provider<ServiceApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ServiceApi(dio);
});

class ServiceApi {
  final Dio _dio;
  ServiceApi(this._dio);

  /// Fetch raw list from backend
  Future<List<ServiceModel>> fetchHomePageServices() async {
    final resp = await _dio.get('/api/Services/services-homepage');
    if (resp.statusCode == 200) {
      final data = resp.data as List<dynamic>;
      return data
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load services: ${resp.statusCode}');
    }
  }

  Future<ServiceDetail> getDetail(String id) async {
    final resp = await _dio.get('/api/Services/$id');
    return ServiceDetail.fromJson(resp.data);
  }
}
