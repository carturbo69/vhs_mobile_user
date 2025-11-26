// lib/viewmodels/auth_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/repositories/auth_repository.dart';
import 'package:vhs_mobile_user/data/models/auth/auth_model.dart';
import 'package:vhs_mobile_user/data/database/app_database.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/dao/profile_dao.dart';
import 'package:vhs_mobile_user/data/dao/service_dao.dart';
import 'package:vhs_mobile_user/data/dao/user_address_dao.dart';
import 'package:vhs_mobile_user/helper/google_sign_in_helper.dart';
import 'package:vhs_mobile_user/core/network/dio_client.dart';
import 'package:vhs_mobile_user/ui/profile/profile_viewmodel.dart';
import 'package:vhs_mobile_user/ui/history/history_viewmodel.dart';
import 'package:vhs_mobile_user/ui/service_list/service_list_viewmodel.dart';
import 'package:vhs_mobile_user/ui/service_detail/service_detail_viewmodel.dart';
import 'package:vhs_mobile_user/ui/user_address/user_address_viewmodel.dart';


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
      // Refresh service list sau khi login thành công (async, không block)
      _refreshDataAfterLogin();
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
      // Refresh service list sau khi login thành công (async, không block)
      _refreshDataAfterLogin();
    } else {
      print("❌ Google login thất bại");
    }

    state = result;
  }

  Future<void> registerWithGoogle(String idToken) async {
    print("🔐 Bắt đầu Google registration...");
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => _repo.loginWithGoogle(idToken), // Backend tự động đăng ký nếu chưa có tài khoản
    );

    if (result.hasValue && result.value != null) {
      print("✅ Google registration thành công, auth đã được lưu");
      // Refresh service list sau khi đăng ký thành công (async, không block)
      _refreshDataAfterLogin();
    } else {
      print("❌ Google registration thất bại");
    }

    state = result;
  }

  /// Refresh các provider sau khi login thành công
  void _refreshDataAfterLogin() async {
    // Đợi một chút để đảm bảo database đã được tạo lại hoàn toàn
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Đảm bảo database được tạo bằng cách đọc appDatabaseProvider
    try {
      final db = ref.read(appDatabaseProvider);
      // Đợi thêm một chút để database được khởi tạo hoàn toàn
      await Future.delayed(const Duration(milliseconds: 200));
      print("✅ Database đã sẵn sàng, bắt đầu refresh providers");
    } catch (e) {
      print("⚠️ Lỗi khi đọc database: $e");
    }
    
    // Invalidate và refresh service list để load lại dữ liệu
    ref.invalidate(serviceListProvider);
    // Invalidate profile để load lại profile mới
    ref.invalidate(profileProvider);
    // Invalidate history để load lại lịch sử
    ref.invalidate(historyProvider);
    // Invalidate user addresses để load lại địa chỉ
    ref.invalidate(userAddressProvider);
    print("✅ Đã refresh tất cả providers sau khi login");
  }

  Future<bool> activateAccount(String email, String otp) async {
  return await _repo.activateAccount(email, otp);
}


  Future<void> logout() async {
    print("🚪 Bắt đầu logout...");
    
    // 1. Sign out khỏi Google (nếu đã đăng nhập bằng Google)
    try {
      final googleHelper = GoogleSignInHelperV7();
      await googleHelper.signOut();
      print("✅ Đã sign out khỏi Google");
    } catch (e) {
      // Ignore nếu không có Google session hoặc lỗi
      print("⚠️ Không thể sign out Google (có thể chưa đăng nhập bằng Google): $e");
    }
    
    // 2. Đóng database connection trước khi xóa
    try {
      final db = ref.read(appDatabaseProvider);
      await db.close();
      print("✅ Đã đóng database connection");
    } catch (e) {
      print("⚠️ Error closing database: $e");
    }
    
    // 3. Xóa toàn bộ database (auth, profile, services, etc.) - bao gồm token
    await _repo.logout();
    print("✅ Đã xóa database file (bao gồm token)");
    
    // 4. Invalidate tất cả các provider phụ thuộc để xóa dữ liệu cache
    // Invalidate các DAO providers trước
    ref.invalidate(authDaoProvider);
    ref.invalidate(profileDaoProvider);
    ref.invalidate(servicesDaoProvider);
    ref.invalidate(userAddressDaoProvider);
    print("✅ Đã invalidate tất cả DAO providers");
    
    // Invalidate các viewmodel providers để xóa dữ liệu cache
    ref.invalidate(profileProvider);
    ref.invalidate(historyProvider);
    ref.invalidate(serviceListProvider);
    ref.invalidate(userAddressProvider);
    // Invalidate serviceDetailProvider (family provider - invalidate tất cả)
    ref.invalidate(serviceDetailProvider);
    print("✅ Đã invalidate tất cả viewmodel providers");
    
    // 5. Invalidate appDatabaseProvider để tạo database mới
    ref.invalidate(appDatabaseProvider);
    print("✅ Đã invalidate appDatabaseProvider");
    
    // 6. Invalidate dioClientProvider để reset Dio instance (xóa token trong interceptor)
    ref.invalidate(dioClientProvider);
    print("✅ Đã invalidate dioClientProvider");
    
    // 7. Đợi một chút để database được đóng hoàn toàn và provider được dispose
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 8. Reset state về null
    state = const AsyncData(null);
    print("✅ Logout hoàn tất - đã xóa hết dữ liệu và reset về trạng thái ban đầu");
  }

  // OTP / Forgot password flows
  Future<String> resendOtp(String email) => _repo.resendOtp(email);

  Future<String> sendForgotOtp(String email) => _repo.sendForgotOtp(email);

  Future<String> verifyForgotOtp(String email, String otp) => _repo.verifyForgotOtp(email, otp);

  Future<bool> resetPassword(String email, String token, String newPassword) => _repo.resetPassword(email, token, newPassword);
}
