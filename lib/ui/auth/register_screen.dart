import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/helper/google_sign_in_helper.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/auth/auth_viewmodel.dart';
import 'package:vhs_mobile_user/ui/auth/terms_and_policy_screen.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> with SingleTickerProviderStateMixin {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hide = true;
  bool _hideConfirm = true;
  bool _agreeToTerms = false;
  bool _showTermsError = false;
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
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

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
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withOpacity(0.2),
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
                                      Icons.person_add,
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
                        const Text(
                          "Đăng ký",
                          style: TextStyle(
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
                          "Tạo tài khoản mới để bắt đầu",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
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
                                    labelText: "Tên đăng nhập",
                                    hintText: "Tối thiểu 8 ký tự, chỉ chữ và số, không khoảng trắng",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 13,
                                    ),
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
                                      return 'Vui lòng nhập tên đăng nhập';
                                    }
                                    if (value.length < 8) {
                                      return 'Tên đăng nhập phải có ít nhất 8 ký tự';
                                    }
                                    // Kiểm tra có khoảng trắng
                                    if (value.contains(' ')) {
                                      return 'Tên đăng nhập không được chứa khoảng trắng';
                                    }
                                    // Kiểm tra chỉ chữ và số, không ký tự đặc biệt
                                    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                                      return 'Tên đăng nhập chỉ được chứa chữ và số, không ký tự đặc biệt';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 18),
                              
                              // Email Field
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
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: "Địa chỉ Email",
                                    hintText: "yourname@gmail.com",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 13,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
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
                                      return 'Vui lòng nhập email';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'Email không hợp lệ';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 18),
                              
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
                                    labelText: "Mật khẩu",
                                    hintText: "Tối thiểu 6 ký tự",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 13,
                                    ),
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
                                    if (value.length < 6) {
                                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 18),
                              
                              // Confirm Password Field
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
                                  controller: _confirmPassword,
                                  obscureText: _hideConfirm,
                                  decoration: InputDecoration(
                                    labelText: "Xác nhận mật khẩu",
                                    hintText: "Nhập lại mật khẩu",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 13,
                                    ),
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
                                        _hideConfirm ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.grey[600],
                                        size: 22,
                                      ),
                                      onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
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
                                      return 'Vui lòng xác nhận mật khẩu';
                                    }
                                    if (value != _password.text) {
                                      return 'Mật khẩu không khớp';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Terms Checkbox
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Checkbox(
                                          value: _agreeToTerms,
                                          onChanged: (value) {
                                            setState(() {
                                              _agreeToTerms = value ?? false;
                                              if (_agreeToTerms) {
                                                _showTermsError = false;
                                              }
                                            });
                                          },
                                          activeColor: primaryBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                            children: [
                                              const TextSpan(text: "Tôi đồng ý với "),
                                              WidgetSpan(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) => const TermsAndPolicyScreen(),
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    "Điều khoản",
                                                    style: TextStyle(
                                                      color: primaryBlue,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (!_agreeToTerms && _showTermsError)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 32, top: 4),
                                      child: Text(
                                        'Vui lòng đồng ý với điều khoản để tiếp tục',
                                        style: TextStyle(
                                          color: Colors.red[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              
                              const SizedBox(height: 28),
                              
                              // Register Button
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
                                            // Kiểm tra checkbox trước
                                            if (!_agreeToTerms) {
                                              setState(() {
                                                _showTermsError = true;
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text('Vui lòng đồng ý với điều khoản để tiếp tục'),
                                                  duration: const Duration(seconds: 2),
                                                  backgroundColor: Colors.red,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  margin: const EdgeInsets.all(16),
                                                ),
                                              );
                                              return;
                                            }
                                            
                                            // Validate form
                                            if (_formKey.currentState!.validate()) {
                                              try {
                                                await ref
                                                    .read(authStateProvider.notifier)
                                                    .register(
                                                      _username.text,
                                                      _password.text,
                                                      _email.text,
                                                    );
                                                if (mounted) {
                                                  context.push(
                                                    Routes.verifyOtp,
                                                    extra: {"email": _email.text, "mode": "activate"},
                                                  );
                                                }
                                              } catch (e) {
                                                if (!mounted) return;
                                                
                                                String errorMessage = "Đăng ký thất bại";
                                                
                                                if (e is DioException) {
                                                  if (e.response != null) {
                                                    final statusCode = e.response?.statusCode;
                                                    final data = e.response?.data;
                                                    
                                                    if (data is Map && data['message'] != null) {
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
                                          child: Center(
                                            child: Text(
                                              "Tạo tài khoản",
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
                        
                        const SizedBox(height: 28),
                        
                        // Login Link
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                              ),
                              children: [
                                const TextSpan(text: "Đã có tài khoản? "),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => context.push(Routes.login),
                                    child: Text(
                                      "Đăng nhập",
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
                        
                        const SizedBox(height: 32),
                        
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
                        
                        // Google Register Button
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
                                        content: Text("Đăng ký Google đã bị hủy hoặc thất bại"),
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

                                  // Google registration tự động kích hoạt tài khoản, không cần OTP
                                  context.go(Routes.listService);
                                } catch (e) {
                                  if (!mounted) return;
                                  
                                  String errorMessage = "Lỗi đăng ký Google";
                                  
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
                                    // Xử lý lỗi từ Google Sign-In
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
                                      "Đăng ký bằng Google",
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
