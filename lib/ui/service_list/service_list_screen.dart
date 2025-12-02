import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/ui/service_list/service_card.dart';

import 'service_list_viewmodel.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/cart/cart_list_viewmodel.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';

// Màu xanh theo web - Sky blue palette
const Color primaryBlue = Color(0xFF0284C7); // Sky-600
const Color darkBlue = Color(0xFF0369A1); // Sky-700
const Color lightBlue = Color(0xFFE0F2FE); // Sky-100
const Color accentBlue = Color(0xFFBAE6FD); // Sky-200

class ServiceListScreen extends ConsumerStatefulWidget {
  const ServiceListScreen({super.key});

  @override
  ConsumerState<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends ConsumerState<ServiceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  String? _category;
  bool _showAll = false; // Track xem đã mở rộng để xem tất cả chưa

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _showAll = false; // Reset khi search thay đổi
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref
          .read(serviceListProvider.notifier)
          .search(_searchController.text.trim());
    });
  }

  List<Widget> _buildServiceListSlivers(List list) {
    // Giới hạn hiển thị 20 items nếu chưa mở rộng
    final displayCount = _showAll || list.length <= 20 
        ? list.length 
        : 20;
    final hasMore = list.length > 20 && !_showAll;

    final slivers = <Widget>[
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        sliver: SliverMasonryGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (context, index) {
            final item = list[index];
            return ServiceCard(
              service: item,
              onTap: () =>
                  context.push(Routes.detailServicePath(item.serviceId)),
            );
          },
          childCount: displayCount,
        ),
      ),
    ];

    // Thêm nút "Xem thêm" nếu có hơn 20 items
    if (hasMore) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showAll = true;
                  });
                },
                icon: const Icon(Icons.expand_more_rounded, size: 22),
                label: Text(
                  "Xem thêm ${list.length - 20} dịch vụ",
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
            ),
          ),
        ),
      );
    }

    // Nếu đã mở rộng, thêm padding bottom
    if (_showAll) {
      slivers.add(
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      );
    }

    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(serviceListProvider);

    final isDark = ThemeHelper.isDarkMode(context);
    
    return Scaffold(
      backgroundColor: ThemeHelper.getScaffoldBackgroundColor(context),
      body: RefreshIndicator(
        onRefresh: () => ref.read(serviceListProvider.notifier).refresh(),
        color: primaryBlue,
        child: CustomScrollView(
          slivers: [
            // Modern App Bar with Gradient
            SliverAppBar(
              expandedHeight: 0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              toolbarHeight: 56,
              title: const Text(
                "Danh sách dịch vụ",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
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
              iconTheme: const IconThemeData(color: Colors.white),
        actions: [
                // Nút giỏ hàng với badge số lượng
                Consumer(
                  builder: (context, ref, child) {
                    final cartAsync = ref.watch(cartProvider);
                    final cartCount = cartAsync.when(
                      data: (items) => items.length,
                      loading: () => 0,
                      error: (_, __) => 0,
                    );

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                            onPressed: () {
                              // Luôn dùng go để tránh duplicate keys với StatefulShellRoute
                              // Lưu route hiện tại để có thể quay lại
                              final currentLocation = GoRouterState.of(context).matchedLocation;
                              if (currentLocation != Routes.cart) {
                                // Lưu route hiện tại vào extra để có thể quay lại
                                context.go(Routes.cart, extra: {'previousRoute': currentLocation});
                              }
                            },
                            tooltip: 'Giỏ hàng',
                          ),
                        ),
                        if (cartCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: cartCount > 9 ? 6 : 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.4),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                cartCount > 99 ? '99+' : cartCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () => ref.read(serviceListProvider.notifier).refresh(),
                    tooltip: 'Làm mới',
                  ),
                ),
              ],
            ),

            // Search and Filter Section
            SliverToBoxAdapter(
              child: Container(
                color: ThemeHelper.getCardBackgroundColor(context),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    // Modern Search Box
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: ThemeHelper.getCardBackgroundColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ThemeHelper.getBorderColor(context),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeHelper.getShadowColor(context),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) {
                            _onSearchChanged();
                            setState(() {});
                          },
                          style: TextStyle(color: ThemeHelper.getTextColor(context)),
                          decoration: InputDecoration(
                            hintText: "Tìm kiếm dịch vụ...",
                            hintStyle: TextStyle(color: ThemeHelper.getTertiaryTextColor(context)),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark 
                                    ? Colors.blue.shade900.withOpacity(0.3)
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.search,
                                color: ThemeHelper.getPrimaryColor(context),
                                size: 20,
                              ),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: ThemeHelper.getSecondaryIconColor(context),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref
                                          .read(serviceListProvider.notifier)
                                          .clearFiltersAndSearch();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: ThemeHelper.getInputBackgroundColor(context),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: ThemeHelper.getPrimaryColor(context),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Modern Filter Button
                    Builder(
                      builder: (context) {
                        // Get all unique categories from services
                        final categories = asyncList.when(
                          data: (state) {
                            final uniqueCategories = <String, String>{};
                            for (var service in state.items) {
                              if (service.categoryId.isNotEmpty && 
                                  service.categoryName.isNotEmpty) {
                                uniqueCategories[service.categoryId] = service.categoryName;
                              }
                            }
                            return uniqueCategories.entries.toList()
                              ..sort((a, b) => a.value.compareTo(b.value));
                          },
                          loading: () => <MapEntry<String, String>>[],
                          error: (_, __) => <MapEntry<String, String>>[],
                        );

                        return Container(
                          decoration: BoxDecoration(
                            color: _category != null 
                                ? ThemeHelper.getPrimaryColor(context)
                                : ThemeHelper.getCardBackgroundColor(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _category != null 
                                  ? ThemeHelper.getPrimaryColor(context)
                                  : ThemeHelper.getBorderColor(context),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeHelper.getShadowColor(context),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: PopupMenuButton<String>(
                            color: ThemeHelper.getPopupMenuBackgroundColor(context),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            onSelected: (value) {
                              setState(() {
                                _category = value == "all" ? null : value;
                                _showAll = false; // Reset khi filter thay đổi
                              });

                              ref
                                  .read(serviceListProvider.notifier)
                                  .applyFilter(categoryId: _category);
                            },
                            itemBuilder: (_) {
                              final items = <PopupMenuEntry<String>>[
                                PopupMenuItem(
                                  value: "all",
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isDark 
                                              ? Colors.blue.shade900.withOpacity(0.3)
                                              : Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          Icons.clear_all,
                                          size: 18,
                                          color: ThemeHelper.getPrimaryColor(context),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Tất cả",
                                        style: TextStyle(color: ThemeHelper.getTextColor(context)),
                                      ),
                                    ],
                                  ),
                                ),
                              ];
                              
                              if (categories.isNotEmpty) {
                                items.add(const PopupMenuDivider());
                                items.addAll(
                                  categories.map((entry) => PopupMenuItem(
                                    value: entry.key,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: isDark 
                                                ? Colors.blue.shade900.withOpacity(0.3)
                                                : Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            Icons.category,
                                            size: 18,
                                            color: ThemeHelper.getPrimaryColor(context),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            entry.value,
                                            style: TextStyle(color: ThemeHelper.getTextColor(context)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                );
                              }
                              
                              return items;
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.tune_rounded,
                                color: _category != null 
                                    ? Colors.white 
                                    : ThemeHelper.getPrimaryColor(context),
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Content Section
            ...asyncList.when(
              loading: () => [
                SliverFillRemaining(
                  child: Center(
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
                          "Đang tải...",
                          style: TextStyle(
                            color: ThemeHelper.getSecondaryTextColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              error: (e, _) => [
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
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
                            "Đã xảy ra lỗi",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ThemeHelper.getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$e",
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeHelper.getSecondaryTextColor(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () => ref.read(serviceListProvider.notifier).refresh(),
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            label: const Text(
                              "Thử lại",
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
                ),
              ],
        data: (state) {
          final list = state.filtered;

          if (list.isEmpty) {
                  return [
                    SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: isDark 
                                      ? Colors.blue.shade900.withOpacity(0.3)
                                      : Colors.blue.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                  color: ThemeHelper.getPrimaryColor(context),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "Không tìm thấy kết quả",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeHelper.getTextColor(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Thử tìm kiếm với từ khóa khác",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ThemeHelper.getSecondaryTextColor(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];
                }

                return _buildServiceListSlivers(list);
                },
              ),
          ],
        ),
      ),
    );
  }
}
