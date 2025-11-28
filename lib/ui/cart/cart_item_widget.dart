import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/cart/cart_item_model.dart';
import 'package:vhs_mobile_user/ui/cart/cart_list_viewmodel.dart';

class CartItemWidget extends ConsumerWidget {
  final CartItemModel item;
  const CartItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final img = (item.serviceImages.isNotEmpty)
        ? item.serviceImages.first
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- IMAGE ----------
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 72,
                height: 72,
                color: Colors.grey.shade200,
                child: img != null
                    ? Image.network(img, fit: BoxFit.cover)
                    : const Icon(Icons.image_outlined),
              ),
            ),

            const SizedBox(width: 12),

            // ---------- MAIN CONTENT ----------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.serviceName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    item.providerName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),

                  const SizedBox(height: 12),

                  // ---------- PRICE + QTY + DELETE ----------
                  Row(
                    children: [
                      Text(
                        "${item.servicePrice.toStringAsFixed(0)} ₫",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const Spacer(),

                      _QtyControl(item: item),

                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          ref.read(cartProvider.notifier).remove(item.cartItemId);
                        },
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
}

/// ================= QTY CONTROL =================
class _QtyControl extends ConsumerWidget {
  final CartItemModel item;
  const _QtyControl({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qty = item.quantity;
    return Row(
      children: [
        
        Text(
          qty.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        
      ],
    );
  }
}
