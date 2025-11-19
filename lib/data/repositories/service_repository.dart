import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:vhs_mobile_user/data/dao/service_dao.dart';
import 'package:vhs_mobile_user/data/database/service_database.dart';
import 'package:vhs_mobile_user/data/models/service/service_model.dart';
import 'package:vhs_mobile_user/data/services/service_api.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final api = ref.watch(serviceApiProvider);
  final db = ServiceDatabase();
  final dao = db.serviceDao;
  return ServiceRepository(api, dao);
});

class ServiceRepository {
  final ServiceApi _api;
  final ServiceDao _dao;

  ServiceRepository(this._api, this._dao);

  /// Fetch từ DB nếu có, nếu forceRefresh thì gọi API
  Future<List<ServiceModel>> getAll({bool forceRefresh = false}) async {
    final local = await _dao.getAll();

    if (local.isNotEmpty && !forceRefresh) {
      return _mapEntities(local);
    }

    final raw = await _api.fetchHomeServicesRaw();
    final list = raw.map((m) => ServiceModel.fromJson(m)).toList();

    // Lưu vào DB
    await _dao.clearAll();
    await _dao.insertAll(list.map(_toCompanion).toList());
    return list;
  }

  Future<List<ServiceModel>> search(String keyword) async {
    final result = await _dao.search(keyword);
    return _mapEntities(result);
  }

  Future<List<ServiceModel>> filter(String categoryId) async {
    final result = await _dao.filterByCategory(categoryId);
    return _mapEntities(result);
  }

  Future<List<ServiceModel>> sortByPrice({bool ascending = true}) async {
    final result = await _dao.sortByPrice(ascending: ascending);
    return _mapEntities(result);
  }

  Future<List<ServiceModel>> queryFiltered({
    String? keyword,
    String? categoryId,
    bool? sortAsc,
  }) async {
    final result = await _dao.queryFiltered(
      keyword: keyword,
      categoryId: categoryId,
      sortAsc: sortAsc,
    );
    return _mapEntities(result);
  }

  Future<List<ServiceModel>> getPage({
    required int limit,
    required int offset,
    String? keyword,
    String? categoryId,
    bool? sortAsc,
  }) async {
    final entities = await _dao.getPage(
      limit: limit,
      offset: offset,
      keyword: keyword,
      categoryId: categoryId,
      sortAsc: sortAsc,
    );
    return _mapEntities(entities);
  }

  void invalidateCache() async {
    await _dao.clearAll();
  }

  // Helper chuyển entity ↔ model
  List<ServiceModel> _mapEntities(List<ServiceEntity> entities) {
    return entities
        .map(
          (e) => ServiceModel(
            serviceId: e.serviceId,
            providerId: e.providerId,
            categoryId: e.categoryId,
            title: e.title,
            description: e.description,
            price: e.price,
            unitType: e.unitType,
            baseUnit: e.baseUnit,
            images: e.images,
            averageRating: e.averageRating,
            totalReviews: e.totalReviews,
            categoryName: e.categoryName ?? '',
          ),
        )
        .toList();
  }

  ServicesCompanion _toCompanion(ServiceModel s) {
    return ServicesCompanion.insert(
      serviceId: s.serviceId,
      providerId: s.providerId,
      categoryId: s.categoryId,
      title: s.title,
      description: Value(s.description),
      price: s.price,
      unitType: s.unitType,
      baseUnit: Value(s.baseUnit),
      images: Value(s.images),
      averageRating: Value(s.averageRating),
      totalReviews: Value(s.totalReviews),
      categoryName: Value(s.categoryName),
    );
  }
}
