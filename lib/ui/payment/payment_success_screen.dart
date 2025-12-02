import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/history/history_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';

class PaymentSuccessData {
  final String transactionId;
  final List<String> bookingIds;
  final double? total;
  final String? message;
  final Map<String, String>? serviceNames; // Map bookingId -> serviceName
  final DateTime? transactionTime; // Thời gian giao dịch từ backend

  PaymentSuccessData({
    required this.transactionId,
    required this.bookingIds,
    this.total,
    this.message,
    this.serviceNames,
    this.transactionTime,
  });
}

class PaymentSuccessScreen extends ConsumerWidget {
  final PaymentSuccessData data;
  const PaymentSuccessScreen({super.key, required this.data});

  String _formatBookingId(String bookingId) {
    // Format bookingId thành BKG-XXXXX
    if (bookingId.length > 8) {
      return 'BKG-${bookingId.substring(0, 8).toUpperCase()}';
    }
    return 'BKG-${bookingId.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Use transaction time from backend if available, otherwise use current time
    final timeToDisplay = data.transactionTime ?? DateTime.now();
    final formattedTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(timeToDisplay);

    final isDark = ThemeHelper.isDarkMode(context);
    
    return Scaffold(
      backgroundColor: ThemeHelper.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
            ),
          ),
        ),
        title: const Text(
          "Thanh toán thành công",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Success icon với gradient và glow
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: ThemeHelper.isDarkMode(context)
                        ? [
                            Colors.green.shade900.withOpacity(0.3),
                            Colors.green.shade800.withOpacity(0.2),
                          ]
                        : [
                      Colors.green.shade50,
                      Colors.green.shade100,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeHelper.getCardBackgroundColor(context),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeHelper.getShadowColor(context),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 72,
                    color: Colors.green.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              
              // Tiêu đề
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    letterSpacing: -0.5,
                    color: ThemeHelper.getTextColor(context),
                  ),
                  children: [
                    const TextSpan(
                      text: '🎉 ',
                      style: TextStyle(fontSize: 32),
                    ),
                    TextSpan(
                      text: 'Thanh toán thành công!',
                      style: TextStyle(
                        color: Colors.green.shade400,
                        shadows: [
                          Shadow(
                            color: Colors.green.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Text giải thích
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi. Giao dịch của bạn đã được xử lý thành công.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.5,
                    color: ThemeHelper.getTextColor(context),
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              
              // Transaction info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ThemeHelper.getCardBackgroundColor(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeHelper.getShadowColor(context),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: ThemeHelper.getShadowColor(context),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment method
                    _buildInfoRow(
                      context: context,
                      icon: Icons.payment_rounded,
                      label: 'Phương thức thanh toán',
                      value: 'VNPay',
                      iconColor: ThemeHelper.getPrimaryColor(context),
                    ),
                    Divider(
                      height: 24,
                      color: ThemeHelper.getBorderColor(context),
                    ),
                    
                    // Transaction ID
                    _buildInfoRow(
                      context: context,
                      icon: Icons.receipt_long_rounded,
                      label: 'Mã giao dịch',
                      value: data.transactionId,
                      iconColor: Colors.purple.shade600,
                    ),
                    
                    // Number of services
                    if (data.bookingIds.isNotEmpty) ...[
                      Divider(
                      height: 24,
                      color: ThemeHelper.getBorderColor(context),
                    ),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.shopping_bag_rounded,
                        label: 'Số lượng dịch vụ',
                        value: '${data.bookingIds.length} booking',
                        iconColor: Colors.orange.shade600,
                      ),
                    ],
                    
                    // Total amount
                    if (data.total != null && data.total! > 0) ...[
                      Divider(
                      height: 24,
                      color: ThemeHelper.getBorderColor(context),
                    ),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.attach_money_rounded,
                        label: 'Tổng thanh toán',
                        value: '${NumberFormat('#,###').format(data.total!.toInt())}₫',
                        iconColor: Colors.green.shade600,
                        isHighlight: true,
                      ),
                    ],
                    
                    // Time
                    Divider(
                      height: 24,
                      color: ThemeHelper.getBorderColor(context),
                    ),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.access_time_rounded,
                      label: 'Thời gian',
                      value: formattedTime,
                      iconColor: Colors.teal.shade600,
                    ),
                  ],
                ),
              ),
              
              // Booking list
              if (data.bookingIds.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ThemeHelper.getLightBlueBackgroundColor(context),
                        ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.description_rounded,
                          size: 22,
                          color: ThemeHelper.getPrimaryDarkColor(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Dịch vụ đã đặt thành công:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                            color: ThemeHelper.getTextColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // List of bookings
                ...data.bookingIds.asMap().entries.map((entry) {
                  final index = entry.key;
                  final bookingId = entry.value;
                  final serviceName = data.serviceNames?[bookingId] ?? 
                      'Dịch vụ số ${index + 1}';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: ThemeHelper.getCardBackgroundColor(context),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeHelper.getShadowColor(context),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: ThemeHelper.getShadowColor(context),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Number badge
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade400,
                                  Colors.green.shade600,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  serviceName,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                    letterSpacing: -0.2,
                                    color: ThemeHelper.getTextColor(context),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: ThemeHelper.isDarkMode(context)
                                        ? Colors.green.shade900.withOpacity(0.3)
                                        : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.green.shade400,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 14,
                                        color: Colors.green.shade400,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '✓ Đã thanh toán',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
              
              const SizedBox(height: 28),
              
              // Footer note
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ThemeHelper.getLightBlueBackgroundColor(context),
                      ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: ThemeHelper.getPrimaryDarkColor(context),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Nếu có bất kỳ thắc mắc nào, vui lòng liên hệ với chúng tôi qua hotline: 0337.868.575 hoặc email: vhsplatform700@gmail.com để được hỗ trợ.',
                        style: TextStyle(
                          fontSize: 14.5,
                          color: ThemeHelper.getTextColor(context),
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 36),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Refresh history trước khi navigate
                        await ref.read(historyProvider.notifier).refresh();
                        if (context.mounted) {
                          context.go(Routes.history);
                        }
                      },
                      icon: const Icon(Icons.calendar_today_rounded, size: 20),
                      label: const Text(
                        'Xem lịch sử',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeHelper.getPrimaryColor(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Refresh history để cập nhật dữ liệu (user có thể vào history sau đó)
                        await ref.read(historyProvider.notifier).refresh();
                        if (context.mounted) {
                          context.go(Routes.listService);
                        }
                      },
                      icon: const Icon(Icons.home_rounded, size: 20),
                      label: const Text(
                        'Về trang chủ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeHelper.getPrimaryColor(context),
                        side: BorderSide(
                          color: ThemeHelper.getPrimaryColor(context),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: ThemeHelper.getSecondaryTextColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                  color: isHighlight
                      ? Colors.green.shade400
                      : ThemeHelper.getTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

