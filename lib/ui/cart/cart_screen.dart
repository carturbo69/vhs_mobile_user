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

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final Set<String> _selectedItems = {};
  bool _selectAll = false;
  String? _previousRoute;
  bool _hasNavigatedToCheckout = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy previousRoute từ extra nếu có
    if (_previousRoute == null) {
      try {
        final extra = GoRouterState.of(context).extra;
        if (extra is Map && extra['previousRoute'] is String) {
          _previousRoute = extra['previousRoute'] as String;
        }
      } catch (e) {
        // Nếu không lấy được, để null
        _previousRoute = null;
      }
    }
  }

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
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ hoặc có translation mới
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
    final asyncCart = ref.watch(cartProvider);

    final isDark = ThemeHelper.isDarkMode(context);
    
    return Scaffold(
      backgroundColor: ThemeHelper.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        // automaticallyImplyLeading: true,
        // leading: (_previousRoute != null || Navigator.canPop(context))
        //     ? IconButton(
        //         icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        //         onPressed: () {
        //           if (_previousRoute != null) {
        //             context.go(_previousRoute!);
        //           } else if (Navigator.canPop(context)) {
        //             Navigator.of(context).pop();
        //           }
        //         },
        //       )
        //     : null,
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
        title: Text(
          context.tr('your_cart'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              onSelected: (value) async {
                if (value == 'delete_all') {
                  if (!mounted) return;
                  final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            context.tr('delete_all_cart'),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          content: Text(context.tr('confirm_delete_all_cart')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: Text(context.tr('cancel')),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: Text(
                                context.tr('delete_all'),
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                  if (!mounted) return;
                  if (ok) {
                    await ref.read(cartProvider.notifier).clear();
                    if (!mounted) return;
                    _selectedItems.clear();
                    setState(() {});
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'delete_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red[700], size: 20),
                      const SizedBox(width: 12),
                      Text(
                        context.tr('delete_all'),
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
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
      body: asyncCart.when(
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeHelper.getPrimaryColor(context),
                ),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                context.tr('loading'),
                style: TextStyle(
                  color: ThemeHelper.getSecondaryTextColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.red.shade900.withOpacity(0.3)
                        : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  context.tr('cannot_load_cart'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeHelper.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('please_try_again_later'),
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeHelper.getSecondaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(cartProvider.notifier).refresh();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(
                    context.tr('try_again'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeHelper.getPrimaryColor(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
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
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: ThemeHelper.getCardBackgroundColor(context),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeHelper.getShadowColor(context),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: ThemeHelper.getLightBackgroundColor(context),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: ThemeHelper.getBorderColor(context),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _selectAll,
                                onChanged: _toggleSelectAll,
                                activeColor: ThemeHelper.primaryBlue,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  context.tr('service_column'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: ThemeHelper.getTextColor(context),
                                    fontSize: 13,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  context.tr('amount_column'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: ThemeHelper.getTextColor(context),
                                    fontSize: 13,
                                    letterSpacing: 0.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  context.tr('action_column'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: ThemeHelper.getTextColor(context),
                                    fontSize: 13,
                                    letterSpacing: 0.2,
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
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ThemeHelper.getLightBlueBackgroundColor(context),
                                      ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: ThemeHelper.getBorderColor(context),
                                      width: 1,
                                    ),
                                  ),
                                ),
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
                                      activeColor: ThemeHelper.primaryBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    if (firstItem.providerImages.isNotEmpty)
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                          image: DecorationImage(
                                            image: NetworkImage(firstItem.providerImages),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: primaryBlue.withOpacity(0.1),
                                          border: Border.all(color: primaryBlue, width: 2),
                                        ),
                                        child: Icon(Icons.business, size: 16, color: primaryBlue),
                                      ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        firstItem.providerName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: ThemeHelper.getPrimaryDarkColor(context),
                                          fontSize: 15,
                                          letterSpacing: 0.1,
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
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark 
                          ? Colors.orange.shade900.withOpacity(0.3)
                          : Colors.orange.shade50,
                      (isDark 
                          ? Colors.orange.shade900.withOpacity(0.3)
                          : Colors.orange.shade50).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark 
                        ? Colors.orange.shade700.withOpacity(0.5)
                        : Colors.orange.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(isDark ? 0.2 : 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.orange.shade800.withOpacity(0.3)
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.local_offer,
                        color: isDark 
                            ? Colors.orange.shade300
                            : Colors.orange.shade700,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final selectedVoucher = ref.watch(selectedVoucherProvider);
                          final selectedTotal = _calculateSelectedTotal(items);
                          
                          return ElevatedButton(
                            onPressed: () {
                              if (!mounted) return;
                              showDialog(
                                context: context,
                                builder: (context) => VoucherDialog(
                                  totalAmount: selectedTotal,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedVoucher != null 
                                  ? (isDark 
                                      ? Colors.green.shade900.withOpacity(0.3)
                                      : Colors.green.shade100)
                                  : ThemeHelper.accentBlue,
                              foregroundColor: selectedVoucher != null 
                                  ? (isDark 
                                      ? Colors.green.shade300
                                      : Colors.green.shade800)
                                  : ThemeHelper.getPrimaryDarkColor(context),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: selectedVoucher != null ? 1 : 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (selectedVoucher != null)
                                  Icon(Icons.check_circle, size: 16, color: Colors.green[800]),
                                if (selectedVoucher != null) const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    selectedVoucher != null 
                                        ? selectedVoucher.code 
                                        : context.tr('select_voucher'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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
                decoration: BoxDecoration(
                  color: ThemeHelper.getCardBackgroundColor(context),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeHelper.getShadowColor(context),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Summary
                        Consumer(
                          builder: (context, ref, child) {
                            final selectedVoucher = ref.watch(selectedVoucherProvider);
                            final voucherDiscount = selectedVoucher != null
                                ? selectedVoucher.calculateDiscount(selectedTotal)
                                : 0.0;
                            final finalTotal = selectedTotal - voucherDiscount;

                            return Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: ThemeHelper.getLightBackgroundColor(context),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ThemeHelper.getBorderColor(context),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle_outline,
                                              size: 14,
                                              color: ThemeHelper.getSecondaryIconColor(context),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${context.tr('selected_count')} $selectedCount',
                                              style: TextStyle(
                                                color: ThemeHelper.getSecondaryTextColor(context),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          context.tr('temporary_total'),
                                          style: TextStyle(
                                            color: ThemeHelper.getTertiaryTextColor(context),
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          '${_formatPrice(selectedTotal)}₫',
                                          style: TextStyle(
                                            color: ThemeHelper.getTextColor(context),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (selectedVoucher != null && voucherDiscount > 0) ...[
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isDark 
                                                  ? Colors.green.shade900.withOpacity(0.3)
                                                  : Colors.green.shade50,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.local_offer,
                                                  size: 12,
                                                  color: isDark 
                                                      ? Colors.green.shade300
                                                      : Colors.green.shade700,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  '${context.tr('discount_prefix')} -${_formatPrice(voucherDiscount)}₫',
                                                  style: TextStyle(
                                                    color: isDark 
                                                        ? Colors.green.shade300
                                                        : Colors.green.shade700,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        context.tr('total_amount'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: ThemeHelper.getTertiaryTextColor(context),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_formatPrice(finalTotal)}₫',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade400,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        // Chọn tất cả và Đặt Dịch Vụ
                        Row(
                          children: [
                            // Chọn tất cả
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _selectAll,
                                  onChanged: _toggleSelectAll,
                                  activeColor: ThemeHelper.primaryBlue,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Text(
                                  context.tr('select_all'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: ThemeHelper.getTextColor(context),
                                  ),
                ),
                              ],
              ),
                            const Spacer(),
                            // Đặt Dịch Vụ Button
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: selectedCount > 0
                                    ? () {
                                        if (!mounted) return;
                                        // Đánh dấu đã navigate đến checkout
                                        _hasNavigatedToCheckout = true;
                                        // Truyền selected item IDs qua extra
                                        context.push(
                                          Routes.checkout,
                                          extra: _selectedItems.toList(),
                                        ).then((_) {
                                          // Khi quay lại từ checkout, clear voucher
                                          if (mounted && _hasNavigatedToCheckout) {
                                            ref.read(selectedVoucherProvider.notifier).clear();
                                            _hasNavigatedToCheckout = false;
                                          }
                                        });
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedCount > 0 
                                      ? ThemeHelper.getPrimaryColor(context)
                                      : (isDark 
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade400),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: selectedCount > 0 ? 4 : 0,
                                  shadowColor: selectedCount > 0 
                                      ? ThemeHelper.getPrimaryColor(context).withOpacity(0.3)
                                      : Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.shopping_bag_rounded, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      context.tr('proceed_to_checkout'),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: ThemeHelper.getLightBlueBackgroundColor(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: ThemeHelper.getPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
                context.tr('empty_cart'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeHelper.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('add_service_to_cart_message'),
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(Routes.listService),
              icon: const Icon(Icons.search_rounded, size: 20),
              label: Text(
                context.tr('find_service'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHelper.getPrimaryColor(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
