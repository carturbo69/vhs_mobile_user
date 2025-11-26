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

  
}
final profileApiProvider = Provider<ProfileApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProfileApi(dioClient);
});
