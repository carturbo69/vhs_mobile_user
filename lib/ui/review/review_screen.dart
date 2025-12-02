import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_detail_model.dart';
import 'package:vhs_mobile_user/data/models/review/review_list_item.dart';
import 'package:vhs_mobile_user/ui/review/review_viewmodel.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final HistoryBookingDetail? bookingDetail;
  final ReviewListItem? reviewItem;

  const ReviewScreen({
    super.key,
    this.bookingDetail,
    this.reviewItem,
  }) : assert(bookingDetail != null || reviewItem != null);

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tối đa 5 hình ảnh")),
      );
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final remaining = 5 - _selectedImages.length;
        final toAdd = images.take(remaining).map((x) => File(x.path)).toList();
        setState(() {
          _selectedImages.addAll(toAdd);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi chọn ảnh: $e")),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitReview() async {
    // Validation
    if (_rating < 1 || _rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng chọn số sao đánh giá"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final comment = _commentController.text.trim();
    if (comment.isEmpty || comment.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(comment.isEmpty
              ? "Vui lòng nhập nội dung đánh giá"
              : "Nội dung đánh giá phải có ít nhất 10 ký tự"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (widget.bookingDetail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không tìm thấy thông tin đặt dịch vụ"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final imagePaths = _selectedImages.map((f) => f.path).toList();
      final success = await ref.read(reviewViewModelProvider.notifier).submitReview(
            bookingId: widget.bookingDetail!.bookingId,
            serviceId: widget.bookingDetail!.service.serviceId,
            rating: _rating,
            comment: comment,
            imagePaths: imagePaths.isNotEmpty ? imagePaths : null,
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đánh giá thành công!"),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh history detail và quay lại
          context.pop(true); // Return true để indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đánh giá thất bại. Vui lòng thử lại."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Nếu là edit mode, prefill data
    if (widget.reviewItem != null) {
      _rating = widget.reviewItem!.rating ?? 0;
      _commentController.text = widget.reviewItem!.comment;
      // TODO: Load existing images
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nếu là edit mode, hiển thị thông báo tạm thời
    if (widget.reviewItem != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Sửa đánh giá"),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Tính năng sửa đánh giá đang được phát triển. Vui lòng quay lại sau.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Create mode - bookingDetail should not be null here
    final bookingDetail = widget.bookingDetail!;
    
    return Scaffold(
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
          "Đánh giá dịch vụ",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: ThemeHelper.getScaffoldBackgroundColor(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service info card
            Container(
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
                child: Row(
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
                        child: Image.network(
                          bookingDetail.service.image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: ThemeHelper.getLightBackgroundColor(context),
                            child: Icon(
                              Icons.image_rounded,
                              size: 40,
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
                            bookingDetail.service.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: ThemeHelper.getTextColor(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bookingDetail.provider.providerName,
                            style: TextStyle(
                              color: ThemeHelper.getSecondaryTextColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Rating section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: ThemeHelper.isDarkMode(context)
                      ? [
                          Colors.orange.shade900.withOpacity(0.3),
                          Colors.orange.shade800.withOpacity(0.2),
                        ]
                      : [
                          Colors.orange.shade50,
                          Colors.orange.shade100,
                        ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.shade400,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeHelper.isDarkMode(context)
                          ? Colors.orange.shade800.withOpacity(0.5)
                          : Colors.orange.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      color: Colors.orange.shade400,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Chất lượng dịch vụ *",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeHelper.getTextColor(context),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = starValue;
                    });
                  },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        _rating >= starValue ? Icons.star_rounded : Icons.star_border_rounded,
                        color: _rating >= starValue ? Colors.amber.shade600 : Colors.grey.shade400,
                        size: 50,
                      ),
                    ),
                );
              }),
            ),
            if (_rating == 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Vui lòng chọn số sao đánh giá",
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 32),

            // Comment section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ThemeHelper.getLightBlueBackgroundColor(context),
                    ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.comment_rounded,
                      color: ThemeHelper.getPrimaryDarkColor(context),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Nội dung đánh giá",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: ThemeHelper.getTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              style: TextStyle(
                color: ThemeHelper.getTextColor(context),
              ),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Chia sẻ trải nghiệm của bạn về dịch vụ này...",
                hintStyle: TextStyle(
                  color: ThemeHelper.getTertiaryTextColor(context),
                ),
                prefixIcon: Icon(
                  Icons.edit_rounded,
                  color: ThemeHelper.getPrimaryColor(context),
                ),
                filled: true,
                fillColor: ThemeHelper.getInputBackgroundColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeHelper.getBorderColor(context),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeHelper.getBorderColor(context),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeHelper.getPrimaryColor(context),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Đánh giá chi tiết sẽ giúp người khác hiểu rõ hơn về dịch vụ",
              style: TextStyle(
                color: ThemeHelper.getSecondaryTextColor(context),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),

            // Images section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ThemeHelper.getLightBlueBackgroundColor(context),
                    ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.image_rounded,
                          color: ThemeHelper.getPrimaryDarkColor(context),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Hình ảnh",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                          color: ThemeHelper.getTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Tối đa 5",
                    style: TextStyle(
                      color: ThemeHelper.getSecondaryTextColor(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Selected images
                ..._selectedImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                // Add image button
                if (_selectedImages.length < 5)
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ThemeHelper.getPrimaryColor(context).withOpacity(0.5),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: ThemeHelper.getLightBlueBackgroundColor(context),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            color: ThemeHelper.getPrimaryColor(context),
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${_selectedImages.length}/5",
                            style: TextStyle(
                              color: ThemeHelper.getPrimaryColor(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitReview,
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  _isSubmitting ? "Đang gửi..." : "Gửi đánh giá",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

