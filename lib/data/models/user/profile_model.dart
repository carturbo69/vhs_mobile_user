// lib/data/models/profile_model.dart
import 'dart:convert';

class ProfileModel {
  final String userId;
  final String accountId;
  final String accountName;
  final String email;
  final String role;
  final String? fullName;
  final String? phoneNumber;
  final String? images; // CSV or single URL returned by backend
  final String? address;
  final DateTime? createdAt;

  ProfileModel({
    required this.userId,
    required this.accountId,
    required this.accountName,
    required this.email,
    required this.role,
    this.fullName,
    this.phoneNumber,
    this.images,
    this.address,
    this.createdAt,
  });

  /// Helper: trả về list ảnh (nếu backend trả CSV)
  List<String> get imageList {
    if (images == null) return [];
    final raw = images!.trim();
    if (raw.isEmpty) return [];
    // nếu backend đã trả JSON array string thì xử lý
    if (raw.startsWith('[') && raw.endsWith(']')) {
      try {
        final list = (json.decode(raw) as List)
            .map((e) => e.toString())
            .toList();
        return list;
      } catch (_) {
        // fallback to CSV parsing
      }
    }
    // CSV split
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  ProfileModel copyWith({
    String? userId,
    String? accountId,
    String? accountName,
    String? email,
    String? role,
    String? fullName,
    String? phoneNumber,
    String? images,
    String? address,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      images: images ?? this.images,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: (json['userId'] ?? json['UserId'] ?? json['id'] ?? '').toString(),
      accountId: (json['accountId'] ?? json['AccountId'] ?? '').toString(),
      accountName:
          json['accountName'] ?? json['username'] ?? json['userName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? null,
      phoneNumber: json['phoneNumber'] ?? json['phone'] ?? null,
      images: json['images'] != null ? json['images'].toString() : null,
      address: json['address'] ?? json['location'] ?? null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'accountId': accountId,
      'accountName': accountName,
      'email': email,
      'role': role,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'images': images,
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory ProfileModel.fromDrift(dynamic row) {
    return ProfileModel(
      userId: row.userId,
      accountId: row.accountId,
      accountName: row.accountName,
      email: row.email,
      role: row.role,
      fullName: row.fullName,
      phoneNumber: row.phoneNumber,
      images: row.images,
      address: row.address,
      createdAt: row.createdAt,
    );
  }
}
