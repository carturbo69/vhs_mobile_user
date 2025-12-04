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

  factory BookingOption.fromJson(Map<String, dynamic> j) {
    // Hỗ trợ cả camelCase và PascalCase
    final getValue = (String camelKey, String pascalKey) => j[camelKey] ?? j[pascalKey];
    return BookingOption(
      optionId: (getValue('optionId', 'OptionId')?.toString() ?? '').trim(),
      optionName: (getValue('optionName', 'OptionName')?.toString() ?? '').trim(),
      tagId: getValue('tagId', 'TagId')?.toString(),
      type: (getValue('type', 'Type')?.toString() ?? '').trim(),
      family: getValue('family', 'Family')?.toString(),
      value: getValue('value', 'Value')?.toString(),
    );
  }

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
    // Hỗ trợ cả camelCase và PascalCase
    final getValue = (String camelKey, String pascalKey) => j[camelKey] ?? j[pascalKey];
    
    final optionsJson = getValue('options', 'Options');
    List<BookingOption> parsedOptions = [];
    
    if (optionsJson != null) {
      if (optionsJson is List) {
        // Parse từng option trong list
        for (var opt in optionsJson) {
          if (opt is Map<String, dynamic>) {
            try {
              parsedOptions.add(BookingOption.fromJson(opt));
            } catch (e) {
              // Bỏ qua option lỗi và tiếp tục
            }
          }
        }
      }
    }
    
    return BookingHistoryItem(
      bookingId: (getValue('bookingId', 'BookingId')?.toString() ?? ''),
      bookingTime: DateTime.parse(getValue('bookingTime', 'BookingTime')?.toString() ?? ''),
      createdAt: getValue('createdAt', 'CreatedAt') != null 
          ? DateTime.tryParse(getValue('createdAt', 'CreatedAt')?.toString() ?? '') 
          : null,
      status: (getValue('status', 'Status')?.toString() ?? ''),
      address: (getValue('address', 'Address')?.toString() ?? ''),
      providerId: (getValue('providerId', 'ProviderId')?.toString() ?? ''),
      providerName: (getValue('providerName', 'ProviderName')?.toString() ?? ''),
      providerImages: getValue('providerImages', 'ProviderImages')?.toString(),
      serviceId: (getValue('serviceId', 'ServiceId')?.toString() ?? ''),
      serviceTitle: (getValue('serviceTitle', 'ServiceTitle')?.toString() ?? ''),
      servicePrice: _parseDouble(getValue('servicePrice', 'ServicePrice')),
      serviceUnitType: (getValue('serviceUnitType', 'ServiceUnitType')?.toString() ?? ''),
      serviceImages: getValue('serviceImages', 'ServiceImages')?.toString(),
      options: parsedOptions,
      voucherDiscount: _parseDouble(getValue('voucherDiscount', 'VoucherDiscount'), defaultValue: 0.0),
      hasReview: (getValue('hasReview', 'HasReview') as bool? ?? false),
      paidAmount: getValue('paidAmount', 'PaidAmount') != null
          ? _parseDouble(getValue('paidAmount', 'PaidAmount'))
          : null,
      paymentStatus: getValue('paymentStatus', 'PaymentStatus')?.toString(),
    );
  }

  static double _parseDouble(dynamic value, {double? defaultValue}) {
    if (value == null) return defaultValue ?? 0.0;
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value.toString());
    return parsed ?? defaultValue ?? 0.0;
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
    if (s == 'in progress') return 'Bắt đầu làm việc';
    if (s == 'service completed') return 'Xác nhận hoàn thành';
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

