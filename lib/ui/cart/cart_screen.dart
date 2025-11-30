import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/cart/cart_list_viewmodel.dart';
import 'package:vhs_mobile_user/ui/cart/cart_item_widget.dart';
import 'package:vhs_mobile_user/ui/cart/cart_total_provider.dart';
import 'package:vhs_mobile_user/data/models/cart/cart_item_model.dart';
import 'package:vhs_mobile_user/ui/voucher/voucher_dialog.dart';
import 'package:vhs_mobile_user/ui/voucher/voucher_viewmodel.dart';

// Màu xanh theo web - Sky blue palette
const Color primaryBlue = Color(0xFF0284C7); // Sky-600
const Color darkBlue = Color(0xFF0369A1); // Sky-700
const Color lightBlue = Color(0xFFE0F2FE); // Sky-100
const Color accentBlue = Color(0xFFBAE6FD); // Sky-200

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final Set<String> _selectedItems = {};
  bool _selectAll = false;

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        final items = ref.read(cartProvider);
        items.whenData((list) {
          _selectedItems.clear();
          _selectedItems.addAll(list.map((e) => e.cartItemId));
        });
      } else {
        _selectedItems.clear();
      }
    });
  }

  void _toggleItem(String cartItemId, bool? value) {
    setState(() {
      if (value ?? false) {
        _selectedItems.add(cartItemId);
      } else {
        _selectedItems.remove(cartItemId);
      }
      // Update select all state
      final items = ref.read(cartProvider);
      items.whenData((list) {
        _selectAll = _selectedItems.length == list.length && list.isNotEmpty;
      });
    });
  }

  double _calculateSelectedTotal(List<CartItemModel> items) {
    return items
        .where((item) => _selectedItems.contains(item.cartItemId))
        .fold(0.0, (sum, item) => sum + item.subtotal);
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

  @override
  Widget build(BuildContext context) {
    final asyncCart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Giỏ hàng của bạn',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: asyncCart.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Lỗi: $e')),
        data: (items) {
          if (items.isEmpty) {
            return _EmptyCart();
          }

          // Group items by provider
          final groupedItems = <String, List<CartItemModel>>{};
          for (var item in items) {
            if (!groupedItems.containsKey(item.providerId)) {
              groupedItems[item.providerId] = [];
            }
            groupedItems[item.providerId]!.add(item);
          }

          final selectedTotal = _calculateSelectedTotal(items);
          final selectedCount = _selectedItems.length;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _selectAll,
                                onChanged: _toggleSelectAll,
                                activeColor: primaryBlue,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  'Dịch vụ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Đơn giá',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Số tiền',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Thao tác',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Service Items by Provider
                        ...groupedItems.entries.map((entry) {
                          final providerItems = entry.value;
                          final firstItem = providerItems.first;
                          
                          return Column(
                            children: [
                              // Provider Header
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                color: lightBlue,
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: providerItems.every((item) => _selectedItems.contains(item.cartItemId)),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value ?? false) {
                                            for (var item in providerItems) {
                                              _selectedItems.add(item.cartItemId);
                                            }
                                          } else {
                                            for (var item in providerItems) {
                                              _selectedItems.remove(item.cartItemId);
                                            }
                                          }
                                          _selectAll = _selectedItems.length == items.length && items.isNotEmpty;
                                        });
                                      },
                                      activeColor: primaryBlue,
                                    ),
                                    const SizedBox(width: 8),
                                    if (firstItem.providerImages.isNotEmpty)
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(firstItem.providerImages),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    else
                                      Icon(Icons.business, size: 20, color: primaryBlue),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        firstItem.providerName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: darkBlue,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Service Items
                              ...providerItems.map((item) => CartItemWidget(
                                item: item,
                                isSelected: _selectedItems.contains(item.cartItemId),
                                onSelectChanged: (value) => _toggleItem(item.cartItemId, value),
                                onDelete: () {
                                  ref.read(cartProvider.notifier).remove(item.cartItemId);
                                  _selectedItems.remove(item.cartItemId);
                                },
                              )),
                            ],
                          );
                        }),

                      ],
                    ),
                  ),
                ),
              ),

              // Voucher Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_offer, color: Colors.orange[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final selectedVoucher = ref.watch(selectedVoucherProvider);
                          final selectedTotal = _calculateSelectedTotal(items);
                          
                          return ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => VoucherDialog(
                                  totalAmount: selectedTotal,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedVoucher != null 
                                  ? Colors.green[100] 
                                  : accentBlue,
                              foregroundColor: selectedVoucher != null 
                                  ? Colors.green[800] 
                                  : darkBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              selectedVoucher != null 
                                  ? selectedVoucher.code 
                                  : 'Chọn voucher',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Footer Summary
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Selection Controls
                    Row(
                      children: [
                        Checkbox(
                          value: _selectAll,
                          onChanged: _toggleSelectAll,
                          activeColor: primaryBlue,
                        ),
                        const Text(
                          'Chọn tất cả',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('Xóa toàn bộ giỏ hàng?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(c, false),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: const Text('Xóa tất cả', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                            if (ok) {
                              await ref.read(cartProvider.notifier).clear();
                              _selectedItems.clear();
                              setState(() {});
                            }
                          },
                          child: const Text(
                            'Xoá tất cả',
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Summary
                    Consumer(
                      builder: (context, ref, child) {
                        final selectedVoucher = ref.watch(selectedVoucherProvider);
                        final voucherDiscount = selectedVoucher != null
                            ? selectedVoucher.calculateDiscount(selectedTotal)
                            : 0.0;
                        final finalTotal = selectedTotal - voucherDiscount;

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Đã chọn $selectedCount',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tạm tính ${_formatPrice(selectedTotal)}₫',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                    if (selectedVoucher != null && voucherDiscount > 0) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Giảm giá: -${_formatPrice(voucherDiscount)}₫',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Tổng cộng',
                                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatPrice(finalTotal)}₫',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Checkout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedCount > 0
                            ? () {
                                context.push(Routes.checkout);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedCount > 0 ? primaryBlue : Colors.grey[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: selectedCount > 0 ? 2 : 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Đặt Dịch Vụ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
