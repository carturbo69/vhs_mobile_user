import 'dart:io';
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

  Future<bool> updateProfile({
    required String accountName,
    required String email,
    String? fullName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final updated = await _repo.updateProfile(
        accountName: accountName,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
      );
      state = AsyncValue.data(updated);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<String?> requestPasswordChangeOTP() async {
    try {
      return await _repo.requestPasswordChangeOTP();
    } catch (e) {
      return null;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    required String otp,
  }) async {
    try {
      return await _repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        otp: otp,
      );
    } catch (e) {
      return false;
    }
  }

  Future<String?> requestEmailChangeOTP() async {
    try {
      return await _repo.requestEmailChangeOTP();
    } catch (e) {
      return null;
    }
  }

  Future<bool> changeEmail({
    required String newEmail,
    required String otpCode,
  }) async {
    try {
      final success = await _repo.changeEmail(
        newEmail: newEmail,
        otpCode: otpCode,
      );
      if (success) {
        await refresh();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadImage(File file) async {
    try {
      final updated = await _repo.uploadImage(file);
      state = AsyncValue.data(updated);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteImage() async {
    try {
      final success = await _repo.deleteImage();
      if (success) {
        await refresh();
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}
