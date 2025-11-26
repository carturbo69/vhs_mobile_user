import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/cart/cart_item_model.dart';
import 'package:vhs_mobile_user/ui/cart/cart_list_viewmodel.dart';

class CartItemWidget extends ConsumerWidget {
  final CartItemModel item;
  const CartItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // item expected fields: cartItemId, serviceName, providerName, price, quantity
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // optional thumbnail
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
                image: item.imageUrl != null
                    ? DecorationImage(image: NetworkImage(item.imageUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: item.imageUrl == null ? const Icon(Icons.image_outlined) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.serviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(item.providerName ?? '', style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('${item.price.toStringAsFixed(0)} đ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      _QtyControl(item: item),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref.read(cartProvider.notifier).remove(item.cartItemId),
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

class _QtyControl extends ConsumerWidget {
  final CartItemModel item;
  const _QtyControl({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qty = item.quantity;
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: qty > 1
              ? () => ref.read(cartProvider.notifier).updateQuantity(item.cartItemId, qty - 1)
              : null,
        ),
        Text(qty.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.cartItemId, qty + 1),
        ),
      ],
    );
  }
}
