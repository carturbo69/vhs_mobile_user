import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/service/service_model.dart';
import 'package:vhs_mobile_user/data/repositories/service_repository.dart';

final serviceListProvider =
    AsyncNotifierProvider<ServiceListNotifier, ServiceListState>(() {
      return ServiceListNotifier();
    });
// service_list_viewmodel.dart

class ServiceListState {
  final List<ServiceModel> items; // original cached / fetched
  final List<ServiceModel> filtered; // after search/filter
  final String? query;
  final Map<String, dynamic>?
  filters; // e.g. {'categoryId': '...', 'minPrice': 10, 'maxPrice': 100}
  final bool loadingMore;

  ServiceListState({
    required this.items,
    required this.filtered,
    this.query,
    this.filters,
    this.loadingMore = false,
  });

  ServiceListState copyWith({
    List<ServiceModel>? items,
    List<ServiceModel>? filtered,
    String? query,
    Map<String, dynamic>? filters,
    bool? loadingMore,
  }) {
    return ServiceListState(
      items: items ?? this.items,
      filtered: filtered ?? this.filtered,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  factory ServiceListState.initial() =>
      ServiceListState(items: [], filtered: []);
}

class ServiceListNotifier extends AsyncNotifier<ServiceListState> {
  late  ServiceRepository _repo;

  @override
  Future<ServiceListState> build() async {
    // provider will set repo before use OR use ref.read
    _repo = ref.read(serviceRepositoryProvider);
    
    // Attempt to fetch from network first
    try {
      final fresh = await _repo.fetchAndCacheServices();
      return ServiceListState(items: fresh, filtered: fresh);
    } catch (e) {
      print("⚠️ Error fetching services from API: $e");
      // Fallback to cache if available
      try {
        final cached = await _repo.getCachedServices();
        if (cached.isNotEmpty) {
          return ServiceListState(items: cached, filtered: cached);
        }
      } catch (cacheError) {
        print("⚠️ Error loading from cache: $cacheError");
      }
      // Return empty list if both fail
      return ServiceListState.initial();
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final fresh = await _repo.fetchAndCacheServices();
      state = AsyncValue.data(ServiceListState(items: fresh, filtered: fresh));
    } catch (e, st) {
      final cached = await _repo.getCachedServices();
      state = AsyncValue.error(e, st);
      // also set data from cache so UI can still show items
      // you may choose to return cached separately
      state = AsyncValue.data(
        ServiceListState(items: cached, filtered: cached),
      );
    }
  }

  void search(String q) {
    final cur = state.value ?? ServiceListState.initial();
    final qLower = q.trim().toLowerCase();
    final filtered = cur.items.where((s) {
      final title = s.title.toLowerCase();
      final cat = s.categoryName.toLowerCase();
      return title.contains(qLower) || cat.contains(qLower);
    }).toList();
    state = AsyncValue.data(cur.copyWith(query: q, filtered: filtered));
  }

  void applyFilter({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool onlyActive = true,
  }) {
    final cur = state.value ?? ServiceListState.initial();
    var list = cur.items;
    if (categoryId != null) {
      list = list.where((s) => s.categoryId == categoryId).toList();
    }
    if (minPrice != null) {
      list = list.where((s) => s.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      list = list.where((s) => s.price <= maxPrice).toList();
    }
    if (onlyActive) {
      list = list.where((s) => s.status?.toLowerCase() == 'active').toList();
    }

    // also apply text query if exists
    final q = cur.query;
    if (q != null && q.trim().isNotEmpty) {
      final ql = q.toLowerCase();
      list = list
          .where(
            (s) =>
                s.title.toLowerCase().contains(ql) ||
                s.categoryName.toLowerCase().contains(ql),
          )
          .toList();
    }

    final newFilters = {
      if (categoryId != null) 'categoryId': categoryId,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      'onlyActive': onlyActive,
    };

    state = AsyncValue.data(cur.copyWith(filters: newFilters, filtered: list));
  }

  void clearFiltersAndSearch() {
    final cur = state.value ?? ServiceListState.initial();
    state = AsyncValue.data(
      cur.copyWith(query: null, filters: {}, filtered: cur.items),
    );
  }

  // optional: load next page from cache or api if you support paging.
}
