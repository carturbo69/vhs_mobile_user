import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';

class DioWeb {
  late Dio _dio;
  final Ref _ref;

  DioWeb(this._ref)
    : _dio = Dio(
        BaseOptions(
          baseUrl: "https://vhs.cuahangkinhdoanh.com",
          connectTimeout: Duration(seconds: 15),
          receiveTimeout: Duration(seconds: 15),
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
    // Nếu frontend cần cookie để login MVC thì add ở đây
    _dio.interceptors.add(
      LogInterceptor(request: true, responseBody: true, requestBody: true),
    );
  }
  Dio get instance => _dio;
}

final dioWebProvider = Provider<DioWeb>((ref) {
  return DioWeb(ref);
});
