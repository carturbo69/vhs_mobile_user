class UserAddressUpdateModel {
  final String provinceName;
  final String districtName;
  final String wardName;
  final String streetAddress;
  final String? recipientName;
  final String? recipientPhone;
  final double? latitude;
  final double? longitude;

  UserAddressUpdateModel({
    required this.provinceName,
    required this.districtName,
    required this.wardName,
    required this.streetAddress,
    this.recipientName,
    this.recipientPhone,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
    "provinceName": provinceName,
    "districtName": districtName,
    "wardName": wardName,
    "streetAddress": streetAddress,
    "recipientName": recipientName,
    "recipientPhone": recipientPhone,
    "latitude": latitude,
    "longitude": longitude,
  };
}
