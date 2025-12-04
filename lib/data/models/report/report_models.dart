// report_models.dart
enum ReportTypeEnum {
  serviceQuality,      // Chất lượng dịch vụ
  providerMisconduct,  // Hành vi sai trái của provider
  staffMisconduct,     // Hành vi sai trái của nhân viên
  dispute,            // Tranh chấp
  technicalIssue,     // Vấn đề kỹ thuật
  refundRequest,       // Yêu cầu hoàn tiền
  other              // Khác
}

extension ReportTypeEnumExtension on ReportTypeEnum {
  String get displayName {
    switch (this) {
      case ReportTypeEnum.serviceQuality:
        return 'Chất lượng dịch vụ';
      case ReportTypeEnum.providerMisconduct:
        return 'Hành vi sai trái của nhà cung cấp';
      case ReportTypeEnum.staffMisconduct:
        return 'Hành vi sai trái của nhân viên';
      case ReportTypeEnum.dispute:
        return 'Tranh chấp';
      case ReportTypeEnum.technicalIssue:
        return 'Vấn đề kỹ thuật';
      case ReportTypeEnum.refundRequest:
        return 'Yêu cầu hoàn tiền';
        case ReportTypeEnum.other:
        return 'Khác';
    }
  }

  String get value {
    switch (this) {
      case ReportTypeEnum.serviceQuality:
        return 'ServiceQuality';
      case ReportTypeEnum.providerMisconduct:
        return 'ProviderMisconduct';
      case ReportTypeEnum.staffMisconduct:
        return 'StaffMisconduct';
      case ReportTypeEnum.dispute:
        return 'Dispute';
      case ReportTypeEnum.technicalIssue:
        return 'TechnicalIssue';
      case ReportTypeEnum.refundRequest:
        return 'RefundRequest';
      case ReportTypeEnum.other:
        return 'Other';
    }
  }

  static ReportTypeEnum fromString(String value) {
    switch (value.toLowerCase()) {
      case 'servicequality':
        return ReportTypeEnum.serviceQuality;
      case 'providermisconduct':
        return ReportTypeEnum.providerMisconduct;
      case 'staffmisconduct':
        return ReportTypeEnum.staffMisconduct;
      case 'dispute':
        return ReportTypeEnum.dispute;
      case 'technicalissue':
        return ReportTypeEnum.technicalIssue;
      case 'refundrequest':
        return ReportTypeEnum.refundRequest;
      default:
        return ReportTypeEnum.other;
    }
  }
}

class CreateReportDTO {
  final String bookingId;
  final ReportTypeEnum reportType;
  final String title;
  final String? description;
  final String? providerId;
  final List<String>? imagePaths; // Local file paths
  final String? bankName;
  final String? accountHolderName;
  final String? bankAccountNumber;

  CreateReportDTO({
    required this.bookingId,
    required this.reportType,
    required this.title,
    this.description,
    this.providerId,
    this.imagePaths,
    this.bankName,
    this.accountHolderName,
    this.bankAccountNumber,
  });
}

class ReadReportDTO {
  final String complaintId;
  final String bookingId;
  final String userId;
  final String? providerId;
  final String complaintType;
  final ReportTypeEnum reportType;
  final String title;
  final String? description;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? resolutionNote;
  final List<String>? attachmentUrls;
  final String? providerName;
  final String? serviceName;
  final int daysSinceCreated;
  
  // Refund information
  final String? cancelReason;
  final String? refundStatus;
  final String? bankAccountNumber;
  final String? bankName;
  final String? accountHolderName;
  final double? refundAmount;

  ReadReportDTO({
    required this.complaintId,
    required this.bookingId,
    required this.userId,
    this.providerId,
    required this.complaintType,
    required this.reportType,
    required this.title,
    this.description,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.resolutionNote,
    this.attachmentUrls,
    this.providerName,
    this.serviceName,
    this.daysSinceCreated = 0,
    this.cancelReason,
    this.refundStatus,
    this.bankAccountNumber,
    this.bankName,
    this.accountHolderName,
    this.refundAmount,
  });

  factory ReadReportDTO.fromJson(Map<String, dynamic> json) {
    return ReadReportDTO(
      complaintId: json['complaintId']?.toString() ?? json['ComplaintId']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? json['BookingId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['UserId']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? json['ProviderId']?.toString(),
      complaintType: json['complaintType']?.toString() ?? json['ComplaintType']?.toString() ?? '',
      reportType: ReportTypeEnumExtension.fromString(
        json['reportType']?.toString() ?? 
        json['ReportType']?.toString() ?? 
        json['complaintType']?.toString() ?? 
        json['ComplaintType']?.toString() ?? 
        'Other'
      ),
      title: json['title']?.toString() ?? json['Title']?.toString() ?? '',
      description: json['description']?.toString() ?? json['Description']?.toString(),
      status: json['status']?.toString() ?? json['Status']?.toString() ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : (json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt'].toString()) : null),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : (json['UpdatedAt'] != null ? DateTime.parse(json['UpdatedAt'].toString()) : null),
      resolutionNote: json['resolutionNote']?.toString() ?? json['ResolutionNote']?.toString(),
      attachmentUrls: json['attachmentUrls'] != null
          ? List<String>.from(json['attachmentUrls'] as List)
          : (json['AttachmentUrls'] != null
              ? List<String>.from(json['AttachmentUrls'] as List)
              : null),
      providerName: json['providerName']?.toString() ?? json['ProviderName']?.toString(),
      serviceName: json['serviceName']?.toString() ?? json['ServiceName']?.toString(),
      daysSinceCreated: json['daysSinceCreated'] ?? json['DaysSinceCreated'] ?? 0,
      cancelReason: json['cancelReason']?.toString() ?? json['CancelReason']?.toString(),
      refundStatus: json['refundStatus']?.toString() ?? json['RefundStatus']?.toString(),
      bankAccountNumber: json['bankAccountNumber']?.toString() ?? json['BankAccountNumber']?.toString(),
      bankName: json['bankName']?.toString() ?? json['BankName']?.toString(),
      accountHolderName: json['accountHolderName']?.toString() ?? json['AccountHolderName']?.toString(),
      refundAmount: json['refundAmount'] != null
          ? (json['refundAmount'] is num ? json['refundAmount'].toDouble() : double.tryParse(json['refundAmount'].toString()))
          : (json['RefundAmount'] != null
              ? (json['RefundAmount'] is num ? json['RefundAmount'].toDouble() : double.tryParse(json['RefundAmount'].toString()))
              : null),
    );
  }

  String get statusVi {
    final s = status.toLowerCase();
    if (s == 'pending') return 'Chờ xử lý';
    if (s == 'inreview') return 'Đang xem xét';
    if (s == 'resolved') return 'Đã giải quyết';
    if (s == 'rejected') return 'Đã từ chối';
    return status;
  }
}

