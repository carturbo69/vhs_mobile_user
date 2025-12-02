import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/ui/auth/auth_viewmodel.dart';

class DioClient {
  late final Dio _dio;
  final Ref _ref;

  DioClient(this._ref)
    : _dio = Dio(
        BaseOptions(
          baseUrl: "http://apivhs.cuahangkinhdoanh.com",
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from Drift
          try {
            final token = await _ref.read(authDaoProvider).getToken();
            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            }
          } catch (e) {
            // Nếu database đã bị xóa hoặc connection đã đóng, bỏ qua việc thêm token
            // Request vẫn tiếp tục mà không có Authorization header
            print("⚠️ Cannot get auth token: $e");
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // Xử lý lỗi 401 - token hết hạn, tự động logout
          if (error.response?.statusCode == 401) {
            try {
              final authDao = _ref.read(authDaoProvider);
              await authDao.clearAuth();
              await authDao.logout();
              
              // Refresh auth state để router tự động redirect
              final authNotifier = _ref.read(authStateProvider.notifier);
              await authNotifier.logout();
              
              print("🔒 Token expired, auto-logout performed");
            } catch (e) {
              print("⚠️ Error during auto-logout: $e");
            }
          }
          return handler.next(error);
        },
      ),
    );
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  Dio get instance => _dio;
}

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref);
});
