import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/ui/service_list/service_card.dart';

import 'service_list_viewmodel.dart';
import 'package:vhs_mobile_user/routing/routes.dart';

class ServiceListScreen extends ConsumerStatefulWidget {
  const ServiceListScreen({super.key});

  @override
  ConsumerState<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends ConsumerState<ServiceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  String? _category;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref
          .read(serviceListProvider.notifier)
          .search(_searchController.text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(serviceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách dịch vụ"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(serviceListProvider.notifier).refresh(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                // SEARCH BOX
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _onSearchChanged(),
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm dịch vụ...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // CATEGORY FILTER
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() {
                      _category = value == "all" ? null : value;
                    });

                    ref
                        .read(serviceListProvider.notifier)
                        .applyFilter(categoryId: _category);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "all", child: Text("Tất cả")),
                    PopupMenuItem(value: "cat1", child: Text("Danh mục 1")),
                    PopupMenuItem(value: "cat2", child: Text("Danh mục 2")),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      body: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Lỗi: $e")),
        data: (state) {
          final list = state.filtered; 

          if (list.isEmpty) {
            return const Center(child: Text("Không có kết quả"));
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(serviceListProvider.notifier).refresh(),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                itemCount: list.length,
                itemBuilder: (_, index) {
                  final item = list[index];
                  return ServiceCard(
                    service: item,
                    onTap: () =>
                        context.push(Routes.detailServicePath(item.serviceId)),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
