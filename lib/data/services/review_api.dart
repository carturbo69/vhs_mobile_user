import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/network/dio_client.dart';
import 'package:vhs_mobile_user/data/models/review/review_list_item.dart';

final reviewApiProvider = Provider<ReviewApi>((ref) {
  return ReviewApi(ref.read(dioClientProvider).instance);
});

class ReviewApi {
  final Dio _dio;
  ReviewApi(this._dio);

  // POST /api/Reviews/{accountId} với multipart/form-data
  Future<bool> createReview({
    required String accountId,
    required String bookingId,
    required String serviceId,
    required int rating,
    String? comment,
    List<String>? imagePaths, // Local file paths
  }) async {
    try {
      final formData = FormData.fromMap({
        'BookingId': bookingId,
        'ServiceId': serviceId,
        'Rating': rating,
        if (comment != null && comment.isNotEmpty) 'Comment': comment,
      });

      // Thêm ảnh nếu có
      if (imagePaths != null && imagePaths.isNotEmpty) {
        for (var path in imagePaths) {
          formData.files.add(MapEntry(
            'ImageFiles',
            await MultipartFile.fromFile(path),
          ));
        }
      }

      final resp = await _dio.post(
        '/api/Reviews/$accountId',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return resp.data['success'] == true || resp.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("Error creating review: $e");
      rethrow;
    }
  }

  // GET /api/Reviews/mine/{accountId}
  Future<List<ReviewListItem>> getMyReviews(String accountId) async {
    try {
      final resp = await _dio.get('/api/Reviews/mine/$accountId');
      if (resp.data['success'] == true && resp.data['data'] != null) {
        final List<dynamic> data = resp.data['data'];
        return data.map((e) => ReviewListItem.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint("Error getting my reviews: $e");
      rethrow;
    }
  }
}

