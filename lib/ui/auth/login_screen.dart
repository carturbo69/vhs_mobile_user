import 'package:cached_network_image/cached_network_image.dart';
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
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
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
                final helper = GoogleSignInHelperV7();
                final idToken = await helper.signInAndGetIdToken();
                if (idToken == null) return;

                await ref
                    .read(authStateProvider.notifier)
                    .loginWithGoogle(idToken);

                if (!mounted) return;

                context.go(Routes.listService);
              },
            ),
          ],
        ),
      ),
    );
  }
}
