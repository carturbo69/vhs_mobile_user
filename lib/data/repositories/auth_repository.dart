// lib/data/repositories/auth_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/auth/auth_model.dart';

import 'package:vhs_mobile_user/data/services/auth_api.dart';
  
class AuthRepository {
  final AuthApi api;
  final AuthDao dao;
  AuthRepository({required this.api, required this.dao});

  Future<String> register(RegisterRequest req) => api.register(req);

  Future<LoginRespond> login(LoginRequest req) async {
    final resp = await api.login(req);
    await dao.upsertLogin(token: resp.token, role: resp.role, accountId: resp.accountId);
    return resp;
  }

  Future<LoginRespond> loginWithGoogle(String idToken) async {
    final resp = await api.googleLogin(idToken);
    await dao.upsertLogin(token: resp.token, role: resp.role, accountId: resp.accountId);
    return resp;
  }

  Future<void> logout() async {
    await dao.clearAuth();
  }

  Future<Map<String, dynamic>?> getSavedAuth() => dao.getSavedAuth();

  Future<String> resendOtp(String email) => api.resendOtp(email);

  Future<String> sendForgotOtp(String email) => api.sendForgotOtp(email);

  Future<String> verifyForgotOtp(String email, String otp) => api.verifyForgotOtp(email, otp);

  Future<bool> resetPassword(String email, String token, String newPassword) => api.resetPassword(email, token, newPassword);
Future<bool> activateAccount(String email, String otp) async {
  return await api.activateAccount(email, otp);
}

}
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.read(authApiProvider);
  final dao = ref.read(authDaoProvider);
  return AuthRepository(api: api, dao: dao);
});
