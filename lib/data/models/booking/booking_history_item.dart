// booking_history_item.dart
class BookingOption {
  final String optionId;
  final String optionName;
  final String? tagId;
  final String type;
  final String? family;
  final String? value;

  BookingOption({
    required this.optionId,
    required this.optionName,
    this.tagId,
    required this.type,
    this.family,
    this.value,
  });

  factory BookingOption.fromJson(Map<String, dynamic> j) => BookingOption(
        optionId: j['optionId']?.toString() ?? '',
        optionName: j['optionName'] ?? '',
        tagId: j['tagId']?.toString(),
        type: j['type'] ?? '',
        family: j['family']?.toString(),
        value: j['value']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'optionId': optionId,
        'optionName': optionName,
        'tagId': tagId,
        'type': type,
        'family': family,
        'value': value,
      };
}

class BookingHistoryItem {
  final String bookingId;
  final DateTime bookingTime;
  final DateTime? createdAt;
  final String status;
  final String address;

  // Provider
  final String providerId;
  final String providerName;
  final String? providerImages;

  // Service
  final String serviceId;
  final String serviceTitle;
  final double servicePrice;
  final String serviceUnitType;
  final String? serviceImages;

  // Options
  final List<BookingOption> options;

  // Voucher
  final double voucherDiscount;

  // Review
  final bool hasReview;

  // Payment
  final double? paidAmount;
  final String? paymentStatus;

  BookingHistoryItem({
    required this.bookingId,
    required this.bookingTime,
    this.createdAt,
    required this.status,
    required this.address,
    required this.providerId,
    required this.providerName,
    this.providerImages,
    required this.serviceId,
    required this.serviceTitle,
    required this.servicePrice,
    required this.serviceUnitType,
    this.serviceImages,
    required this.options,
    this.voucherDiscount = 0.0,
    this.hasReview = false,
    this.paidAmount,
    this.paymentStatus,
  });

  factory BookingHistoryItem.fromJson(Map<String, dynamic> j) {
    final optionsJson = j['options'] as List<dynamic>?;
    return BookingHistoryItem(
      bookingId: j['bookingId']?.toString() ?? '',
      bookingTime: DateTime.parse(j['bookingTime']),
      createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null,
      status: j['status'] ?? '',
      address: j['address'] ?? '',
      providerId: j['providerId']?.toString() ?? '',
      providerName: j['providerName'] ?? '',
      providerImages: j['providerImages'],
      serviceId: j['serviceId']?.toString() ?? '',
      serviceTitle: j['serviceTitle'] ?? '',
      servicePrice: (j['servicePrice'] is num) 
          ? (j['servicePrice'] as num).toDouble() 
          : double.tryParse(j['servicePrice']?.toString() ?? '') ?? 0.0,
      serviceUnitType: j['serviceUnitType'] ?? '',
      serviceImages: j['serviceImages'],
      options: optionsJson != null
          ? optionsJson.map((e) => BookingOption.fromJson(e as Map<String, dynamic>)).toList()
          : [],
      voucherDiscount: (j['voucherDiscount'] is num)
          ? (j['voucherDiscount'] as num).toDouble()
          : double.tryParse(j['voucherDiscount']?.toString() ?? '') ?? 0.0,
      hasReview: j['hasReview'] as bool? ?? false,
      paidAmount: j['paidAmount'] != null
          ? ((j['paidAmount'] is num)
              ? (j['paidAmount'] as num).toDouble()
              : double.tryParse(j['paidAmount']?.toString() ?? ''))
          : null,
      paymentStatus: j['paymentStatus']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'bookingTime': bookingTime.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'status': status,
        'address': address,
        'providerId': providerId,
        'providerName': providerName,
        'providerImages': providerImages,
        'serviceId': serviceId,
        'serviceTitle': serviceTitle,
        'servicePrice': servicePrice,
        'serviceUnitType': serviceUnitType,
        'serviceImages': serviceImages,
        'options': options.map((o) => o.toJson()).toList(),
        'voucherDiscount': voucherDiscount,
        'hasReview': hasReview,
        'paidAmount': paidAmount,
        'paymentStatus': paymentStatus,
      };

  double get totalPrice => servicePrice;

  // Helper để lấy danh sách ảnh service
  List<String> get serviceImageList {
    if (serviceImages == null || serviceImages!.trim().isEmpty) return [];
    return serviceImages!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  // Helper để lấy danh sách ảnh provider
  List<String> get providerImageList {
    if (providerImages == null || providerImages!.trim().isEmpty) return [];
    return providerImages!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  // Helper để lấy status tiếng Việt
  String get statusVi {
    final s = status.trim().toLowerCase();
    if (s == 'pending') return 'Chờ xác nhận';
    if (s == 'confirmed') return 'Đã xác nhận';
    if (s == 'in progress') return 'Đang thực hiện';
    if (s == 'service completed') return 'Dịch vụ hoàn thành';
    if (s == 'completed') return 'Hoàn thành';
    if (s == 'cancelled') return 'Đã hủy';
    return status;
  }
}

class BookingHistoryListResponse {
  final List<BookingHistoryItem> items;

  BookingHistoryListResponse({required this.items});

  factory BookingHistoryListResponse.fromJson(Map<String, dynamic> j) {
    final itemsJson = j['items'] as List<dynamic>?;
    return BookingHistoryListResponse(
      items: itemsJson != null
          ? itemsJson.map((e) => BookingHistoryItem.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }
}

