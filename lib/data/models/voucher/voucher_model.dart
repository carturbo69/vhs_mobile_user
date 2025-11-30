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
    return VoucherModel(
      voucherId: json['voucherId']?.toString() ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      discountPercent: json['discountPercent'] != null
          ? (json['discountPercent'] as num).toDouble()
          : null,
      discountMaxAmount: json['discountMaxAmount'] != null
          ? (json['discountMaxAmount'] as num).toDouble()
          : null,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'])
          : null,
      endDate:
          json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      usageLimit: json['usageLimit'],
      usedCount: json['usedCount'],
      isActive: json['isActive'],
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

