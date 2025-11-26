import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_item.dart';
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
    required DateTime date,
    required TimeOfDay time,
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
    ); // correct backend type

    final List<Map<String, dynamic>> bookingItems = items.map((i) {
      return {
        "cartItemId": i.cartItemId,
        "serviceId": i.serviceId,
        "bookingTime": dt.toIso8601String(),
        "optionIds": [],
        "optionValues": null,
      };
    }).toList();

    final payload = {
      "accountId": accountId,
      "address": address.fullAddress, // backend requires Address (string)
      "addressId": address.addressId, // preferred by backend
      "voucherId": null, // no voucher for now
      "latitude": address.latitude,
      "longitude": address.longitude,
      "recipientName": address.recipientName,
      "recipientPhone": address.recipientPhone,
      "items": bookingItems,
    };

    final res = await api.createMany(payload);
    return res;  
  }
     /// Lấy danh sách lịch sử đơn hàng
  Future<List<BookingHistoryItem>> getHistoryByAccount(String accountId) async {
    final response = await api.getHistoryByAccount(accountId);
    return response.items;
  }
}
