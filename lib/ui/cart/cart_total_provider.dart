import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cart_list_viewmodel.dart';

final cartTotalProvider = Provider<double>((ref) {
  final listAsync = ref.watch(cartProvider);
  final items = listAsync.maybeWhen(
    data: (data) => data,
    orElse: () => [],
  );
  double sum = 0.0;
  for (var i in items) {
    sum += i.price * i.quantity;
  }
  return sum;
});
