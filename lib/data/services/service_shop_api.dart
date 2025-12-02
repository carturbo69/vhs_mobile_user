import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/network/dio_client.dart';
import 'package:vhs_mobile_user/data/models/service_shop/service_shop_models.dart';
import 'package:vhs_mobile_user/data/models/service/service_detail.dart';
import 'package:vhs_mobile_user/data/models/service/service_model.dart';

final serviceShopApiProvider = Provider<ServiceShopApi>((ref) {
  final dio = ref.watch(dioClientProvider).instance;
  return ServiceShopApi(dio);
});

class ServiceShopApi {
  final Dio _dio;
  ServiceShopApi(this._dio);

  /// Get service shop data for a provider
  /// This follows the same logic as web frontend ServiceShopService
  Future<ServiceShopViewModel> getServiceShop({
    required String providerId,
    int? categoryId,
    String? tagId,
    String sortBy = 'popular',
    int page = 1,
  }) async {
    try {
      // BƯỚC 1: Lấy tất cả services của provider từ API
      final providerServices = await _getProviderServices(providerId);
      debugPrint("Step 1: Found ${providerServices.length} services");

      // BƯỚC 2: Lấy thông tin chi tiết của provider từ service detail
      final shopInfo = await _getShopInfo(providerId, providerServices);
      debugPrint("Step 2: ShopInfo - Name: '${shopInfo.name}', TotalServices: ${shopInfo.totalServices}");

      // BƯỚC 3: Lấy ratings từ homepage API
      final servicesRatingMap = await _getServicesRatingMap(providerId);
      debugPrint("Step 3: Rating map for ${servicesRatingMap.length} services");

      // BƯỚC 4: Map services thành ServiceShopItems với ratings
      final allServiceItems = _mapServicesToItems(providerServices, servicesRatingMap);
      debugPrint("Step 4: Mapped ${allServiceItems.length} ServiceItems");

      // BƯỚC 5: Lọc, sort và phân trang
      final (filteredServices, totalPages) = _applyFiltersAndPagination(
        allServiceItems,
        categoryId,
        tagId,
        sortBy,
        page,
      );
      debugPrint("Step 5: Filtered to ${filteredServices.length} services, $totalPages pages");

      // BƯỚC 6: Tạo các collections cho view
      final bestsellingServices = _getBestsellingServices(allServiceItems);
      final categories = _buildCategories(allServiceItems);

      return ServiceShopViewModel(
        providerId: providerId,
        shopInfo: shopInfo,
        bestsellingServices: bestsellingServices,
        shopCategories: categories,
        allCategories: categories,
        services: filteredServices,
        currentPage: page,
        totalPages: totalPages > 0 ? totalPages : 1,
        selectedCategoryId: categoryId,
        selectedTagId: tagId,
        sortBy: sortBy,
      );
    } on DioException catch (e) {
      debugPrint("Error getting service shop: $e");
      rethrow;
    }
  }

  /// BƯỚC 1: Lấy tất cả services của provider
  Future<List<Map<String, dynamic>>> _getProviderServices(String providerId) async {
    try {
      final resp = await _dio.get('/api/ServiceProvider/provider/$providerId');
      
      if (resp.statusCode == 200) {
        final data = resp.data;
        List<dynamic> servicesList = [];
        
        if (data is Map && data['success'] == true && data['data'] != null) {
          servicesList = data['data'] as List<dynamic>;
        } else if (data is List) {
          servicesList = data;
        }

        // Filter by status (only Approved/Active)
        final validServices = servicesList
            .where((s) {
              final status = s['status']?.toString() ?? '';
              return (status.isEmpty || status == 'Approved' || status == 'Active') &&
                     status != 'Pending' &&
                     status != 'PendingUpdate';
            })
            .where((s) => s['providerId']?.toString() == providerId)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        return validServices;
      }
      return [];
    } catch (e) {
      debugPrint("Error getting provider services: $e");
      return [];
    }
  }

