import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:vhs_mobile_user/data/dao/service_dao.dart';
import 'package:vhs_mobile_user/data/database/service_database.dart';
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
    await _dao.upsertServices(list);
    return list;
  }

  /// Load from local cache
  Future<List<ServiceModel>> getCachedServices() {
    return _dao.getAllServices();
  }
  Future<ServiceDetail> getServiceDetail(String id) async {
  return _api.getDetail(id);
}

}
  