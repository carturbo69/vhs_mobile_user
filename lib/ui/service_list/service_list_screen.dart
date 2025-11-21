// lib/ui/service_list_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/service_list/service_list_viewmodel.dart';

import 'service_card.dart';

class ServiceListScreen extends ConsumerStatefulWidget {
  const ServiceListScreen({super.key});

  @override
  ConsumerState<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends ConsumerState<ServiceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  bool? _sortAsc; // null => no sort, true => asc, false => desc

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final q = _searchController.text.trim();
      ref.read(serviceListProvider.notifier).search(q);
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(serviceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dịch vụ nổi bật'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(serviceListProvider.notifier).refresh(),
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _onSearchChanged(),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm dịch vụ...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(serviceListProvider.notifier)
                                    .search('');
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Filter button (category) - simple dropdown example
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (val) {
                    setState(() {
                      _selectedCategory = val == 'all' ? null : val;
                    });
                    ref
                        .read(serviceListProvider.notifier)
                        .filterByCategory(_selectedCategory);
                  },
                  itemBuilder: (ctx) => <PopupMenuEntry<String>>[
                    const PopupMenuItem(value: 'all', child: Text('Tất cả')),
                    const PopupMenuItem(
                      value: 'cat1',
                      child: Text('Category 1'),
                    ),
                    const PopupMenuItem(
                      value: 'cat2',
                      child: Text('Category 2'),
                    ),
                    // TODO: replace static categories with dynamic categories from repo/DB
                  ],
                ),
                const SizedBox(width: 8),
                // Sort button (toggle: none -> asc -> desc -> none)
                IconButton(
                  icon: Icon(
                    _sortAsc == null
                        ? Icons.sort
                        : (_sortAsc!
                              ? Icons.arrow_upward
                              : Icons.arrow_downward),
                  ),
                  onPressed: () {
                    setState(() {
                      if (_sortAsc == null)
                        _sortAsc = true;
                      else if (_sortAsc == true)
                        _sortAsc = false;
                      else
                        _sortAsc = null;
                    });
                    ref
                        .read(serviceListProvider.notifier)
                        .sortByPrice(_sortAsc);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (services) {
          if (services.isEmpty) {
            return Center(child: Text('Không có kết quả'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(serviceListProvider.notifier).refresh();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: services.length,
                itemBuilder: (context, idx) {
                  final s = services[idx];
                  return ServiceCard(
                    service: s,
                    // Navigate to detail page
                    onTap: () =>
                        context.push(Routes.detailServicePath(s.serviceId)),
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
