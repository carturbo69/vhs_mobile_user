import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vhs_mobile_user/data/models/cart/cart_item_model.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/services/translation_cache_provider.dart';
import 'package:vhs_mobile_user/services/data_translation_service.dart';

// Màu xanh theo web - Sky blue palette
const Color primaryBlue = Color(0xFF0284C7); // Sky-600
const Color darkBlue = Color(0xFF0369A1); // Sky-700
const Color lightBlue = Color(0xFFE0F2FE); // Sky-100
const Color accentBlue = Color(0xFFBAE6FD); // Sky-200

class CartItemWidget extends ConsumerWidget {
  final CartItemModel item;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectChanged;
  final VoidCallback? onDelete;

  const CartItemWidget({
    super.key,
    required this.item,
    this.isSelected = false,
    this.onSelectChanged,
    this.onDelete,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ hoặc có translation mới
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
    final img = item.serviceImages.isNotEmpty ? item.serviceImages.first : null;
    final isDark = ThemeHelper.isDarkMode(context);
    
    // Dịch serviceName nếu cần
    final locale = ref.read(localeProvider);
    final translationService = DataTranslationService(ref);
    
    String serviceName = item.serviceName;
    if (locale.languageCode != 'vi') {
      serviceName = translationService.smartTranslate(item.serviceName);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark
                ? Colors.blue.shade900.withOpacity(0.3)
                : lightBlue.withOpacity(0.3))
            : ThemeHelper.getCardBackgroundColor(context),
        border: Border(
          bottom: BorderSide(color: ThemeHelper.getBorderColor(context), width: 1),
        ),
      ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Checkbox
          Checkbox(
            value: isSelected,
            onChanged: onSelectChanged,
            activeColor: primaryBlue,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),

          // Service Image + Name (flex: 4)
          Expanded(
            flex: 4,
            child: Row(
              children: [
                // Image
            ClipRRect(
                  borderRadius: BorderRadius.circular(10),
              child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                child: img != null
                        ? CachedNetworkImage(
                            imageUrl: img,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: isDark ? Colors.grey.shade800 : Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primaryBlue,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.image_outlined,
                              size: 28,
                              color: isDark ? Colors.grey.shade400 : Colors.grey,
                            ),
                          )
                        : Icon(
                            Icons.image_outlined,
                            size: 28,
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
                          ),
              ),
            ),
            const SizedBox(width: 12),
                // Service Name
                Flexible(
                  child: Text(
                    serviceName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: ThemeHelper.getTextColor(context),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
                    ),
                  ),

          const SizedBox(width: 8),

          // Amount (flex: 2)
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.red.shade900.withOpacity(0.3)
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark 
                        ? Colors.red.shade700.withOpacity(0.5)
                        : Colors.red.shade200,
                    width: 1,
                  ),
                ),
                child: Text(
                  '${_formatPrice(item.subtotal)}₫',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade400,
                    fontSize: 12,
                        ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Action (flex: 1)
          Expanded(
            flex: 1,
            child: Center(
              child: TextButton(
                onPressed: onDelete,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.tr('delete_item'),
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                      ),
                ),
                  ),
              ),
            ),
          ],
      ),
    );
  }
}
