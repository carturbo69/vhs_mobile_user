import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:vhs_mobile_user/data/models/service/service_detail.dart';
import 'package:vhs_mobile_user/data/models/service/service_model.dart';
import 'package:vhs_mobile_user/data/services/service_api.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/cart/cart_list_viewmodel.dart';
import 'package:vhs_mobile_user/ui/service_detail/service_detail_viewmodel.dart';
import 'package:vhs_mobile_user/ui/service_list/service_card.dart';
import 'package:vhs_mobile_user/ui/chat/chat_list_viewmodel.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';

// Màu xanh theo web - Sky blue palette
const Color primaryBlue = Color(0xFF0284C7); // Sky-600
const Color darkBlue = Color(0xFF0369A1); // Sky-700
const Color lightBlue = Color(0xFFE0F2FE); // Sky-100
const Color accentBlue = Color(0xFFBAE6FD); // Sky-200

class ServiceDetailPage extends ConsumerWidget {
  final String serviceId;
  const ServiceDetailPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(serviceDetailProvider(serviceId));

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
          "Chi tiết dịch vụ",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Nút giỏ hàng với badge số lượng
          Consumer(
            builder: (context, ref, child) {
              final cartAsync = ref.watch(cartProvider);
              final cartCount = cartAsync.when(
                data: (items) => items.length,
                loading: () => 0,
                error: (_, __) => 0,
              );

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                      onPressed: () {
                        // Luôn dùng go để tránh duplicate keys với StatefulShellRoute
                        // Lưu route hiện tại để có thể quay lại
                        final currentLocation = GoRouterState.of(context).matchedLocation;
                        if (currentLocation != Routes.cart) {
                          // Lưu route hiện tại vào extra để có thể quay lại
                          context.go(Routes.cart, extra: {'previousRoute': currentLocation});
                        }
                      },
                      tooltip: 'Giỏ hàng',
                    ),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: cartCount > 9 ? 6 : 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          cartCount > 99 ? '99+' : cartCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () =>
                  ref.read(serviceDetailProvider(serviceId).notifier).refresh(),
              tooltip: 'Làm mới',
            ),
          ),
        ],
      ),
      body: asyncDetail.when(
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
        error: (e, _) {
          final isDark = ThemeHelper.isDarkMode(context);
          return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: isDark 
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
                  onPressed: () => ref.read(serviceDetailProvider(serviceId).notifier).refresh(),
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
        );
        },
        data: (detail) => Stack(
          children: [
            _DetailContent(detail: detail, serviceId: '',),
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

class _DetailContent extends ConsumerWidget {
  final ServiceDetail detail;
  final String serviceId;
  const _DetailContent({required this.detail, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageList = detail.imageList;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100), // Padding để tránh bị che bởi bottom action bar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context, imageList),
          _buildPriceSection(context),
          _buildTitleSection(context),
          _buildRatingSection(context),
          _buildOptionsSection(context),
          _buildProviderSection(context, ref),
          _buildDescriptionSection(context),
          _buildReviewSection(context),
          _buildRelatedServicesSection(context, ref),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ====================== IMAGE SECTION WITH THUMBNAILS ============================
  Widget _buildImageSection(BuildContext context, List<String> imgs) {
    if (imgs.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: ThemeHelper.getLightBackgroundColor(context),
        ),
        child: Icon(
          Icons.image,
          size: 48,
          color: ThemeHelper.getSecondaryIconColor(context),
        ),
      );
    }

    return _ImageGallery(images: imgs);
  }

  // ======================= PRICE ===============================
  Widget _buildPriceSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardBackgroundColor(context),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            "${_formatPrice(detail.price)}₫",
        style: const TextStyle(
          color: Colors.red,
              fontSize: 28,
          fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.red[200]!, width: 1),
            ),
            child: Text(
              "/ ${_translateUnitType(detail.unitType)}",
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
        ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final priceInt = price.toInt();
    final priceStr = priceInt.toString();
    final buffer = StringBuffer();
    
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(priceStr[i]);
    }
    
    return buffer.toString();
  }

  String _translateUnitType(String unitType) {
    final lowerUnitType = unitType.toLowerCase().trim();
    
    switch (lowerUnitType) {
      case 'squaremeter':
      case 'square meter':
      case 'm²':
      case 'm2':
        return 'Mét vuông';
      case 'visit':
        return 'Lần';
      case 'hour':
      case 'hours':
        return 'Giờ';
      case 'day':
      case 'days':
        return 'Ngày';
      case 'apartment':
      case 'apartments':
        return 'Căn';
      case 'room':
      case 'rooms':
        return 'Phòng';
      case 'person':
      case 'persons':
      case 'people':
        return 'Người';
      case 'package':
      case 'packages':
        return 'Gói';
      case 'event':
      case 'events':
        return 'Sự kiện';
      case 'week':
      case 'weeks':
        return 'Tuần';
      case 'month':
      case 'months':
        return 'Tháng';
      default:
        return unitType;
    }
  }

  // ===================== TITLE ================================
  Widget _buildTitleSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardBackgroundColor(context),
      ),
      child: Text(
        detail.title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ThemeHelper.getTextColor(context),
          height: 1.3,
        ),
      ),
    );
  }

  // ================= RATING & REVIEW COUNT =====================
  Widget _buildRatingSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardBackgroundColor(context),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ThemeHelper.isDarkMode(context)
                  ? Colors.amber.shade900.withOpacity(0.3)
                  : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.amber.shade400,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
          Text(
            detail.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "(${detail.totalReviews} đánh giá)",
            style: TextStyle(
              color: ThemeHelper.getTertiaryTextColor(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ================= PROVIDER (SHOP) SECTION ====================
  Widget _buildProviderSection(BuildContext context, WidgetRef ref) {
    final p = detail.provider;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardBackgroundColor(context),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeHelper.getShadowColor(context),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: p.images != null
                  ? CachedNetworkImage(
                      imageUrl: p.images!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        decoration: BoxDecoration(
                          color: ThemeHelper.getLightBlueBackgroundColor(context),
                        ),
                        child: Icon(
                          Icons.store,
                          color: ThemeHelper.getPrimaryColor(context),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          color: ThemeHelper.getLightBlueBackgroundColor(context),
                        ),
                        child: Icon(
                          Icons.store,
                          color: ThemeHelper.getPrimaryColor(context),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: ThemeHelper.getLightBlueBackgroundColor(context),
                      ),
                      child: Icon(
                        Icons.store,
                        color: ThemeHelper.getPrimaryColor(context),
                        size: 28,
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
                  p.providerName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: ThemeHelper.getTextColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.business_center,
                      size: 14,
                      color: ThemeHelper.getTertiaryTextColor(context),
                    ),
                    const SizedBox(width: 4),
                Text(
                      "${p.totalServices} dịch vụ",
                      style: TextStyle(
                        color: ThemeHelper.getTertiaryTextColor(context),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      p.averageRatingAllServices.toStringAsFixed(1),
                      style: TextStyle(
                        color: ThemeHelper.getTertiaryTextColor(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              context.push(Routes.serviceShopPath(detail.providerId));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[400]!, Colors.red[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                "Xem shop",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== OPTIONS SECTION ==========================
  Widget _buildOptionsSection(BuildContext context) {
    // Tách options thành 2 nhóm: regular và textarea/text (giống service_card.dart)
    final regularOptions = detail.serviceOptions
        .where((opt) => opt.type.toLowerCase() != 'textarea' && opt.type.toLowerCase() != 'text')
        .toList();
    final textareaOptions = detail.serviceOptions
        .where((opt) => opt.type.toLowerCase() == 'textarea' || opt.type.toLowerCase() == 'text')
        .toList();
    
    if (regularOptions.isEmpty && textareaOptions.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardBackgroundColor(context),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ThemeHelper.getLightBlueBackgroundColor(context),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: ThemeHelper.getPrimaryColor(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "TÙY CHỌN ĐÃ BAO GỒM",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: ThemeHelper.getTextColor(context),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Hiển thị regular options trước
          ...regularOptions.map(
                  (o) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                color: ThemeHelper.getLightBackgroundColor(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ThemeHelper.getBorderColor(context),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: ThemeHelper.getPrimaryColor(context),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      o.optionName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ThemeHelper.getTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Hiển thị textarea options ở cuối cùng
          ...textareaOptions.map((opt) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: ThemeHelper.getLightBackgroundColor(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ThemeHelper.getBorderColor(context),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: ThemeHelper.getPrimaryColor(context),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          opt.optionName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ThemeHelper.getTextColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (opt.value != null && opt.value!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Text(
                        opt.value!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: ThemeHelper.getSecondaryTextColor(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ================= DESCRIPTION ==============================
  Widget _buildDescriptionSection(BuildContext context) {
    if (detail.description == null || detail.description!.isEmpty) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardBackgroundColor(context),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ThemeHelper.getLightBlueBackgroundColor(context),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.description,
                  color: ThemeHelper.getPrimaryColor(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
            "Mô tả dịch vụ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: ThemeHelper.getTextColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: ThemeHelper.getLightBackgroundColor(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ThemeHelper.getBorderColor(context),
                width: 1,
              ),
            ),
            child: Text(
              detail.description!.replaceAll('\r\n', '\n').replaceAll('\r', '\n'),
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.getSecondaryTextColor(context),
                height: 1.6,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  // ================= TAGS ==============================
  Widget _buildTagsSection(BuildContext context) {
    if (detail.tags.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardBackgroundColor(context),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.label, color: Colors.orange.shade400, size: 20),
              const SizedBox(width: 8),
              Text(
                "Thẻ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ThemeHelper.getTextColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
        spacing: 8,
            runSpacing: 8,
        children: detail.tags
            .map(
              (t) {
                final isDark = ThemeHelper.isDarkMode(context);
                return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                      colors: isDark
                          ? [
                              Colors.orange.shade900.withOpacity(0.3),
                              Colors.orange.shade800.withOpacity(0.2),
                            ]
                          : [Colors.orange.shade50, Colors.orange.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.orange.shade400,
                      width: 1,
                    ),
                    ),
                    child: Text(
                      t.name,
                      style: TextStyle(
                      color: Colors.orange.shade400,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                );
              },
            )
            .toList(),
          ),
        ],
      ),
    );
  }

  // ================= REVIEW SECTION =========================
  Widget _buildReviewSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardBackgroundColor(context),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.rate_review,
                color: ThemeHelper.getPrimaryColor(context),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                "Đánh giá dịch vụ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ThemeHelper.getTextColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Review List
          if (detail.reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Chưa có đánh giá",
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeHelper.getSecondaryTextColor(context),
                ),
              ),
            )
          else
            ...detail.reviews.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildReviewItem(context, r),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, ReviewItem r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: r.avatar != null
                      ? CachedNetworkImage(
                          imageUrl: r.avatar!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              color: ThemeHelper.getLightBlueBackgroundColor(context),
                            ),
                            child: Icon(
                              Icons.person,
                              color: ThemeHelper.getPrimaryColor(context),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: ThemeHelper.getLightBlueBackgroundColor(context),
                          ),
                          child: Icon(
                            Icons.person,
                            color: ThemeHelper.getPrimaryColor(context),
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
                      r.fullName ?? "Người dùng ẩn",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: ThemeHelper.getTextColor(context),
                      ),
          ),
                    const SizedBox(height: 4),
          Row(
            children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color: index < r.rating
                              ? Colors.amber
                              : ThemeHelper.getDividerColor(context),
                          size: 16,
                        ),
            ),
          ),
                  ],
                ),
              ),
            ],
          ),
          if (r.comment != null) ...[
            const SizedBox(height: 12),
            Text(
              r.comment!,
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.getSecondaryTextColor(context),
                height: 1.5,
              ),
            ),
          ],
          if (r.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
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
                        placeholder: (_, __) => Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: ThemeHelper.getLightBackgroundColor(context),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ThemeHelper.getPrimaryColor(context),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: ThemeHelper.getLightBackgroundColor(context),
                          ),
                          child: Icon(
                            Icons.image,
                            color: ThemeHelper.getSecondaryIconColor(context),
                          ),
                        ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ],
      ),
    );
  }

  // ================= RELATED SERVICES SECTION =========================
  Widget _buildRelatedServicesSection(BuildContext context, WidgetRef ref) {
    // Tạo FutureProvider để fetch services với serviceId để lọc
    final relatedServicesAsync = ref.watch(_relatedServicesProvider(detail.serviceId));
        
    return relatedServicesAsync.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (services) {
            if (services.isEmpty) return const SizedBox();
            
            final displayServices = services.take(10).toList();
            final hasMore = services.length > 10;
            
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeHelper.getCardBackgroundColor(context),
                boxShadow: [
                  BoxShadow(
                    color: ThemeHelper.getShadowColor(context),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
            ),
        ],
      ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: ThemeHelper.getLightBlueBackgroundColor(context),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.grid_view,
                          color: ThemeHelper.getPrimaryColor(context),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Dịch vụ khác",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: ThemeHelper.getTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Grid hiển thị dịch vụ (2 cột)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: displayServices.length,
                    itemBuilder: (context, index) {
                      final service = displayServices[index];
                      return _CompactServiceCard(
                        service: service,
                        onTap: () {
                          context.push(Routes.detailServicePath(service.serviceId));
                        },
                      );
                    },
                  ),
                  // Nút "Xem thêm" nếu có hơn 10 dịch vụ
                  if (hasMore) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          context.push(Routes.listService);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: ThemeHelper.getPrimaryColor(context),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Text(
                          "Xem thêm",
                          style: TextStyle(
                            color: ThemeHelper.getPrimaryColor(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
  }
}

// Provider để fetch related services
final _relatedServicesProvider = FutureProvider.family<List<ServiceModel>, String>((ref, currentServiceId) async {
  final api = ref.watch(serviceApiProvider);
  final allServices = await api.fetchHomePageServices();
  // Lọc bỏ dịch vụ hiện tại và shuffle để random
  final filtered = allServices.where((s) => s.serviceId != currentServiceId).toList();
  filtered.shuffle();
  return filtered;
});

// Compact Service Card cho related services (đơn giản như hình)
class _CompactServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const _CompactServiceCard({required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    final images = service.imageList;
    final img = images.isNotEmpty ? images.first : null;
    final isDark = ThemeHelper.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: ThemeHelper.getBorderColor(context),
            width: 1,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        elevation: 2,
        shadowColor: ThemeHelper.getShadowColor(context),
        color: ThemeHelper.getCardBackgroundColor(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            img != null
                ? CachedNetworkImage(
                    imageUrl: img,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 140,
                      color: ThemeHelper.getLightBackgroundColor(context),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ThemeHelper.getPrimaryColor(context),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 140,
                      color: ThemeHelper.getLightBackgroundColor(context),
                      child: Icon(
                        Icons.broken_image,
                        size: 32,
                        color: ThemeHelper.getSecondaryIconColor(context),
                      ),
                    ),
                  )
                : Container(
                    height: 140,
                    color: ThemeHelper.getLightBackgroundColor(context),
                    child: Icon(
                      Icons.image,
                      size: 32,
                      color: ThemeHelper.getSecondaryIconColor(context),
                    ),
                  ),
            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    service.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark
                          ? ThemeHelper.getPrimaryColor(context)
                          : ThemeHelper.getPrimaryDarkColor(context),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Rating
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < service.averageRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 12,
                          color: Colors.amber,
                        );
                      }),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          "${service.averageRating.toStringAsFixed(1)}/5 (${service.totalReviews})",
                          style: TextStyle(
                            fontSize: 10,
                            color: ThemeHelper.getSecondaryTextColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Price
                  Text(
                    "${_formatPrice(service.price)}₫/ ${_translateUnitType(service.unitType)}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.getPrimaryColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final priceInt = price.toInt();
    final priceStr = priceInt.toString();
    final buffer = StringBuffer();
    
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(priceStr[i]);
    }
    
    return buffer.toString();
  }

  String _translateUnitType(String unitType) {
    final lowerUnitType = unitType.toLowerCase().trim();
    
    switch (lowerUnitType) {
      case 'squaremeter':
      case 'square meter':
      case 'm²':
      case 'm2':
        return 'Mét vuông';
      case 'visit':
        return 'Lần';
      case 'hour':
      case 'hours':
        return 'Giờ';
      case 'day':
      case 'days':
        return 'Ngày';
      case 'apartment':
      case 'apartments':
        return 'Căn';
      case 'room':
      case 'rooms':
        return 'Phòng';
      case 'person':
      case 'persons':
      case 'people':
        return 'Người';
      case 'package':
      case 'packages':
        return 'Gói';
      case 'event':
      case 'events':
        return 'Sự kiện';
      case 'week':
      case 'weeks':
        return 'Tuần';
      case 'month':
      case 'months':
        return 'Tháng';
      default:
        return unitType;
    }
  }
}

class _ImageGallery extends StatefulWidget {
  final List<String> images;
  const _ImageGallery({required this.images});

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  int currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Image Carousel
        Container(
          height: 300,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: ThemeHelper.getShadowColor(context),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.images[index],
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    color: ThemeHelper.getLightBackgroundColor(context),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: ThemeHelper.getPrimaryColor(context),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    color: ThemeHelper.getLightBackgroundColor(context),
                  ),
                  child: Icon(
                    Icons.image,
                    size: 48,
                    color: ThemeHelper.getSecondaryIconColor(context),
                  ),
                ),
              );
            },
          ),
        ),
        // Thumbnail Gallery
        if (widget.images.length > 1)
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: ThemeHelper.getCardBackgroundColor(context),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final isSelected = index == currentIndex;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? ThemeHelper.getPrimaryColor(context)
                            : ThemeHelper.getBorderColor(context),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.images[index],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              decoration: BoxDecoration(
                                color: ThemeHelper.getLightBackgroundColor(context),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: ThemeHelper.getPrimaryColor(context),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                color: ThemeHelper.getLightBackgroundColor(context),
                              ),
                              child: Icon(
                                Icons.image,
                                size: 24,
                                color: ThemeHelper.getSecondaryIconColor(context),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: ThemeHelper.getPrimaryColor(context),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _BottomActionBar extends ConsumerWidget {
  final ServiceDetail detail;
  const _BottomActionBar({required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: ThemeHelper.getCardBackgroundColor(context),
        boxShadow: [
          BoxShadow(
              color: ThemeHelper.getShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
      child: Row(
        children: [
          // ----------- Icon Chat với Provider ----------
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                  color: ThemeHelper.getPrimaryColor(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                      color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
              onPressed: () async {
                try {
                  // Start conversation with provider
                  final conversationId = await ref
                      .read(chatListProvider.notifier)
                      .startConversationWithProvider(detail.providerId);
                  
                  if (conversationId != null && context.mounted) {
                    // Navigate to chat detail
                    context.push(Routes.chatDetailPath(conversationId));
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Không thể tạo cuộc trò chuyện. Vui lòng thử lại."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Lỗi: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              tooltip: "Chat với ${detail.provider.providerName}",
            ),
          ),

          const SizedBox(width: 12),

          // ----------- Nút thêm vào giỏ ----------
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                try {
                  // Convert service options to optionIds and optionValues
                  final optionIds = detail.serviceOptions
                      .map((opt) => opt.optionId)
                      .toList();
                  final optionValues = detail.serviceOptions.isNotEmpty
                      ? Map<String, dynamic>.fromEntries(
                          detail.serviceOptions.map((opt) => MapEntry(
                                opt.optionId,
                                opt.value ?? '',
                              )),
                        )
                      : null;

                  await ref.read(cartProvider.notifier).addToCartFromDetail(
                        serviceId: detail.serviceId,
                        optionIds: optionIds,
                        optionValues: optionValues,
                      );
                    
                    // Hiển thị thông báo thành công
                    if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã thêm vào giỏ"),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                  );
                    }
                } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString().contains('đã có trong giỏ hàng') 
                              ? "Dịch vụ này đã có trong giỏ hàng" 
                              : "Lỗi: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                }
              },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: ThemeHelper.getPrimaryColor(context),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_shopping_cart_rounded,
                      color: ThemeHelper.getPrimaryColor(context),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Thêm vào giỏ",
                      style: TextStyle(
                        color: ThemeHelper.getPrimaryColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ),
          ),

          const SizedBox(width: 12),

          // ----------- Nút Đặt ngay (đi đến checkout trực tiếp, không qua cart) ----------
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Navigate đến checkout với serviceId trực tiếp (không qua cart)
                context.push(
                  Routes.checkout,
                  extra: {'serviceId': detail.serviceId},
                );
              },
                style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHelper.getPrimaryColor(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                shadowColor: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_rounded, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Đặt ngay",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
