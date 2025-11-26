import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/auth/auth_viewmodel.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quên mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text("Nhập email để nhận mã OTP"),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () async {
                try {
                  final msg = await ref
                      .read(authStateProvider.notifier)
                      .sendForgotOtp(_email.text);

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(msg)));

                  context.push(
                    Routes.verifyOtp,
                    extra: {"email": _email.text, "mode": "forgot"},
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text("Gửi OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
