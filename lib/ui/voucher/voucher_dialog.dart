import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/voucher/voucher_model.dart';
import 'package:vhs_mobile_user/ui/voucher/voucher_viewmodel.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';

class VoucherDialog extends ConsumerWidget {
  final double totalAmount; // Tổng tiền để tính discount

  const VoucherDialog({
    super.key,
    required this.totalAmount,
  });

  String _formatPrice(double price) {
    final priceInt = price.toInt();
    final priceStr = priceInt.toString();
    final buffer = StringBuffer();
    
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(priceStr[i]);
    }
    
    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    // Format: dd/MM/yyyy
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voucherAsync = ref.watch(voucherListProvider);
    final selectedVoucher = ref.watch(selectedVoucherProvider);

    final isDark = ThemeHelper.isDarkMode(context);
    return Dialog(
      backgroundColor: ThemeHelper.getDialogBackgroundColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade600,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Chọn Voucher',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: voucherAsync.when(
                loading: () => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeHelper.getPrimaryColor(context),
                        ),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Đang tải...",
                        style: TextStyle(
                          color: ThemeHelper.getSecondaryTextColor(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.red.shade900.withOpacity(0.3)
                                : Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không thể tải voucher',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeHelper.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$error',
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeHelper.getSecondaryTextColor(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => ref.refresh(voucherListProvider),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text(
                            'Thử lại',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeHelper.getPrimaryColor(context),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (vouchers) {
                  if (vouchers.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.orange.shade900.withOpacity(0.3)
                                    : Colors.orange.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.local_offer_outlined,
                                size: 64,
                                color: Colors.orange.shade400,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Không có voucher nào',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ThemeHelper.getTextColor(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hiện tại không có voucher khả dụng',
                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeHelper.getSecondaryTextColor(context),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shrinkWrap: true,
                    itemCount: vouchers.length,
                    itemBuilder: (context, index) {
                      final voucher = vouchers[index];
                      final discount = voucher.calculateDiscount(totalAmount);
                      final isSelected = selectedVoucher?.voucherId == voucher.voucherId;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: ThemeHelper.getCardBackgroundColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? ThemeHelper.getPrimaryColor(context)
                                : ThemeHelper.getBorderColor(context),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? ThemeHelper.getPrimaryColor(context).withOpacity(0.2)
                                  : ThemeHelper.getShadowColor(context),
                              blurRadius: isSelected ? 8 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            if (isSelected) {
                              ref.read(selectedVoucherProvider.notifier).clear();
                            } else {
                              ref.read(selectedVoucherProvider.notifier).select(voucher);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Checkbox
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? ThemeHelper.getPrimaryColor(context)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected 
                                          ? ThemeHelper.getPrimaryColor(context)
                                          : ThemeHelper.getSecondaryIconColor(context),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_rounded
                                        : null,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Voucher Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Code
                                      Text(
                                        voucher.code,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected 
                                              ? ThemeHelper.getPrimaryColor(context)
                                              : ThemeHelper.getTextColor(context),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Description
                                      if (voucher.description != null)
                                        Text(
                                          voucher.description!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: ThemeHelper.getSecondaryTextColor(context),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 8),
                                      // Discount Info - Wrap để tránh overflow
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          if (voucher.discountPercent != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    ThemeHelper.getLightBlueBackgroundColor(context),
                                                    ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.7),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                'Giảm ${voucher.discountPercent}%',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: ThemeHelper.getPrimaryDarkColor(context),
                                                ),
                                              ),
                                            ),
                                          if (voucher.discountMaxAmount != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: ThemeHelper.getLightBackgroundColor(context),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Tối đa ${_formatPrice(voucher.discountMaxAmount!)}₫',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: ThemeHelper.getTertiaryTextColor(context),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (discount > 0) ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ThemeHelper.isDarkMode(context)
                                                ? Colors.green.shade900.withOpacity(0.3)
                                                : Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: Colors.green.shade400,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.savings_rounded,
                                                size: 14,
                                                color: Colors.green.shade400,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Tiết kiệm: ${_formatPrice(discount)}₫',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green.shade400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 6),
                                      // Usage và Expiry Info - Wrap để tránh overflow
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          // Số lượt còn lại
                                          if (voucher.usageLimit != null)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.people_outline,
                                                  size: 12,
                                                  color: ThemeHelper.getTertiaryTextColor(context),
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  'Còn ${voucher.usageLimit! - (voucher.usedCount ?? 0)} lượt',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: ThemeHelper.getTertiaryTextColor(context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          // Thời gian hết hạn
                                          if (voucher.endDate != null)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 12,
                                                  color: ThemeHelper.getTertiaryTextColor(context),
                                                ),
                                                const SizedBox(width: 3),
                                                Flexible(
                                                  child: Text(
                                                    'Hết hạn: ${_formatDate(voucher.endDate!)}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: ThemeHelper.getTertiaryTextColor(context),
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Footer Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ThemeHelper.getCardBackgroundColor(context),
                border: Border(
                  top: BorderSide(
                    color: ThemeHelper.getBorderColor(context),
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (selectedVoucher != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(selectedVoucherProvider.notifier).clear();
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: ThemeHelper.getSecondaryTextColor(context),
                        ),
                        label: Text(
                          'Bỏ chọn',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ThemeHelper.getSecondaryTextColor(context),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: ThemeHelper.getBorderColor(context),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (selectedVoucher != null) const SizedBox(width: 12),
                  Expanded(
                    flex: selectedVoucher != null ? 2 : 1,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: const Text(
                        'Xác nhận',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeHelper.getPrimaryColor(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

