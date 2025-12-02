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

  // GET /api/admin/vouchers - Lấy danh sách voucher available
  Future<List<VoucherModel>> getAvailableVouchers() async {
    try {
      print('🔍 Fetching vouchers from /api/admin/vouchers...');
      
      // Dùng endpoint admin với filter active và lấy nhiều voucher
      final resp = await _dio.get('/api/admin/vouchers', queryParameters: {
        'onlyActive': true,
        'page': 1,
        'pageSize': 1000, // Lấy nhiều voucher để đảm bảo không bỏ sót
      });
      
      print('📦 Response status: ${resp.statusCode}');
      print('📦 Response data type: ${resp.data.runtimeType}');
      
      final data = resp.data;
      
      // Backend trả { total, items }
      if (data is Map) {
        final total = data['total'];
        final list = data['items'];
        
        print('📦 Total vouchers from API: $total');
        print('📦 Items type: ${list.runtimeType}');
        
        if (list is List) {
          print('📦 Parsing ${list.length} vouchers...');
          final vouchers = list.map((e) {
            try {
              return VoucherModel.fromJson(e);
            } catch (parseError) {
              print('❌ Error parsing voucher: $parseError');
              print('❌ Voucher data: $e');
              rethrow;
            }
          }).toList();
          
          print('✅ Successfully parsed ${vouchers.length} vouchers');
          return vouchers;
        } else {
          print('⚠️ Items is not a List, type: ${list.runtimeType}');
        }
      } else if (data is List) {
        // Trường hợp backend trả trực tiếp List
        print('📦 Response is direct List with ${data.length} items');
        return data.map((e) => VoucherModel.fromJson(e)).toList();
      } else {
        print('⚠️ Unexpected response format: ${data.runtimeType}');
      }
      
      print('⚠️ No vouchers found in response');
      return [];
    } catch (e, stackTrace) {
      print('❌ Error fetching vouchers: $e');
      print('❌ Stack trace: $stackTrace');
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

