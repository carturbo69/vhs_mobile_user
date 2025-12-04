import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/auth_dao.dart';
import 'package:vhs_mobile_user/data/dao/cart_dao.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_result_model.dart';
import 'package:vhs_mobile_user/data/models/cart/cart_item_model.dart';
import 'package:vhs_mobile_user/data/models/provider/provider_availability_model.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_model.dart';
import 'package:vhs_mobile_user/data/repositories/booking_repository.dart';
import 'package:vhs_mobile_user/data/repositories/cart_repository.dart';
import 'package:flutter/material.dart';
import 'package:vhs_mobile_user/data/services/cart_api.dart';
import 'package:vhs_mobile_user/data/services/provider_availability_api.dart';
import 'package:vhs_mobile_user/ui/cart/cart_list_viewmodel.dart';

final checkoutProvider = AsyncNotifierProvider<CheckoutNotifier, void>(
  CheckoutNotifier.new,
);

class CheckoutNotifier extends AsyncNotifier<void> {
  late  BookingRepository _bookingRepo;
  late  CartRepository _cartRepo;
  late final Ref _ref;

  @override
  Future<void> build() async {
    _ref = ref;
    _bookingRepo = ref.read(bookingRepositoryProvider);
    _cartRepo = ref.read(cartRepositoryProvider);
    return;
  }

  Future<bool> checkDateAvailability(DateTime date, {List<String>? selectedItemIds, String? providerId}) async {
    // Nếu có providerId trực tiếp (cho direct booking), dùng nó
    if (providerId != null) {
      try {
        final api = ref.read(providerAvailabilityApiProvider);
        final dto = await api.checkAvailability(providerId, date, '08:00');
        return dto.hasScheduleForDay ?? true; // Mặc định true nếu null
      } catch (e) {
        // Nếu có lỗi, mặc định cho phép (optimistic approach)
        return true;
      }
    }
    
    // Logic cũ: lấy từ cart items
    // brute force: check sample time (08:00) to detect hasScheduleForDay via providerAvailabilityApi
    final allCartItems = await _cartRepo.readLocal();
    final cartItems = selectedItemIds != null && selectedItemIds.isNotEmpty
        ? allCartItems.where((item) => selectedItemIds.contains(item.cartItemId)).toList()
        : allCartItems;
    
    // Nếu không có cart items (có thể là direct booking với virtual cart item)
    // Mặc định return true để cho phép chọn ngày
    if (cartItems.isEmpty) return true;
    
    final itemProviderId = cartItems.first.providerId;
    if (itemProviderId == null) return true; // Mặc định true nếu không có providerId
    
    try {
      final api = ref.read(providerAvailabilityApiProvider);
      final dto = await api.checkAvailability(itemProviderId, date, '08:00');
      return dto.hasScheduleForDay ?? true; // Mặc định true nếu null
    } catch (e) {
      // Nếu có lỗi, mặc định cho phép (optimistic approach)
      return true;
    }
  }

  Future<ProviderAvailabilityModel> checkTimeAvailability(
    DateTime date,
    TimeOfDay time, {
    List<String>? selectedItemIds,
    String? providerId,
  }) async {
    // Nếu có providerId trực tiếp (cho direct booking), dùng nó
    if (providerId != null) {
      try {
        final api = ref.read(providerAvailabilityApiProvider);
        final dto = await api.checkAvailability(
          providerId,
          date,
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        );
        return dto;
      } catch (e) {
        // Nếu có lỗi, trả về model mặc định với isAvailable = true (optimistic)
        return ProviderAvailabilityModel(
          isAvailable: true,
          hasScheduleForDay: true,
        );
      }
    }
    
    // Logic cũ: lấy từ cart items
    final allCartItems = await _cartRepo.readLocal();
    final cartItems = selectedItemIds != null && selectedItemIds.isNotEmpty
        ? allCartItems.where((item) => selectedItemIds.contains(item.cartItemId)).toList()
        : allCartItems;
    
    // Nếu không có cart items (có thể là direct booking với virtual cart item)
    // Trả về model mặc định với isAvailable = true
    if (cartItems.isEmpty) {
      return ProviderAvailabilityModel(
        isAvailable: true,
        hasScheduleForDay: true,
      );
    }
    
    final itemProviderId = cartItems.first.providerId;
    if (itemProviderId == null) {
      return ProviderAvailabilityModel(
        isAvailable: true,
        hasScheduleForDay: true,
      );
    }
    
    try {
      final api = ref.read(providerAvailabilityApiProvider);
      final dto = await api.checkAvailability(
        itemProviderId,
        date,
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      );
      return dto;
    } catch (e) {
      // Nếu có lỗi, trả về model mặc định với isAvailable = true (optimistic)
      return ProviderAvailabilityModel(
        isAvailable: true,
        hasScheduleForDay: true,
      );
    }
  }

