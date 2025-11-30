import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/ui/service_list/service_card.dart';

import 'service_list_viewmodel.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/cart/cart_list_viewmodel.dart';

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
                icon: const Icon(Icons.expand_more, size: 20),
                label: Text(
                  "Xem thêm ${list.length - 20} dịch vụ",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
              backgroundColor: primaryBlue,
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
                    colors: [primaryBlue, darkBlue],
                  ),
                ),
              ),
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
                        IconButton(
                          icon: const Icon(Icons.shopping_cart, color: Colors.white),
                          onPressed: () => context.push(Routes.cart),
                          tooltip: 'Giỏ hàng',
                        ),
                        if (cartCount > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                cartCount > 99 ? '99+' : cartCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
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
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => ref.read(serviceListProvider.notifier).refresh(),
                  tooltip: 'Làm mới',
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Search and Filter Section
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    // Modern Search Box
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
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
                          decoration: InputDecoration(
                            hintText: "Tìm kiếm dịch vụ...",
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon: Icon(Icons.search, color: primaryBlue),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: Colors.grey[600]),
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
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
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
                            color: _category != null ? primaryBlue : Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: PopupMenuButton<String>(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                const PopupMenuItem(
                                  value: "all",
                                  child: Row(
                                    children: [
                                      Icon(Icons.clear_all, size: 20),
                                      SizedBox(width: 12),
                                      Text("Tất cả"),
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
                                        Icon(Icons.category, size: 20, color: primaryBlue),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            entry.value,
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
                                Icons.tune,
                                color: _category != null ? Colors.white : primaryBlue,
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
                          valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Đang tải...",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Đã xảy ra lỗi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$e",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => ref.read(serviceListProvider.notifier).refresh(),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Thử lại"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Không tìm thấy kết quả",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Thử tìm kiếm với từ khóa khác",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
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
