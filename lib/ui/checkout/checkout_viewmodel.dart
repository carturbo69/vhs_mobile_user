import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_result_model.dart';
import 'package:vhs_mobile_user/data/models/provider/provider_availability_model.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_model.dart';
import 'package:vhs_mobile_user/data/repositories/booking_repository.dart';
import 'package:vhs_mobile_user/data/repositories/cart_repository.dart';
import 'package:flutter/material.dart';
import 'package:vhs_mobile_user/data/services/cart_api.dart';
import 'package:vhs_mobile_user/data/services/provider_availability_api.dart';

final checkoutProvider = AsyncNotifierProvider<CheckoutNotifier, void>(
  CheckoutNotifier.new,
);

class CheckoutNotifier extends AsyncNotifier<void> {
  late final BookingRepository _bookingRepo;
  late final CartRepository _cartRepo;
  late final Ref _ref;

  @override
  Future<void> build() async {
    _ref = ref;
    _bookingRepo = ref.read(bookingRepositoryProvider);
    _cartRepo = ref.read(cartRepositoryProvider);
    return;
  }

  Future<bool> checkDateAvailability(DateTime date) async {
    // brute force: check sample time (08:00) to detect hasScheduleForDay via providerAvailabilityApi
    final cartItems = await _cartRepo.readLocal();
    if (cartItems.isEmpty) return false;
    final providerId = cartItems.first.providerId;
    if (providerId == null) return false;
    final api = ref.read(providerAvailabilityApiProvider);
    final dto = await api.checkAvailability(providerId, date, '08:00');
    return dto.hasScheduleForDay ?? false;
  }

  Future<ProviderAvailabilityModel> checkTimeAvailability(
    DateTime date,
    TimeOfDay time,
  ) async {
    final cartItems = await _cartRepo.readLocal();
    if (cartItems.isEmpty) throw Exception('No cart items');
    final providerId = cartItems.first.providerId;
    if (providerId == null) throw Exception('No provider');
    final api = ref.read(providerAvailabilityApiProvider);
    final dto = await api.checkAvailability(
      providerId,
      date,
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
    );
    return dto;
  }

  Future<BookingResultModel> submitBooking({
    required UserAddressModel address,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    state = const AsyncLoading();

    try {
      final cartItems = await _cartRepo.readLocal();

      final result = await _bookingRepo.createFromCart(
        items: cartItems,
        address: address,
        date: date,
        time: time,
      );

      // cleanup cart after booking
      final saved = await ref.read(authDaoProvider).getSavedAuth();
      final accountId = saved?['accountId'];

      if (accountId != null) {
        final cartApi = ref.read(cartApiProvider);
        final ids = cartItems.map((e) => e.cartItemId).toList();

        await cartApi.removeMany(accountId.toString(), {"cartItemIds": ids});
      }

      await _cartRepo.clearAll();

      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
