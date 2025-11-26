import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/network/dio_client.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_model.dart';

class UserAddressApi {
  final DioClient _client;

  UserAddressApi(this._client);

  Future<List<UserAddressModel>> getAll() async {
    final res = await _client.instance.get("/api/UserAddress");
    final data = res.data["Data"] as List;
    return data.map((e) => UserAddressModel.fromJson(e)).toList();
  }

  Future<UserAddressModel> getById(String id) async {
    final res = await _client.instance.get("/api/UserAddress/$id");
    return UserAddressModel.fromJson(res.data["Data"]);
  }

  Future<void> create(Map<String, dynamic> dto) async {
    await _client.instance.post("/api/UserAddress", data: dto);
  }

  Future<void> update(String id, Map<String, dynamic> dto) async {
    await _client.instance.put("/api/UserAddress/$id", data: dto);
  }

  Future<void> delete(String id) async {
    await _client.instance.delete("/api/UserAddress/$id");
  }
}

final userAddressApiProvider = Provider<UserAddressApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return UserAddressApi(dioClient);
});