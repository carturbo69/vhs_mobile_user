import 'dart:convert';
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

  String? errorMessage; // Lỗi sẽ hiển thị nếu VNPay fail hoặc callback fail

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) async {
            debugPrint("WebView URL: $url");

            // 1) Thành công VNPay → callback mobile
            
            if (url.contains("/api/mobile/payment/vnpay-return")) {
              // Gọi JS lấy body JSON
              try {
                final jsonText = await controller.runJavaScriptReturningResult(
                    "document.body.innerText");

                final response = jsonDecode(jsonText.toString());

                debugPrint("MOBILE CALLBACK JSON: $response");

                if (response["success"] == true) {
                  Navigator.pop(context, true);
                } else {
                  setState(() {
                    errorMessage =
                        "Xác nhận thanh toán thất bại:\n${response["message"]}";
                  });
                }
              } catch (e) {
                setState(() {
                  errorMessage = "Không thể đọc phản hồi từ máy chủ.\n$e";
                });
              }

              return;
            }

            // =====================================
            // 2) Lỗi / Hủy bên VNPay
            // =====================================
            if (url.contains("vnp_ResponseCode=24") || // user cancel
                url.contains("vnp_ResponseCode=99") || // generic fail
                url.toLowerCase().contains("error") ||
                url.contains("code=")) {
              setState(() {
                errorMessage = "VNPay báo lỗi khi thanh toán.\n\nURL: $url";
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null;

    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán VNPay")),
      body: hasError ? _buildErrorWidget() : WebViewWidget(controller: controller),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            const Text(
              "Thanh toán thất bại",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Đóng và quay lại"),
            ),
          ],
        ),
      ),
    );
  }
}
