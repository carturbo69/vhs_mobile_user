import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/user_address_dao.dart';
import 'package:vhs_mobile_user/data/database/app_database.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_create_model.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_model.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_update_model.dart';
import 'package:vhs_mobile_user/data/services/user_address_api.dart';

class UserAddressRepository {
  final UserAddressApi api;
  final UserAddressDao dao;

  UserAddressRepository({required this.api, required this.dao});

  Future<List<UserAddressModel>> fetch() async {
    final list = await api.getAll();

    await dao.clear();
    if (list.isNotEmpty) {
      await dao.saveAll(
        list.map((e) {
          return UserAddressTableCompanion(
            addressId: Value(e.addressId),
            provinceName: Value(e.provinceName),
            districtName: Value(e.districtName),
            wardName: Value(e.wardName),
            streetAddress: Value(e.streetAddress),
            recipientName: Value(e.recipientName),
            recipientPhone: Value(e.recipientPhone),
            latitude: Value(e.latitude),
            longitude: Value(e.longitude),
            createdAt: Value(e.createdAt),
            fullAddress: Value(e.fullAddress),
          );
        }).toList(),
      );
    }
    return list;
  }

  Future<void> create(UserAddressCreateModel dto) => api.create(dto.toJson());

  Future<void> update(String id, UserAddressUpdateModel dto) =>
      api.update(id, dto.toJson());

  Future<void> delete(String id) => api.delete(id);
}

final userAddressRepositoryProvider = Provider<UserAddressRepository>((ref) {
  final api = ref.watch(userAddressApiProvider);
  final dao = ref.watch(userAddressDaoProvider);
  return UserAddressRepository(api: api, dao: dao);
});
