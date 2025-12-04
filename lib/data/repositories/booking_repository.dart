import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_result_model.dart';
import 'package:vhs_mobile_user/data/models/cart/cart_item_model.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_model.dart';
import 'package:vhs_mobile_user/data/services/booking_api.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(
    api: ref.read(bookingApiProvider),
    authDao: ref.read(authDaoProvider),
  );
});

class BookingRepository {
  final BookingApi api;
  final AuthDao authDao;

  BookingRepository({required this.api, required this.authDao});

  Future<BookingResultModel> createFromCart({
    required List<CartItemModel> items,
    required UserAddressModel address,
    required Map<String, DateTime> dates, // Map<cartItemId, DateTime>
    required Map<String, TimeOfDay> times, // Map<cartItemId, TimeOfDay>
    String? voucherId,
  }) async {
    final saved = await authDao.getSavedAuth();
    final accountId = saved?['accountId'];
    if (accountId == null) throw Exception("Missing accountId");

    final List<Map<String, dynamic>> bookingItems = items.map((i) {
      // Lấy ngày và giờ cho từng item
      final date = dates[i.cartItemId] ?? 
                   (dates.values.isNotEmpty ? dates.values.first : DateTime.now());
      final time = times[i.cartItemId] ?? 
                   (times.values.isNotEmpty ? times.values.first : const TimeOfDay(hour: 8, minute: 0));
      final dt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      
      // Trích xuất options từ cart item
      // Gửi tất cả optionIds để backend biết có những options nào
      // Gửi tất cả options trong optionValues (giống như createFromServiceId) để backend lưu lại
      // Đảm bảo optionIds luôn là list (không null), ngay cả khi rỗng
      final List<String> optionIds = i.options.map((opt) => opt.optionId).where((id) => id.isNotEmpty).toList();
      final Map<String, dynamic>? optionValues = i.options.isNotEmpty
          ? Map<String, dynamic>.fromEntries(
              i.options
                  .where((opt) => opt.optionId.isNotEmpty) // Chỉ lấy options có optionId hợp lệ
                  .map((opt) => MapEntry(opt.optionId, opt.value.isNotEmpty ? opt.value : '')),
            )
          : null;
      
      // Debug: Log options cho từng item
      print('🔍 [createFromCart] Item: ${i.serviceName} (${i.cartItemId})');
      print('  - options count: ${i.options.length}');
      print('  - optionIds: $optionIds (count: ${optionIds.length})');
      print('  - optionValues: $optionValues');
      if (optionValues != null) {
        print('  - optionValues entries: ${optionValues.entries.map((e) => '${e.key}: "${e.value}"').join(', ')}');
      }
      
      return {
        "cartItemId": i.cartItemId,
        "serviceId": i.serviceId,
        "bookingTime": dt.toIso8601String(),
        "optionIds": optionIds,
        "optionValues": optionValues,
      };
    }).toList();

    final payload = {
      "accountId": accountId,
      "address": address.fullAddress, // backend requires Address (string)
      "addressId": address.addressId, // preferred by backend
      "voucherId": voucherId,
      "latitude": address.latitude,
      "longitude": address.longitude,
      "recipientName": address.recipientName,
      "recipientPhone": address.recipientPhone,
      "items": bookingItems,
    };

    // Debug: Log full payload
    print('🔍 [createFromCart] Full payload:');
    print('  - items count: ${bookingItems.length}');
    for (var i = 0; i < bookingItems.length; i++) {
      print('  - items[$i]: serviceId=${bookingItems[i]["serviceId"]}, optionIds=${bookingItems[i]["optionIds"]}, optionValues=${bookingItems[i]["optionValues"]}');
    }

    final res = await api.createMany(payload);
    return res;  
  }

  Future<void> cancelBooking(String bookingId, String accountId, String reason) async {
    await api.cancelBooking(bookingId, accountId, reason);
  }

  Future<bool> confirmServiceCompleted(String bookingId) async {
    final saved = await authDao.getSavedAuth();
    final accountId = saved?['accountId'];
    if (accountId == null) throw Exception("Missing accountId");
    
    return await api.confirmServiceCompleted(bookingId, accountId);
  }

  // Tạo booking trực tiếp từ serviceId (không qua cart)
  Future<BookingResultModel> createFromServiceId({
    required String serviceId,
    required UserAddressModel address,
    required DateTime date,
    required TimeOfDay time,
    String? voucherId,
    List<CartOptionModel> options = const [],
  }) async {
    final saved = await authDao.getSavedAuth();
    final accountId = saved?['accountId'];
    if (accountId == null) throw Exception("Missing accountId");

    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // Extract optionIds and optionValues from options
    // Gửi tất cả optionIds để backend biết có những options nào
    // Gửi tất cả options trong optionValues (giống như createFromCart) để backend lưu lại
    // Backend có thể cần cả optionIds và optionValues để lưu options
    // Đảm bảo optionIds luôn là list (không null), ngay cả khi rỗng
    final List<String> optionIds = options.map((opt) => opt.optionId).where((id) => id.isNotEmpty).toList();
    final Map<String, dynamic>? optionValues = options.isNotEmpty
        ? Map<String, dynamic>.fromEntries(
            options
                .where((opt) => opt.optionId.isNotEmpty) // Chỉ lấy options có optionId hợp lệ
                .map((opt) => MapEntry(opt.optionId, opt.value.isNotEmpty ? opt.value : '')),
          )
        : null;

    final bookingItems = [
      {
        "serviceId": serviceId,
        "bookingTime": dt.toIso8601String(),
        "optionIds": optionIds,
        "optionValues": optionValues,
      }
    ];

    final payload = {
      "accountId": accountId,
      "address": address.fullAddress,
      "addressId": address.addressId,
      "voucherId": voucherId,
      "latitude": address.latitude,
      "longitude": address.longitude,
      "recipientName": address.recipientName,
      "recipientPhone": address.recipientPhone,
      "items": bookingItems,
    };

    // Debug: Log payload để kiểm tra options có được gửi không
    print('🔍 [createFromServiceId] Payload:');
    print('  - serviceId: $serviceId');
    print('  - options count: ${options.length}');
    print('  - optionIds: $optionIds (count: ${optionIds.length})');
    print('  - optionValues: $optionValues');
    if (optionValues != null) {
      print('  - optionValues entries: ${optionValues.entries.map((e) => '${e.key}: "${e.value}"').join(', ')}');
    }
    print('  - bookingItems[0]: ${bookingItems.first}');

    final res = await api.createMany(payload);
    return res;
  }

}
