import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/service_shop/service_shop_models.dart';
import 'package:vhs_mobile_user/data/repositories/service_shop_repository.dart';

final serviceShopProvider = FutureProvider.family<ServiceShopViewModel, ServiceShopParams>(
  (ref, params) async {
    final repo = ref.read(serviceShopRepositoryProvider);
    return await repo.getServiceShop(
      providerId: params.providerId,
      categoryId: params.categoryId,
      tagId: params.tagId,
      sortBy: params.sortBy,
      page: params.page,
    );
  },
);

class ServiceShopParams {
  final String providerId;
  final int? categoryId;
  final String? tagId;
  final String sortBy;
  final int page;

  ServiceShopParams({
    required this.providerId,
    this.categoryId,
    this.tagId,
    this.sortBy = 'popular',
    this.page = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceShopParams &&
          runtimeType == other.runtimeType &&
          providerId == other.providerId &&
          categoryId == other.categoryId &&
          tagId == other.tagId &&
          sortBy == other.sortBy &&
          page == other.page;

  @override
  int get hashCode =>
      providerId.hashCode ^
      categoryId.hashCode ^
      tagId.hashCode ^
      sortBy.hashCode ^
      page.hashCode;
}

