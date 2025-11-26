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
          final token = await _ref.read(authDaoProvider).getToken();

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
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
