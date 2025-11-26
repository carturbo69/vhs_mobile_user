// lib/data/repositories/auth_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/auth/auth_model.dart';
import 'package:vhs_mobile_user/data/services/auth_api.dart';
import 'package:vhs_mobile_user/data/database/app_database.dart';
  
class AuthRepository {
  final AuthApi api;
  final AuthDao dao;
  final Ref ref;
  AuthRepository({required this.api, required this.dao, required this.ref});

  Future<String> register(RegisterRequest req) => api.register(req);

  Future<LoginRespond> login(LoginRequest req) async {
    // Lấy user đang lưu trong DB (nếu có)
    LoginRespond? old;
    try {
      old = await dao.getAuth();
    } catch (e) {
      // Database có thể đã bị xóa hoặc connection đã đóng, bỏ qua
      print("⚠️ Cannot get old auth (database may be closed or deleted): $e");
      // Nếu database connection đã đóng, invalidate để tạo lại
      if (e.toString().contains('connection was closed')) {
        print("🔄 Database connection was closed, invalidating...");
        // Invalidate authDaoProvider trước để nó không giữ reference đến database cũ
        ref.invalidate(authDaoProvider);
        ref.invalidate(appDatabaseProvider);
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    // Gọi API login
    final newUser = await api.login(req);

    // Nếu là người khác → xóa toàn DB
    if (old != null && old.accountId != newUser.accountId) {
      print("🔴 Login user changed → nuking DB...");
      await _clearAllData();
      // Invalidate để tạo database mới
      ref.invalidate(authDaoProvider);
      ref.invalidate(appDatabaseProvider);
      // Đợi một chút để database được tạo lại
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Lưu user mới
    // Đợi một chút để đảm bảo database được tạo lại hoàn toàn
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Luôn sử dụng freshDao sau khi invalidate để đảm bảo database mới
    try {
      // Đảm bảo database được tạo bằng cách đọc appDatabaseProvider trước
      final db = ref.read(appDatabaseProvider);
      // Đợi một chút để database được khởi tạo hoàn toàn
      await Future.delayed(const Duration(milliseconds: 100));
      
      final freshDao = ref.read(authDaoProvider);
      print("💾 Đang lưu auth vào database...");
      await freshDao.upsertLogin(
        token: newUser.token,
        role: newUser.role,
        accountId: newUser.accountId,
      );
      print("✅ Đã lưu auth vào database: ${newUser.accountId}");
      
      // Verify: đọc lại để đảm bảo đã lưu
      final saved = await freshDao.getAuth();
      if (saved != null) {
        print("✅ Verify: Auth đã được lưu thành công");
      } else {
        print("⚠️ Warning: Không thể verify auth sau khi lưu");
      }
    } catch (e) {
      // Nếu vẫn lỗi, thử lại sau khi đợi thêm và invalidate lại
      print("⚠️ Error saving with fresh dao, retrying after delay and re-invalidate: $e");
      ref.invalidate(authDaoProvider);
      ref.invalidate(appDatabaseProvider);
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        // Đảm bảo database được tạo
        final db = ref.read(appDatabaseProvider);
        await Future.delayed(const Duration(milliseconds: 100));
        final retryDao = ref.read(authDaoProvider);
        await retryDao.upsertLogin(
          token: newUser.token,
          role: newUser.role,
          accountId: newUser.accountId,
        );
        print("✅ Đã lưu auth sau khi retry");
      } catch (e2) {
        print("❌ Error saving after retry: $e2");
        rethrow;
      }
    }

    return newUser;
  }

  Future<LoginRespond> loginWithGoogle(String idToken) async {
    // Lấy user đang lưu trong DB (nếu có)
    LoginRespond? old;
    try {
      old = await dao.getAuth();
    } catch (e) {
      // Database có thể đã bị xóa hoặc connection đã đóng, bỏ qua
      print("⚠️ Cannot get old auth (database may be closed or deleted): $e");
      // Nếu database connection đã đóng, invalidate để tạo lại
      if (e.toString().contains('connection was closed')) {
        print("🔄 Database connection was closed, invalidating...");
        // Invalidate authDaoProvider trước để nó không giữ reference đến database cũ
        ref.invalidate(authDaoProvider);
        ref.invalidate(appDatabaseProvider);
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    // Gọi API login
    final newUser = await api.googleLogin(idToken);

    // Nếu là người khác → xóa toàn DB
    if (old != null && old.accountId != newUser.accountId) {
      print("🔴 Login user changed → nuking DB...");
      await _clearAllData();
      // Invalidate để tạo database mới
      ref.invalidate(authDaoProvider);
      ref.invalidate(appDatabaseProvider);
      // Đợi một chút để database được tạo lại
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Lưu user mới
    // Đợi một chút để đảm bảo database được tạo lại hoàn toàn
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Luôn sử dụng freshDao sau khi invalidate để đảm bảo database mới
    try {
      // Đảm bảo database được tạo bằng cách đọc appDatabaseProvider trước
      final db = ref.read(appDatabaseProvider);
      // Đợi một chút để database được khởi tạo hoàn toàn
      await Future.delayed(const Duration(milliseconds: 100));
      
      final freshDao = ref.read(authDaoProvider);
      print("💾 Đang lưu auth vào database...");
      await freshDao.upsertLogin(
        token: newUser.token,
        role: newUser.role,
        accountId: newUser.accountId,
      );
      print("✅ Đã lưu auth vào database: ${newUser.accountId}");
      
      // Verify: đọc lại để đảm bảo đã lưu
      final saved = await freshDao.getAuth();
      if (saved != null) {
        print("✅ Verify: Auth đã được lưu thành công");
      } else {
        print("⚠️ Warning: Không thể verify auth sau khi lưu");
      }
    } catch (e) {
      // Nếu vẫn lỗi, thử lại sau khi đợi thêm và invalidate lại
      print("⚠️ Error saving with fresh dao, retrying after delay and re-invalidate: $e");
      ref.invalidate(authDaoProvider);
      ref.invalidate(appDatabaseProvider);
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        // Đảm bảo database được tạo
        final db = ref.read(appDatabaseProvider);
        await Future.delayed(const Duration(milliseconds: 100));
        final retryDao = ref.read(authDaoProvider);
        await retryDao.upsertLogin(
          token: newUser.token,
          role: newUser.role,
          accountId: newUser.accountId,
        );
        print("✅ Đã lưu auth sau khi retry");
      } catch (e2) {
        print("❌ Error saving after retry: $e2");
        rethrow;
      }
    }

    return newUser;
  }

  Future<void> logout() async {
    // Xóa toàn bộ database để đảm bảo không còn dữ liệu cũ
    // Khi người dùng mới đăng nhập sẽ không thấy dữ liệu của người dùng trước
    await _clearAllData();
  }

  /// Xóa toàn bộ dữ liệu: chỉ xóa file database
  /// Việc invalidate providers sẽ được xử lý ở viewmodel
  Future<void> _clearAllData() async {
    // Xóa file database (sẽ xóa tất cả dữ liệu: auth, profile, services, etc.)
    await AppDatabase.deleteDatabase();
    // Không invalidate ở đây để tránh lỗi khi dao đang được sử dụng
    // Invalidate sẽ được xử lý ở viewmodel
  }

  Future<LoginRespond?> getLoggedIn() async {
    try {
      print("🔍 Đang đọc auth từ database...");
      final auth = await dao.getAuth();
      if (auth != null) {
        print("✅ Đã đọc auth từ database: ${auth.accountId}");
      } else {
        print("ℹ️ Không có auth trong database");
      }
      return auth;
    } catch (e) {
      // Database có thể đã bị xóa, trả về null
      print("⚠️ Cannot get logged in user: $e");
      print("⚠️ Stack trace: ${StackTrace.current}");
      return null;
    }
  }

  /// Validate token với server
  /// Trả về true nếu token hợp lệ, false nếu không hợp lệ
  Future<bool> validateToken(LoginRespond auth) async {
    try {
      return await api.validateToken(auth.accountId);
    } catch (e) {
      print("⚠️ Error validating token: $e");
      // Nếu có lỗi khi validate, giả sử token vẫn hợp lệ
      // để tránh logout khi mất mạng
      return true;
    }
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
  return AuthRepository(api: api, dao: dao, ref: ref);
});
