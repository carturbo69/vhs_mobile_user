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

class _LoginPageState extends ConsumerState<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Đăng nhập")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              controller: _username,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _password,
              obscureText: _hide,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _hide = !_hide),
                ),
              ),
            ),
            const SizedBox(height: 20),

            auth.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref
                            .read(authStateProvider.notifier)
                            .login(_username.text, _password.text);

                        if (!mounted) return;

                        context.go(Routes.listService); // CHUYỂN TRỰC TIẾP
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
                          ),
                        );
                      }
                    },
                    child: const Text("Đăng nhập"),
                  ),

            TextButton(
              onPressed: () => context.push(Routes.register),
              child: const Text("Chưa có tài khoản? Đăng ký"),
            ),

            TextButton(
              onPressed: () => context.push(Routes.forgotPassword),
              child: const Text("Quên mật khẩu?"),
            ),

            const SizedBox(height: 30),

            // ================= GOOGLE LOGIN ===============
            OutlinedButton.icon(
              icon: CachedNetworkImage(
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
              label: const Text("Đăng nhập bằng Google"),
              onPressed: () async {
                try {
                  final helper = GoogleSignInHelperV7();
                  final idToken = await helper.signInAndGetIdToken();
                  
                  if (idToken == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Đăng nhập Google đã bị hủy hoặc thất bại"),
                        duration: Duration(seconds: 2),
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
                    errorMessage = e.toString();
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      duration: const Duration(seconds: 4),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