  /// BƯỚC 2: Lấy thông tin shop từ service detail
  Future<ShopInfo> _getShopInfo(
      String providerId, List<Map<String, dynamic>> providerServices) async {
    if (providerServices.isEmpty) {
      return _createFallbackShopInfo(providerId, 0);
    }

    // Thử lấy từ service đầu tiên
    for (final service in providerServices.take(5)) {
      try {
        final serviceId = service['serviceId']?.toString();
        if (serviceId == null) continue;

        final serviceDetailResp = await _dio.get('/api/Services/$serviceId');
        if (serviceDetailResp.statusCode == 200) {
          final serviceDetail = ServiceDetail.fromJson(serviceDetailResp.data);
          
          // Kiểm tra providerId khớp
          if (serviceDetail.providerId == providerId && serviceDetail.provider != null) {
            final provider = serviceDetail.provider;
            
            // Tính response rate từ reviews
            double responseRate = 100.0;
            int totalRatings = 0;
            if (serviceDetail.reviews.isNotEmpty) {
              totalRatings = serviceDetail.reviews.length;
              final reviewsWithReply = serviceDetail.reviews
                  .where((r) => r.reply != null && r.reply!.isNotEmpty)
                  .length;
              if (totalRatings > 0) {
                responseRate = (reviewsWithReply * 100.0) / totalRatings;
                if (responseRate == 0) responseRate = 100.0;
              }
            }

            // Lấy logo từ provider images
            String logo = '';
            if (provider.images != null && provider.images!.isNotEmpty) {
              final images = provider.images!.split(',');
              if (images.isNotEmpty) {
                logo = images[0].trim();
              }
            }

            // Lấy status
            final status = (provider.status == 'Active' || provider.status == 'Approved')
                ? 'Online'
                : 'Offline';

            // Lấy join date
            String joinDate = '';
            if (provider.joinedAt != null) {
              final date = provider.joinedAt!;
              joinDate = '${date.month.toString().padLeft(2, '0')}/${date.year}';
            }

            var shopInfo = ShopInfo(
              id: 0,
              name: provider.providerName,
              logo: logo,
              status: status,
              lastOnline: 'Gần đây',
              totalServices: providerServices.length,
              following: 0,
              followers: 0,
              responseRate: responseRate,
              rating: 0.0, // Will be enhanced with ratings from all services
              totalRatings: totalRatings > 0 ? totalRatings : serviceDetail.totalReviews,
              joinDate: joinDate,
              isFollowed: false,
            );

            // Enhance với ratings từ tất cả services
            shopInfo = await _enhanceShopInfoWithRatings(shopInfo, providerId);
            
            return shopInfo;
          }
        }
      } catch (e) {
        debugPrint("Error getting service detail: $e");
        continue;
      }
    }

    return _createFallbackShopInfo(providerId, providerServices.length);
  }

  /// Enhance ShopInfo với ratings từ homepage API
  Future<ShopInfo> _enhanceShopInfoWithRatings(
      ShopInfo shopInfo, String providerId) async {
    try {
      // Lấy ratings từ homepage API
      final homepageResp = await _dio.get('/api/Services/services-homepage');
      if (homepageResp.statusCode == 200) {
        final services = (homepageResp.data as List)
            .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
            .where((s) => s.providerId == providerId)
            .toList();

        double totalWeightedRating = 0;
        int totalReviewsCount = 0;

        for (final svc in services) {
          if (svc.averageRating > 0 && svc.totalReviews > 0) {
            totalWeightedRating += svc.averageRating * svc.totalReviews;
            totalReviewsCount += svc.totalReviews;
          }
        }

        if (totalReviewsCount > 0) {
          final averageRating = totalWeightedRating / totalReviewsCount;
          return ShopInfo(
            id: shopInfo.id,
            name: shopInfo.name,
            logo: shopInfo.logo,
            status: shopInfo.status,
            lastOnline: shopInfo.lastOnline,
            totalServices: shopInfo.totalServices,
            following: shopInfo.following,
            followers: shopInfo.followers,
            responseRate: shopInfo.responseRate,
            rating: double.parse(averageRating.toStringAsFixed(1)),
            totalRatings: totalReviewsCount,
            joinDate: shopInfo.joinDate,
            isFollowed: shopInfo.isFollowed,
          );
        }
      }
    } catch (e) {
      debugPrint("Error enhancing shop info with ratings: $e");
    }
    return shopInfo;
  }

  /// BƯỚC 3: Lấy ratings từ homepage API
  Future<Map<String, Map<String, dynamic>>> _getServicesRatingMap(
      String providerId) async {
    final ratingMap = <String, Map<String, dynamic>>{};
    try {
      final resp = await _dio.get('/api/Services/services-homepage');
      if (resp.statusCode == 200) {
        final services = (resp.data as List)
            .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
            .where((s) => s.providerId == providerId)
            .toList();

        for (final svc in services) {
          ratingMap[svc.serviceId] = {
            'rating': svc.averageRating,
            'ratingCount': svc.totalReviews,
          };
        }
      }
    } catch (e) {
      debugPrint("Error getting rating map: $e");
    }
    return ratingMap;
  }

  /// BƯỚC 4: Map services thành ServiceShopItems
  List<ServiceShopItem> _mapServicesToItems(
      List<Map<String, dynamic>> providerServices,
      Map<String, Map<String, dynamic>> ratingMap) {
    return providerServices.map((dto) {
      final serviceId = dto['serviceId']?.toString() ?? '';
      final ratingInfo = ratingMap[serviceId];
      
      // Parse images
      String? imageUrl;
      final images = dto['images']?.toString();
      if (images != null && images.isNotEmpty) {
        try {
          // Try JSON array first
          final parsed = images.split(',');
          if (parsed.isNotEmpty) {
            imageUrl = parsed[0].trim();
          }
        } catch (e) {
          imageUrl = images;
        }
      }

      // Get tags
      List<String>? tags;
      if (dto['tags'] != null) {
        final tagsList = dto['tags'] as List?;
        if (tagsList != null) {
          tags = tagsList
              .map((t) => t['name']?.toString() ?? '')
              .where((t) => t.isNotEmpty)
              .toList();
        }
      }

      return ServiceShopItem(
        serviceId: serviceId,
        providerId: dto['providerId']?.toString() ?? '',
        categoryId: dto['categoryId']?.toString() ?? '',
        categoryName: dto['categoryName']?.toString() ?? '',
        name: dto['title']?.toString() ?? '',
        description: dto['description']?.toString(),
        price: (dto['price'] is num) ? (dto['price'] as num).toDouble() : 0.0,
        unitType: dto['unitType']?.toString() ?? '',
        baseUnit: dto['baseUnit'] ?? 0,
        imageUrl: imageUrl,
        image: imageUrl,
        status: dto['status']?.toString(),
        createdAt: dto['createdAt'] != null
            ? DateTime.tryParse(dto['createdAt'].toString())
            : null,
        tags: tags,
        serviceOptions: null,
        rating: ratingInfo?['rating'] ?? 0.0,
        ratingCount: ratingInfo?['ratingCount'] ?? 0,
      );
    }).toList();
  }

