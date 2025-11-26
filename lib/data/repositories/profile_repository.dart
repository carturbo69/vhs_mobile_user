import 'dart:io';
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

  Future<ProfileModel> updateProfile({
    required String accountName,
    required String email,
    String? fullName,
    String? phoneNumber,
    String? address,
  }) async {
    final updatedProfile = await api.updateProfile(
      accountName: accountName,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      address: address,
    );
    await dao.cacheProfile(updatedProfile);
    return updatedProfile;
  }

  Future<String> requestPasswordChangeOTP() async {
    return await api.requestPasswordChangeOTP();
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    required String otp,
  }) async {
    return await api.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
      otp: otp,
    );
  }

  Future<String> requestEmailChangeOTP() async {
    return await api.requestEmailChangeOTP();
  }

  Future<bool> changeEmail({
    required String newEmail,
    required String otpCode,
  }) async {
    final success = await api.changeEmail(
      newEmail: newEmail,
      otpCode: otpCode,
    );
    if (success) {
      // Refresh profile after email change
      await getProfile();
    }
    return success;
  }

  Future<ProfileModel> uploadImage(File file) async {
    final imageUrl = await api.uploadImage(file);
    // Refresh profile to get updated image
    return await getProfile();
  }

  Future<bool> deleteImage() async {
    final success = await api.deleteImage();
    if (success) {
      // Refresh profile after deleting image
      await getProfile();
    }
    return success;
  }
}
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final api = ref.read(profileApiProvider);
  final dao = ref.read(profileDaoProvider);
  return ProfileRepository(api: api, dao: dao);
});