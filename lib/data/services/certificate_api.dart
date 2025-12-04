// lib/data/services/certificate_api.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/network/dio_client.dart';

final certificateApiProvider = Provider<CertificateApi>((ref) {
  final dio = ref.watch(dioClientProvider).instance;
  return CertificateApi(dio);
});

class CertificateApi {
  final Dio _dio;
  CertificateApi(this._dio);

  /// Lấy danh sách certificate theo providerId
  /// Endpoint: /api/admin/certificates/provider/{providerId}
  Future<List<Map<String, dynamic>>> getCertificatesByProviderId(String providerId) async {
    try {
      // Sử dụng endpoint giống như frontend: /api/admin/certificates/provider/{providerId}
      final resp = await _dio.get('/api/admin/certificates/provider/$providerId');
      if (resp.statusCode == 200) {
        final data = resp.data;
        if (data is List) {
          return data.map((e) => e as Map<String, dynamic>).toList();
        } else if (data is Map<String, dynamic>) {
          // Nếu trả về object có Items hoặc items
          final items = data['Items'] ?? data['items'] ?? data['Data'] ?? data['data'];
          if (items is List) {
            return items.map((e) => e as Map<String, dynamic>).toList();
          }
        }
        return [];
      } else {
        throw Exception('Failed to load certificates: ${resp.statusCode}');
      }
    } catch (e) {
      print('Error loading certificates: $e');
      return [];
    }
  }
}

