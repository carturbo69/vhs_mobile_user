  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:flutter_riverpod/legacy.dart';
  import 'package:vhs_mobile_user/data/services/payment_api.dart';
  import 'package:vhs_mobile_user/ui/history/history_detail_viewmodel.dart';
  import 'package:vhs_mobile_user/ui/payment/payment_webview_screen.dart';

  final paymentViewModelProvider =
      StateNotifierProvider<PaymentViewModel, AsyncValue<void>>(
    (ref) => PaymentViewModel(ref),
  );

  class PaymentViewModel extends StateNotifier<AsyncValue<void>> {
    final Ref ref;

    PaymentViewModel(this.ref) : super(const AsyncData(null));

    Future<void> payBooking({
      required String bookingId,
      required double amount,
      required BuildContext context,
    }) async {
      state = const AsyncLoading();
      try {
        final api = ref.read(paymentApiProvider);

        final url = await api.createVnPayUrl(
          bookingId: bookingId,
          amount: amount,
        );
        print("👉 VNPay URL: $url");

        state = const AsyncData(null);

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebViewScreen(paymentUrl: url),
          ),
        );

        if (result == true) {
          // Trigger reload history detail
          ref.refresh(historyDetailProvider(bookingId));
        }
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    }
  }
