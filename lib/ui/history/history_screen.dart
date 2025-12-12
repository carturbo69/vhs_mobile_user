import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_item.dart';
import 'package:vhs_mobile_user/data/repositories/booking_repository.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/history/history_viewmodel.dart';
import 'package:vhs_mobile_user/ui/payment/payment_viewmodel.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/services/translation_cache_provider.dart';
import 'package:vhs_mobile_user/services/data_translation_service.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _selectedStatus = "All";
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Force load khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasInitialized) {
        _hasInitialized = true;
        ref.read(historyProvider.notifier).loadHistory();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BookingHistoryItem> _filterItems(List<BookingHistoryItem> items) {
    var filtered = items;

    // Filter by status
    if (_selectedStatus != "All") {
      filtered = filtered.where((item) {
        // Normalize status: loại bỏ khoảng trắng và chuyển về lowercase
        final rawStatus = item.status.trim();
        final status = rawStatus.toLowerCase().replaceAll(' ', '').replaceAll('-', '');
        final statusVi = item.statusVi.toLowerCase();
        final selected = _selectedStatus.toLowerCase().replaceAll(' ', '').replaceAll('-', '');

        bool matches = false;

        if (selected == "pending") {
          matches = status == "pending" ||
              status.contains("pending") ||
              statusVi.contains("chờ xác nhận") ||
              statusVi.contains("đang chờ");
        } else if (selected == "confirmed") {
          matches = status == "confirmed" ||
              status.contains("confirmed") ||
              statusVi.contains("xác nhận") ||
              statusVi.contains("đã xác nhận");
        } else if (selected == "inprogress") {
          matches = status == "inprogress" ||
              status.contains("inprogress") ||
              status.contains("in_progress") ||
              statusVi.contains("bắt đầu") ||
              statusVi.contains("bắtđầu") ||
              rawStatus.toLowerCase().contains("in progress");
        } else if (selected == "completed") {
          matches = status == "completed" ||
              status == "servicecompleted" ||
              status.contains("completed") ||
              status.contains("servicecompleted") ||
              statusVi.contains("hoàn thành") ||
              statusVi.contains("xác nhận hoàn thành");
        } else if (selected == "cancelled") {
          matches = status == "cancelled" ||
              status.contains("cancelled") ||
              status.contains("cancel") ||
              statusVi.contains("hủy") ||
              statusVi.contains("đã hủy");
        }

        return matches;
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.serviceTitle.toLowerCase().contains(query) ||
            item.providerName.toLowerCase().contains(query) ||
            item.bookingId.toString().toLowerCase().contains(query) ||
            item.address.toLowerCase().contains(query);
      }).toList();
    }

    // Sắp xếp theo thời gian tạo (createdAt) từ mới nhất đến cũ nhất
    // Nếu createdAt null thì dùng bookingTime
    filtered.sort((a, b) {
      final aTime = a.createdAt ?? a.bookingTime;
      final bTime = b.createdAt ?? b.bookingTime;
      return bTime.compareTo(aTime); // Giảm dần (mới nhất trước)
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ hoặc có translation mới
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
    final historyState = ref.watch(historyProvider);

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
          context.tr('order_history'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                ref.read(historyProvider.notifier).refresh();
              },
              tooltip: context.tr('refresh'),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Container(
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
            child: Column(
              children: [
                // Status Filter Tabs
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    children: [
                    _StatusTab("All", context.tr('all'), _selectedStatus == "All", () {
                      setState(() => _selectedStatus = "All");
                    }),
                    _StatusTab(
                      "Pending",
                      context.tr('pending'),
                      _selectedStatus == "Pending",
                      () {
                        setState(() => _selectedStatus = "Pending");
                      },
                    ),
                    _StatusTab(
                      "Confirmed",
                      context.tr('confirmed'),
                      _selectedStatus == "Confirmed",
                      () {
                        setState(() => _selectedStatus = "Confirmed");
                      },
                    ),
                    _StatusTab(
                      "InProgress",
                      context.tr('in_progress'),
                      _selectedStatus == "InProgress",
                      () {
                        setState(() => _selectedStatus = "InProgress");
                      },
                    ),
                    _StatusTab(
                      "Completed",
                      context.tr('completed'),
                      _selectedStatus == "Completed",
                      () {
                        setState(() => _selectedStatus = "Completed");
                      },
                    ),
                    _StatusTab(
                      "Cancelled",
                      context.tr('cancelled'),
                      _selectedStatus == "Cancelled",
                      () {
                        setState(() => _selectedStatus = "Cancelled");
                      },
                    ),
                  ],
                ),
                ),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText:
                          context.tr('search_by_shop_id_service'),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: ThemeHelper.getPrimaryColor(context),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: ThemeHelper.getSecondaryIconColor(context),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = "");
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: ThemeHelper.getInputBackgroundColor(context),
                      hintStyle: TextStyle(color: ThemeHelper.getTertiaryTextColor(context)),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: historyState.when(
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
                context.tr('loading'),
                style: TextStyle(
                      color: ThemeHelper.getSecondaryTextColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) {
          String errorMessage = context.tr('error_loading_history');

          if (error.toString().contains('404')) {
            errorMessage = context.tr('no_data_found');
          } else if (error.toString().contains('401')) {
            errorMessage = context.tr('session_expired');
          } else if (error.toString().contains('timeout') ||
              error.toString().contains('Timeout')) {
            errorMessage = context.tr('connection_timeout');
          } else if (error.toString().contains('connection') ||
              error.toString().contains('Connection')) {
            errorMessage = context.tr('cannot_connect_server');
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
                    errorMessage,
                    style: TextStyle(
                      color: ThemeHelper.getTextColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: TextStyle(
                      color: ThemeHelper.getSecondaryTextColor(context),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(historyProvider.notifier).refresh();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: Text(
                      context.tr('try_again'),
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
        data: (items) {
          // Sắp xếp lại theo thời gian tạo (createdAt) từ mới nhất đến cũ nhất
          final sortedItems = List<BookingHistoryItem>.from(items);
          sortedItems.sort((a, b) {
            final aTime = a.createdAt ?? a.bookingTime;
            final bTime = b.createdAt ?? b.bookingTime;
            return bTime.compareTo(aTime); // Giảm dần (mới nhất trước)
          });
          
          final filteredItems = _filterItems(sortedItems);

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
                        Icons.history_rounded,
                        size: 80,
                        color: ThemeHelper.getPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.tr('no_history_yet'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelper.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('history_will_appear_here'),
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

          if (filteredItems.isEmpty) {
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
                        Icons.search_off_rounded,
                        size: 80,
                        color: Colors.orange.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.tr('no_results_found'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelper.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('try_changing_filter'),
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
            onRefresh: () => ref.read(historyProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return _BookingHistoryCard(item: item);
              },
            ),
          );
        },
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final String code;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusTab(this.code, this.label, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? null
              : Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ThemeHelper.getShadowColor(context),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected 
                  ? ThemeHelper.getPrimaryColor(context)
                  : Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingHistoryCard extends ConsumerWidget {
  final BookingHistoryItem item;

  const _BookingHistoryCard({required this.item});

  Color _getStatusColor(BuildContext context, String status) {
    final s = status.trim().toLowerCase();
    if (s == 'pending' || s.contains('pending') || s.contains('chờ')) return Colors.orange.shade600;
    if (s == 'confirmed' || s.contains('confirmed') || s.contains('xác nhận')) return Colors.blue.shade600;
    if (s == 'inprogress' || s.contains('inprogress') || s.contains('bắt đầu')) return Colors.purple.shade600;
    if (s == 'completed' || s.contains('completed') || s.contains('hoàn thành')) return Colors.green.shade600;
    if (s == 'cancelled' || s.contains('cancelled') || s.contains('hủy')) return Colors.red.shade600;
    return ThemeHelper.getSecondaryTextColor(context); // Use theme color for default
  }

  bool _isPending(String status) {
    final s = status.trim().toLowerCase();
    return s == 'pending' ||
        s.contains("chờ xác nhận") ||
        s.contains("đang chờ");
  }

  bool _isConfirmed(String status) {
    final s = status.trim().toLowerCase();
    return s == 'confirmed' || s.contains("xác nhận");
  }

  bool _isServiceCompleted(String status) {
    final s = status.trim().toLowerCase();
    return s == 'servicecompleted' ||
        s == 'service completed' ||
        s.contains("servicecompleted") ||
        s.contains("service completed");
  }

  String _getLocalizedStatus(WidgetRef ref, String status, String statusVi, DataTranslationService translationService) {
    final locale = ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    if (isVietnamese) {
      return statusVi;
    }
    
    // Dịch statusVi bằng DataTranslationService
    return translationService.smartTranslate(statusVi);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ hoặc có translation mới
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
    final firstImage = item.serviceImageList.isNotEmpty
        ? item.serviceImageList.first
        : null;
    
    // Dịch service name và provider name từ backend
    final translationService = DataTranslationService(ref);
    final locale = ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    
    String serviceTitle = item.serviceTitle;
    String providerName = item.providerName;
    String statusText = item.statusVi;
    
    if (!isVietnamese) {
      serviceTitle = translationService.smartTranslate(serviceTitle);
      providerName = translationService.smartTranslate(providerName);
      // Dịch status từ statusVi sang tiếng Anh
      statusText = _getLocalizedStatus(ref, item.status, item.statusVi, translationService);
    }
    
    // Hiển thị tất cả options - dịch vụ nào cũng phải có options
    // Chỉ lọc bỏ những option hoàn toàn không hợp lệ (không có optionId, optionName và không có value hợp lệ)
    // Xử lý trường hợp value là chuỗi "null" (không phải null thực sự)
    final validOptions = item.options.where((option) {
      // Kiểm tra optionId hoặc optionName
      final hasIdOrName = option.optionId.isNotEmpty || option.optionName.isNotEmpty;
      
      // Kiểm tra value hợp lệ (không null, không rỗng, và không phải chuỗi "null")
      final hasValidValue = option.value != null && 
                            option.value!.isNotEmpty && 
                            option.value!.toLowerCase() != 'null';
      
      return hasIdOrName || hasValidValue;
    }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () {
          context.push(Routes.bookingDetail, extra: item);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status và Review status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(context, item.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getStatusColor(context, item.status),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: _getStatusColor(context, item.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Hiển thị "Đánh giá" hoặc "Đã đánh giá" cho đơn Completed (không phải Service Completed)
                      if (!_isServiceCompleted(item.status) && 
                          (item.status.toLowerCase().contains("completed")))
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            item.hasReview ? context.tr('reviewed') : context.tr('review'),
                            style: TextStyle(
                              fontSize: 12,
                              color: item.hasReview 
                                  ? ThemeHelper.getSecondaryTextColor(context)
                                  : Colors.orange.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Provider Header với Logo
              Row(
                children: [
                  // Provider Logo
                  if (item.providerImageList.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: ThemeHelper.getBorderColor(context),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: item.providerImageList.first,
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            width: 28,
                            height: 28,
                            color: ThemeHelper.getLightBackgroundColor(context),
                            child: Icon(
                              Icons.store_rounded,
                              size: 16,
                              color: ThemeHelper.getSecondaryIconColor(context),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: ThemeHelper.getLightBackgroundColor(context),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: ThemeHelper.getBorderColor(context),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.store_rounded,
                        size: 16,
                        color: ThemeHelper.getSecondaryIconColor(context),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      providerName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.getTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Service Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Image
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
                      child: firstImage != null
                          ? CachedNetworkImage(
                              imageUrl: firstImage,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 100,
                                height: 100,
                                color: ThemeHelper.getLightBackgroundColor(context),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ThemeHelper.getPrimaryColor(context),
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 100,
                                height: 100,
                                color: ThemeHelper.getLightBackgroundColor(context),
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  size: 32,
                                  color: ThemeHelper.getSecondaryIconColor(context),
                                ),
                              ),
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: ThemeHelper.getLightBackgroundColor(context),
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                size: 32,
                                color: ThemeHelper.getSecondaryIconColor(context),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Service Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeHelper.getTextColor(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: ThemeHelper.getLightBackgroundColor(context),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: ThemeHelper.getSecondaryIconColor(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.address,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ThemeHelper.getSecondaryTextColor(context),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Price Breakdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${context.tr('service_price')}:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ThemeHelper.getTertiaryTextColor(context),
                                  ),
                                ),
                                Text(
                                  '${NumberFormat('#,###').format(item.servicePrice)} ₫',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ThemeHelper.getSecondaryTextColor(context),
                                  ),
                                ),
                              ],
                            ),
                            if (item.voucherDiscount > 0) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${context.tr('discount')}:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: ThemeHelper.getTertiaryTextColor(context),
                                    ),
                                  ),
                                  Text(
                                    '-${NumberFormat('#,###').format(item.voucherDiscount)} ₫',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade400,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 4),
                            Divider(
                              height: 1,
                              color: ThemeHelper.getDividerColor(context),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${context.tr('total_amount')}:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: ThemeHelper.getTextColor(context),
                                  ),
                                ),
                                Text(
                                  '${NumberFormat('#,###').format(item.totalPrice - item.voucherDiscount)} ₫',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeHelper.getPrimaryColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Options - Luôn hiển thị section này để nhất quán
                const SizedBox(height: 12),
                Divider(color: ThemeHelper.getDividerColor(context)),
                const SizedBox(height: 8),
              if (validOptions.isNotEmpty) ...[
                ...validOptions.map((option) {
                  final isDark = ThemeHelper.isDarkMode(context);
                  
                  // Dịch option name và value
                  String optionName = option.optionName.isNotEmpty 
                      ? option.optionName 
                      : (option.optionId.isNotEmpty 
                          ? 'Option ${option.optionId}' 
                          : context.tr('option'));
                  
                  String? optionValue = option.value;
                  
                  if (!isVietnamese) {
                    if (option.optionName.isNotEmpty) {
                      optionName = translationService.smartTranslate(option.optionName);
                    }
                    if (optionValue != null && optionValue.isNotEmpty) {
                      optionValue = translationService.smartTranslate(optionValue);
                    }
                  }
                  
                  // Format: optionName (value) nếu có value, hiển thị trên cùng một dòng
                  final displayText = (optionValue != null && optionValue.isNotEmpty 
                      ? '$optionName ($optionValue)'
                      : optionName).replaceAll(RegExp(r'\s+'), ' ').trim();
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.green.shade900.withOpacity(0.3)
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: Colors.green.shade400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            displayText,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: ThemeHelper.getTextColor(context),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ] else ...[
                // Hiển thị thông báo khi không có options để đảm bảo nhất quán
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    context.tr('no_options'),
                    style: TextStyle(
                      fontSize: 13,
                      color: ThemeHelper.getTertiaryTextColor(context),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],

              // Action Buttons
              const SizedBox(height: 12),
              if (_isPending(item.status))
                // Hiển thị 2 nút cho đơn hàng đang chờ xác nhận
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          // Hiển thị dialog nhập lý do hủy
                          final cancelReason = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              final reasonController = TextEditingController();
                              return AlertDialog(
                                backgroundColor: ThemeHelper.getDialogBackgroundColor(context),
                                title: Text(
                                  context.tr('cancel_order'),
                                  style: TextStyle(color: ThemeHelper.getTextColor(context)),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('please_enter_cancel_reason'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ThemeHelper.getTextColor(context),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: reasonController,
                                      style: TextStyle(color: ThemeHelper.getTextColor(context)),
                                      decoration: InputDecoration(
                                        hintText: context.tr('enter_cancel_reason'),
                                        hintStyle: TextStyle(
                                          color: ThemeHelper.getTertiaryTextColor(context),
                                        ),
                                        fillColor: ThemeHelper.getInputBackgroundColor(context),
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ThemeHelper.getBorderColor(context),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ThemeHelper.getBorderColor(context),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ThemeHelper.getPrimaryColor(context),
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.all(12),
                                      ),
                                      maxLines: 3,
                                      autofocus: true,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      context.tr('cancel'),
                                      style: TextStyle(
                                        color: ThemeHelper.getSecondaryTextColor(context),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final reason = reasonController.text.trim();
                                      if (reason.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(context.tr('please_enter_cancel_reason_required')),
                                            backgroundColor: Colors.orange.shade400,
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.pop(context, reason);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red.shade400,
                                    ),
                                    child: Text(context.tr('confirm_cancel')),
                                  ),
                                ],
                              );
                            },
                          );

                          if (cancelReason != null && cancelReason.isNotEmpty && context.mounted) {
                            // Hiển thị loading
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (dialogContext) => Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ThemeHelper.getPrimaryColor(context),
                                    ),
                                  ),
                                ),
                              );
                            }

                            final result = await ref
                                .read(historyProvider.notifier)
                                .cancelBooking(item.bookingId, cancelReason);

                            // Đóng loading dialog nếu context còn mounted
                            if (context.mounted) {
                              // Kiểm tra xem có dialog nào đang mở không
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message'] as String),
                                  backgroundColor: result['success'] as bool
                                      ? Colors.green
                                      : Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.cancel_rounded, size: 18),
                        label: Text(
                          context.tr('cancel'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: Colors.red.shade600,
                          side: BorderSide(color: Colors.red.shade600, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push(Routes.bookingDetail, extra: item);
                        },
                        icon: const Icon(Icons.visibility, size: 18),
                        label: Text(context.tr('view_details')),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                )
              else if (_isConfirmed(item.status) &&
                  (item.paymentStatus == null ||
                      item.paymentStatus!.toLowerCase().contains("chưa")))
                // Hiển thị 2 nút "Thanh toán" và "Xem chi tiết" cho đơn đã xác nhận chưa thanh toán
                Consumer(
                  builder: (context, ref, _) {
                    final vm = ref.watch(paymentViewModelProvider);
                    final isLoading = vm is AsyncLoading;

                    return Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    final amount = item.servicePrice - item.voucherDiscount;
                                    ref.read(paymentViewModelProvider.notifier).payBooking(
                                          bookingId: item.bookingId,
                                          amount: amount,
                                          context: context,
                                        );
                                  },
                            icon: isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.payment_rounded, size: 18),
                            label: Text(
                              context.tr('payment'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: ThemeHelper.getPrimaryColor(context),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.push(Routes.bookingDetail, extra: item);
                            },
                            icon: const Icon(Icons.visibility_rounded, size: 18),
                            label: Text(
                              context.tr('view_details'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              foregroundColor: ThemeHelper.getPrimaryColor(context),
                              side: BorderSide(
                                color: ThemeHelper.getPrimaryColor(context),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )
              else if (_isServiceCompleted(item.status))
                // Hiển thị 2 nút "Xác nhận hoàn thành" và "Xem chi tiết" cho đơn Service Completed
                _ConfirmServiceCompletedButton(item: item)
              else
                // Hiển thị 2 nút "Đặt lại" và "Xem chi tiết" cho các đơn hàng khác
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Navigate đến checkout với serviceId trực tiếp (không qua cart)
                          context.push(
                            Routes.checkout,
                            extra: {'serviceId': item.serviceId},
                              );
                        },
                        icon: const Icon(Icons.replay_rounded, size: 18),
                        label: Text(
                          context.tr('reorder'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: ThemeHelper.getPrimaryColor(context),
                          side: BorderSide(
                            color: ThemeHelper.getPrimaryColor(context),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push(Routes.bookingDetail, extra: item);
                        },
                        icon: const Icon(Icons.visibility_rounded, size: 18),
                        label: Text(
                          context.tr('view_details'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: ThemeHelper.getPrimaryColor(context),
                          side: BorderSide(
                            color: ThemeHelper.getPrimaryColor(context),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget riêng cho nút "Xác nhận hoàn thành"
class _ConfirmServiceCompletedButton extends ConsumerStatefulWidget {
  final BookingHistoryItem item;

  const _ConfirmServiceCompletedButton({required this.item});

  @override
  ConsumerState<_ConfirmServiceCompletedButton> createState() => _ConfirmServiceCompletedButtonState();
}

class _ConfirmServiceCompletedButtonState extends ConsumerState<_ConfirmServiceCompletedButton> {
  bool _isConfirming = false;

  Future<void> _handleConfirm() async {
    setState(() {
      _isConfirming = true;
    });

    try {
      final bookingRepo = ref.read(bookingRepositoryProvider);
      final success = await bookingRepo.confirmServiceCompleted(widget.item.bookingId);
      
      if (mounted) {
        if (success) {
          // Refresh history
          ref.read(historyProvider.notifier).refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('confirm_completed_success')),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('confirm_completed_failed')),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${context.tr('error')}: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isConfirming ? null : _handleConfirm,
            icon: _isConfirming
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_rounded, size: 18),
            label: Text(
              context.tr('confirm_service_completed'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              context.push(Routes.bookingDetail, extra: widget.item);
            },
            icon: const Icon(Icons.visibility_rounded, size: 18),
            label: Text(
              context.tr('view_details'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: ThemeHelper.getPrimaryColor(context),
              side: BorderSide(
                color: ThemeHelper.getPrimaryColor(context),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
