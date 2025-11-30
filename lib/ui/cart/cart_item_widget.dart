import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vhs_mobile_user/data/models/cart/cart_item_model.dart';

// Màu xanh theo web - Sky blue palette
const Color primaryBlue = Color(0xFF0284C7); // Sky-600
const Color darkBlue = Color(0xFF0369A1); // Sky-700
const Color lightBlue = Color(0xFFE0F2FE); // Sky-100
const Color accentBlue = Color(0xFFBAE6FD); // Sky-200

class CartItemWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final img = item.serviceImages.isNotEmpty ? item.serviceImages.first : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
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
          ),
          const SizedBox(width: 4),

          // Service Image + Name (flex: 4)
          Expanded(
            flex: 4,
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: img != null
                        ? CachedNetworkImage(
                            imageUrl: img,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (_, __, ___) => const Icon(Icons.image_outlined, size: 24),
                          )
                        : const Icon(Icons.image_outlined, size: 24),
                  ),
                ),
                const SizedBox(width: 8),
                // Service Name
                Flexible(
                  child: Text(
                    item.serviceName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // Unit Price (flex: 2)
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                '${_formatPrice(item.servicePrice)}₫',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: primaryBlue,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),


          // Amount (flex: 2)
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                '${_formatPrice(item.subtotal)}₫',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Action (flex: 1)
          Expanded(
            flex: 1,
            child: Center(
              child: TextButton(
                onPressed: onDelete,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Xoá',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
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