  Future<BookingResultModel> submitBooking({
    required UserAddressModel address,
    required Map<String, DateTime> dates, // Map<cartItemId, DateTime>
    required Map<String, TimeOfDay> times, // Map<cartItemId, TimeOfDay>
    List<String>? selectedItemIds,
    String? voucherId,
  }) async {
    state = const AsyncLoading();

    try {
      final allCartItems = await _cartRepo.readLocal();
      
      // Lọc chỉ lấy selected items
      final cartItems = selectedItemIds != null && selectedItemIds.isNotEmpty
          ? allCartItems.where((item) => selectedItemIds.contains(item.cartItemId)).toList()
          : allCartItems;

      if (cartItems.isEmpty) {
        throw Exception('No services selected'); // Will be translated in UI
      }

      final result = await _bookingRepo.createFromCart(
        items: cartItems,
        address: address,
        dates: dates, // Map<cartItemId, DateTime>
        times: times, // Map<cartItemId, TimeOfDay>
        voucherId: voucherId,
      );

      // cleanup cart after booking - chỉ xóa selected items
      // Nếu xóa trên server thất bại, vẫn tiếp tục vì booking đã thành công
      bool serverDeleteSuccess = false;
      try {
        final saved = await ref.read(authDaoProvider).getSavedAuth();
        final accountId = saved?['accountId'];

        if (accountId != null) {
          final cartApi = ref.read(cartApiProvider);
          final ids = cartItems.map((e) => e.cartItemId).toList();

          await cartApi.removeMany(accountId.toString(), {"cartItemIds": ids});
          serverDeleteSuccess = true;
        }
      } catch (e) {
        // Log lỗi nhưng không throw - booking đã thành công
        debugPrint('⚠️ Không thể xóa cart items trên server: $e');
        // Tiếp tục xóa local cart items để đảm bảo UI được cập nhật
      }

      // Xóa selected items khỏi local cart (luôn thực hiện để đảm bảo UI được cập nhật)
      // Nếu đã xóa thành công trên server, chỉ cần xóa local qua DAO
      // Nếu chưa xóa trên server, vẫn cố gắng xóa qua removeItem (có thể gặp lỗi 404 nếu item đã bị xóa)
      try {
        if (serverDeleteSuccess) {
          // Đã xóa thành công trên server, chỉ cần xóa local qua DAO
          final cartDao = ref.read(cartDaoProvider);
          for (final item in cartItems) {
            await cartDao.deleteById(item.cartItemId);
          }
        } else {
          // Chưa xóa trên server, thử xóa qua removeItem (có thể gặp lỗi 404)
          for (final item in cartItems) {
            try {
              await _cartRepo.removeItem(item.cartItemId);
            } catch (e) {
              // Nếu gặp lỗi (ví dụ 404), vẫn cố xóa local
              debugPrint('⚠️ Không thể xóa cart item ${item.cartItemId} trên server: $e');
              final cartDao = ref.read(cartDaoProvider);
              await cartDao.deleteById(item.cartItemId);
            }
          }
        }

        // Refresh cart state
        final cartNotifier = ref.read(cartProvider.notifier);
        await cartNotifier.refresh();
      } catch (e) {
        debugPrint('⚠️ Không thể xóa cart items local: $e');
        // Vẫn tiếp tục vì booking đã thành công
      }

      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Submit booking trực tiếp từ serviceId (không qua cart)
  Future<BookingResultModel> submitBookingFromServiceId({
    required String serviceId,
    required UserAddressModel address,
    required DateTime date,
    required TimeOfDay time,
    String? voucherId,
    List<CartOptionModel>? options,
  }) async {
    state = const AsyncLoading();

    try {
      final result = await _bookingRepo.createFromServiceId(
        serviceId: serviceId,
        address: address,
        date: date,
        time: time,
        voucherId: voucherId,
        options: options ?? [],
      );

      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
