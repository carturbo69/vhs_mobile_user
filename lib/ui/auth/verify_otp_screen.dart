import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/auth/auth_viewmodel.dart';

class VerifyOtpPage extends ConsumerStatefulWidget {
  final String email;
  final String mode; // "activate" | "forgot"

  const VerifyOtpPage({
    super.key,
    required this.email,
    required this.mode,
  });

  @override
  ConsumerState<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends ConsumerState<VerifyOtpPage> with SingleTickerProviderStateMixin {
  final _otp = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _countdownTimer;
  int _countdownSeconds = 120; // 2 phút = 120 giây

  // Màu xanh theo web - Sky blue palette
  static const Color primaryBlue = Color(0xFF0284C7); // Sky-600
  static const Color darkBlue = Color(0xFF0369A1); // Sky-700
  static const Color lightBlue = Color(0xFFE0F2FE); // Sky-100
  static const Color accentBlue = Color(0xFFBAE6FD); // Sky-200

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownSeconds = 120;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdownSeconds > 0) {
            _countdownSeconds--;
          } else {
            _countdownTimer?.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otp.dispose();
    _animationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final isActivateFlow = widget.mode == "activate";

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              lightBlue.withOpacity(0.3),
              accentBlue.withOpacity(0.2),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryBlue.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -150,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentBlue.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              
              // Main content
              FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: MediaQuery.of(context).padding.top + 20),
                        
                        // Icon Section
                        Center(
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Icon(
                              isActivateFlow ? Icons.verified_user : Icons.security,
                              size: 60,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // Title Section
                        Text(
                          isActivateFlow ? "Kích hoạt tài khoản" : "Xác thực OTP",
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: 0.5,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Mã OTP đã được gửi tới",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.email,
                          style: TextStyle(
                            fontSize: 15,
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 36),
                        
                        // Form Section
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // OTP Field
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _otp,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 8,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                  decoration: InputDecoration(
                                    labelText: "Mã OTP",
                                    labelStyle: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    hintText: "000000",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 24,
                                      letterSpacing: 8,
                                    ),
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(12),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: primaryBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.lock_outline_rounded,
                                        color: primaryBlue,
                                        size: 20,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: primaryBlue,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập mã OTP';
                                    }
                                    if (value.length < 6) {
                                      return 'Mã OTP phải có 6 chữ số';
                                    }
                                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                      return 'Mã OTP chỉ được chứa số';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 28),
                              
                              // Confirm Button
                              auth.isLoading
                                  ? Container(
                                      height: 58,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: primaryBlue.withOpacity(0.3),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 58,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: [primaryBlue, darkBlue],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryBlue.withOpacity(0.4),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _handleOTP(),
                                          borderRadius: BorderRadius.circular(16),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.check_circle_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  "Xác nhận",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // Info Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primaryBlue.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: primaryBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.info_outline_rounded,
                                      color: primaryBlue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Vui lòng kiểm tra email và nhập mã OTP 6 chữ số đã được gửi đến bạn.",
                                      style: TextStyle(
                                        color: darkBlue,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: _countdownSeconds > 0
                                    ? Text(
                                        "Gửi lại mã sau: ${_formatTime(_countdownSeconds)}",
                                        style: TextStyle(
                                          color: darkBlue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    : TextButton(
                                        onPressed: () async {
                                          try {
                                            final msg = await ref
                                                .read(authStateProvider.notifier)
                                                .resendOtp(widget.email);
                                            
                                            if (!mounted) return;
                                            
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(msg),
                                                duration: const Duration(seconds: 2),
                                                backgroundColor: Colors.green,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                                ),
                                                margin: EdgeInsets.all(16),
                                              ),
                                            );
                                            
                                            _startCountdown();
                                          } catch (e) {
                                            if (!mounted) return;
                                            
                                            String errorMessage = "Gửi lại OTP thất bại";
                                            if (e is DioException) {
                                              if (e.response != null) {
                                                final data = e.response?.data;
                                                if (data is Map && data['message'] != null) {
                                                  errorMessage = data['message'].toString();
                                                } else if (data is Map && data['Message'] != null) {
                                                  errorMessage = data['Message'].toString();
                                                }
                                              } else if (e.type == DioExceptionType.connectionTimeout ||
                                                         e.type == DioExceptionType.receiveTimeout) {
                                                errorMessage = "Kết nối timeout. Vui lòng thử lại.";
                                              } else if (e.type == DioExceptionType.connectionError) {
                                                errorMessage = "Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.";
                                              }
                                            }
                                            
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(errorMessage),
                                                duration: const Duration(seconds: 3),
                                                backgroundColor: Colors.red,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                margin: const EdgeInsets.all(16),
                                              ),
                                            );
                                          }
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.refresh_rounded,
                                              size: 16,
                                              color: primaryBlue,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Gửi lại mã OTP",
                                              style: TextStyle(
                                                color: primaryBlue,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Back to Login Link
                        Center(
                          child: TextButton(
                            onPressed: () => context.go(Routes.login),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    size: 14,
                                    color: primaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Quay lại đăng nhập",
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _handleOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      if (widget.mode == "activate") {
        // 🔵 CASE 1: Kích hoạt tài khoản
        final ok = await ref
            .read(authStateProvider.notifier)
            .activateAccount(widget.email, _otp.text);

        if (!mounted) return;

        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tài khoản đã kích hoạt thành công"),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              margin: EdgeInsets.all(16),
            ),
          );

          context.go(Routes.login);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("OTP không hợp lệ. Vui lòng thử lại."),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              margin: EdgeInsets.all(16),
            ),
          );
        }

      } else {
        // 🟣 CASE 2: Quên mật khẩu → verify OTP
        final token = await ref
            .read(authStateProvider.notifier)
            .verifyForgotOtp(widget.email, _otp.text);

        if (!mounted) return;

        context.push(
          Routes.resetPassword,
          extra: {"email": widget.email, "token": token},
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = "Xác thực OTP thất bại";
      
      if (e is DioException) {
        if (e.response != null) {
          final statusCode = e.response?.statusCode;
          final data = e.response?.data;
          
          if (statusCode == 400) {
            errorMessage = "Mã OTP không hợp lệ hoặc đã hết hạn";
          } else if (data is Map && data['message'] != null) {
            errorMessage = data['message'].toString();
          } else if (data is Map && data['Message'] != null) {
            errorMessage = data['Message'].toString();
          } else {
            errorMessage = "Lỗi từ server: $statusCode";
          }
        } else if (e.type == DioExceptionType.connectionTimeout ||
                   e.type == DioExceptionType.receiveTimeout) {
          errorMessage = "Kết nối timeout. Vui lòng thử lại.";
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = "Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.";
        } else {
          errorMessage = "Lỗi kết nối: ${e.message ?? e.toString()}";
        }
      } else {
        errorMessage = e.toString();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
