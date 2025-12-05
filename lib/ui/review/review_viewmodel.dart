import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:vhs_mobile_user/data/repositories/review_repository.dart';

final reviewViewModelProvider =
    StateNotifierProvider<ReviewViewModel, AsyncValue<void>>((ref) {
  return ReviewViewModel(ref.read(reviewRepositoryProvider));
});

class ReviewViewModel extends StateNotifier<AsyncValue<void>> {
  final ReviewRepository _repository;

  ReviewViewModel(this._repository) : super(const AsyncData(null));

  Future<bool> submitReview({
    required String bookingId,
    required String serviceId,
    required int rating,
    String? comment,
    List<String>? imagePaths,
  }) async {
    state = const AsyncLoading();
    try {
      final success = await _repository.createReview(
        bookingId: bookingId,
        serviceId: serviceId,
        rating: rating,
        comment: comment,
        imagePaths: imagePaths,
      );
      if (success) {
        state = const AsyncData(null);
        return true;
      } else {
        state = AsyncError(
          Exception("Không thể tạo đánh giá"),
          StackTrace.current,
        );
        return false;
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
    List<String>? newImagePaths,
    List<String>? removeImageUrls,
  }) async {
    state = const AsyncLoading();
    try {
      final success = await _repository.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
        newImagePaths: newImagePaths,
        removeImageUrls: removeImageUrls,
      );
      if (success) {
        state = const AsyncData(null);
        return true;
      } else {
        state = AsyncError(
          Exception("Không thể cập nhật đánh giá"),
          StackTrace.current,
        );
        return false;
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> deleteReview({
    required String reviewId,
  }) async {
    state = const AsyncLoading();
    try {
      final success = await _repository.deleteReview(
        reviewId: reviewId,
      );
      if (success) {
        state = const AsyncData(null);
        return true;
      } else {
        state = AsyncError(
          Exception("Không thể xóa đánh giá"),
          StackTrace.current,
        );
        return false;
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

