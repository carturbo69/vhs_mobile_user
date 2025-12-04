import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/dao/cart_dao.dart';
import 'package:vhs_mobile_user/data/models/cart/cart_item_model.dart';
import 'package:vhs_mobile_user/data/repositories/cart_repository.dart';
import 'package:vhs_mobile_user/data/models/cart/add_cart_item_request.dart'; // nhớ import

// Error message constants - UI layer sẽ dịch các message này
class CartErrorMessages {
  static const String serviceAlreadyInCart = 'Dịch vụ này đã có trong giỏ hàng';
}

final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartItemModel>>(
  CartNotifier.new,
);

class CartNotifier extends AsyncNotifier<List<CartItemModel>> {
  late  CartRepository _repo;

  @override
  Future<List<CartItemModel>> build() async {
    _repo = ref.read(cartRepositoryProvider);

    final local = await _repo.readLocal();

    _repo.watchLocal().listen((items) {
      state = AsyncData(items);
    });

    try {
      final remote = await _repo.fetchRemote();
      state = AsyncData(remote);
    } on DioException catch (e) {
      // Nếu lỗi 404, coi như cart rỗng (hợp lệ)
      if (e.response?.statusCode == 404) {
        // Xóa local cart và set state thành empty list
        final cartDao = ref.read(cartDaoProvider);
        await cartDao.clearAll();
        state = const AsyncData([]);
      }
      // Các lỗi khác thì bỏ qua và dùng local data
    } catch (_) {
      // Các lỗi khác thì bỏ qua và dùng local data
    }

    return local;
  }

  // =====================================================
  // 🔥 HÀM QUAN TRỌNG: Add Cart Item (dùng backend chuẩn)
  // =====================================================
  Future<void> addCartItem(AddCartItemRequest req) async {
    // Kiểm tra xem dịch vụ đã có trong giỏ hàng chưa
    final currentItems = state.maybeWhen(
      data: (items) => items,
      orElse: () => <CartItemModel>[],
    );
    final serviceExists = currentItems.any((item) => item.serviceId == req.serviceId);
    
    if (serviceExists) {
      throw Exception(CartErrorMessages.serviceAlreadyInCart);
    }
    
    try {
      await _repo.addToCart(req); // map tới CartRepository
      // Refresh từ server để đảm bảo đồng bộ với tất cả màn hình
      await refresh();
    } catch (e, st) {
      // Chỉ set error nếu là lỗi thực sự, không phải validation error
      // Giữ nguyên state hiện tại để không làm mất dữ liệu
      rethrow;
    }
  }

  // =====================================================
  // 🔥 HÀM THUẬN TIỆN CHO UI SERVICE DETAIL
  // =====================================================
  Future<void> addToCartFromDetail({
    required String serviceId,
    List<String> optionIds = const [],
    Map<String, dynamic>? optionValues,
  }) async {
    final req = AddCartItemRequest(
      serviceId: serviceId,
      optionIds: optionIds,
      optionValues: optionValues,
    );

    await addCartItem(req); // reuse logic addCartItem
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final remote = await _repo.fetchRemote();
      state = AsyncData(remote);
    } catch (e, st) {
      // Nếu lỗi 404, coi như cart rỗng (hợp lệ)
      if (e is DioException && e.response?.statusCode == 404) {
        // Xóa local cart và set state thành empty list
        final cartDao = ref.read(cartDaoProvider);
        await cartDao.clearAll();
        state = const AsyncData([]);
      } else {
        // Các lỗi khác thì set error
        state = AsyncError(e, st);
      }
    }
  }

  Future<void> remove(String cartItemId) async {
    state = const AsyncLoading();
    try {
      await _repo.removeItem(cartItemId);
      // Refresh từ server để đảm bảo đồng bộ với tất cả màn hình
      await refresh();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> clear() async {
    state = const AsyncLoading();
    try {
      await _repo.clearAll();
      // Refresh từ server để đảm bảo đồng bảo với tất cả màn hình
      await refresh();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateQuantity(String cartItemId, int newQty) async {
    await _repo.updateQuantityLocal(cartItemId, newQty);
    // Refresh từ server để đảm bảo đồng bộ với tất cả màn hình
    await refresh();
  }
}
