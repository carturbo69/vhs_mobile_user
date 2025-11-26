import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/auth/auth_viewmodel.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _hide = true;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký")),
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
              controller: _email,
              decoration: const InputDecoration(labelText: "Email"),
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
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                    child: const Text("Đăng ký"),
                  ),
          ],
        ),
      ),
    );
  }
}
