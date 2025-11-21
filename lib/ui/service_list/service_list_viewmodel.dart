import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/service/service_model.dart';
import 'package:vhs_mobile_user/data/repositories/service_repository.dart';

final serviceListProvider =
    AsyncNotifierProvider<ServiceListNotifier, List<ServiceModel>>(
  ServiceListNotifier.new,
);

class ServiceListNotifier extends AsyncNotifier<List<ServiceModel>> {
  late final ServiceRepository _repo;

  // Pagination config
  static const int _pageSize = 20;
  int _currentOffset = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  // Filters/search/sort
  String? _query;
  String? _categoryId;
  bool? _sortAsc;

  @override
  Future<List<ServiceModel>> build() async {
    _repo = ref.read(serviceRepositoryProvider);
    return await _loadPage(reset: true);
  }

  /// Refresh toàn bộ danh sách (force fetch nếu cần)
  Future<void> refresh() async {
    await _loadPage(reset: true, forceRefresh: true);
  }

  /// Lazy load (load trang tiếp theo)
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;

    try {
      final more = await _repo.getPage(
        limit: _pageSize,
        offset: _currentOffset,
        keyword: _query,
        categoryId: _categoryId,
        sortAsc: _sortAsc,
      );

      if (more.isEmpty) {
        _hasMore = false;
      } else {
        final current = state.maybeMap(
          data: (data) => data.value,
          orElse: () => [],
        );
        _currentOffset += more.length;
        state = AsyncData([...current, ...more]);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Search (theo keyword)
  Future<void> search(String keyword) async {
    _query = keyword.trim().isEmpty ? null : keyword.trim();
    await _loadPage(reset: true);
  }

  /// Filter theo categoryId
  Future<void> filterByCategory(String? categoryId) async {
    _categoryId = (categoryId == null || categoryId.isEmpty) ? null : categoryId;
    await _loadPage(reset: true);
  }

  /// Sort theo giá (asc/desc)
  Future<void> sortByPrice(bool? sortAsc) async {
    _sortAsc = sortAsc;
    await _loadPage(reset: true);
  }

  /// Xóa toàn bộ filter/search/sort
  Future<void> clearFilters() async {
    _query = null;
    _categoryId = null;
    _sortAsc = null;
    await _loadPage(reset: true);
  }

  /// Load trang đầu tiên hoặc refresh
  Future<List<ServiceModel>> _loadPage({
    bool reset = false,
    bool forceRefresh = false,
  }) async {
    if (reset) {
      _currentOffset = 0;
      _hasMore = true;
      state = const AsyncLoading();
    }

    try {
      final page = await _repo.getPage(
        limit: _pageSize,
        offset: _currentOffset,
        keyword: _query,
        categoryId: _categoryId,
        sortAsc: _sortAsc,
      );

      if (reset) {
        _currentOffset = page.length;
        _hasMore = page.length == _pageSize;
        state = AsyncData(page);
      }

      return page;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Invalidate cache (xóa DB) và load lại
  Future<void> invalidateAndReload() async {
    _repo.invalidateCache();
    await _loadPage(reset: true, forceRefresh: true);
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}
