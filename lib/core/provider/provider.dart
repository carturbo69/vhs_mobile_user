import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://apivhs.cuahangkinhdoanh.com/api', // hoặc domain thật
      connectTimeout: const Duration(seconds: 5),
    ),
  );
});
