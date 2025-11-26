import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';

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
      ),
    );
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  Dio get instance => _dio;
}

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref);
});
