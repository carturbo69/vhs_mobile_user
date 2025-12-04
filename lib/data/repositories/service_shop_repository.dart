import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/service_shop/service_shop_models.dart';
import 'package:vhs_mobile_user/data/services/service_shop_api.dart';

final serviceShopRepositoryProvider =
    Provider<ServiceShopRepository>((ref) {
  final api = ref.read(serviceShopApiProvider);
  return ServiceShopRepository(api);
});

class ServiceShopRepository {
  final ServiceShopApi _api;

  ServiceShopRepository(this._api);

  Future<ServiceShopViewModel> getServiceShop({
    required String providerId,
    int? categoryId,
    String? tagId,
    String sortBy = 'popular',
    int page = 1,
  }) async {
    return await _api.getServiceShop(
      providerId: providerId,
      categoryId: categoryId,
      tagId: tagId,
      sortBy: sortBy,
      page: page,
    );
  }
}

