import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/network/dio_client.dart';
import 'package:vhs_mobile_user/data/models/user/profile_model.dart';

class ProfileApi {
  final DioClient _client;
  ProfileApi(this._client);

  Future<ProfileModel> getProfile() async {
    final resp = await _client.instance.get("/api/Profile");
    return ProfileModel.fromJson(resp.data);
  }

  Future<String> uploadImage(File file) async {
    final form = FormData.fromMap({
      "image": await MultipartFile.fromFile(file.path)
    });

    final resp = await _client.instance.post("/api/Profile/upload-image", data: form);
    return resp.data["imageUrl"];
  }

  Future<bool> deleteImage() async {
    final resp = await _client.instance.delete("/api/Profile/delete-image");
    return resp.data["success"] == true;
  }

  Future<ProfileModel> updateProfile({
    required String accountName,
    required String email,
    String? fullName,
    String? phoneNumber,
    String? address,
  }) async {
    final resp = await _client.instance.put(
      "/api/Profile",
      data: {
        "accountName": accountName,
        "email": email,
        "fullName": fullName,
        "phoneNumber": phoneNumber,
        "address": address,
      },
    );
    
    // Backend trả về ProfileResponseDTO với Data là ViewProfileDTO
    if (resp.data is Map && resp.data["data"] != null) {
      return ProfileModel.fromJson(resp.data["data"] as Map<String, dynamic>);
    }
    throw Exception("Invalid response format");
  }

  Future<String> requestPasswordChangeOTP() async {
    final resp = await _client.instance.post("/api/Profile/request-password-change-otp");
    return resp.data["message"] as String? ?? "OTP sent successfully";
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    required String otp,
  }) async {
    final resp = await _client.instance.post(
      "/api/Profile/change-password",
      data: {
        "currentPassword": currentPassword,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
        "otp": otp,
      },
    );
    return resp.data["success"] == true;
  }

  Future<String> requestEmailChangeOTP() async {
    final resp = await _client.instance.post("/api/Profile/request-email-change-otp");
    return resp.data["message"] as String? ?? "OTP sent successfully";
  }

  Future<bool> changeEmail({
    required String newEmail,
    required String otpCode,
  }) async {
    final resp = await _client.instance.post(
      "/api/Profile/change-email",
      data: {
        "newEmail": newEmail,
        "otpCode": otpCode,
      },
    );
    return resp.data["success"] == true;
  }
}
final profileApiProvider = Provider<ProfileApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProfileApi(dioClient);
});
