class VoucherModel {
  final String voucherId;
  final String code;
  final String? description;
  final double? discountPercent;
  final double? discountMaxAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? usageLimit;
  final int? usedCount;
  final bool? isActive;

  VoucherModel({
    required this.voucherId,
    required this.code,
    this.description,
    this.discountPercent,
    this.discountMaxAmount,
    this.startDate,
    this.endDate,
    this.usageLimit,
    this.usedCount,
    this.isActive,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    // Hỗ trợ cả PascalCase (backend) và camelCase
    final voucherId = json['voucherId'] ?? json['VoucherId'];
    final code = json['code'] ?? json['Code'] ?? '';
    final description = json['description'] ?? json['Description'];
    final discountPercent = json['discountPercent'] ?? json['DiscountPercent'];
    final discountMaxAmount = json['discountMaxAmount'] ?? json['DiscountMaxAmount'];
    final startDate = json['startDate'] ?? json['StartDate'];
    final endDate = json['endDate'] ?? json['EndDate'];
    final usageLimit = json['usageLimit'] ?? json['UsageLimit'];
    final usedCount = json['usedCount'] ?? json['UsedCount'];
    final isActive = json['isActive'] ?? json['IsActive'];
    
    return VoucherModel(
      voucherId: voucherId?.toString() ?? '',
      code: code.toString(),
      description: description?.toString(),
      discountPercent: discountPercent != null
          ? (discountPercent as num).toDouble()
          : null,
      discountMaxAmount: discountMaxAmount != null
          ? (discountMaxAmount as num).toDouble()
          : null,
      startDate: startDate != null
          ? DateTime.tryParse(startDate.toString())
          : null,
      endDate: endDate != null
          ? DateTime.tryParse(endDate.toString())
          : null,
      usageLimit: usageLimit != null ? (usageLimit as num).toInt() : null,
      usedCount: usedCount != null ? (usedCount as num).toInt() : null,
      isActive: isActive != null ? (isActive as bool) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'voucherId': voucherId,
        'code': code,
        'description': description,
        'discountPercent': discountPercent,
        'discountMaxAmount': discountMaxAmount,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'usageLimit': usageLimit,
        'usedCount': usedCount,
        'isActive': isActive,
      };

  // Helper method to check if voucher is valid
  bool get isValid {
    // Nếu isActive được set và là false thì không hợp lệ
    if (isActive == false) {
      print('❌ Voucher $code: isActive = false');
      return false;
    }
    
    final now = DateTime.now();
    
    // Kiểm tra startDate - so sánh theo ngày (chỉ so sánh year, month, day)
    if (startDate != null) {
      final startDateOnly = DateTime(startDate!.year, startDate!.month, startDate!.day);
      final nowDateOnly = DateTime(now.year, now.month, now.day);
      if (nowDateOnly.isBefore(startDateOnly)) {
        print('❌ Voucher $code: chưa đến ngày bắt đầu (startDate: $startDate, now: $now)');
        return false;
      }
    }
    
    // Kiểm tra endDate - so sánh theo ngày (nếu endDate là ngày 30, thì cả ngày 30 vẫn hợp lệ)
    if (endDate != null) {
      final endDateOnly = DateTime(endDate!.year, endDate!.month, endDate!.day);
      final nowDateOnly = DateTime(now.year, now.month, now.day);
      // Chỉ hết hạn khi đã qua ngày endDate (tức là đã sang ngày hôm sau)
      if (nowDateOnly.isAfter(endDateOnly)) {
        print('❌ Voucher $code: đã hết hạn (endDate: $endDate, now: $now)');
        return false;
      }
    }
    
    // Kiểm tra usageLimit
    if (usageLimit != null && usedCount != null) {
      if (usedCount! >= usageLimit!) {
        print('❌ Voucher $code: đã hết lượt sử dụng (usedCount: $usedCount, limit: $usageLimit)');
        return false;
      }
    }
    
    print('✅ Voucher $code: hợp lệ');
    return true;
  }

  // Helper method to calculate discount amount
  double calculateDiscount(double totalAmount) {
    if (!isValid) return 0;
    double discount = 0;
    if (discountPercent != null) {
      discount = totalAmount * (discountPercent! / 100);
      if (discountMaxAmount != null && discount > discountMaxAmount!) {
        discount = discountMaxAmount!;
      }
    }
    return discount;
  }
}

