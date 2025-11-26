import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/cart/cart_item_model.dart';
import 'package:vhs_mobile_user/data/repositories/cart_repository.dart';
import 'package:vhs_mobile_user/data/models/cart/add_cart_item_request.dart'; // nhớ import

final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartItemModel>>(
  CartNotifier.new,
);

class CartNotifier extends AsyncNotifier<List<CartItemModel>> {
  late final CartRepository _repo;

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
    } catch (_) {}

    return local;
  }

  // =====================================================
  // 🔥 HÀM QUAN TRỌNG: Add Cart Item (dùng backend chuẩn)
  // =====================================================
  Future<void> addCartItem(AddCartItemRequest req) async {
    try {
      await _repo.addToCart(req); // map tới CartRepository
      final local = await _repo.readLocal();
      state = AsyncData(local);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // =====================================================
  // 🔥 HÀM THUẬN TIỆN CHO UI SERVICE DETAIL
  // =====================================================
  Future<void> addToCartFromDetail({required String serviceId}) async {
    final req = AddCartItemRequest(serviceId: serviceId);

    await addCartItem(req); // reuse logic addCartItem
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchRemote());
  }

  Future<void> remove(String cartItemId) async {
    state = const AsyncLoading();
    try {
      await _repo.removeItem(cartItemId);
      final items = await _repo.readLocal();
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> clear() async {
    state = const AsyncLoading();
    try {
      await _repo.clearAll();
      state = const AsyncData([]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateQuantity(String cartItemId, int newQty) async {
    await _repo.updateQuantityLocal(cartItemId, newQty);
    final items = await _repo.readLocal();
    state = AsyncData(items);
  }
}
