import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vhs_mobile_user/data/models/service_shop/service_shop_models.dart';
import 'package:vhs_mobile_user/ui/service_shop/service_shop_viewmodel.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/chat/chat_list_viewmodel.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';

const Color primaryBlue = Color(0xFF0284C7);
const Color darkBlue = Color(0xFF0369A1);
const Color lightBlue = Color(0xFFE0F2FE);

class ServiceShopScreen extends ConsumerStatefulWidget {
  final String providerId;

  const ServiceShopScreen({super.key, required this.providerId});

  @override
  ConsumerState<ServiceShopScreen> createState() => _ServiceShopScreenState();
}

class _ServiceShopScreenState extends ConsumerState<ServiceShopScreen> {
  late ServiceShopParams _filterParams;

  @override
  void initState() {
    super.initState();
    _filterParams = ServiceShopParams(providerId: widget.providerId);
  }

  void updateFilter({int? categoryId, String? sortBy}) {
    setState(() {
      _filterParams = ServiceShopParams(
        providerId: widget.providerId,
        categoryId: categoryId,
        sortBy: sortBy ?? _filterParams.sortBy,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(
      serviceShopProvider(_filterParams),
    );

    final isDark = ThemeHelper.isDarkMode(context);
    
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
          "Shop Dịch Vụ",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: shopAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.blue.shade600,
                ),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                "Đang tải...",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
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
                  'Đã xảy ra lỗi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeHelper.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$err',
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeHelper.getSecondaryTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(serviceShopProvider(
                      ServiceShopParams(providerId: widget.providerId),
                    ));
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text(
                    'Thử lại',
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
        data: (shop) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(serviceShopProvider(_filterParams));
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shop Profile Section
                _buildShopProfile(context, ref, shop.shopInfo),
                
                // Bestselling Services
                if (shop.bestsellingServices.isNotEmpty)
                  _buildBestsellingSection(context, shop.bestsellingServices),
                
                // Categories Filter
                if (shop.allCategories.isNotEmpty)
                  _buildCategoriesFilter(context, ref, shop),
                
                // Services Grid
                _buildServicesGrid(shop.services, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopProfile(
      BuildContext context, WidgetRef ref, ShopInfo shopInfo) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        children: [
          Row(
            children: [
              // Logo
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemeHelper.getBorderColor(context),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeHelper.getShadowColor(context),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: shopInfo.logo.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: shopInfo.logo,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: ThemeHelper.getLightBackgroundColor(context),
                            child: Icon(
                              Icons.store_rounded,
                              size: 40,
                              color: ThemeHelper.getSecondaryIconColor(context),
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: ThemeHelper.getLightBackgroundColor(context),
                          child: Icon(
                            Icons.store_rounded,
                            size: 40,
                            color: ThemeHelper.getSecondaryIconColor(context),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Shop Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shopInfo.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelper.getTextColor(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: shopInfo.status == 'Online'
                                ? Colors.green.shade500
                                : Colors.grey.shade400,
                            boxShadow: shopInfo.status == 'Online'
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.4),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${shopInfo.status} ${shopInfo.lastOnline}',
                            style: TextStyle(
                              fontSize: 13,
                              color: ThemeHelper.getSecondaryTextColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Chat Button
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final conversationId = await ref
                        .read(chatListProvider.notifier)
                        .startConversationWithProvider(widget.providerId);
                    if (conversationId != null && context.mounted) {
                      context.push(Routes.chatDetailPath(conversationId));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text(
                  'Chat',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildStatItem('Dịch Vụ', shopInfo.totalServices.toString()),
              ),
              Expanded(
                child: _buildStatItem(
                  'Đánh Giá',
                  shopInfo.rating > 0 && shopInfo.totalRatings > 0
                      ? '${shopInfo.rating.toStringAsFixed(1)} (${shopInfo.totalRatings})'
                      : 'Chưa có đánh giá',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Tham Gia',
                  shopInfo.joinDate.isNotEmpty && shopInfo.joinDate != '—'
                      ? shopInfo.joinDate
                      : '—',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: ThemeHelper.getLightBlueBackgroundColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: ThemeHelper.getPrimaryDarkColor(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: ThemeHelper.getTertiaryTextColor(context),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBestsellingSection(BuildContext context, List<ServiceShopItem> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
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
                    Icons.star_rounded,
                    color: ThemeHelper.getPrimaryDarkColor(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'DỊCH VỤ NỔI BẬT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: ThemeHelper.getTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 200,
                child: _buildServiceCard(context, services[index], width: 200),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesFilter(
      BuildContext context, WidgetRef ref, ServiceShopViewModel shop) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: shop.allCategories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // "Tất cả" option
            final isActive = shop.selectedCategoryId == null;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  'Tất cả (${shop.shopInfo.totalServices})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: isActive,
                onSelected: (_) {
                  // Update filter state
                  final state = context.findAncestorStateOfType<_ServiceShopScreenState>();
                  state?.updateFilter(categoryId: null);
                },
                selectedColor: ThemeHelper.getPrimaryColor(context),
                backgroundColor: ThemeHelper.getCardBackgroundColor(context),
                side: BorderSide(
                  color: isActive
                      ? ThemeHelper.getPrimaryColor(context)
                      : ThemeHelper.getBorderColor(context),
                  width: isActive ? 2 : 1,
                ),
                labelStyle: TextStyle(
                  color: isActive
                      ? Colors.white
                      : ThemeHelper.getTextColor(context),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
                checkmarkColor: Colors.white,
                showCheckmark: isActive,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          }
          final category = shop.allCategories[index - 1];
          final isActive = shop.selectedCategoryId == category.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                '${category.name} (${category.serviceCount})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              selected: isActive,
              onSelected: (_) {
                // Update filter state
                final state = context.findAncestorStateOfType<_ServiceShopScreenState>();
                state?.updateFilter(categoryId: category.id);
              },
              selectedColor: ThemeHelper.getPrimaryColor(context),
              backgroundColor: ThemeHelper.getCardBackgroundColor(context),
              side: BorderSide(
                color: isActive
                    ? ThemeHelper.getPrimaryColor(context)
                    : ThemeHelper.getBorderColor(context),
                width: isActive ? 2 : 1,
              ),
              labelStyle: TextStyle(
                color: isActive
                    ? Colors.white
                    : ThemeHelper.getTextColor(context),
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              checkmarkColor: Colors.white,
              showCheckmark: isActive,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }


  Widget _buildServicesGrid(List<ServiceShopItem> services, BuildContext context) {
    if (services.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ThemeHelper.getLightBlueBackgroundColor(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.room_service_outlined,
                  size: 64,
                  color: ThemeHelper.getPrimaryColor(context),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Chưa có dịch vụ nào',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeHelper.getTextColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vui lòng quay lại sau',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeHelper.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return _buildServiceCard(context, services[index]);
        },
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceShopItem service, {double? width}) {
    final imageUrl = service.firstImage;

    return GestureDetector(
      onTap: () {
        context.push(Routes.detailServicePath(service.serviceId));
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: width ?? double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: width ?? double.infinity,
                        height: 120,
                        color: ThemeHelper.getLightBackgroundColor(context),
                        child: Icon(
                          Icons.image_rounded,
                          size: 40,
                          color: ThemeHelper.getSecondaryIconColor(context),
                        ),
                      ),
                    )
                  : Container(
                      width: width ?? double.infinity,
                      height: 120,
                      color: ThemeHelper.getLightBackgroundColor(context),
                      child: Icon(
                        Icons.image_rounded,
                        size: 40,
                        color: ThemeHelper.getSecondaryIconColor(context),
                      ),
                    ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    service.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.getTextColor(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatPrice(service.price)}₫',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (service.rating > 0 && service.ratingCount > 0) ...[
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${service.rating.toStringAsFixed(1)} (${service.ratingCount})',
                            style: TextStyle(
                              fontSize: 12,
                              color: ThemeHelper.getSecondaryTextColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else
                        Text(
                          'Chưa có đánh giá',
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeHelper.getSecondaryTextColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
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
}

