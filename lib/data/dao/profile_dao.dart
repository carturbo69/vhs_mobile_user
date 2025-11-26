import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/database/profile_table.dart';
import 'package:vhs_mobile_user/data/database/app_database.dart';
import 'package:vhs_mobile_user/data/models/user/profile_model.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: [ProfileTable])
class ProfileDao extends DatabaseAccessor<AppDatabase>
    with _$ProfileDaoMixin {
  ProfileDao(AppDatabase db) : super(db);

  Future<void> cacheProfile(ProfileModel p) async {
    await into(profileTable).insertOnConflictUpdate(
      ProfileTableCompanion(
        userId: Value(p.userId),
        accountId: Value(p.accountId),
        accountName: Value(p.accountName),
        email: Value(p.email),
        role: Value(p.role),
        fullName: Value(p.fullName),
        phoneNumber: Value(p.phoneNumber),
        images: Value(p.images),
        address: Value(p.address),
      ),
    );
  }

  Future<ProfileModel?> getCachedProfile() async {
    final data = await select(profileTable).getSingleOrNull();
    return data != null ? ProfileModel.fromDrift(data) : null;
  }
}
final profileDaoProvider = Provider<ProfileDao>((ref) {
  final db = ref.read(appDatabaseProvider);
  return ProfileDao(db);
});
