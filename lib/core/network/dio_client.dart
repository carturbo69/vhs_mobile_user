import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/ui/auth/auth_viewmodel.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';

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

          // Thêm locale để server trả về data theo ngôn ngữ
          try {
            final locale = _ref.read(localeProvider);
            final languageCode = locale.languageCode;
            
            // Cách 1: Gửi qua Accept-Language header (chuẩn HTTP)
            options.headers["Accept-Language"] = languageCode;
            
            // Cách 2: Gửi qua query parameter (nếu backend yêu cầu)
            // Xử lý cả relative và absolute paths
            final path = options.path;
            final uri = path.startsWith('http') 
                ? Uri.parse(path) 
                : Uri.parse('${options.baseUrl}$path');
            
            final existingParams = Map<String, String>.from(uri.queryParameters);
            existingParams['lang'] = languageCode;
            
            // Rebuild query string
            final queryString = existingParams.entries
                .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                .join('&');
            
            // Update path với query parameter mới
            if (path.contains('?')) {
              options.path = path.split('?').first + (queryString.isNotEmpty ? '?$queryString' : '');
            } else {
              options.path = path + (queryString.isNotEmpty ? '?$queryString' : '');
            }
            
            print("🌐 Sending locale to server: $languageCode (header + query param)");
          } catch (e) {
            // Nếu không lấy được locale, mặc định là 'vi'
            options.headers["Accept-Language"] = "vi";
            final path = options.path;
            final uri = path.startsWith('http') 
                ? Uri.parse(path) 
                : Uri.parse('${options.baseUrl}$path');
            final existingParams = Map<String, String>.from(uri.queryParameters);
            existingParams['lang'] = 'vi';
            final queryString = existingParams.entries
                .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                .join('&');
            if (path.contains('?')) {
              options.path = path.split('?').first + (queryString.isNotEmpty ? '?$queryString' : '');
            } else {
              options.path = path + (queryString.isNotEmpty ? '?$queryString' : '');
            }
            print("⚠️ Cannot get locale, defaulting to 'vi': $e");
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // Xử lý lỗi 401 - token hết hạn, tự động logout
          // NHƯNG không auto-logout nếu là login/register endpoint (người dùng đăng nhập sai)
          if (error.response?.statusCode == 401) {
            final path = error.requestOptions.path;
            final isLoginEndpoint = path.contains('/Auth/login') || 
                                   path.contains('/Auth/register') ||
                                   path.contains('/Auth/google-login');
            
            // Chỉ auto-logout nếu KHÔNG phải login endpoint
            // (tức là token đã hết hạn khi gọi các API khác)
            if (!isLoginEndpoint) {
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
            } else {
              // Nếu là login endpoint bị 401 (sai username/password), 
              // chỉ log và để UI xử lý
              print("❌ Login failed: incorrect credentials");
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
