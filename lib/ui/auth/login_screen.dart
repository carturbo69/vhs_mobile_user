import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/helper/google_sign_in_helper.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/auth/auth_viewmodel.dart';
import 'package:vhs_mobile_user/ui/auth/terms_and_policy_screen.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Màu xanh theo web - Sky blue palette
  static const Color primaryBlue = Color(0xFF0284C7); // Sky-600
  static const Color darkBlue = Color(0xFF0369A1); // Sky-700
  static const Color lightBlue = Color(0xFFE0F2FE); // Sky-100
  static const Color accentBlue = Color(0xFFBAE6FD); // Sky-200
  static const Color deepBlue = Color(0xFF0C4A6E); // Sky-800

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
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final size = MediaQuery.of(context).size;
    final isDark = ThemeHelper.isDarkMode(context);

    return Scaffold(
      backgroundColor: ThemeHelper.getScaffoldBackgroundColor(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF121212),
                    Colors.blue.shade900.withOpacity(0.3),
                    Colors.blue.shade800.withOpacity(0.2),
                  ]
                : [
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
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                        
                        // Logo Section
                        Center(
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ThemeHelper.getCardBackgroundColor(context),
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/vhs_logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [primaryBlue, darkBlue],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // Title Section
                        Text(
                          context.tr('login_title'),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: ThemeHelper.getTextColor(context),
                            letterSpacing: 0.5,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tr('login_subtitle'),
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeHelper.getSecondaryTextColor(context),
                            fontWeight: FontWeight.w400,
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
                              // Username Field
                              Container(
                                decoration: BoxDecoration(
                                  color: ThemeHelper.getCardBackgroundColor(context),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ThemeHelper.getShadowColor(context),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _username,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ThemeHelper.getTextColor(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: context.tr('username_or_email'),
                                    labelStyle: TextStyle(
                                      color: ThemeHelper.getSecondaryTextColor(context),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(12),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.person_outline_rounded,
                                        color: ThemeHelper.getPrimaryColor(context),
                                        size: 20,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: ThemeHelper.getInputBackgroundColor(context),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: ThemeHelper.getBorderColor(context),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: ThemeHelper.getPrimaryColor(context),
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
                                      return context.tr('field_required');
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 18),
                              
                              // Password Field
                              Container(
                                decoration: BoxDecoration(
                                  color: ThemeHelper.getCardBackgroundColor(context),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ThemeHelper.getShadowColor(context),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _password,
                                  obscureText: _hide,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ThemeHelper.getTextColor(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: context.tr('password'),
                                    labelStyle: TextStyle(
                                      color: ThemeHelper.getSecondaryTextColor(context),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(12),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.lock_outline_rounded,
                                        color: ThemeHelper.getPrimaryColor(context),
                                        size: 20,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _hide ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                        color: ThemeHelper.getSecondaryIconColor(context),
                                        size: 22,
                                      ),
                                      onPressed: () => setState(() => _hide = !_hide),
                                    ),
                                    filled: true,
                                    fillColor: ThemeHelper.getInputBackgroundColor(context),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: ThemeHelper.getBorderColor(context),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: ThemeHelper.getPrimaryColor(context),
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
                                      return context.tr('field_required');
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 10),
                              
                              // Forgot Password Link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => context.push(Routes.forgotPassword),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  child: Text(
                                    context.tr('forgot_password'),
                                    style: TextStyle(
                                      color: ThemeHelper.getPrimaryColor(context),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 28),
                              
                              // Login Button
                              auth.isLoading
                                  ? Container(
                                      height: 58,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            ThemeHelper.getPrimaryColor(context),
                                          ),
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 58,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: [
                                            ThemeHelper.getPrimaryColor(context),
                                            ThemeHelper.getPrimaryDarkColor(context),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ThemeHelper.getPrimaryColor(context).withOpacity(0.4),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () async {
                                            if (_formKey.currentState!.validate()) {
                                              try {
                                                await ref
                                                    .read(authStateProvider.notifier)
                                                    .login(_username.text, _password.text);

                                                if (!mounted) return;

                                                context.go(Routes.listService);
                                              } catch (e) {
                                                if (!mounted) return;
                                                
                                                String errorTitle = "Đăng nhập thất bại";
                                                String errorMessage = "";
                                                IconData errorIcon = Icons.error_outline_rounded;
                                                
                                                if (e is DioException) {
                                                  if (e.response != null) {
                                                    final statusCode = e.response?.statusCode;
                                                    final data = e.response?.data;
                                                    
                                                    if (statusCode == 401) {
                                                      errorTitle = "Thông tin đăng nhập không chính xác";
                                                      errorIcon = Icons.lock_outline_rounded;
                                                      
                                                      // Ưu tiên hiển thị message từ server nếu có
                                                      if (data is Map && (data['message'] != null || data['Message'] != null)) {
                                                        final serverMessage = (data['message'] ?? data['Message']).toString();
                                                        errorMessage = serverMessage;
                                                      } else {
                                                        // Fallback message nếu server không trả về message cụ thể
                                                        errorMessage = "• Tên đăng nhập hoặc email không tồn tại\n• Mật khẩu không đúng\n\nVui lòng kiểm tra lại thông tin đăng nhập của bạn.";
                                                      }
                                                    } else if (statusCode == 403) {
                                                      errorTitle = "Tài khoản bị khóa";
                                                      errorMessage = "Tài khoản của bạn đã bị khóa hoặc vô hiệu hóa. Vui lòng liên hệ quản trị viên để được hỗ trợ.";
                                                      errorIcon = Icons.block_rounded;
                                                    } else if (statusCode == 423) {
                                                      errorTitle = "Tài khoản chưa được kích hoạt";
                                                      errorMessage = "Vui lòng kiểm tra email để kích hoạt tài khoản trước khi đăng nhập.";
                                                      errorIcon = Icons.mail_outline_rounded;
                                                    } else if (statusCode == 400) {
                                                      errorTitle = "Thông tin không hợp lệ";
                                                      if (data is Map && (data['message'] != null || data['Message'] != null)) {
                                                        errorMessage = (data['message'] ?? data['Message']).toString();
                                                      } else {
                                                        errorMessage = "Vui lòng kiểm tra lại thông tin đăng nhập.";
                                                      }
                                                      errorIcon = Icons.warning_amber_rounded;
                                                    } else if (statusCode == 500 || statusCode == 502 || statusCode == 503) {
                                                      errorTitle = "Lỗi máy chủ";
                                                      errorMessage = "Server đang gặp sự cố. Vui lòng thử lại sau ít phút.";
                                                      errorIcon = Icons.cloud_off_rounded;
                                                    } else if (data is Map && data['message'] != null) {
                                                      errorMessage = data['message'].toString();
                                                    } else if (data is Map && data['Message'] != null) {
                                                      errorMessage = data['Message'].toString();
                                                    } else {
                                                      errorTitle = "Lỗi không xác định";
                                                      errorMessage = "Mã lỗi: $statusCode\nVui lòng thử lại hoặc liên hệ hỗ trợ.";
                                                    }
                                                  } else if (e.type == DioExceptionType.connectionTimeout ||
                                                             e.type == DioExceptionType.receiveTimeout) {
                                                    errorTitle = "Kết nối timeout";
                                                    errorMessage = "Không thể kết nối đến server trong thời gian cho phép.\n\n• Kiểm tra kết nối mạng\n• Thử lại sau";
                                                    errorIcon = Icons.timer_off_rounded;
                                                  } else if (e.type == DioExceptionType.connectionError) {
                                                    errorTitle = "Lỗi kết nối";
                                                    errorMessage = "Không thể kết nối đến server.\n\n• Kiểm tra kết nối internet\n• Kiểm tra cài đặt mạng\n• Thử lại sau";
                                                    errorIcon = Icons.wifi_off_rounded;
                                                  } else {
                                                    errorTitle = "Lỗi kết nối";
                                                    errorMessage = e.message ?? "Có lỗi xảy ra khi kết nối đến server.";
                                                  }
                                                } else {
                                                  errorMessage = e.toString();
                                                }
                                                
                                                // Hiển thị dialog với thông tin lỗi chi tiết
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    backgroundColor: ThemeHelper.getDialogBackgroundColor(context),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    title: Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.all(10),
                                                          decoration: BoxDecoration(
                                                            color: Colors.red.shade50,
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: Icon(
                                                            errorIcon,
                                                            color: Colors.red.shade600,
                                                            size: 28,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            errorTitle,
                                                            style: TextStyle(
                                                              fontSize: 19,
                                                              fontWeight: FontWeight.bold,
                                                              color: ThemeHelper.getTextColor(context),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          errorMessage.isNotEmpty ? errorMessage : "Vui lòng thử lại.",
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            height: 1.6,
                                                            color: ThemeHelper.getSecondaryTextColor(context),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        style: TextButton.styleFrom(
                                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                          backgroundColor: ThemeHelper.getPrimaryColor(context),
                                                          foregroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          "Đã hiểu",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(16),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.login_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  context.tr('login'),
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
                        
                        // Register Link
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: ThemeHelper.getSecondaryTextColor(context),
                                fontSize: 15,
                              ),
                              children: [
                                TextSpan(text: "${context.tr('dont_have_account')} "),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => context.push(Routes.register),
                                    child: Text(
                                      context.tr('register'),
                                      style: TextStyle(
                                        color: ThemeHelper.getPrimaryColor(context),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: ThemeHelper.getDividerColor(context),
                                thickness: 1,
                                height: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                context.tr('or'),
                                style: TextStyle(
                                  color: ThemeHelper.getTertiaryTextColor(context),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: ThemeHelper.getDividerColor(context),
                                thickness: 1,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Google Login Button
                        Container(
                          height: 58,
                          decoration: BoxDecoration(
                            color: ThemeHelper.getCardBackgroundColor(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ThemeHelper.getBorderColor(context),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeHelper.getShadowColor(context),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                              child: InkWell(
                              onTap: () async {
                                try {
                                  final helper = GoogleSignInHelperV7();
                                  final idToken = await helper.signInAndGetIdToken();
                                  
                                  if (idToken == null) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Đăng nhập Google đã bị hủy hoặc thất bại"),
                                        duration: Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                        ),
                                        margin: EdgeInsets.all(16),
                                      ),
                                    );
                                    return;
                                  }

                                  await ref
                                      .read(authStateProvider.notifier)
                                      .loginWithGoogle(idToken);

                                  if (!mounted) return;

                                  context.go(Routes.listService);
                                } catch (e) {
                                  if (!mounted) return;
                                  
                                  String errorMessage = "Lỗi đăng nhập Google";
                                  
                                  if (e is DioException) {
                                    if (e.response != null) {
                                      final data = e.response?.data;
                                      if (data is Map && data['message'] != null) {
                                        errorMessage = data['message'].toString();
                                      } else if (data is Map && data['Message'] != null) {
                                        errorMessage = data['Message'].toString();
                                      } else {
                                        errorMessage = "Lỗi từ server: ${e.response?.statusCode}";
                                      }
                                    } else if (e.type == DioExceptionType.connectionTimeout ||
                                               e.type == DioExceptionType.receiveTimeout) {
                                      errorMessage = "Kết nối timeout. Vui lòng thử lại.";
                                    } else if (e.type == DioExceptionType.connectionError) {
                                      errorMessage = "Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.";
                                    } else {
                                      errorMessage = "Lỗi kết nối: ${e.message ?? e.toString()}";
                                    }
                                  } else if (e is GoogleSignInEmulatorException) {
                                    // Handle emulator-specific errors with better formatting
                                    errorMessage = e.message;
                                  } else if (e is Exception) {
                                    // Handle other exceptions
                                    final errorStr = e.toString();
                                    // Remove "Exception: " prefix if present
                                    if (errorStr.startsWith('Exception: ')) {
                                      errorMessage = errorStr.substring(11);
                                    } else {
                                      errorMessage = errorStr;
                                    }
                                  } else {
                                    errorMessage = e.toString();
                                  }
                                  
                                  // Show error in a dialog for better readability (especially for emulator errors)
                                  if (e is GoogleSignInEmulatorException || 
                                      (errorMessage.contains('emulator') || 
                                       errorMessage.contains('Google Play Services'))) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: ThemeHelper.getDialogBackgroundColor(context),
                                        title: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade50,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.orange.shade600,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                "Lỗi đăng nhập Google",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: ThemeHelper.getTextColor(context),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: Text(
                                          errorMessage,
                                          style: TextStyle(
                                            fontSize: 15,
                                            height: 1.5,
                                            color: ThemeHelper.getTextColor(context),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: Text(
                                              "Đã hiểu",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: ThemeHelper.getPrimaryColor(context),
                                              ),
                                            ),
                                          ),
                                        ],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Show regular snackbar for other errors
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(errorMessage),
                                        duration: const Duration(seconds: 5),
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
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            "https://developers.google.com/identity/images/g-logo.png",
                                        width: 20,
                                        height: 20,
                                        placeholder: (_, __) => const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                        errorWidget: (_, __, ___) => Icon(
                                          Icons.g_mobiledata_rounded,
                                          size: 20,
                                          color: ThemeHelper.getPrimaryColor(context),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      context.tr('login_with_google'),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: ThemeHelper.getTextColor(context),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Terms and Privacy Links
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const TermsAndPolicyScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.description_rounded,
                                      size: 14,
                                      color: ThemeHelper.getPrimaryColor(context),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    context.tr('terms_of_service'),
                                    style: TextStyle(
                                      color: ThemeHelper.getPrimaryColor(context),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 16,
                              color: ThemeHelper.getDividerColor(context),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const TermsAndPolicyScreen(initialTab: 2),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.lock_rounded,
                                      size: 14,
                                      color: ThemeHelper.getPrimaryColor(context),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    context.tr('privacy_policy'),
                                    style: TextStyle(
                                      color: ThemeHelper.getPrimaryColor(context),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
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
}
