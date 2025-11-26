import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_create_model.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_model.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_update_model.dart';
import 'package:vhs_mobile_user/data/repositories/user_address_repository.dart';

final userAddressProvider =
    AsyncNotifierProvider<UserAddressNotifier, List<UserAddressModel>>(
  UserAddressNotifier.new,
);

class UserAddressNotifier
    extends AsyncNotifier<List<UserAddressModel>> {
  late final UserAddressRepository _repo;

  @override
  Future<List<UserAddressModel>> build() async {
    _repo = ref.read(userAddressRepositoryProvider);
    return _repo.fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetch());
  }

  Future<void> add(UserAddressCreateModel dto) async {
    await _repo.create(dto);
    await refresh();
  }

  Future<void> edit(String id, UserAddressUpdateModel dto) async {
    await _repo.update(id, dto);
    await refresh();
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    await refresh();
  }
}
