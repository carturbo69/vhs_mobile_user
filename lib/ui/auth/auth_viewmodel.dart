// lib/viewmodels/auth_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/repositories/auth_repository.dart';
import 'package:vhs_mobile_user/data/models/auth/auth_model.dart';
import 'package:vhs_mobile_user/data/database/app_database.dart';


final authStateProvider = AsyncNotifierProvider<AuthNotifier, LoginRespond?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<LoginRespond?> {
  late final AuthRepository _repo;

  @override
  Future<LoginRespond?> build() async {
    _repo = ref.read(authRepositoryProvider);
    
    print("🔄 Đang load auth từ database...");
    
    // Load auth từ database
    final auth = await _repo.getLoggedIn();
    
    if (auth == null) {
      print("ℹ️ Không có auth trong database");
      return null;
    }
    
    print("✅ Đã load auth từ database: ${auth.accountId}");
    
    // Validate token trong background, không block build
    // Trả về auth ngay để app có thể vào home
    // Nếu token không hợp lệ, sẽ xóa auth sau
    _validateTokenInBackground(auth);
    
    return auth;
  }
  
  /// Validate token trong background
  /// Nếu token không hợp lệ, sẽ tự động xóa auth
  Future<void> _validateTokenInBackground(LoginRespond auth) async {
    try {
      print("🔄 Đang validate token với server...");
      final isValid = await _repo.validateToken(auth);
      
      if (!isValid) {
        print("🔴 Token không hợp lệ, tự động xóa auth...");
        // Xóa auth và update state
        await _repo.logout();
        ref.invalidate(appDatabaseProvider);
        state = const AsyncData(null);
      } else {
        print("✅ Token hợp lệ");
      }
    } catch (e) {
      // Nếu có lỗi khi validate (network, etc.), vẫn giữ auth
      print("⚠️ Lỗi khi validate token: $e, giữ nguyên auth");
    }
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
    print("🔐 Bắt đầu login...");
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => _repo.login(LoginRequest(username: username, password: password)),
    );

    if (result.hasValue && result.value != null) {
      print("✅ Login thành công, auth đã được lưu");
    } else {
      print("❌ Login thất bại");
    }

    state = result;
  }

  Future<void> loginWithGoogle(String idToken) async {
    print("🔐 Bắt đầu Google login...");
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => _repo.loginWithGoogle(idToken),
    );

    if (result.hasValue && result.value != null) {
      print("✅ Google login thành công, auth đã được lưu");
    } else {
      print("❌ Google login thất bại");
    }

    state = result;
  }

  Future<bool> activateAccount(String email, String otp) async {
  return await _repo.activateAccount(email, otp);
}


  Future<void> logout() async {
    // Xóa toàn bộ database (auth, profile, services, etc.)
    await _repo.logout();
    
    // Invalidate các provider để clear cache và tạo database mới
    ref.invalidate(appDatabaseProvider);
    
    // Reset state về null
    state = const AsyncData(null);
  }

  // OTP / Forgot password flows
  Future<String> resendOtp(String email) => _repo.resendOtp(email);

  Future<String> sendForgotOtp(String email) => _repo.sendForgotOtp(email);

  Future<String> verifyForgotOtp(String email, String otp) => _repo.verifyForgotOtp(email, otp);

  Future<bool> resetPassword(String email, String token, String newPassword) => _repo.resetPassword(email, token, newPassword);
}
