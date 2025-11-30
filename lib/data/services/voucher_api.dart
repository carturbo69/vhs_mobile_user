import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/network/dio_client.dart';
import 'package:vhs_mobile_user/data/models/voucher/voucher_model.dart';

final voucherApiProvider = Provider<VoucherApi>((ref) {
  return VoucherApi(ref.read(dioClientProvider).instance);
});

class VoucherApi {
  final Dio _dio;
  VoucherApi(this._dio);

  // GET /api/vouchers hoặc /api/admin/vouchers - Lấy danh sách voucher available
  Future<List<VoucherModel>> getAvailableVouchers() async {
    try {
      // Thử endpoint cho user trước
      try {
        final resp = await _dio.get('/api/vouchers', queryParameters: {
          'onlyActive': true,
        });
        
        final data = resp.data;
        
        // Case 1: Backend trả trực tiếp List
        if (data is List) {
          return data.map((e) => VoucherModel.fromJson(e)).toList();
        }
        
        // Case 2: Backend trả Map có "items" hoặc "data": List
        if (data is Map) {
          final list = data['items'] ?? data['data'] ?? data['vouchers'];
          if (list is List) {
            return list.map((e) => VoucherModel.fromJson(e)).toList();
          }
        }
      } catch (e) {
        // Nếu endpoint user không tồn tại, thử endpoint admin
        print('⚠️ User voucher endpoint failed, trying admin endpoint: $e');
      }
      
      // Thử endpoint admin với filter active
      final resp = await _dio.get('/api/admin/vouchers', queryParameters: {
        'onlyActive': true,
        'page': 1,
        'pageSize': 100, // Lấy nhiều voucher
      });
      
      final data = resp.data;
      
      // Backend trả { total, items }
      if (data is Map) {
        final list = data['items'];
        if (list is List) {
          return list.map((e) => VoucherModel.fromJson(e)).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('⚠️ Error fetching vouchers: $e');
      // Nếu endpoint không tồn tại, trả về list rỗng
      return [];
    }
  }

  // GET /api/user/vouchers - Lấy voucher của user (nếu có endpoint riêng)
  Future<List<VoucherModel>> getUserVouchers(String accountId) async {
    try {
      final resp = await _dio.get('/api/user/vouchers', queryParameters: {
        'accountId': accountId,
      });
      
      final data = resp.data;
      
      if (data is List) {
        return data.map((e) => VoucherModel.fromJson(e)).toList();
      }
      
      if (data is Map) {
        final list = data['items'] ?? data['data'] ?? data['vouchers'];
        if (list is List) {
          return list.map((e) => VoucherModel.fromJson(e)).toList();
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
}

