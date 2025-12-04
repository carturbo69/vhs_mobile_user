import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/data/models/provider/provider_availability_model.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_model.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/auth/auth_viewmodel.dart';
import 'package:vhs_mobile_user/ui/cart/cart_list_viewmodel.dart';
import 'package:vhs_mobile_user/ui/checkout/checkout_viewmodel.dart';
import 'package:vhs_mobile_user/ui/checkout/custom_pickers.dart';
import 'package:vhs_mobile_user/ui/user_address/user_address_viewmodel.dart';
import 'package:vhs_mobile_user/ui/voucher/voucher_dialog.dart';
import 'package:vhs_mobile_user/ui/voucher/voucher_viewmodel.dart';
import 'package:vhs_mobile_user/data/services/booking_api.dart';
import 'package:vhs_mobile_user/ui/service_detail/service_detail_viewmodel.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_result_model.dart';
import 'package:vhs_mobile_user/data/models/cart/cart_item_model.dart';
import 'package:vhs_mobile_user/data/models/service/service_detail.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/services/translation_cache_provider.dart';
import 'package:vhs_mobile_user/services/data_translation_service.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, this.selectedItemIds, this.serviceId});

  final List<String>? selectedItemIds;
  final String? serviceId; // Nếu có serviceId, đặt hàng trực tiếp không qua cart

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  Map<String, DateTime?> selectedDates = {}; // Map<cartItemId, DateTime>
  Map<String, TimeOfDay?> selectedTimes = {}; // Map<cartItemId, TimeOfDay>
  UserAddressModel? selectedAddress;
  List<String>? _selectedItemIds;
  String? _serviceId; // Nếu có serviceId, đặt hàng trực tiếp không qua cart
  bool _hasTriedToGetExtra = false;
  bool _agreedToTerms = false;
  String? _selectedPaymentMethod;
  bool _isSubmitting = false; // Track if booking is being submitted
  
  // Error messages for each field
  String? _addressError;
  Map<String, String?> _dateErrors = {}; // Map<cartItemId, error message>
  Map<String, String?> _timeErrors = {}; // Map<cartItemId, error message>
  String? _termsError;
  String? _paymentError;
  

  @override
  void initState() {
    super.initState();
    // Khởi tạo ngày mặc định cho tất cả items sẽ được set khi có items
    // Lấy selected item IDs từ extra parameter hoặc widget parameter
    _selectedItemIds = widget.selectedItemIds;
    _serviceId = widget.serviceId;
    // Không clear voucher ở đây để giữ voucher khi chuyển từ cart sang checkout
  }

  @override
  void dispose() {
    // Clear voucher khi thoát khỏi checkout screen
    // Điều này đảm bảo khi vào lại checkout screen, voucher sẽ được clear
    // Bỏ qua lỗi nếu widget đã unmount hoặc có vấn đề với ref
    try {
      if (mounted) {
        ref.read(selectedVoucherProvider.notifier).clear();
      }
    } catch (e) {
      // Bỏ qua lỗi - không cần thiết phải clear voucher nếu có lỗi
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy selected item IDs hoặc serviceId từ GoRouterState extra nếu chưa có và chưa thử lấy
    if (_selectedItemIds == null && _serviceId == null && !_hasTriedToGetExtra && mounted) {
      _hasTriedToGetExtra = true;
      try {
        final extra = GoRouterState.of(context).extra;
        if (extra is Map<String, dynamic> && extra.containsKey('serviceId')) {
          // Nếu extra là Map với serviceId, lấy serviceId
          _serviceId = extra['serviceId'] as String?;
        } else if (extra is List<String>) {
          _selectedItemIds = extra;
        } else if (extra is List && extra.isNotEmpty && extra.first is String) {
          // Fallback: nếu là List nhưng không phải List<String>, thử cast
          _selectedItemIds = extra.cast<String>();
        }
      } catch (e) {
        // Nếu không lấy được từ extra, để null và sẽ dùng tất cả items
        _selectedItemIds = null;
      }
    }
  }

  double _calculateSelectedTotal(List<dynamic> items) {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  // Helper method để dịch tên dịch vụ
  String _getLocalizedServiceName(String serviceName) {
    final locale = ref.read(localeProvider);
    if (locale.languageCode == 'vi') {
      return serviceName;
    }
    // Sử dụng translation cache để dịch
    final cache = ref.read(translationCacheProvider.notifier);
    return cache.getTranslationSync(serviceName);
  }

  // Helper method để dịch nội dung HTML (Terms of Service)
  Future<String> _getLocalizedHtmlContent(String htmlContent) async {
    final locale = ref.read(localeProvider);
    if (locale.languageCode == 'vi') {
      return htmlContent;
    }
    // Sử dụng translation cache để dịch HTML content
    // Google Translate có thể xử lý HTML và giữ nguyên tags
    final cache = ref.read(translationCacheProvider.notifier);
    return await cache.getTranslation(htmlContent);
  }

  // Helper: Convert ServiceDetail to CartItemModel để dùng chung UI
  CartItemModel _serviceDetailToCartItem(ServiceDetail detail) {
    // Convert ServiceOptionDetail to CartOptionModel
    final cartOptions = detail.serviceOptions.map((serviceOpt) {
      return CartOptionModel(
        cartItemOptionId: serviceOpt.serviceOptionId,
        optionId: serviceOpt.optionId,
        optionName: serviceOpt.optionName,
        tagId: serviceOpt.tagId ?? '',
        type: serviceOpt.type,
        family: serviceOpt.family ?? '',
        value: serviceOpt.value ?? '',
      );
    }).toList();
    
    // Debug: Log options conversion
    print('🔍 [_serviceDetailToCartItem] Service: ${detail.title}');
    print('  - serviceOptions count: ${detail.serviceOptions.length}');
    print('  - cartOptions count: ${cartOptions.length}');
    for (var opt in cartOptions) {
      print('    - optionId: ${opt.optionId}, optionName: ${opt.optionName}, value: ${opt.value}');
    }
    
    return CartItemModel(
      cartItemId: 'direct_${detail.serviceId}', // Temporary ID cho direct booking
      cartId: 'direct_cart',
      serviceId: detail.serviceId,
      createdAt: DateTime.now(),
      serviceName: detail.title,
      servicePrice: detail.price,
      serviceImages: detail.imageList,
      providerId: detail.providerId,
      providerName: detail.provider.providerName,
      providerImages: detail.provider.images ?? '',
      options: cartOptions,
      quantity: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider); // Rebuild when language changes
    ref.watch(translationCacheProvider); // Rebuild when translations are updated
    final addresses = ref.watch(userAddressProvider);
    
    // Nếu có serviceId, tạo virtual cart item từ service detail
    if (_serviceId != null) {
      final serviceDetail = ref.watch(serviceDetailProvider(_serviceId!));

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
          title: Text(
            context.tr('booking'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: serviceDetail.when(
          loading: () {
            final isDark = ThemeHelper.isDarkMode(context);
            return Center(
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
                  context.tr('loading'),
                  style: TextStyle(
                      color: ThemeHelper.getSecondaryTextColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            );
          },
          error: (e, st) {
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
                    context.tr('error_occurred'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                        color: ThemeHelper.getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$e',
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
          },
          data: (detail) {
            // Tạo virtual cart item từ service detail
            final virtualCartItem = _serviceDetailToCartItem(detail);
            // Khởi tạo ngày mặc định cho virtual item
            if (selectedDates[virtualCartItem.cartItemId] == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    selectedDates[virtualCartItem.cartItemId] = DateTime.now();
                  });
                }
              });
            }
            // Dùng chung UI với cart checkout
            return _buildCartCheckoutBody(context, [virtualCartItem], addresses, isDirectBooking: true);
          },
        ),
      );
    }

    // Logic từ cart
    final cart = ref.watch(cartProvider);

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
        title: Text(
          context.tr('booking'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cart.when(
        loading: () {
          final isDark = ThemeHelper.isDarkMode(context);
          return Center(
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
                context.tr('loading'),
                style: TextStyle(
                    color: ThemeHelper.getSecondaryTextColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          );
        },
        error: (e, st) {
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
                  context.tr('error_occurred'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                      color: ThemeHelper.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$e',
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
        },
        data: (allItems) {
          // Lọc chỉ lấy selected items
          final items = _selectedItemIds != null && _selectedItemIds!.isNotEmpty
              ? allItems.where((item) => _selectedItemIds!.contains(item.cartItemId)).toList()
              : allItems;
          
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: ThemeHelper.getLightBlueBackgroundColor(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: ThemeHelper.getPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.tr('no_services_selected'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelper.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('please_select_services_from_cart'),
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.getSecondaryTextColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                      label: Text(
                        context.tr('back_to_cart'),
                        style: const TextStyle(
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
          }
          
          // Khởi tạo ngày mặc định cho các items chưa có ngày (chỉ set state một lần)
          final now = DateTime.now();
          bool needsInit = false;
          for (final item in items) {
            if (selectedDates[item.cartItemId] == null) {
              needsInit = true;
              break;
            }
          }
          if (needsInit) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  for (final item in items) {
                    if (selectedDates[item.cartItemId] == null) {
                      selectedDates[item.cartItemId] = now;
                    }
                  }
                });
              }
            });
          }

          return addresses.when(
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
            error: (e, st) {
              // Kiểm tra nếu là lỗi 401 - token hết hạn
              final errorMsg = e.toString();
              final is401 = errorMsg.contains('401') || 
                          errorMsg.contains('Unauthorized') ||
                          (e is DioException && e.response?.statusCode == 401);
              
              if (is401) {
                // Tự động logout và redirect về login
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    ref.read(authStateProvider.notifier).logout();
                  }
                });
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        context.tr('login_session_expired'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('redirecting_to_login'),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              return Center(
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
                        context.tr('error_occurred'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ThemeHelper.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${context.tr('address_error')}: $e',
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeHelper.getSecondaryTextColor(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        label: Text(
                          context.tr('back'),
                          style: const TextStyle(
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
            data: (addrs) {
              if (addrs.isNotEmpty && selectedAddress == null) {
                selectedAddress = addrs.first;
              }

              return _buildCartCheckoutBody(context, items, addresses, isDirectBooking: false);
            },
          );
        },
      ),
    );
  }

  // Build UI chung cho cả cart checkout và direct booking
  Widget _buildCartCheckoutBody(
    BuildContext context,
    List<CartItemModel> items,
    AsyncValue<List<UserAddressModel>> addresses,
    {required bool isDirectBooking}
  ) {
    return addresses.when(
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
                color: ThemeHelper.getSecondaryTextColor(context),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      error: (e, st) {
        // Kiểm tra nếu là lỗi 401 - token hết hạn
        final errorMsg = e.toString();
        final is401 = errorMsg.contains('401') || 
                    errorMsg.contains('Unauthorized') ||
                    (e is DioException && e.response?.statusCode == 401);
        
        if (is401) {
          // Tự động logout và redirect về login
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              ref.read(authStateProvider.notifier).logout();
            }
          });
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Phiên đăng nhập đã hết hạn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Đang chuyển đến trang đăng nhập...',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        return Center(
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
                  'Đã xảy ra lỗi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lỗi địa chỉ: $e',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  label: const Text(
                    'Quay lại',
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
      data: (addrs) {
        if (addrs.isNotEmpty && selectedAddress == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                selectedAddress = addrs.first;
              });
            }
          });
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Section: Địa chỉ giao hàng
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
                            Icons.location_on_rounded,
                            color: ThemeHelper.getPrimaryDarkColor(context),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.tr('booking_address'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: ThemeHelper.getTextColor(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AddressManager(
                    addresses: addrs,
                    selected: selectedAddress,
                    onChanged: (a) => setState(() {
                      selectedAddress = a;
                      _addressError = null; // Clear error when address is selected
                    }),
                  ),
                  if (_addressError != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, size: 16, color: Colors.red[700]),
                          const SizedBox(width: 4),
                          Text(
                            _addressError!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  
                  // Section: Chọn ngày và giờ cho từng dịch vụ
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
                            Icons.calendar_today_rounded,
                            color: ThemeHelper.getPrimaryDarkColor(context),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.tr('select_date_time_for_service'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: ThemeHelper.getTextColor(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Hiển thị date và time selector cho từng item
                  ...items.map((item) {
                    final itemDate = selectedDates[item.cartItemId] ?? DateTime.now();
                    final hasDate = selectedDates[item.cartItemId] != null;
                    final hasTime = selectedTimes[item.cartItemId] != null;
                    final isComplete = hasDate && hasTime;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ThemeHelper.getCardBackgroundColor(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isComplete
                                  ? ThemeHelper.getPrimaryColor(context)
                                  : ThemeHelper.getBorderColor(context),
                              width: isComplete ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isComplete
                                    ? ThemeHelper.getPrimaryColor(context).withOpacity(0.1)
                                    : ThemeHelper.getShadowColor(context),
                                blurRadius: isComplete ? 8 : 4,
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
                                      color: isComplete
                                          ? ThemeHelper.getLightBlueBackgroundColor(context)
                                          : ThemeHelper.getInputBackgroundColor(context),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.room_service_rounded,
                                      size: 16,
                                      color: isComplete
                                          ? ThemeHelper.getPrimaryColor(context)
                                          : ThemeHelper.getSecondaryIconColor(context),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _getLocalizedServiceName(item.serviceName),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isComplete
                                            ? ThemeHelper.getPrimaryColor(context)
                                            : ThemeHelper.getTextColor(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Date selector
                  _DateSelector(
                                selected: itemDate,
                                onDaySelected: (d) => setState(() {
                                  selectedDates[item.cartItemId] = d;
                                  _dateErrors.remove(item.cartItemId); // Clear error when date is selected
                                }),
                    onCheckAvailability: (d) async {
                      // Nếu là direct booking (cartItemId bắt đầu bằng "direct_"), 
                      // truyền providerId trực tiếp vì không có cart item trong local DB
                      final isDirectBooking = item.cartItemId.startsWith('direct_');
                      return await ref
                          .read(checkoutProvider.notifier)
                          .checkDateAvailability(
                            d, 
                            selectedItemIds: isDirectBooking ? null : [item.cartItemId],
                            providerId: isDirectBooking ? item.providerId : null,
                          );
                    },
                  ),
                              if (_dateErrors[item.cartItemId] != null) ...[
                  const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, size: 16, color: Colors.red[700]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          _dateErrors[item.cartItemId]!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              // Time selector
                  _TimeSelector(
                                date: itemDate,
                                selected: selectedTimes[item.cartItemId],
                                onTimeSelected: (t) => setState(() {
                                  selectedTimes[item.cartItemId] = t;
                                  _timeErrors.remove(item.cartItemId); // Clear error when time is selected
                                }),
                    onCheckTime: (date, timeOfDay) async {
                      // Nếu là direct booking (cartItemId bắt đầu bằng "direct_"), 
                      // truyền providerId trực tiếp vì không có cart item trong local DB
                      final isDirectBooking = item.cartItemId.startsWith('direct_');
                      final dto = await ref
                          .read(checkoutProvider.notifier)
                                      .checkTimeAvailability(
                                        date,
                                        timeOfDay,
                            selectedItemIds: isDirectBooking ? null : [item.cartItemId],
                            providerId: isDirectBooking ? item.providerId : null,
                                      );
                                  return dto;
                                },
                              ),
                              if (_timeErrors[item.cartItemId] != null) ...[
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, size: 16, color: Colors.red[700]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          _timeErrors[item.cartItemId]!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                  const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  // Checkbox đồng ý điều khoản
                  Card(
                    elevation: 2,
                    shadowColor: ThemeHelper.getShadowColor(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _agreedToTerms 
                            ? ThemeHelper.getPrimaryColor(context).withOpacity(0.3)
                            : ThemeHelper.getBorderColor(context),
                        width: _agreedToTerms ? 2 : 1,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _agreedToTerms 
                            ? ThemeHelper.getPrimaryColor(context).withOpacity(0.05)
                            : ThemeHelper.getCardBackgroundColor(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CheckboxListTile(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                            _termsError = null; // Clear error when terms are agreed
                          });
                        },
                        title: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeHelper.getTextColor(context),
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(text: '${context.tr('i_have_read_and_agree')} '),
                              TextSpan(
                                text: context.tr('terms_of_service'),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _showTermsDialog(context);
                                  },
                              ),
                              TextSpan(text: ' ${context.tr('of_this_provider')}.'),
                            ],
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  if (_termsError != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, size: 16, color: Colors.red[700]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _termsError!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  
                  // Section: Voucher
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
                            Icons.local_offer_rounded,
                            color: ThemeHelper.getPrimaryDarkColor(context),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.tr('voucher'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: ThemeHelper.getTextColor(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer(
                    builder: (context, ref, child) {
                      final selectedVoucher = ref.watch(selectedVoucherProvider);
                      final selectedTotal = _calculateSelectedTotal(items);
                      
                      return InkWell(
                        onTap: () {
                          if (!mounted) return;
                          showDialog(
                            context: context,
                            builder: (context) => VoucherDialog(
                              totalAmount: selectedTotal,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: selectedVoucher != null 
                                ? Colors.green.shade50.withOpacity(ThemeHelper.isDarkMode(context) ? 0.2 : 1.0)
                                : ThemeHelper.getInputBackgroundColor(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedVoucher != null 
                                  ? Colors.green.shade400
                                  : ThemeHelper.getBorderColor(context),
                              width: selectedVoucher != null ? 2 : 1,
                            ),
                            boxShadow: selectedVoucher != null
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selectedVoucher != null 
                                    ? Icons.local_offer 
                                    : Icons.local_offer_outlined,
                                color: selectedVoucher != null 
                                    ? Colors.green[700] 
                                    : Colors.grey[600],
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedVoucher != null 
                                          ? selectedVoucher.code 
                                          : context.tr('select_voucher_text'),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: selectedVoucher != null 
                                            ? Colors.green.shade700
                                            : ThemeHelper.getTextColor(context),
                                      ),
                                    ),
                                    if (selectedVoucher != null)
                                      Text(
                                        context.tr('applied'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (selectedVoucher != null)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green[700],
                                  size: 24,
                                )
                              else
                                Icon(
                                  Icons.chevron_right,
                                  color: ThemeHelper.getSecondaryIconColor(context),
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Section: Phương thức thanh toán
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
                            Icons.payment_rounded,
                            color: ThemeHelper.getPrimaryDarkColor(context),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.tr('payment_method'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: ThemeHelper.getTextColor(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'VNPay';
                        _paymentError = null; // Clear error when payment is selected
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedPaymentMethod == 'VNPay' 
                            ? ThemeHelper.getLightBlueBackgroundColor(context)
                            : ThemeHelper.getCardBackgroundColor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedPaymentMethod == 'VNPay' 
                              ? ThemeHelper.getPrimaryColor(context)
                              : ThemeHelper.getBorderColor(context),
                          width: _selectedPaymentMethod == 'VNPay' ? 2.5 : 1.5,
                        ),
                        boxShadow: _selectedPaymentMethod == 'VNPay'
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: ThemeHelper.getShadowColor(context),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _selectedPaymentMethod == 'VNPay'
                                  ? ThemeHelper.getLightBlueBackgroundColor(context)
                                  : ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _selectedPaymentMethod == 'VNPay'
                                  ? [
                                      BoxShadow(
                                        color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              Icons.account_balance_rounded,
                              color: _selectedPaymentMethod == 'VNPay'
                                  ? ThemeHelper.getPrimaryColor(context)
                                  : ThemeHelper.getPrimaryDarkColor(context),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'VNPay',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: _selectedPaymentMethod == 'VNPay'
                                        ? ThemeHelper.getPrimaryColor(context)
                                        : ThemeHelper.getTextColor(context),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.tr('qr_atm_card'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ThemeHelper.getSecondaryTextColor(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedPaymentMethod == 'VNPay')
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: ThemeHelper.getPrimaryColor(context),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_paymentError != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, size: 16, color: Colors.red[700]),
                          const SizedBox(width: 4),
                          Text(
                            _paymentError!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  _OrderSummary(items: items),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : () async {
                      // Kiểm tra nếu đang xử lý thì không làm gì
                      if (_isSubmitting) return;
                      
                      bool hasError = false;
                      
                      // Kiểm tra có items không
                      if (items.isEmpty) {
                        setState(() {
                          hasError = true;
                        });
                        // Scroll to top to show error
                        return;
                      }
                      
                      // Kiểm tra địa chỉ
                      if (selectedAddress == null) {
                        setState(() {
                          _addressError = context.tr('please_select_delivery_address');
                          hasError = true;
                        });
                      } else {
                        setState(() {
                          _addressError = null;
                        });
                      }
                      
                      // Kiểm tra ngày đặt cho từng item
                      final dateErrors = <String, String>{};
                      for (final item in items) {
                        if (selectedDates[item.cartItemId] == null) {
                          dateErrors[item.cartItemId] = '${context.tr('please_select_date_for')} ${_getLocalizedServiceName(item.serviceName)}';
                          hasError = true;
                        }
                      }
                      setState(() {
                        _dateErrors = dateErrors;
                      });
                      
                      // Kiểm tra giờ đặt cho từng item
                      final timeErrors = <String, String>{};
                      for (final item in items) {
                        if (selectedTimes[item.cartItemId] == null) {
                          timeErrors[item.cartItemId] = '${context.tr('please_select_time_slot_for')} ${_getLocalizedServiceName(item.serviceName)}';
                          hasError = true;
                        }
                      }
                      setState(() {
                        _timeErrors = timeErrors;
                      });
                      
                      // Kiểm tra đã đồng ý điều khoản chưa
                      if (!_agreedToTerms) {
                        setState(() {
                          _termsError = context.tr('please_agree_to_terms');
                          hasError = true;
                        });
                      } else {
                        setState(() {
                          _termsError = null;
                        });
                      }
                      
                      // Kiểm tra đã chọn phương thức thanh toán chưa
                      if (_selectedPaymentMethod == null) {
                        setState(() {
                          _paymentError = context.tr('please_select_payment_method');
                          hasError = true;
                        });
                      } else {
                        setState(() {
                          _paymentError = null;
                        });
                      }
                      
                      // Nếu có lỗi, dừng lại
                      if (hasError) {
                        return;
                      }
                      
                      // Set submitting state để disable nút
                      setState(() {
                        _isSubmitting = true;
                      });
                      
                      try {
                        // Lấy voucherId nếu có (voucher không bắt buộc)
                        final selectedVoucher = ref.read(selectedVoucherProvider);
                        final voucherId = selectedVoucher?.voucherId;
                        
                        // Submit booking
                        BookingResultModel result;
                        
                        // Kiểm tra nếu có serviceId (direct booking từ service detail page)
                        if (_serviceId != null && items.isNotEmpty && items.first.cartItemId.startsWith('direct_')) {
                          // Lấy date và time từ selectedDates/selectedTimes cho virtual cart item
                          final directItem = items.first;
                          final directDate = selectedDates[directItem.cartItemId];
                          final directTime = selectedTimes[directItem.cartItemId];
                          
                          if (directDate == null || directTime == null) {
                            setState(() {
                              _isSubmitting = false;
                            });
                            return;
                          }
                          
                          result = await ref
                              .read(checkoutProvider.notifier)
                              .submitBookingFromServiceId(
                                serviceId: _serviceId!,
                                address: selectedAddress!,
                                date: directDate,
                                time: directTime,
                                voucherId: voucherId,
                                options: directItem.options, // Pass options from virtual cart item
                              );
                        } else {
                          // Submit booking với selected items từ cart
                          // Convert Map<String, DateTime?> thành Map<String, DateTime> (bỏ null)
                          final datesMap = <String, DateTime>{};
                          for (final item in items) {
                            final date = selectedDates[item.cartItemId];
                            if (date != null) {
                              datesMap[item.cartItemId] = date;
                            }
                          }
                          
                          // Convert Map<String, TimeOfDay?> thành Map<String, TimeOfDay> (bỏ null)
                          final timesMap = <String, TimeOfDay>{};
                          for (final item in items) {
                            final time = selectedTimes[item.cartItemId];
                            if (time != null) {
                              timesMap[item.cartItemId] = time;
                            }
                          }
                          
                          result = await ref
                                .read(checkoutProvider.notifier)
                                .submitBooking(
                                  address: selectedAddress!,
                                dates: datesMap,
                                times: timesMap,
                                selectedItemIds: _selectedItemIds,
                                voucherId: voucherId,
                              );
                        }

                        if (!mounted) return;

                            if (result.bookingIds.isNotEmpty) {
                              context.go(Routes.bookingResult, extra: result);
                            } else {
                          if (!mounted) return;
                          setState(() {
                            _isSubmitting = false;
                          });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.tr('booking_failed')),
                            ),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        setState(() {
                          _isSubmitting = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${context.tr('error')}: ${e.toString()}"),
                            backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSubmitting 
                          ? ThemeHelper.getSecondaryIconColor(context)
                          : ThemeHelper.getPrimaryColor(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: _isSubmitting ? 0 : 4,
                      shadowColor: _isSubmitting 
                          ? Colors.transparent
                          : ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                context.tr('processing'),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                context.tr('booking'),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                    ),
                  ),
                ],
              );
            },
    );
  }

  void _showTermsDialog(BuildContext context) async {
    // Lấy providerId từ cart items
    final cart = ref.read(cartProvider);
    String? providerId;
    
    cart.whenData((items) {
      if (items.isNotEmpty) {
        final selectedItems = _selectedItemIds != null && _selectedItemIds!.isNotEmpty
            ? items.where((item) => _selectedItemIds!.contains(item.cartItemId)).toList()
            : items;
        if (selectedItems.isNotEmpty) {
          providerId = selectedItems.first.providerId;
        }
      }
    });

    // Lấy TermOfService từ API
    String? termDescription;
    String? providerName;
    
    if (providerId != null && providerId!.isNotEmpty) {
      try {
        final bookingApi = ref.read(bookingApiProvider);
        final termOfService = await bookingApi.getTermOfServiceByProviderId(providerId!);
        
        if (termOfService != null) {
          providerName = termOfService['providerName'] as String? ?? 
                        termOfService['ProviderName'] as String?;
          var rawDescription = termOfService['description'] as String? ?? 
                              termOfService['Description'] as String?;
          
          // Convert \r\n và \n thành <br> để hiển thị đúng line breaks như database lưu
          if (rawDescription != null && rawDescription.isNotEmpty) {
            // Convert tất cả line breaks thành <br> tags
            // Đảm bảo preserve formatting như database lưu
            termDescription = rawDescription
                .replaceAll('\r\n', '<br>')
                .replaceAll('\r', '<br>')
                .replaceAll('\n', '<br>');
          }
        }
      } catch (e) {
        print('Error loading TermOfService: $e');
      }
    }

    if (!mounted) return;
    
    final baseUrl = 'http://apivhs.cuahangkinhdoanh.com';
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          // Watch để rebuild khi translation cache cập nhật - giống như service_list
          ref.watch(localeProvider);
          final translationCache = ref.watch(translationCacheProvider);
          
          // Lấy localized content - sử dụng DataTranslationService như service_list
          String? displayTermDescription = termDescription;
          if (termDescription != null && termDescription!.isNotEmpty) {
            final locale = ref.read(localeProvider);
            
            if (locale.languageCode != 'vi') {
              // Tạo cache key từ HTML content
              final cacheKey = termDescription!;
              
              // Kiểm tra cache
              if (translationCache.containsKey(cacheKey)) {
                // Đã có trong cache, dùng luôn
                displayTermDescription = translationCache[cacheKey];
              } else {
                // Chưa có trong cache, trigger async translation
                // UI sẽ rebuild khi translation hoàn thành và cache được update
                ref.read(translationCacheProvider.notifier).getTranslation(cacheKey).then((translated) {
                  // Translation hoàn thành, cache đã được update
                  // UI sẽ tự động rebuild vì đã watch translationCacheProvider
                }).catchError((e) {
                  print('⚠️ Error translating terms: $e');
                });
                
                // Dùng text gốc tạm thời, sẽ được update khi translation hoàn thành
                displayTermDescription = termDescription;
              }
            }
          }
          
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              decoration: BoxDecoration(
                color: ThemeHelper.getDialogBackgroundColor(context),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: ThemeHelper.getShadowColor(context),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header với gradient đẹp hơn
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeHelper.getShadowColor(context),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.description_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('terms_of_service'),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                          if (providerName != null && providerName!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                providerName!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.95),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeHelper.getShadowColor(context),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            tooltip: context.tr('close'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content với background đẹp hơn
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ThemeHelper.getScaffoldBackgroundColor(context),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hiển thị Description từ TermOfService (hiển thị HTML đúng như database lưu)
                            if (displayTermDescription != null && displayTermDescription!.isNotEmpty) ...[
                          Container(
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
                            child: Html(
                              data: displayTermDescription!,
                              style: {
                                "body": Style(
                                  fontSize: FontSize(15.5),
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                  lineHeight: LineHeight(1.7),
                                  color: ThemeHelper.getTextColor(context),
                                ),
                                "p": Style(
                                  margin: Margins.only(bottom: 14),
                                  lineHeight: LineHeight(1.7),
                                ),
                                "div": Style(
                                  margin: Margins.only(bottom: 14),
                                ),
                                "h1": Style(
                                  fontSize: FontSize(22),
                                  fontWeight: FontWeight.bold,
                                  margin: Margins.only(bottom: 18, top: 24),
                                  color: ThemeHelper.getPrimaryColor(context),
                                  letterSpacing: -0.3,
                                ),
                                "h2": Style(
                                  fontSize: FontSize(20),
                                  fontWeight: FontWeight.bold,
                                  margin: Margins.only(bottom: 14, top: 20),
                                  color: ThemeHelper.getPrimaryColor(context),
                                  letterSpacing: -0.2,
                                ),
                                "h3": Style(
                                  fontSize: FontSize(18),
                                  fontWeight: FontWeight.w600,
                                  margin: Margins.only(bottom: 12, top: 18),
                                  color: ThemeHelper.getTextColor(context),
                                  letterSpacing: -0.1,
                                ),
                                "ul": Style(
                                  margin: Margins.only(bottom: 14),
                                  padding: HtmlPaddings.only(left: 24),
                                ),
                                "ol": Style(
                                  margin: Margins.only(bottom: 14),
                                  padding: HtmlPaddings.only(left: 24),
                                ),
                                "li": Style(
                                  margin: Margins.only(bottom: 8),
                                  display: Display.listItem,
                                  lineHeight: LineHeight(1.7),
                                ),
                                "img": Style(
                                  display: Display.block,
                                  margin: Margins.only(bottom: 20, top: 12),
                                  width: Width(MediaQuery.of(context).size.width * 0.7),
                                ),
                                "br": Style(
                                  display: Display.block,
                                  height: Height(10),
                                ),
                                "strong": Style(
                                  fontWeight: FontWeight.bold,
                                  color: ThemeHelper.getTextColor(context),
                                ),
                                "b": Style(
                                  fontWeight: FontWeight.bold,
                                  color: ThemeHelper.getTextColor(context),
                                ),
                              },
                            ),
                          ),
                        ],
              
                        // Nếu không có TermOfService, hiển thị điều khoản mặc định
                        if (displayTermDescription == null || displayTermDescription!.isEmpty) ...[
                          _buildDefaultTermSection(
                            context,
                            ref,
                            '1. Điều khoản chung',
                            'Khi sử dụng dịch vụ của chúng tôi, bạn đồng ý tuân thủ các điều khoản và điều kiện sau đây.',
                          ),
                          const SizedBox(height: 20),
                          _buildDefaultTermSection(
                            context,
                            ref,
                            '2. Đặt lịch và thanh toán',
                            '• Bạn có thể đặt lịch dịch vụ thông qua ứng dụng.\n'
                            '• Thanh toán được thực hiện qua VNPay (QR/ATM/Thẻ).\n'
                            '• Đơn hàng chỉ được xác nhận sau khi thanh toán thành công.',
                          ),
                          const SizedBox(height: 20),
                          _buildDefaultTermSection(
                            context,
                            ref,
                            '3. Hủy và hoàn tiền',
                            '• Hủy đơn trước 24 giờ: Hoàn tiền 100%.\n'
                            '• Hủy đơn trong vòng 24 giờ: Hoàn tiền 50%.\n'
                            '• Hủy đơn trong vòng 12 giờ: Không hoàn tiền.',
                          ),
                          const SizedBox(height: 20),
                          _buildDefaultTermSection(
                            context,
                            ref,
                            '4. Trách nhiệm',
                            '• Nhà cung cấp dịch vụ chịu trách nhiệm về chất lượng dịch vụ.\n'
                            '• Khách hàng cung cấp thông tin chính xác khi đặt lịch.\n'
                            '• Ứng dụng không chịu trách nhiệm về các tranh chấp giữa khách hàng và nhà cung cấp.',
                          ),
                          const SizedBox(height: 20),
                          _buildDefaultTermSection(
                            context,
                            ref,
                            '5. Bảo mật thông tin',
                            'Chúng tôi cam kết bảo mật thông tin cá nhân của bạn theo quy định của pháp luật.',
                          ),
                        ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Footer với nút đóng đẹp hơn
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ThemeHelper.getCardBackgroundColor(context),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: ThemeHelper.getBorderColor(context),
                          width: 1,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeHelper.getShadowColor(context),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [
                              ThemeHelper.getPrimaryColor(context),
                              ThemeHelper.getPrimaryDarkColor(context),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeHelper.getPrimaryColor(context).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.check_rounded, size: 20),
                          label: Text(
                            context.tr('close'),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultTermSection(BuildContext context, WidgetRef ref, String title, String content) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ hoặc có translation mới
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
    // Dịch title và content nếu cần - sử dụng DataTranslationService như service_list
    final locale = ref.read(localeProvider);
    final translationService = DataTranslationService(ref);
    
    String localizedTitle = title;
    String localizedContent = content;
    
    if (locale.languageCode != 'vi') {
      // Sử dụng smartTranslate để dịch tự động
      localizedTitle = translationService.smartTranslate(title);
      localizedContent = translationService.smartTranslate(content);
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeHelper.getBorderColor(context),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade600,
                      Colors.blue.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  localizedTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue.shade600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            localizedContent,
            style: TextStyle(
              fontSize: 15.5,
              height: 1.7,
              color: ThemeHelper.getTextColor(context),
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  // Helper function để strip HTML tags
  String _stripHtmlTags(String html) {
    // Loại bỏ các HTML tags
    String text = html.replaceAll(RegExp(r'<[^>]*>'), '');
    // Decode HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
    // Loại bỏ khoảng trắng thừa
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

}

class _AddressManager extends ConsumerStatefulWidget {
  final List<UserAddressModel> addresses;
  final UserAddressModel? selected;
  final ValueChanged<UserAddressModel> onChanged;

  const _AddressManager({
    required this.addresses,
    required this.selected,
    required this.onChanged,
  });

  @override
  ConsumerState<_AddressManager> createState() => _AddressManagerState();
}

class _AddressManagerState extends ConsumerState<_AddressManager> {
  @override
  Widget build(BuildContext context) {
      return Container(
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
            if (widget.selected != null) ...[
              // Hiển thị địa chỉ đã chọn - có thể bấm vào để thay đổi
              InkWell(
                onTap: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (c) => _AddressSelectionDialog(
                      addresses: widget.addresses,
                      selected: widget.selected,
                      onAdd: () {
                        Navigator.pop(c, {'action': 'add'});
                      },
                    ),
                  );
                  if (!mounted) return;
                  if (result != null) {
                    if (result['action'] == 'select') {
                      widget.onChanged(result['address'] as UserAddressModel);
                    } else if (result['action'] == 'add') {
                      await context.push(Routes.addAddress);
                      if (!mounted) return;
                      await ref.read(userAddressProvider.notifier).refresh();
                      if (!mounted) return;
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (!mounted) return;
                      final updatedAddresses = ref.read(userAddressProvider);
                      updatedAddresses.whenData((addrs) {
                        if (!mounted) return;
                        if (addrs.isNotEmpty) {
                          widget.onChanged(addrs.first);
                        }
                      });
                    } else if (result['action'] == 'edit') {
                      final addr = result['address'] as UserAddressModel;
                      await context.push(
                        Routes.addAddress,
                        extra: addr,
                      );
                      if (!mounted) return;
                      await ref.read(userAddressProvider.notifier).refresh();
                      if (!mounted) return;
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (!mounted) return;
                      final updatedAddresses = ref.read(userAddressProvider);
                      updatedAddresses.whenData((addrs) {
                        if (!mounted) return;
                        final updated = addrs.firstWhere(
                          (a) => a.addressId == addr.addressId,
                          orElse: () => addrs.isNotEmpty ? addrs.first : addr,
                        );
                        if (widget.selected?.addressId == addr.addressId) {
                          widget.onChanged(updated);
                        }
                      });
                    } else if (result['action'] == 'delete') {
                      final addr = result['address'] as UserAddressModel;
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(context.tr('delete_address_question')),
                          content: Text(context.tr('are_you_sure_delete_address')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(context.tr('cancel')),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(
                                context.tr('delete'),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (!mounted) return;
                      if (confirm == true) {
                        await ref.read(userAddressProvider.notifier).remove(addr.addressId);
                        if (!mounted) return;
                        await Future.delayed(const Duration(milliseconds: 300));
                        if (!mounted) return;
                        final updatedAddresses = ref.read(userAddressProvider);
                        updatedAddresses.whenData((addrs) {
                          if (!mounted) return;
                          if (widget.selected?.addressId == addr.addressId) {
                            if (addrs.isNotEmpty) {
                              widget.onChanged(addrs.first);
                            }
                          }
                        });
                      }
                    }
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.selected!.fullAddress,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ThemeHelper.getTextColor(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.selected!.recipientName != null || widget.selected!.recipientPhone != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${widget.selected!.recipientName ?? ''}${widget.selected!.recipientName != null && widget.selected!.recipientPhone != null ? ' • ' : ''}${widget.selected!.recipientPhone ?? ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: ThemeHelper.getSecondaryTextColor(context),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            // Nút thêm địa chỉ (chỉ hiển thị khi chưa có địa chỉ nào)
            if (widget.selected == null)
              TextButton.icon(
                onPressed: () async {
                  await context.push(Routes.addAddress);
                  if (!mounted) return;
                  await ref.read(userAddressProvider.notifier).refresh();
                  if (!mounted) return;
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (!mounted) return;
                  final updatedAddresses = ref.read(userAddressProvider);
                  updatedAddresses.whenData((addrs) {
                    if (!mounted) return;
                    if (addrs.isNotEmpty) {
                      widget.onChanged(addrs.first);
                    }
                  });
                },
                icon: const Icon(Icons.add_location_alt, size: 18),
                label: Text(context.tr('add_address')),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddressSelectionDialog extends StatelessWidget {
  final List<UserAddressModel> addresses;
  final UserAddressModel? selected;
  final VoidCallback onAdd;

  const _AddressSelectionDialog({
    required this.addresses,
    required this.selected,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: ThemeHelper.getDialogBackgroundColor(context),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.getShadowColor(context),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade600,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      context.tr('select_address'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: addresses.length,
                itemBuilder: (ctx, idx) {
                  final addr = addresses[idx];
                  final isSelected = selected?.addressId == addr.addressId;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ThemeHelper.getLightBlueBackgroundColor(context)
                          : ThemeHelper.getCardBackgroundColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? ThemeHelper.getPrimaryColor(context)
                            : ThemeHelper.getBorderColor(context),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? ThemeHelper.getPrimaryColor(context).withOpacity(0.2)
                              : ThemeHelper.getShadowColor(context),
                          blurRadius: isSelected ? 10 : 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context, {'action': 'select', 'address': addr});
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Radio button
                            Container(
                              width: 26,
                              height: 26,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? ThemeHelper.getPrimaryColor(context)
                                      : ThemeHelper.getBorderColor(context),
                                  width: 2.5,
                                ),
                                color: isSelected
                                    ? ThemeHelper.getPrimaryColor(context)
                                    : Colors.transparent,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            // Address info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    addr.fullAddress,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? ThemeHelper.getPrimaryColor(context)
                                          : ThemeHelper.getTextColor(context),
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (addr.recipientName != null || addr.recipientPhone != null) ...[
                                    const SizedBox(height: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (addr.recipientName != null)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Icon(
                                                    Icons.person_outline_rounded,
                                                    size: 14,
                                                    color: ThemeHelper.getSecondaryTextColor(context),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    addr.recipientName!,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: ThemeHelper.getSecondaryTextColor(context),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (addr.recipientPhone != null)
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Icon(
                                                  Icons.phone_outlined,
                                                  size: 14,
                                                  color: ThemeHelper.getSecondaryTextColor(context),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  addr.recipientPhone!,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: ThemeHelper.getSecondaryTextColor(context),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Menu button
                            PopupMenuButton<String>(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.more_vert_rounded,
                                  size: 20,
                                  color: ThemeHelper.getSecondaryTextColor(context),
                                ),
                              ),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: "edit",
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: ThemeHelper.getLightBlueBackgroundColor(context),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          Icons.edit_rounded,
                                          size: 18,
                                          color: ThemeHelper.getPrimaryColor(context),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        context.tr('edit'),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: "delete",
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          Icons.delete_outline_rounded,
                                          size: 18,
                                          color: Colors.red.shade600,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        context.tr('delete'),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == "edit") {
                                  Navigator.pop(context, {'action': 'edit', 'address': addr});
                                } else if (value == "delete") {
                                  Navigator.pop(context, {'action': 'delete', 'address': addr});
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Add button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_location_alt_rounded, size: 22),
                  label: Text(
                    context.tr('add_new_address'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeHelper.getPrimaryColor(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: Colors.blue.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            // Cancel button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text(
                    context.tr('cancel'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ThemeHelper.getSecondaryTextColor(context),
                    side: BorderSide(
                      color: ThemeHelper.getBorderColor(context),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSelector extends ConsumerWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onDaySelected;
  final Future<bool> Function(DateTime) onCheckAvailability;

  const _DateSelector({
    required this.selected,
    required this.onDaySelected,
    required this.onCheckAvailability,
  });

  String _formatDate(DateTime date, BuildContext context) {
    final weekdays = [
      context.tr('weekday_sunday'),
      context.tr('weekday_monday'),
      context.tr('weekday_tuesday'),
      context.tr('weekday_wednesday'),
      context.tr('weekday_thursday'),
      context.tr('weekday_friday'),
      context.tr('weekday_saturday'),
    ];
    return '${weekdays[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          // Mở custom date picker đẹp
          final picked = await showDialog<DateTime>(
            context: context,
            builder: (context) => CustomDatePicker(
              initialDate: selected,
              onCheckAvailability: onCheckAvailability,
            ),
          );
          
          if (picked != null && context.mounted) {
            // Kiểm tra availability trước khi chọn
            try {
              final available = await onCheckAvailability(picked);
              if (available && context.mounted) {
                onDaySelected(picked);
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('this_date_no_schedule')),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            } catch (e) {
              if (!context.mounted) return;
              final errorMsg = e.toString();
              if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Phiên đăng nhập đã hết hạn. Đang chuyển đến trang đăng nhập...'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (context.mounted) {
                    ref.read(authStateProvider.notifier).logout();
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ThemeHelper.getLightBlueBackgroundColor(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: ThemeHelper.getPrimaryColor(context),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(selected, context),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: ThemeHelper.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('tap_to_select_another_date'),
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeHelper.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeSelector extends ConsumerWidget {
  final DateTime date;
  final TimeOfDay? selected;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final Future<ProviderAvailabilityModel> Function(
    DateTime date,
    TimeOfDay time,
  )
  onCheckTime;

  const _TimeSelector({
    required this.date,
    required this.selected,
    required this.onTimeSelected,
    required this.onCheckTime,
  });

  String _formatTime(TimeOfDay? time, BuildContext context) {
    if (time == null) return context.tr('not_selected');
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // Mở custom time picker đẹp với slider
          final picked = await showDialog<TimeOfDay>(
            context: context,
            builder: (context) => CustomTimePicker(
              initialTime: selected ?? const TimeOfDay(hour: 8, minute: 0),
              date: date,
              onCheckTime: onCheckTime,
            ),
          );
          
          if (picked != null && context.mounted) {
            try {
              final dto = await onCheckTime(date, picked);
              if (dto.isAvailable && context.mounted) {
                onTimeSelected(picked);
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('time_slot_not_available')),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            } catch (e) {
              if (!context.mounted) return;
              final errorMsg = e.toString();
              if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Phiên đăng nhập đã hết hạn. Đang chuyển đến trang đăng nhập...'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (context.mounted) {
                    ref.read(authStateProvider.notifier).logout();
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ThemeHelper.getLightBlueBackgroundColor(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: ThemeHelper.getPrimaryColor(context),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected != null ? _formatTime(selected, context) : context.tr('time_not_selected'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: selected != null
                            ? ThemeHelper.getTextColor(context)
                            : ThemeHelper.getSecondaryTextColor(context),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('tap_to_select_time_slot'),
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeHelper.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSummary extends ConsumerWidget {
  final List<CartItemModel> items;

  const _OrderSummary({required this.items});

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

  // Helper method để dịch tên dịch vụ
  String _getLocalizedServiceName(String serviceName, WidgetRef ref) {
    final locale = ref.read(localeProvider);
    if (locale.languageCode == 'vi') {
      return serviceName;
    }
    // Sử dụng translation cache để dịch
    final cache = ref.read(translationCacheProvider.notifier);
    return cache.getTranslationSync(serviceName);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider); // Rebuild when language changes
    ref.watch(translationCacheProvider); // Rebuild when translations are updated
    // Tính tổng từ items
    final selectedTotal = items.fold(0.0, (sum, item) => sum + item.subtotal);
    
    // Lấy voucher và tính discount
    final selectedVoucher = ref.watch(selectedVoucherProvider);
    final voucherDiscount = selectedVoucher != null
        ? selectedVoucher.calculateDiscount(selectedTotal)
        : 0.0;
    final finalTotal = selectedTotal - voucherDiscount;
    
    return Container(
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ThemeHelper.getLightBlueBackgroundColor(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: ThemeHelper.getPrimaryColor(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  context.tr('order_summary'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                    color: ThemeHelper.getTextColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map(
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getLocalizedServiceName(i.serviceName, ref),
                        style: TextStyle(
                          fontSize: 15,
                          color: ThemeHelper.getTextColor(context),
                        ),
                      ),
                    ),
                    Text(
                      '${_formatPrice(i.subtotal)}₫',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.getTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            // Hiển thị voucher discount nếu có
            if (selectedVoucher != null && voucherDiscount > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_offer_rounded,
                      size: 18,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${context.tr('discount')} (${selectedVoucher.code})',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '-${_formatPrice(voucherDiscount)}₫',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              padding: const EdgeInsets.all(16),
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
                  Text(
                    context.tr('total'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: ThemeHelper.getTextColor(context),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_formatPrice(finalTotal)}₫',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: ThemeHelper.getPrimaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
