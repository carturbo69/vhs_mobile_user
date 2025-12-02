import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_result_model.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:intl/intl.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';

class BookingResultScreen extends StatelessWidget {
  final BookingResultModel result;
  const BookingResultScreen({super.key, required this.result});

  String _formatBookingId(String bookingId) {
    // Format bookingId thành BKG-XXXXX
    if (bookingId.length > 8) {
      return 'BKG-${bookingId.substring(0, 8).toUpperCase()}';
    }
    return 'BKG-${bookingId.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
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
          "Kết quả đặt hàng",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Icon hourglass với gradient và glow đẹp hơn
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
                            Colors.orange.shade900.withOpacity(0.3),
                            Colors.orange.shade800.withOpacity(0.2),
                          ]
                        : [
                            Colors.orange.shade50,
                            Colors.orange.shade100,
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.2),
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
                    Icons.hourglass_empty_rounded,
                    size: 72,
                    color: Colors.orange.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              
              // Tiêu đề với typography đẹp hơn
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
                    TextSpan(
                      text: 'Đơn hàng đang ',
                      style: TextStyle(
                        color: Colors.orange.shade400,
                        shadows: [
                          Shadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    TextSpan(
                      text: 'chờ xác nhận',
                      style: TextStyle(
                        color: Colors.teal.shade400,
                        shadows: [
                          Shadow(
                            color: Colors.teal.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Text giải thích với design đẹp hơn
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Text(
                      'Đơn hàng của bạn đã được tạo thành công và đang chờ nhà cung cấp xác nhận.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.5,
                        color: ThemeHelper.getTextColor(context),
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Bạn sẽ nhận được email thông báo khi đơn hàng được xác nhận.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.5,
                        color: ThemeHelper.getSecondaryTextColor(context),
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              
              // Danh sách dịch vụ đã đặt với header đẹp hơn
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
                  boxShadow: [
                    BoxShadow(
                      color: ThemeHelper.getShadowColor(context),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                        size: 20,
                        color: ThemeHelper.getPrimaryDarkColor(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Danh sách dịch vụ đã đặt',
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
              
              // List services với design đẹp hơn
              // Lấy tên dịch vụ từ dữ liệu booking result (không hardcode)
              ...result.breakdown.map((item) {
                // Lấy tên dịch vụ từ booking breakdown item
                final serviceName = item.serviceName.isNotEmpty 
                    ? item.serviceName 
                    : 'Dịch vụ không xác định';
                
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(top: 6, right: 14),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange[400]!,
                                        Colors.orange[600]!,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.4),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    serviceName,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                      letterSpacing: -0.2,
                                      color: ThemeHelper.getTextColor(context),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: ThemeHelper.isDarkMode(context)
                                          ? [
                                              Colors.orange.shade900.withOpacity(0.3),
                                              Colors.orange.shade800.withOpacity(0.2),
                                            ]
                                          : [
                                              Colors.orange.shade50,
                                              Colors.orange.shade100,
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.orange.shade400,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.hourglass_empty_rounded,
                                        size: 16,
                                        color: Colors.orange[700],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Chờ xác nhận',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange[700],
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: ThemeHelper.isDarkMode(context)
                                    ? Colors.purple.shade900.withOpacity(0.3)
                                    : Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.purple.shade400,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: ThemeHelper.isDarkMode(context)
                                          ? Colors.purple.shade800.withOpacity(0.5)
                                          : Colors.purple.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.receipt_long_rounded,
                                      size: 16,
                                      color: Colors.purple.shade400,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Mã đơn: ${_formatBookingId(item.bookingId)}',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      color: Colors.purple.shade400,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              
              const SizedBox(height: 28),
              
              // Lưu ý với design đẹp hơn
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
                        shape: BoxShape.circle,
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
                        'Lưu ý: Sau khi nhà cung cấp xác nhận đơn hàng, bạn sẽ nhận được email thông báo và có thể tiến hành thanh toán.',
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
              
              // Buttons với design hiện đại hơn
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.go(Routes.history);
                      },
                      icon: const Icon(Icons.history_rounded, size: 20),
                      label: const Text(
                        'Xem lịch sử đặt',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeHelper.getPrimaryColor(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.go(Routes.listService);
                      },
                      icon: Icon(
                        Icons.home_rounded,
                        size: 20,
                        color: ThemeHelper.getPrimaryColor(context),
                      ),
                      label: Text(
                        'Về trang chủ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.getPrimaryColor(context),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: ThemeHelper.getPrimaryColor(context),
                          width: 2,
                        ),
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
}
