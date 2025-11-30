import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_item.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/history/history_viewmodel.dart';

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
        final status = item.status.trim().toLowerCase();
        final selected = _selectedStatus.toLowerCase();

        if (selected == "pending") {
          return status == "pending" ||
              status.contains("chờ xác nhận") ||
              status.contains("đang chờ");
        } else if (selected == "confirmed") {
          return status == "confirmed" || status.contains("xác nhận");
        } else if (selected == "inprogress") {
          return status == "inprogress" ||
              status.contains("bắt đầu") ||
              status.contains("đang thực hiện");
        } else if (selected == "completed") {
          return status == "completed" ||
              status == "servicecompleted" ||
              status.contains("hoàn thành");
        } else if (selected == "cancelled") {
          return status == "cancelled" || status.contains("hủy");
        }
        return true;
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

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);

    // Đảm bảo load khi màn hình được build và state chưa được load
    if (!historyState.isLoading &&
        !historyState.hasValue &&
        !historyState.hasError &&
        !_hasInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _hasInitialized = true;
          ref.read(historyProvider.notifier).loadHistory();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử đơn hàng"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(historyProvider.notifier).refresh();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Status Filter Tabs
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    _StatusTab("All", "Tất cả", _selectedStatus == "All", () {
                      setState(() => _selectedStatus = "All");
                    }),
                    _StatusTab(
                      "Pending",
                      "Chờ xác nhận",
                      _selectedStatus == "Pending",
                      () {
                        setState(() => _selectedStatus = "Pending");
                      },
                    ),
                    _StatusTab(
                      "Confirmed",
                      "Xác Nhận",
                      _selectedStatus == "Confirmed",
                      () {
                        setState(() => _selectedStatus = "Confirmed");
                      },
                    ),
                    _StatusTab(
                      "InProgress",
                      "Bắt Đầu Làm Việc",
                      _selectedStatus == "InProgress",
                      () {
                        setState(() => _selectedStatus = "InProgress");
                      },
                    ),
                    _StatusTab(
                      "Completed",
                      "Hoàn thành",
                      _selectedStatus == "Completed",
                      () {
                        setState(() => _selectedStatus = "Completed");
                      },
                    ),
                    _StatusTab(
                      "Cancelled",
                      "Đã hủy",
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
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText:
                        "Tìm kiếm theo tên Shop, ID đơn hàng hoặc Tên dịch vụ",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            },
                          )
                        : null,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
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
      body: historyState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          String errorMessage = "Đã xảy ra lỗi khi tải lịch sử";

          if (error.toString().contains('404')) {
            errorMessage =
                "Không tìm thấy dữ liệu. Có thể bạn chưa có đơn hàng nào.";
          } else if (error.toString().contains('401')) {
            errorMessage =
                "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.";
          } else if (error.toString().contains('timeout') ||
              error.toString().contains('Timeout')) {
            errorMessage =
                "Kết nối timeout. Vui lòng kiểm tra kết nối mạng và thử lại.";
          } else if (error.toString().contains('connection') ||
              error.toString().contains('Connection')) {
            errorMessage =
                "Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.";
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(historyProvider.notifier).refresh();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Thử lại"),
                  ),
                ],
              ),
            ),
          );
        },
        data: (items) {
          final filteredItems = _filterItems(items);

          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Chưa có lịch sử",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Lịch sử đặt dịch vụ của bạn sẽ hiển thị ở đây",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (filteredItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "Không tìm thấy kết quả",
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingHistoryCard extends StatelessWidget {
  final BookingHistoryItem item;

  const _BookingHistoryCard({required this.item});

  Color _getStatusColor(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'pending') return Colors.orange;
    if (s == 'confirmed') return Colors.blue;
    if (s == 'inprogress') return Colors.purple;
    if (s == 'completed') return Colors.green;
    if (s == 'cancelled') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final firstImage = item.serviceImageList.isNotEmpty
        ? item.serviceImageList.first
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to booking detail
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status và Booking Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(item.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getStatusColor(item.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      item.statusVi,
                      style: TextStyle(
                        color: _getStatusColor(item.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    dateFormat.format(item.bookingTime),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Provider Header với Logo
              Row(
                children: [
                  // Provider Logo
                  if (item.providerImageList.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: item.providerImageList.first,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          width: 24,
                          height: 24,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.store, size: 16),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.store, size: 16),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.providerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: firstImage != null
                        ? CachedNetworkImage(
                            imageUrl: firstImage,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          )
                        : Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported),
                          ),
                  ),
                  const SizedBox(width: 12),

                  // Service Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.serviceTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.address,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
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
                                  'Giá dịch vụ:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '${NumberFormat('#,###').format(item.servicePrice)} ₫',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
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
                                    'Giảm giá:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    '-${NumberFormat('#,###').format(item.voucherDiscount)} ₫',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 4),
                            const Divider(height: 1),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Thành tiền:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${NumberFormat('#,###').format(item.totalPrice - item.voucherDiscount)} ₫',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
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

              // Options (nếu có) - Hiển thị chi tiết như web
              if (item.options.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                ...item.options.map((option) {
                  final isTextarea =
                      option.type.toLowerCase() == "textarea" ||
                      option.type.toLowerCase() == "text";
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                option.optionName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (option.value != null &&
                            option.value!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 22),
                            child: isTextarea
                                ? Text(
                                    option.value!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      height: 1.4,
                                    ),
                                  )
                                : Text(
                                    option.value!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ],

              // Action Button
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(Routes.bookingDetail, extra: item);
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text("Xem chi tiết"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
