import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/data/models/service/service_detail.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/cart/cart_list_viewmodel.dart';
import 'package:vhs_mobile_user/ui/service_detail/service_detail_viewmodel.dart';

class ServiceDetailPage extends ConsumerWidget {
  final String serviceId;
  const ServiceDetailPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(serviceDetailProvider(serviceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết dịch vụ"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(serviceDetailProvider(serviceId).notifier).refresh(),
          ),
        ],
      ),
      body: asyncDetail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Lỗi: $e")),
        data: (detail) => Stack(
          children: [
            _DetailContent(detail: detail),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomActionBar(detail: detail),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final ServiceDetail detail;
  const _DetailContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    final imageList = detail.imageList;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSlider(imageList),
          _buildPriceSection(),
          _buildTitleSection(),
          _buildRatingSection(),
          _buildProviderSection(),
          _buildOptionsSection(),
          _buildDescriptionSection(),
          _buildTagsSection(),
          _buildReviewHeader(),
          _buildReviewList(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ====================== IMAGE SLIDER ============================
  Widget _buildImageSlider(List<String> imgs) {
    if (imgs.isEmpty) {
      return Container(
        height: 260,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, size: 48),
      );
    }

    return CarouselSlider(
      items: imgs
          .map(
            (url) => CachedNetworkImage(
              imageUrl: url,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
          .toList(),
      options: CarouselOptions(
        height: 260,
        viewportFraction: 1,
        autoPlay: true,
      ),
    );
  }

  // ======================= PRICE ===============================
  Widget _buildPriceSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Text(
        "${detail.price.toStringAsFixed(0)} ₫ / ${detail.unitType}",
        style: const TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===================== TITLE ================================
  Widget _buildTitleSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      color: Colors.white,
      child: Text(
        detail.title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ================= RATING & REVIEW COUNT =====================
  Widget _buildRatingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 20),
          const SizedBox(width: 6),
          Text(
            detail.averageRating.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            "(${detail.totalReviews} đánh giá)",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ================= PROVIDER (SHOP) SECTION ====================
  Widget _buildProviderSection() {
    final p = detail.provider;
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: p.images != null ? NetworkImage(p.images!) : null,
            child: p.images == null ? const Icon(Icons.store) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.providerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${p.totalServices} dịch vụ • ★ ${p.averageRatingAllServices.toStringAsFixed(1)}",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text("Xem shop", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ================== OPTIONS SECTION ==========================
  Widget _buildOptionsSection() {
    final opts = detail.serviceOptions;
    if (opts.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tuỳ chọn dịch vụ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: opts
                .map(
                  (o) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.grey.shade100,
                    ),
                    child: Text(
                      o.optionName,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ================= DESCRIPTION ==============================
  Widget _buildDescriptionSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mô tả dịch vụ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            detail.description ?? "Không có mô tả",
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ================= TAGS ==============================
  Widget _buildTagsSection() {
    if (detail.tags.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        children: detail.tags
            .map(
              (t) => Chip(
                label: Text(t.name),
                backgroundColor: Colors.orange.shade50,
              ),
            )
            .toList(),
      ),
    );
  }

  // ================ REVIEW HEADER =========================
  Widget _buildReviewHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: const Text(
        "Đánh giá sản phẩm",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  // ================= REVIEW LIST =========================
  Widget _buildReviewList() {
    if (detail.reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text("Chưa có đánh giá"),
      );
    }

    return Column(
      children: detail.reviews.map((r) => _buildReviewItem(r)).toList(),
    );
  }

  Widget _buildReviewItem(ReviewItem r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 4),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: r.avatar != null
                    ? NetworkImage(r.avatar!)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(r.fullName ?? "Người dùng ẩn"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              r.rating,
              (_) => const Icon(Icons.star, color: Colors.amber, size: 16),
            ),
          ),
          const SizedBox(height: 8),
          if (r.comment != null)
            Text(r.comment!, style: const TextStyle(fontSize: 14)),
          if (r.images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: r.images
                    .map(
                      (img) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: img,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends ConsumerWidget {
  final ServiceDetail detail;
  const _BottomActionBar({required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ----------- Nút thêm vào giỏ ----------
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(cartProvider.notifier)
                      .addToCartFromDetail(serviceId: detail.serviceId);
                  context.go(Routes.cart);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã thêm vào giỏ")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                }
              },
              child: const Text("Thêm vào giỏ"),
            ),
          ),

          const SizedBox(width: 12),

          // ----------- Nút Đặt ngay (đi đến checkout) ----------
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(cartProvider.notifier)
                      .addToCartFromDetail(serviceId: detail.serviceId);

                  // Sau khi add → đi đến Checkout
                  context.push(Routes.checkout);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                }
              },
              child: const Text("Đặt ngay"),
            ),
          ),
        ],
      ),
    );
  }
}
