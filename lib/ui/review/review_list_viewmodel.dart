import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/review/review_list_item.dart';
import 'package:vhs_mobile_user/data/repositories/review_repository.dart';

final reviewListProvider =
    FutureProvider<List<ReviewListItem>>((ref) async {
  final repository = ref.read(reviewRepositoryProvider);
  return await repository.getMyReviews();
});

