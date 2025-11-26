class UserAddressModel {
  final String addressId;

  final String provinceName;
  final String districtName;
  final String wardName;
  final String streetAddress;

  final String? recipientName;
  final String? recipientPhone;

  final double? latitude;
  final double? longitude;

  final DateTime? createdAt;

  // full address computed from backend
  final String fullAddress;

  UserAddressModel({
    required this.addressId,
    required this.provinceName,
    required this.districtName,
    required this.wardName,
    required this.streetAddress,
    required this.recipientName,
    required this.recipientPhone,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.fullAddress,
  });

  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    return UserAddressModel(
      addressId: json['addressId'].toString(),
      provinceName: json['provinceName'],
      districtName: json['districtName'],
      wardName: json['wardName'],
      streetAddress: json['streetAddress'],
      recipientName: json['recipientName'],
      recipientPhone: json['recipientPhone'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      fullAddress: json['fullAddress'] ?? "",
    );
  }

  factory UserAddressModel.fromDrift(dynamic row) {
    return UserAddressModel(
      addressId: row.addressId,
      provinceName: row.provinceName,
      districtName: row.districtName,
      wardName: row.wardName,
      streetAddress: row.streetAddress,
      recipientName: row.recipientName,
      recipientPhone: row.recipientPhone,
      latitude: row.latitude,
      longitude: row.longitude,
      createdAt: row.createdAt,
      fullAddress: row.fullAddress,
    );
  }
}
