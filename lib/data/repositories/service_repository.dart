import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:vhs_mobile_user/data/dao/service_dao.dart';
import 'package:vhs_mobile_user/data/database/app_database.dart';
import 'package:vhs_mobile_user/data/models/service/service_detail.dart';
import 'package:vhs_mobile_user/data/models/service/service_model.dart';
import 'package:vhs_mobile_user/data/services/service_api.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final api = ref.read(serviceApiProvider);
  final dao = ref.read(servicesDaoProvider);
  return ServiceRepository( api,  dao);
});

// service_repository.dart


class ServiceRepository {
  final ServiceApi _api;
  final ServicesDao _dao;

  ServiceRepository(  this._api,  this._dao );

  /// Fetch from network and cache into drift. Return the fresh list.
  Future<List<ServiceModel>> fetchAndCacheServices() async {
    final list = await _api.fetchHomePageServices();
    try {
      await _dao.upsertServices(list);
    } catch (e) {
      // Nếu database connection đã đóng, bỏ qua việc cache nhưng vẫn trả về data từ API
      if (e.toString().contains('connection was closed') || 
          e.toString().contains('Bad state')) {
        print("⚠️ Database connection closed, skipping cache but returning API data");
      } else {
        rethrow;
      }
    }
    return list;
  }

  /// Load from local cache
  Future<List<ServiceModel>> getCachedServices() async {
    try {
      return await _dao.getAllServices();
    } catch (e) {
      // Nếu database connection đã đóng hoặc chưa được tạo, trả về empty list
      if (e.toString().contains('connection was closed') || 
          e.toString().contains('Bad state')) {
        print("⚠️ Database connection closed, returning empty cache");
        return [];
      }
      rethrow;
    }
  }
  Future<ServiceDetail> getServiceDetail(String id) async {
  return _api.getDetail(id);
}

}
  