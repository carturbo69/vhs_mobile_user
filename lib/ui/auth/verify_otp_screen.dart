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

class _VerifyOtpPageState extends ConsumerState<VerifyOtpPage> {
  final _otp = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isActivateFlow = widget.mode == "activate";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isActivateFlow ? "Kích hoạt tài khoản" : "Xác thực OTP",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              "Mã OTP đã được gửi tới ${widget.email}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otp,
              decoration: const InputDecoration(labelText: "OTP"),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () async => _handleOTP(ref, context),
              child: const Text("Xác nhận"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOTP(WidgetRef ref, BuildContext context) async {
    try {
      if (widget.mode == "activate") {
        // 🔵 CASE 1: Kích hoạt tài khoản
        final ok = await ref
            .read(authStateProvider.notifier)
            .activateAccount(widget.email, _otp.text);

        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tài khoản đã kích hoạt thành công")),
          );

          context.go(Routes.login);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP không hợp lệ")),
          );
        }

      } else {
        // 🟣 CASE 2: Quên mật khẩu → verify OTP
        final token = await ref
            .read(authStateProvider.notifier)
            .verifyForgotOtp(widget.email, _otp.text);

        context.push(
          Routes.resetPassword,
          extra: {"email": widget.email, "token": token},
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}