// lib/viewmodels/auth_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/repositories/auth_repository.dart';
import 'package:vhs_mobile_user/data/models/auth/auth_model.dart';


final authStateProvider = AsyncNotifierProvider<AuthNotifier, LoginRespond?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<LoginRespond?> {
  late final AuthRepository _repo;

  @override
  Future<LoginRespond?> build() async {
    _repo = ref.read(authRepositoryProvider);
    // load saved auth from DB if exists (fast startup)
    final saved = await _repo.getSavedAuth();
    if (saved == null) return null;
    final token = saved['token'] as String?;
    final role = saved['role'] as String?;
    final accountId = saved['accountId'] as String?;
    if (token == null) return null;
    return LoginRespond(token: token, role: role ?? '', accountId: accountId ?? '');
  }

  Future<void> register(String username, String password, String email) async {
    state = const AsyncLoading();
    try {
      final msg = await _repo.register(RegisterRequest(username: username, password: password, email: email));
      // keep state as previous or null; return success via message or throw?
      state = AsyncData(state.value);
      // You can surface msg via UI (return or event). Here we just set to existing.
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    try {
      final resp = await _repo.login(LoginRequest(username: username, password: password));
      state = AsyncData(resp);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> loginWithGoogle(String idToken) async {
    state = const AsyncLoading();
    try {
      final resp = await _repo.loginWithGoogle(idToken);
      state = AsyncData(resp);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<bool> activateAccount(String email, String otp) async {
  return await _repo.activateAccount(email, otp);
}


  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData(null);
  }

  // OTP / Forgot password flows
  Future<String> resendOtp(String email) => _repo.resendOtp(email);

  Future<String> sendForgotOtp(String email) => _repo.sendForgotOtp(email);

  Future<String> verifyForgotOtp(String email, String otp) => _repo.verifyForgotOtp(email, otp);

  Future<bool> resetPassword(String email, String token, String newPassword) => _repo.resetPassword(email, token, newPassword);
}
