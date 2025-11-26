class BookingAmountItem {
  final String bookingId;
  final String serviceId;
  final String serviceName;
  final double subtotal;
  final double discount;
  final double amount;

  BookingAmountItem({
    required this.bookingId,
    required this.serviceId,
    required this.serviceName,
    required this.subtotal,
    required this.discount,
    required this.amount,
  });

  factory BookingAmountItem.fromJson(Map<String, dynamic> j) {
    return BookingAmountItem(
      bookingId: j['bookingId']?.toString() ?? "",
      serviceId: j['serviceId']?.toString() ?? "",
      serviceName: j['serviceName'] ?? "",
      subtotal: (j['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (j['discount'] as num?)?.toDouble() ?? 0.0,
      amount: (j['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BookingResultModel {
  final List<String> bookingIds;
  final List<BookingAmountItem> breakdown;
  final double subtotal;
  final double discount;
  final double total;

  BookingResultModel({
    required this.bookingIds,
    required this.breakdown,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  factory BookingResultModel.fromJson(Map<String, dynamic> j) {
    return BookingResultModel(
      bookingIds: (j['bookingIds'] as List).map((e) => e.toString()).toList(),
      breakdown: ((j['breakdown'] ?? []) as List)
          .map((e) => BookingAmountItem.fromJson(e))
          .toList(),
      subtotal: (j['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (j['discount'] as num?)?.toDouble() ?? 0.0,
      total: (j['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
