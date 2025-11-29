import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  const PaymentWebViewScreen({super.key, required this.paymentUrl});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint("WebView URL: $url");

            // Thành công: url chứa vnpay success + response=00
            if (url.contains("VnPaySuccess") ||
                url.contains("vnp_ResponseCode=00")) {
              Navigator.pop(context, true);
            }

            // Thất bại hoặc hủy
            if (url.contains("vnp_ResponseCode=24") ||
                url.contains("Cancel") ||
                url.contains("Fail")) {
              Navigator.pop(context, false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán VNPay")),
      body: WebViewWidget(controller: controller),
    );
  }
}
