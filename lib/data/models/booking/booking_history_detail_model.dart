import 'package:vhs_mobile_user/data/models/service/service_detail.dart';

class HistoryBookingDetail {
  final String bookingId;
  final String bookingCode;
  final String status;

  final DateTime createdAt;
  final DateTime? completedAt;

  final String recipientFullName;
  final String recipientPhone;
  final String addressLine;

  final BookingServiceBrief service;
  final List<String> serviceImages;

  final BookingServiceProvider provider;

  final String? staffId;
  final String? staffName;
  final String? staffPhone;
  final String? staffAddress;
  final String? staffImage;

  final double shippingFee;
  final double voucherDiscount;
  final double? paidAmount;
  final String? paymentMethod;
  final String? paymentStatus;

  final bool hasReview;

  final List<TimelineEvent> timeline;

  final String? cancelReason;
  final String? bankName;
  final String? accountHolderName;
  final String? bankAccountNumber;
  final String? refundStatus;
  final String? resolutionNote;

  HistoryBookingDetail({
    required this.bookingId,
    required this.bookingCode,
    required this.status,
    required this.createdAt,
    required this.completedAt,
    required this.recipientFullName,
    required this.recipientPhone,
    required this.addressLine,
    required this.service,
    required this.serviceImages,
    required this.provider,
    this.staffId,
    this.staffName,
    this.staffPhone,
    this.staffAddress,
    this.staffImage,
    required this.shippingFee,
    required this.voucherDiscount,
    required this.paidAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.hasReview,
    required this.timeline,
    required this.cancelReason,
    required this.bankName,
    required this.accountHolderName,
    required this.bankAccountNumber,
    required this.refundStatus,
    required this.resolutionNote,
  });

  factory HistoryBookingDetail.fromJson(Map<String, dynamic> json) {
    return HistoryBookingDetail(
      bookingId: json["bookingId"] ?? "",
      bookingCode: json["bookingCode"] ?? "",
      status: json["status"] ?? "Unknown",

      createdAt: DateTime.parse(json["createdAt"]),
      completedAt: json["completedAt"] != null
          ? DateTime.parse(json["completedAt"])
          : null,

      recipientFullName: json["recipientFullName"] ?? "",
      recipientPhone: json["recipientPhone"] ?? "",
      addressLine: json["addressLine"] ?? "",

      service: BookingServiceBrief.fromJson(json["service"]),

      serviceImages: (json["serviceImages"] ?? "")
          .toString()
          .split(",")
          .where((e) => e.trim().isNotEmpty)
          .toList(),

      provider: BookingServiceProvider.fromJson({
        "providerId": json["providerId"],
        "providerName": json["providerName"],
        "providerImages": json["providerImages"],
      }),

      staffId: json["staffId"],
      staffName: json["staffName"],
      staffPhone: json["staffPhone"],
      staffAddress: json["staffAddress"],
      staffImage: json["staffImage"],

      shippingFee: (json["shippingFee"] ?? 0).toDouble(),
      voucherDiscount: (json["voucherDiscount"] ?? 0).toDouble(),
      paidAmount: json["paidAmount"] != null
          ? (json["paidAmount"] as num).toDouble()
          : null,

      paymentMethod: (json["paymentMethod"] ?? "").toString(),
      paymentStatus: json["paymentStatus"],

      hasReview: json["hasReview"] ?? false,

      timeline: (json["timeline"] ?? [])
          .map<TimelineEvent>((e) => TimelineEvent.fromJson(e))
          .toList(),

      cancelReason: json["cancelReason"],
      bankName: json["bankName"],
      accountHolderName: json["accountHolderName"],
      bankAccountNumber: json["bankAccountNumber"],
      refundStatus: json["refundStatus"],
      resolutionNote: json["resolutionNote"],
    );
  }
}

class TimelineEvent {
  final String code;
  final String title;
  final String? description;
  final DateTime? time;
  final List<MediaProof> proofs;

  TimelineEvent({
    required this.code,
    required this.title,
    this.description,
    this.time,
    required this.proofs,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      code: json["code"] ?? "",
      title: json["title"] ?? "",
      description: json["description"],
      time: json["time"] != null ? DateTime.parse(json["time"]) : null,
      proofs: (json["proofs"] ?? [])
          .map<MediaProof>((e) {
            if (e is Map) {
              return MediaProof.fromJson(Map<String, dynamic>.from(e));
            }
            return MediaProof.fromJson({});
          })
          .toList(),
    );
  }
}

class MediaProof {
  final String mediaType; // "image" hoặc "video"
  final String url;
  final String? caption;

  MediaProof({
    required this.mediaType,
    required this.url,
    this.caption,
  });

  factory MediaProof.fromJson(Map<String, dynamic> json) {
    return MediaProof(
      mediaType: json["mediaType"] ?? json["MediaType"] ?? "image",
      url: json["url"] ?? json["Url"] ?? "",
      caption: json["caption"] ?? json["Caption"],
    );
  }
}

class BookingServiceProvider {
  final String providerId;
  final String providerName;
  final List<String> providerImages;

  BookingServiceProvider({
    required this.providerId,
    required this.providerName,
    required this.providerImages,
  });

  factory BookingServiceProvider.fromJson(Map<String, dynamic> json) {
    return BookingServiceProvider(
      providerId: json["providerId"] ?? "",
      providerName: json["providerName"] ?? "",
      providerImages: (json["providerImages"] ?? "")
          .toString()
          .split(",")
          .where((e) => e.trim().isNotEmpty)
          .toList(),
    );
  }
}

class BookingServiceBrief {
  final String serviceId;
  final String title;
  final String image;
  final double unitPrice;
  final int quantity;
  final String unitType;

  final List<BookingServiceOption> options;
  final bool includeOptionPriceToLineTotal;
  final double optionsTotal;
  final double lineTotal;

  BookingServiceBrief({
    required this.serviceId,
    required this.title,
    required this.image,
    required this.unitPrice,
    required this.quantity,
    required this.unitType,
    required this.options,
    required this.includeOptionPriceToLineTotal,
    required this.optionsTotal,
    required this.lineTotal,
  });

  factory BookingServiceBrief.fromJson(Map<String, dynamic> json) {
    return BookingServiceBrief(
      serviceId: json["serviceId"] ?? "",
      title: json["title"] ?? "",
      image: json["image"] ?? "",
      unitPrice: (json["unitPrice"] ?? 0).toDouble(),
      quantity: json["quantity"] ?? 1,
      unitType: json["unitType"] ?? "",

      options: (json["options"] ?? [])
          .map<BookingServiceOption>((e) => BookingServiceOption.fromJson(e))
          .toList(),

      includeOptionPriceToLineTotal:
          json["includeOptionPriceToLineTotal"] ?? false,

      optionsTotal: (json["optionsTotal"] ?? 0).toDouble(),
      lineTotal: (json["lineTotal"] ?? 0).toDouble(),
    );
  }
}

class BookingServiceOption {
  final String optionId;
  final String optionName;
  final String? value;

  BookingServiceOption({
    required this.optionId,
    required this.optionName,
    this.value,
  });

  factory BookingServiceOption.fromJson(Map<String, dynamic> json) {
    return BookingServiceOption(
      optionId: json["optionId"] ?? "",
      optionName: json["optionName"] ?? "",
      value: json["value"],
    );
  }
}