  /// BƯỚC 5: Áp dụng filters, sorting và pagination
  (List<ServiceShopItem>, int) _applyFiltersAndPagination(
      List<ServiceShopItem> allServices,
      int? categoryId,
      String? tagId,
      String sortBy,
      int page) {
    var filtered = allServices;

    // Filter by category - so sánh bằng hash code của categoryId
    if (categoryId != null) {
      filtered = filtered
          .where((s) {
            // So sánh hash code của categoryId string với categoryId int (đã là hash code)
            final serviceCategoryHash = s.categoryId.hashCode;
            return serviceCategoryHash == categoryId;
          })
          .toList();
    }

    // Filter by tag
    if (tagId != null) {
      filtered = filtered
          .where((s) => s.tags?.contains(tagId) ?? false)
          .toList();
    }

    // Apply sorting
    filtered = _applySorting(filtered, sortBy);

    // Pagination
    const pageSize = 12;
    final totalPages = (filtered.length / pageSize).ceil();
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    final paginated = filtered
        .sublist(
            startIndex.clamp(0, filtered.length),
            endIndex.clamp(0, filtered.length))
        .toList();

    return (paginated, totalPages > 0 ? totalPages : 1);
  }

  /// Get bestselling services - chỉ lấy services có rating >= 4
  List<ServiceShopItem> _getBestsellingServices(
      List<ServiceShopItem> allServices) {
    // Chỉ lấy services có rating >= 4
    final highRatedServices = allServices
        .where((s) => s.rating >= 4.0)
        .toList();
    
    final sorted = List<ServiceShopItem>.from(highRatedServices)
      ..sort((a, b) {
        final ratingCompare = b.rating.compareTo(a.rating);
        if (ratingCompare != 0) return ratingCompare;
        return b.ratingCount.compareTo(a.ratingCount);
      });
    return sorted.take(6).toList();
  }

  ShopInfo _createFallbackShopInfo(String providerId, int serviceCount) {
    return ShopInfo(
      id: 0,
      name: 'Đối tác VHS',
      logo: '',
      status: 'Online',
      lastOnline: 'Gần đây',
      totalServices: serviceCount,
      following: 0,
      followers: 0,
      responseRate: 100.0,
      rating: 0.0,
      totalRatings: 0,
      joinDate: '',
      isFollowed: false,
    );
  }

  List<ServiceCategory> _buildCategories(List<ServiceShopItem> services) {
    final categoryMap = <String, ServiceCategory>{};
    
    for (final service in services) {
      if (!categoryMap.containsKey(service.categoryId)) {
        // Sử dụng hash code của categoryId string làm id
        categoryMap[service.categoryId] = ServiceCategory(
          id: service.categoryId.hashCode,
          categoryId: service.categoryId,
          name: service.categoryName,
          icon: '',
          serviceCount: 0,
          subCategories: [],
          tags: [],
        );
      }
      final category = categoryMap[service.categoryId]!;
      categoryMap[service.categoryId] = ServiceCategory(
        id: category.id,
        categoryId: category.categoryId,
        name: category.name,
        icon: category.icon,
        serviceCount: category.serviceCount + 1,
        subCategories: category.subCategories,
        tags: category.tags,
      );
    }

    return categoryMap.values.toList();
  }

  List<ServiceShopItem> _applySorting(
      List<ServiceShopItem> services, String sortBy) {
    final sorted = List<ServiceShopItem>.from(services);
    
    switch (sortBy.toLowerCase()) {
      case 'popular':
        sorted.sort((a, b) {
          final ratingCompare = b.rating.compareTo(a.rating);
          if (ratingCompare != 0) return ratingCompare;
          return b.ratingCount.compareTo(a.ratingCount);
        });
        break;
      case 'bestselling':
        sorted.sort((a, b) {
          final ratingCompare = b.rating.compareTo(a.rating);
          if (ratingCompare != 0) return ratingCompare;
          return b.ratingCount.compareTo(a.ratingCount);
        });
        break;
      case 'price-asc':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price-desc':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'price':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      default:
        // Keep original order
        break;
    }
    
    return sorted;
  }
}

