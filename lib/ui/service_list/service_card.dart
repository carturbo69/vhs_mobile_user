// lib/ui/service_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vhs_mobile_user/data/models/service/service_model.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';

// Màu xanh theo web - Sky blue palette
const Color primaryBlue = Color(0xFF0284C7); // Sky-600
const Color darkBlue = Color(0xFF0369A1); // Sky-700
const Color lightBlue = Color(0xFFE0F2FE); // Sky-100
const Color accentBlue = Color(0xFFBAE6FD); // Sky-200

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    final images = service.imageList; // CSV → List<String>
    final img = images.isNotEmpty ? images.first : null;
    final isDark = ThemeHelper.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.hardEdge,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
        color: ThemeHelper.getCardBackgroundColor(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.blue.shade900.withOpacity(0.3)
                    : lightBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, size: 18, color: primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      service.providerName ?? "Nhà cung cấp",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.blue.shade300 : darkBlue,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),

            // ================= IMAGE WITH TAG =================
            Stack(
              children: [
            img != null
                ? CachedNetworkImage(
                    imageUrl: img,
                    width: double.infinity,
                        height: 180,
                    fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 180,
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                        errorWidget: (_, __, ___) => Container(
                          height: 180,
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                    ),
                  )
                : Container(
                        height: 180,
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                      ),
                // Tag category ở góc trên trái
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      service.categoryName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
                  ),

            // ================= INFO =================
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - lớn, đậm, màu xanh
                  Text(
                    service.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.blue.shade300 : darkBlue,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // ================= SERVICES LIST WITH CHECKMARKS =================
                  if (service.serviceOptions.isNotEmpty) ...[
                    Builder(
                      builder: (context) {
                        // Tách options thành 2 nhóm: regular và textarea/text (giống Index.cshtml)
                        final regularOptions = service.serviceOptions
                            .where((opt) => opt.type.toLowerCase() != 'textarea' && opt.type.toLowerCase() != 'text')
                            .toList();
                        final textareaOptions = service.serviceOptions
                            .where((opt) => opt.type.toLowerCase() == 'textarea' || opt.type.toLowerCase() == 'text')
                            .toList();
                        
                        final totalRegular = regularOptions.length;
                        
                        // Tạo list widgets cho regular options
                        final regularWidgets = regularOptions.take(5).map((opt) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 18,
                                color: Colors.green[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  opt.optionName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ThemeHelper.getTextColor(context),
                                    height: 1.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )).toList();
                        
                        // Tạo list widgets cho textarea options
                        final textareaWidgets = textareaOptions.map((opt) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 18,
                                      color: Colors.green[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            opt.optionName,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: ThemeHelper.getTextColor(context),
                                            ),
                                          ),
                                          if (opt.value != null && opt.value!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                  Text(
                                              opt.value!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: ThemeHelper.getSecondaryTextColor(context),
                                                height: 1.4,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList();
                        
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Hiển thị regular options trước
                            ...regularWidgets,
                            // Hiển thị indicator nếu còn nhiều hơn 5 regular options
                            if (totalRegular > 5)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 26), // Space for icon
                  Text(
                                      "+${totalRegular - 5} tùy chọn khác",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: primaryBlue,
                      fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                            // Hiển thị textarea/text options ở cuối
                            ...textareaWidgets,
                          ],
                        );
                      },
                  ),
                  const SizedBox(height: 6),
                  ],

                  // ================= AREA/DURATION ICON =================
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.blue.shade900.withOpacity(0.3)
                          : lightBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                    children: [
                        Icon(Icons.access_time, size: 16, color: primaryBlue),
                      const SizedBox(width: 6),
                      Text(
                          service.baseUnit != null 
                              ? "${service.baseUnit} ${_translateUnitType(service.unitType)}"
                              : "1 ${_translateUnitType(service.unitType)}",
                          style: TextStyle(
                          fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.blue.shade300 : darkBlue,
                        ),
                      ),
                    ],
                  ),
                  ),
                  const SizedBox(height: 12),

                  // ================= PRICE SECTION =================
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: ThemeHelper.getBorderColor(context), width: 1),
                        bottom: BorderSide(color: ThemeHelper.getBorderColor(context), width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "GIÁ CHỈ",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ThemeHelper.getSecondaryTextColor(context),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_formatPrice(service.price)}₫",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ================= RATING =================
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < service.averageRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        "${service.averageRating.toStringAsFixed(1)} (${service.totalReviews})",
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeHelper.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  String _translateUnitType(String unitType) {
    final lowerUnitType = unitType.toLowerCase().trim();
    
    // Map các unit type từ tiếng Anh sang tiếng Việt (theo Index.cshtml)
    switch (lowerUnitType) {
      case 'squaremeter':
      case 'square meter':
      case 'm²':
      case 'm2':
        return 'Mét vuông';
      case 'visit':
      case 'lần':
        return 'Lần';
      case 'hour':
      case 'hours':
      case 'giờ':
        return 'Giờ';
      case 'day':
      case 'days':
      case 'ngày':
        return 'Ngày';
      case 'apartment':
      case 'apartments':
      case 'căn':
        return 'Căn';
      case 'room':
      case 'rooms':
      case 'phòng':
        return 'Phòng';
      case 'person':
      case 'persons':
      case 'people':
      case 'người':
        return 'Người';
      case 'package':
      case 'packages':
      case 'gói':
        return 'Gói';
      case 'event':
      case 'events':
      case 'sự kiện':
        return 'Sự kiện';
      case 'week':
      case 'weeks':
      case 'tuần':
        return 'Tuần';
      case 'month':
      case 'months':
      case 'tháng':
        return 'Tháng';
      case 'session':
      case 'sessions':
      case 'buổi':
        return 'Buổi';
      default:
        // Nếu không tìm thấy, trả về nguyên bản hoặc chuyển đổi cơ bản
        if (unitType.contains('meter') || unitType.contains('m²') || unitType.contains('m2')) {
          return 'Mét vuông';
        }
        return unitType; // Trả về nguyên bản nếu không xác định được
    }
  }
}
