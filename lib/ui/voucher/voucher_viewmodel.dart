import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/voucher/voucher_model.dart';
import 'package:vhs_mobile_user/data/services/voucher_api.dart';

final voucherListProvider =
    FutureProvider<List<VoucherModel>>((ref) async {
  try {
    final api = ref.read(voucherApiProvider);
    final vouchers = await api.getAvailableVouchers();
    print('📦 Fetched ${vouchers.length} vouchers from API');
    
    // Debug: In thông tin từng voucher
    for (var v in vouchers) {
      print('📋 Voucher: ${v.code}, isActive: ${v.isActive}, startDate: ${v.startDate}, endDate: ${v.endDate}, usedCount: ${v.usedCount}/${v.usageLimit}');
    }
    
    // Lọc chỉ lấy voucher hợp lệ
    final validVouchers = vouchers.where((v) => v.isValid).toList();
    print('✅ ${validVouchers.length} valid vouchers after filtering (out of ${vouchers.length} total)');
    
    // Nếu có voucher bị loại, in ra lý do
    if (validVouchers.length < vouchers.length) {
      final invalid = vouchers.where((v) => !v.isValid).toList();
      print('⚠️ ${invalid.length} vouchers were filtered out');
    }
    
    return validVouchers;
  } catch (e, stackTrace) {
    print('❌ Error in voucherListProvider: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
});

// Notifier để quản lý voucher đã chọn
class SelectedVoucherNotifier extends Notifier<VoucherModel?> {
  @override
  VoucherModel? build() {
    return null;
  }

  void select(VoucherModel? voucher) {
    state = voucher;
  }

  void clear() {
    state = null;
  }
}

// Provider để lưu voucher đã chọn
final selectedVoucherProvider =
    NotifierProvider<SelectedVoucherNotifier, VoucherModel?>(() {
  return SelectedVoucherNotifier();
});

