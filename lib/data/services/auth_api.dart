// lib/data/services/auth_api.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/provider/provider.dart';
import 'package:vhs_mobile_user/data/models/auth/auth_model.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  Future<String> register(RegisterRequest req) async {
    final r = await _dio.post('/api/Auth/register', data: req.toJson());
    // backend returns string message
    return r.data.toString();
  }

  Future<LoginRespond> login(LoginRequest req) async {
    final r = await _dio.post('/api/Auth/login', data: req.toJson());
    return LoginRespond.fromJson(r.data as Map<String, dynamic>);
  }

  Future<LoginRespond> googleLogin(String idToken) async {
    final r = await _dio.post('/api/Auth/google-login', data: {'idToken': idToken});
    return LoginRespond.fromJson(r.data as Map<String, dynamic>);
  }

  Future<String> resendOtp(String email) async {
    final r = await _dio.post('/api/Auth/resend-otp', data: {'email': email});
    return (r.data is Map) ? r.data['message'] ?? r.data.toString() : r.data.toString();
  }

  Future<String> sendForgotOtp(String email) async {
    final r = await _dio.post('/api/Auth/forgot-password/send-otp', data: {'email': email});
    return (r.data is Map) ? r.data['message'] ?? r.data.toString() : r.data.toString();
  }

  Future<String> verifyForgotOtp(String email, String otp) async {
    final r = await _dio.post('/api/Auth/forgot-password/verify-otp', data: {'email': email, 'otp': otp});
    // returns token in response -> r.data['token']
    return r.data['token'] as String;
  }

  Future<bool> resetPassword(String email, String token, String newPassword) async {
    final r = await _dio.post('/api/Auth/reset-password', data: {'email': email, 'token': token, 'password': newPassword});
    // assume backend returns success boolean or object {success:true}
    if (r.data is Map && r.data['success'] != null) return r.data['success'] == true;
    return r.statusCode == 200;
  }
  Future<bool> activateAccount(String email, String otp) async {
  final r = await _dio.post("/api/Auth/activate-account", data: {
    "email": email,
    "otp": otp,
  });

  if (r.data["success"] == true) return true;
  return false;
}

}
final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthApi(dio);
});