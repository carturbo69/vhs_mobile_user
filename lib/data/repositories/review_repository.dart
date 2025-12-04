import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/review/review_list_item.dart';
import 'package:vhs_mobile_user/data/services/review_api.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(
    api: ref.read(reviewApiProvider),
    authDao: ref.read(authDaoProvider),
  );
});

class ReviewRepository {
  final ReviewApi api;
  final AuthDao authDao;

  ReviewRepository({required this.api, required this.authDao});

  Future<bool> createReview({
    required String bookingId,
    required String serviceId,
    required int rating,
    String? comment,
    List<String>? imagePaths,
  }) async {
    final saved = await authDao.getSavedAuth();
    final accountId = saved?['accountId'];
    if (accountId == null) throw Exception("Missing accountId");

    return await api.createReview(
      accountId: accountId,
      bookingId: bookingId,
      serviceId: serviceId,
      rating: rating,
      comment: comment,
      imagePaths: imagePaths,
    );
  }

  Future<List<ReviewListItem>> getMyReviews() async {
    final saved = await authDao.getSavedAuth();
    final accountId = saved?['accountId'];
    if (accountId == null) throw Exception("Missing accountId");

    return await api.getMyReviews(accountId);
  }
}

