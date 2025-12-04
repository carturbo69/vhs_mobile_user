import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:vhs_mobile_user/data/repositories/booking_history_repository.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/payment/payment_success_screen.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/services/translation_cache_provider.dart';

class PaymentWebViewScreen extends ConsumerStatefulWidget {
  final String paymentUrl;
  const PaymentWebViewScreen({super.key, required this.paymentUrl});

  @override
  ConsumerState<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends ConsumerState<PaymentWebViewScreen> {
  late final WebViewController controller;

  String? errorMessage; // Error key để dịch
  String? errorUrl; // URL của error để hiển thị
  String? errorDetail; // Chi tiết error từ response
  bool _isProcessingCallback = false; // Flag để ẩn WebView khi đang xử lý callback
  bool _hasProcessedCallback = false; // Flag để tránh xử lý callback nhiều lần
  bool _isLoading = true; // Flag để hiển thị loading khi WebView đang load
  int _loadingProgress = 0; // Progress của WebView loading

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) async {
            debugPrint("🔵 WebView onPageStarted: $url");
            
            // Reset loading state when page starts loading
            if (mounted) {
              setState(() {
                _isLoading = true;
                _loadingProgress = 0;
              });
            }

            // =====================================
            // 1) Thành công VNPay → callback mobile (chỉ log, không set flag)
            // =====================================
            if (url.contains("/api/mobile/payment/vnpay-return") && !_hasProcessedCallback) {
              debugPrint("✅ Detected callback URL, will process in onPageFinished");
              // Không set _isProcessingCallback ở đây để WebView vẫn hiển thị
              // Sẽ xử lý trong onPageFinished
            }

            // =====================================
            // 2) Lỗi / Hủy bên VNPay
            // =====================================
            if (url.contains("vnp_ResponseCode=24") || // user cancel
                url.contains("vnp_ResponseCode=99") || // generic fail
                url.toLowerCase().contains("error") ||
                url.contains("code=")) {
              if (mounted) {
                setState(() {
                  errorMessage = 'vnpay_error';
                  errorUrl = url;
                  _isLoading = false;
                });
              }
            }
          },
          onProgress: (int progress) {
            debugPrint("📊 WebView loading progress: $progress%");
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
                // Hide loading when progress reaches 100
                if (progress >= 100) {
                  _isLoading = false;
                }
              });
            }
          },
          onPageFinished: (url) async {
            debugPrint("🟢 WebView onPageFinished: $url");
            
            // Mark loading as complete
            if (mounted) {
              setState(() {
                _isLoading = false;
                _loadingProgress = 100;
              });
            }

            // 1) Thành công VNPay → callback mobile
            if (url.contains("/api/mobile/payment/vnpay-return") && !_hasProcessedCallback) {
              // Đánh dấu đã xử lý để tránh xử lý nhiều lần
              _hasProcessedCallback = true;
              
              // Ẩn WebView và hiển thị loading
              if (mounted) {
                setState(() {
                  _isProcessingCallback = true;
                });
              }
              
              // Ẩn body bằng JavaScript sau khi trang đã load xong
              try {
                await controller.runJavaScript('''
                  if (document.body) {
                    document.body.style.display = 'none';
                    document.body.style.visibility = 'hidden';
                  }
                  if (document.documentElement) {
                    document.documentElement.style.backgroundColor = '#FFFFFF';
                  }
                ''');
              } catch (e) {
                debugPrint("Failed to hide body: $e");
              }
              
              // Đợi một chút để đảm bảo response đã sẵn sàng
              await Future.delayed(const Duration(milliseconds: 200));
              
              // Gọi JS lấy body JSON
              try {
                // Try multiple methods to get the JSON response
                String jsonString = '';
                try {
                  // Method 1: Try to get innerText
                  final result = await controller.runJavaScriptReturningResult(
                      "document.body.innerText");
                  jsonString = result.toString().trim();
                  
                  // Remove any leading/trailing quotes if present
                  if (jsonString.startsWith('"') && jsonString.endsWith('"')) {
                    jsonString = jsonString.substring(1, jsonString.length - 1);
                    // Unescape the string
                    jsonString = jsonString.replaceAll('\\"', '"').replaceAll('\\n', '\n');
                  }
                  
                  debugPrint("Raw JSON string from innerText: $jsonString");
                } catch (e) {
                  debugPrint("Failed to get innerText: $e");
                  // Method 2: Try to get textContent
                  try {
                    final result = await controller.runJavaScriptReturningResult(
                        "document.body.textContent");
                    jsonString = result.toString().trim();
                    debugPrint("Raw JSON string from textContent: $jsonString");
                  } catch (e2) {
                    debugPrint("Failed to get textContent: $e2");
                    throw Exception("Cannot extract JSON from page body");
                  }
                }

                // Parse JSON
                Map<String, dynamic> response;
                try {
                  response = jsonDecode(jsonString) as Map<String, dynamic>;
                } catch (e) {
                  debugPrint("JSON decode error: $e");
                  debugPrint("Attempting to parse as string: $jsonString");
                  // If direct decode fails, try to extract JSON from HTML
                  final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(jsonString);
                  if (jsonMatch != null) {
                    jsonString = jsonMatch.group(0)!;
                    response = jsonDecode(jsonString) as Map<String, dynamic>;
                  } else {
                    throw Exception("Cannot find valid JSON in response");
                  }
                }

                debugPrint("Parsed MOBILE CALLBACK JSON: $response");

                if (response["success"] == true) {
                  // Extract payment data from response
                  final transactionId = response["transactionId"]?.toString() ?? '';
                  
                  // Handle both single bookingId and multiple bookingIds
                  List<String> bookingIds = [];
                  if (response.containsKey("bookingId") && response["bookingId"] != null) {
                    final bookingIdValue = response["bookingId"];
                    if (bookingIdValue is List) {
                      bookingIds = (bookingIdValue as List)
                          .map((id) => id.toString())
                          .toList();
                    } else if (bookingIdValue is String) {
                      bookingIds = [bookingIdValue];
                    } else {
                      bookingIds = [bookingIdValue.toString()];
                    }
                  } else if (response.containsKey("bookingIds") && response["bookingIds"] != null) {
                    final bookingIdsValue = response["bookingIds"];
                    if (bookingIdsValue is List) {
                      bookingIds = (bookingIdsValue as List)
                          .map((id) => id.toString())
                          .toList();
                    } else if (bookingIdsValue is String) {
                      bookingIds = [bookingIdsValue];
                    } else {
                      bookingIds = [bookingIdsValue.toString()];
                    }
                  }
                  
                  // Extract total amount if available
                  double? total;
                  if (response.containsKey("total") && response["total"] != null) {
                    final totalValue = response["total"];
                    if (totalValue is num) {
                      total = totalValue.toDouble();
                    } else if (totalValue is String) {
                      total = double.tryParse(totalValue);
                    }
                  } else if (response.containsKey("amount") && response["amount"] != null) {
                    final amountValue = response["amount"];
                    if (amountValue is num) {
                      total = amountValue.toDouble();
                    } else if (amountValue is String) {
                      total = double.tryParse(amountValue);
                    }
                  }
                  
                  final message = response["message"]?.toString();
                  
                  // Extract service names from breakdown if available
                  Map<String, String>? serviceNames;
                  if (response.containsKey("breakdown") && response["breakdown"] != null) {
                    final breakdown = response["breakdown"];
                    if (breakdown is List) {
                      serviceNames = {};
                      for (var item in breakdown) {
                        if (item is Map<String, dynamic>) {
                          final bookingId = item["bookingId"]?.toString();
                          final serviceName = item["serviceName"]?.toString();
                          if (bookingId != null && serviceName != null && serviceName.isNotEmpty) {
                            serviceNames![bookingId] = serviceName;
                          }
                        }
                      }
                    }
                  }
                  
                  // If service names are missing, fetch from booking detail API
                  if (serviceNames == null || serviceNames.isEmpty || 
                      bookingIds.any((id) => !serviceNames!.containsKey(id))) {
                    debugPrint("Fetching service names from booking detail API...");
                    try {
                      final bookingRepo = ref.read(bookingHistoryRepositoryProvider);
                      final fetchedServiceNames = <String, String>{};
                      
                      // Fetch service names for all booking IDs
                      for (final bookingId in bookingIds) {
                        if (serviceNames == null || !serviceNames.containsKey(bookingId)) {
                          try {
                            final detail = await bookingRepo.getDetail(bookingId);
                            fetchedServiceNames[bookingId] = detail.service.title;
                            debugPrint("Fetched service name for $bookingId: ${detail.service.title}");
                          } catch (e) {
                            debugPrint("Failed to fetch service name for $bookingId: $e");
                          }
                        }
                      }
                      
                      // Merge with existing service names
                      serviceNames ??= {};
                      serviceNames!.addAll(fetchedServiceNames);
                    } catch (e) {
                      debugPrint("Error fetching service names: $e");
                    }
                  }
                  
                  // Extract transaction time if available
                  DateTime? transactionTime;
                  if (response.containsKey("transactionTime") && response["transactionTime"] != null) {
                    try {
                      final timeStr = response["transactionTime"].toString();
                      transactionTime = DateTime.parse(timeStr);
                    } catch (e) {
                      debugPrint("Failed to parse transactionTime: $e");
                    }
                  } else if (response.containsKey("createdAt") && response["createdAt"] != null) {
                    try {
                      final timeStr = response["createdAt"].toString();
                      transactionTime = DateTime.parse(timeStr);
                    } catch (e) {
                      debugPrint("Failed to parse createdAt: $e");
                    }
                  }
                  
                  debugPrint("Extracted data - transactionId: $transactionId, bookingIds: $bookingIds, total: $total");
                  debugPrint("Service names: $serviceNames");
                  debugPrint("Transaction time: $transactionTime");
                  
                  // Create payment success data
                  final successData = PaymentSuccessData(
                    transactionId: transactionId,
                    bookingIds: bookingIds,
                    total: total,
                    message: message,
                    serviceNames: serviceNames,
                    transactionTime: transactionTime,
                  );
                  
                  // Navigate to payment success screen
                  if (context.mounted) {
                    // Pop the webview first and return true to indicate success
                    Navigator.pop(context, true);
                    // Then navigate to success screen
                    context.push(Routes.paymentSuccess, extra: successData);
                  }
                } else {
                  setState(() {
                    errorMessage = 'payment_confirmation_failed';
                    errorDetail = response["message"]?.toString();
                  });
                }
              } catch (e, st) {
                debugPrint("Error parsing payment response: $e");
                debugPrint("Stack trace: $st");
                setState(() {
                  errorMessage = 'cannot_read_server_response';
                  errorDetail = e.toString();
                });
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ hoặc có translation mới
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
    final hasError = errorMessage != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
            ),
          ),
        ),
        title: Text(
          context.tr('vnpay_payment'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // WebView - always present but may be hidden
          if (!hasError && !_isProcessingCallback)
            WebViewWidget(controller: controller),
          
          // Loading indicator overlay
          if (_isLoading && !hasError && !_isProcessingCallback)
            Container(
              color: ThemeHelper.getScaffoldBackgroundColor(context),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ThemeHelper.getPrimaryColor(context),
                      ),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.tr('loading_payment_page'),
                      style: TextStyle(
                        fontSize: 16,
                        color: ThemeHelper.getSecondaryTextColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_loadingProgress > 0 && _loadingProgress < 100) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeHelper.getLightBlueBackgroundColor(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$_loadingProgress%',
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeHelper.getPrimaryDarkColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          
          // Processing callback indicator
          if (_isProcessingCallback && !hasError)
            Container(
              color: ThemeHelper.getScaffoldBackgroundColor(context),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ThemeHelper.getLightBlueBackgroundColor(context),
                        shape: BoxShape.circle,
                      ),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeHelper.getPrimaryColor(context),
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.tr('processing_payment'),
                      style: TextStyle(
                        fontSize: 18,
                        color: ThemeHelper.getTextColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('please_wait_moment'),
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Error widget
          if (hasError) _buildErrorWidget(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Builder(
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ThemeHelper.isDarkMode(context)
                      ? Colors.red.shade900.withOpacity(0.3)
                      : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade400,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.tr('payment_failed_title'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ThemeHelper.getTextColor(context),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeHelper.getCardBackgroundColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemeHelper.getBorderColor(context),
                    width: 1,
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    String message = '';
                    if (errorMessage == 'vnpay_error') {
                      message = context.tr('vnpay_error');
                      if (errorUrl != null) {
                        message += '\n\nURL: $errorUrl';
                      }
                    } else if (errorMessage == 'payment_confirmation_failed') {
                      message = context.tr('payment_confirmation_failed');
                      if (errorDetail != null) {
                        message += ':\n$errorDetail';
                      } else {
                        message += ':\n${context.tr('error_unknown')}';
                      }
                    } else if (errorMessage == 'cannot_read_server_response') {
                      message = context.tr('cannot_read_server_response');
                      if (errorDetail != null) {
                        message += '\n$errorDetail';
                      }
                    } else if (errorMessage != null) {
                      message = errorMessage!;
                    }
                    return Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.getTextColor(context),
                        height: 1.5,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, false),
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              label: Text(
                context.tr('close_and_return'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHelper.getPrimaryColor(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
