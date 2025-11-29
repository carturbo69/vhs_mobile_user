import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/helper/google_sign_in_helper.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/auth/auth_viewmodel.dart';

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

  // Màu xanh nước biển chủ đạo - cải thiện palette
  static const Color primaryBlue = Color(0xFF00BCD4); // Cyan
  static const Color darkBlue = Color(0xFF00838F); // Darker cyan
  static const Color lightBlue = Color(0xFFB2EBF2); // Light cyan
  static const Color accentBlue = Color(0xFF4DD0E1); // Accent cyan
  static const Color deepBlue = Color(0xFF006064); // Deep cyan

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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              lightBlue.withOpacity(0.4),
              primaryBlue.withOpacity(0.1),
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
                        const SizedBox(height: 50),
                        
                        // Logo/Icon Section
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [primaryBlue, darkBlue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Title Section
                        const Text(
                          "Đăng nhập",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: 0.5,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Chào mừng bạn trở lại!",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // Form Section
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Username Field
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
                                  controller: _username,
                                  decoration: InputDecoration(
                                    labelText: "Username",
                                    labelStyle: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: primaryBlue,
                                      size: 22,
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
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập username';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Password Field
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
                                  controller: _password,
                                  obscureText: _hide,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    labelStyle: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: primaryBlue,
                                      size: 22,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _hide ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.grey[600],
                                        size: 22,
                                      ),
                                      onPressed: () => setState(() => _hide = !_hide),
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
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập mật khẩu';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Forgot Password Link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => context.push(Routes.forgotPassword),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  child: Text(
                                    "Quên mật khẩu?",
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Login Button
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
                                                
                                                String errorMessage = "Đăng nhập thất bại";
                                                
                                                if (e is DioException) {
                                                  if (e.response != null) {
                                                    final statusCode = e.response?.statusCode;
                                                    final data = e.response?.data;
                                                    
                                                    if (statusCode == 401) {
                                                      errorMessage = "Tên đăng nhập hoặc mật khẩu không đúng";
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
                                          },
                                          borderRadius: BorderRadius.circular(16),
                                          child: const Center(
                                            child: Text(
                                              "Đăng nhập",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Register Link
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                              ),
                              children: [
                                const TextSpan(text: "Chưa có tài khoản? "),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => context.push(Routes.register),
                                    child: Text(
                                      "Đăng ký",
                                      style: TextStyle(
                                        color: primaryBlue,
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
                        
                        const SizedBox(height: 40),
                        
                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                                height: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "HOẶC",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
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
                                  } else {
                                    final errorStr = e.toString();
                                    if (errorStr.contains('no credential') || 
                                        errorStr.contains('no credentials available') ||
                                        errorStr.contains('Google Play Services')) {
                                      errorMessage = errorStr;
                                    } else {
                                      errorMessage = errorStr;
                                    }
                                  }
                                  
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
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl:
                                          "https://developers.google.com/identity/images/g-logo.png",
                                      width: 24,
                                      height: 24,
                                      placeholder: (_, __) => const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      errorWidget: (_, __, ___) => const Icon(Icons.g_mobiledata),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Đăng nhập bằng Google",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A1A),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
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
}
