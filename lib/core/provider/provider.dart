import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'http://apivhs.cuahangkinhdoanh.com', // hoặc domain thật
      connectTimeout: const Duration(seconds: 5),
    ),
  );
});
