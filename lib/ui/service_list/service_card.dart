// lib/ui/service_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vhs_mobile_user/data/models/service/service_model.dart';
import 'package:vhs_mobile_user/data/models/service/service_localization_extension.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/services/translation_cache_provider.dart';

// Màu xanh theo web - Sky blue palette
const Color primaryBlue = Color(0xFF0284C7); // Sky-600
const Color darkBlue = Color(0xFF0369A1); // Sky-700
const Color lightBlue = Color(0xFFE0F2FE); // Sky-100
const Color accentBlue = Color(0xFFBAE6FD); // Sky-200

class ServiceCard extends ConsumerWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ hoặc có translation mới
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
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
                      service.getLocalizedProviderName(ref) ?? context.tr('provider'),
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
                      service.getLocalizedCategoryName(ref).toUpperCase(),
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
                    service.getLocalizedTitle(ref),
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
                        // Watch translation cache để rebuild khi có translation mới
                        ref.watch(translationCacheProvider);
                        
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
                                  opt.getLocalizedOptionName(ref),
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
                                            opt.getLocalizedOptionName(ref),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: ThemeHelper.getTextColor(context),
                                            ),
                                          ),
                                          _TextareaValueWidget(option: opt),
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
                                      "+${totalRegular - 5} ${context.tr('more_options')}",
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
                              ? "${service.baseUnit} ${service.getLocalizedUnitType(ref)}"
                              : "1 ${service.getLocalizedUnitType(ref)}",
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
                          context.tr('price_only'),
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
}

/// Widget riêng để hiển thị textarea value với translation
class _TextareaValueWidget extends ConsumerWidget {
  final ServiceOption option;
  
  const _TextareaValueWidget({required this.option});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch translation cache để rebuild khi có translation mới
    ref.watch(translationCacheProvider);
    
    if (option.value == null || option.value!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final localizedValue = option.getLocalizedValue(ref) ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          localizedValue,
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
    );
  }
}
