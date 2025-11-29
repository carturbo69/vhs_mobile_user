class BookingResultModel {
  final List<String> bookingIds;
  final List<BookingBreakdownItem> breakdown;
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

  factory BookingResultModel.fromJson(Map<String, dynamic> json) {
    return BookingResultModel(
      bookingIds: List<String>.from(json['bookingIds'] ?? []),
      breakdown: (json['breakdown'] as List<dynamic>)
          .map((e) => BookingBreakdownItem.fromJson(e))
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

class BookingBreakdownItem {
  final String bookingId;
  final String serviceId;
  final String serviceName;
  final double subtotal;
  final double discount;
  final double amount;

  BookingBreakdownItem({
    required this.bookingId,
    required this.serviceId,
    required this.serviceName,
    required this.subtotal,
    required this.discount,
    required this.amount,
  });

  factory BookingBreakdownItem.fromJson(Map<String, dynamic> json) {
    return BookingBreakdownItem(
      bookingId: json['bookingId'],
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}
