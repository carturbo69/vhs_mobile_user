import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/profile_dao.dart';
import 'package:vhs_mobile_user/data/models/user/profile_model.dart';
import 'package:vhs_mobile_user/data/services/profile_api.dart';

class ProfileRepository {
  final ProfileApi api;
  final ProfileDao dao;

  ProfileRepository({
    required this.api,
    required this.dao,
  });

  Future<ProfileModel> getProfile() async {
    final profile = await api.getProfile();
    await dao.cacheProfile(profile); // CACHE TO DRIFT
    return profile;
  }

  Future<ProfileModel?> getCachedProfile() {
    return dao.getCachedProfile();
  }

  
}
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final api = ref.read(profileApiProvider);
  final dao = ref.read(profileDaoProvider);
  return ProfileRepository(api: api, dao: dao);
});