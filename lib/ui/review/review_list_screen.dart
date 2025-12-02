import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vhs_mobile_user/data/models/review/review_list_item.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/review/review_list_viewmodel.dart';
import 'package:vhs_mobile_user/ui/review/review_screen.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';

class ReviewListScreen extends ConsumerWidget {
  const ReviewListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncReviews = ref.watch(reviewListProvider);

    return Scaffold(
      backgroundColor: ThemeHelper.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
            ),
          ),
        ),
        title: const Text(
          'Đánh giá dịch vụ của tôi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: asyncReviews.when(
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeHelper.getPrimaryColor(context),
                ),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                "Đang tải...",
                style: TextStyle(
                  color: ThemeHelper.getSecondaryTextColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: ThemeHelper.isDarkMode(context)
                        ? Colors.red.shade900.withOpacity(0.3)
                        : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Đã xảy ra lỗi",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeHelper.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$e",
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeHelper.getSecondaryTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(reviewListProvider),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text(
                    "Thử lại",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeHelper.getPrimaryColor(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (reviews) {
          if (reviews.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: ThemeHelper.isDarkMode(context)
                            ? Colors.orange.shade900.withOpacity(0.3)
                            : Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.rate_review_rounded,
                        size: 80,
                        color: Colors.orange.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Chưa có đánh giá nào',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelper.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy mua dịch vụ và chia sẻ trải nghiệm của bạn!',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.getSecondaryTextColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(reviewListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return _ReviewCard(
                  review: reviews[index],
                  onEdit: () async {
                    // Navigate to edit review screen
                    final result = await context.push<bool>(
                      Routes.review,
                      extra: reviews[index],
                    );
                    if (result == true && context.mounted) {
                      ref.invalidate(reviewListProvider);
                    }
                  },
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: ThemeHelper.getDialogBackgroundColor(context),
                        title: Text(
                          'Xác nhận',
                          style: TextStyle(
                            color: ThemeHelper.getTextColor(context),
                          ),
                        ),
                        content: Text(
                          'Bạn có chắc chắn muốn xóa đánh giá này?',
                          style: TextStyle(
                            color: ThemeHelper.getTextColor(context),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                color: ThemeHelper.getSecondaryTextColor(context),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      // TODO: Implement delete review
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng xóa đang được phát triển')),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewListItem review;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.review,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final createdAt = review.createdAt != null
        ? dateFormat.format(review.createdAt!.toLocal())
        : '';

    final isDark = ThemeHelper.isDarkMode(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeHelper.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Header
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ThemeHelper.getBorderColor(context),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeHelper.getShadowColor(context),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: review.serviceThumbnailUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 60,
                        height: 60,
                        color: ThemeHelper.getLightBackgroundColor(context),
                        child: Icon(
                          Icons.image_rounded,
                          color: ThemeHelper.getSecondaryIconColor(context),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 60,
                        height: 60,
                        color: ThemeHelper.getLightBackgroundColor(context),
                        child: Icon(
                          Icons.image_rounded,
                          color: ThemeHelper.getSecondaryIconColor(context),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.serviceTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeHelper.getTextColor(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        createdAt,
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeHelper.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // User Info & Rating
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                  backgroundImage: review.userAvatarUrl.isNotEmpty
                      ? CachedNetworkImageProvider(review.userAvatarUrl)
                      : null,
                  child: review.userAvatarUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          color: ThemeHelper.getPrimaryColor(context),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.fullName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < (review.rating ?? 0)
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 18,
                              color: Colors.amber.shade600,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '${review.rating ?? 0}.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: ThemeHelper.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (review.likeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ThemeHelper.isDarkMode(context)
                          ? Colors.red.shade900.withOpacity(0.3)
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.shade400,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          size: 16,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${review.likeCount}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Comment
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.comment,
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeHelper.getTextColor(context),
                ),
              ),
            ],

            // Images
            if (review.reviewImageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.reviewImageUrls.length > 5
                      ? 5
                      : review.reviewImageUrls.length,
                  itemBuilder: (context, index) {
                    final url = review.reviewImageUrls[index];
                    final isLast = index == 4 && review.reviewImageUrls.length > 5;
                    final extraCount = review.reviewImageUrls.length - 5;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 80,
                                height: 80,
                                color: ThemeHelper.getLightBackgroundColor(context),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 80,
                                height: 80,
                                color: ThemeHelper.getLightBackgroundColor(context),
                                child: Icon(
                                  Icons.image,
                                  color: ThemeHelper.getSecondaryIconColor(context),
                                ),
                              ),
                            ),
                          ),
                          if (isLast)
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '+$extraCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],

            // Reply
            if (review.reply.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeHelper.getLightBlueBackgroundColor(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 16,
                          color: ThemeHelper.getPrimaryDarkColor(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Phản hồi từ Người bán',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ThemeHelper.getPrimaryDarkColor(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.reply,
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.getTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Actions
            if (review.canEdit || review.canDelete) ...[
              const SizedBox(height: 16),
              Divider(
                color: ThemeHelper.getBorderColor(context),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (review.canEdit)
                    OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text(
                        'Sửa',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeHelper.getPrimaryColor(context),
                        side: BorderSide(
                          color: ThemeHelper.getPrimaryColor(context),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  if (review.canDelete) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_rounded, size: 18),
                      label: const Text(
                        'Xóa',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

