import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/core/network/dio_web.dart';

class PaymentApi {
  final Dio dio;

  PaymentApi(this.dio);

  Future<String> createVnPayUrl({
    required String bookingId,
    required double amount,
  }) async {
    final response = await dio.post(
      "/api/mobile/payment/create-url",
      data: {
        "orderType": "other",
        "amount": amount,
        "orderDescription": "BOOKINGS:$bookingId",
        "name": "Thanh toán dịch vụ"
      },
      options: Options(
        followRedirects: false,
        validateStatus: (_) => true,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception("API trả về lỗi: ${response.statusCode}");
    }

    final paymentUrl = response.data["paymentUrl"];
    if (paymentUrl == null || paymentUrl.toString().isEmpty) {
      throw Exception("Không lấy được paymentUrl từ API.");
    }

    return paymentUrl;
  }
}

final paymentApiProvider = Provider((ref) {
  final dio = ref.read(dioWebProvider).instance;
  return PaymentApi(dio);
});
