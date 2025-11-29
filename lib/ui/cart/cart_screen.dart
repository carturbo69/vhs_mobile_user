import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/cart/cart_list_viewmodel.dart';
import 'package:vhs_mobile_user/ui/cart/cart_item_widget.dart';
import 'package:vhs_mobile_user/ui/cart/cart_total_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(cartProvider.notifier).refresh(),
          ),
        ],
      ),
      body: asyncCart.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Lỗi: $e')),
        data: (items) {
          if (items.isEmpty) {
            return _EmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => CartItemWidget(item: items[i]),
                ),
              ),
              const _BottomSummary(),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 96, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Giỏ hàng trống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Thêm dịch vụ vào giỏ để đặt lịch', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => context.go(Routes.listService),
              icon: const Icon(Icons.add),
              label: const Text('Tìm dịch vụ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSummary extends ConsumerWidget {
  const _BottomSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(cartTotalProvider); // assume a provider returning num
    return Material(
      elevation: 12,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tổng', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      total is double ? '${total.toStringAsFixed(0)} đ' : '$total đ',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.push(Routes.checkout); // assume route exists
                },
                child: const Text('Thanh toán'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Xóa toàn bộ giỏ hàng?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
                            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Xóa')),
                          ],
                        ),
                      ) ??
                      false;
                  if (ok) {
                    await ref.read(cartProvider.notifier).clear();
                  }
                },
                child: const Text('Xóa hết'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
