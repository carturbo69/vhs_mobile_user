import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/profile_dao.dart';
import 'package:vhs_mobile_user/data/models/user/profile_model.dart';
import 'package:vhs_mobile_user/data/repositories/profile_repository.dart';
import 'package:vhs_mobile_user/data/services/profile_api.dart';

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileModel>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<ProfileModel> {
  late  ProfileRepository _repo;

  @override
  Future<ProfileModel> build() async {
    _repo = ProfileRepository(
      api: ref.read(profileApiProvider),
      dao: ref.read(profileDaoProvider),
    );

    return _repo.getProfile();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getProfile());
  }

 
}
