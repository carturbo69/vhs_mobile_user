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
      // Database có thể đã bị xóa, bỏ qua
      print("⚠️ Cannot get old auth: $e");
    }

    // Gọi API login
    final newUser = await api.login(req);

    // Nếu là người khác → xóa toàn DB
    if (old != null && old.accountId != newUser.accountId) {
      print("🔴 Login user changed → nuking DB...");
      await _clearAllData();
      // Invalidate để tạo database mới
      ref.invalidate(appDatabaseProvider);
      // Đợi một chút để database được tạo lại
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Lưu user mới
    try {
      final freshDao = ref.read(authDaoProvider);
      // Đảm bảo database được khởi tạo bằng cách thực hiện một query đơn giản
      await freshDao.getAuth();
      // Sau đó mới save
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
      // Nếu vẫn lỗi, thử lại với dao hiện tại
      print("⚠️ Error saving with fresh dao, retrying: $e");
      await dao.upsertLogin(
        token: newUser.token,
        role: newUser.role,
        accountId: newUser.accountId,
      );
      print("✅ Đã lưu auth với dao hiện tại");
    }

    return newUser;
  }

  Future<LoginRespond> loginWithGoogle(String idToken) async {
    // Lấy user đang lưu trong DB (nếu có)
    LoginRespond? old;
    try {
      old = await dao.getAuth();
    } catch (e) {
      // Database có thể đã bị xóa, bỏ qua
      print("⚠️ Cannot get old auth: $e");
    }

    // Gọi API login
    final newUser = await api.googleLogin(idToken);

    // Nếu là người khác → xóa toàn DB
    if (old != null && old.accountId != newUser.accountId) {
      print("🔴 Login user changed → nuking DB...");
      await _clearAllData();
      // Invalidate để tạo database mới
      ref.invalidate(appDatabaseProvider);
      // Đợi một chút để database được tạo lại
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Lưu user mới
    try {
      final freshDao = ref.read(authDaoProvider);
      // Đảm bảo database được khởi tạo bằng cách thực hiện một query đơn giản
      await freshDao.getAuth();
      // Sau đó mới save
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
      // Nếu vẫn lỗi, thử lại với dao hiện tại
      print("⚠️ Error saving with fresh dao, retrying: $e");
      await dao.upsertLogin(
        token: newUser.token,
        role: newUser.role,
        accountId: newUser.accountId,
      );
      print("✅ Đã lưu auth với dao hiện tại");
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
