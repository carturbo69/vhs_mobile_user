import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/user/profile_model.dart';
import 'package:vhs_mobile_user/ui/profile/profile_viewmodel.dart';

class ChangeEmailScreen extends ConsumerStatefulWidget {
  final ProfileModel profile;

  const ChangeEmailScreen({super.key, required this.profile});

  @override
  ConsumerState<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newEmailController = TextEditingController();
  bool _isLoading = false;
  bool _otpRequested = false;

  @override
  void dispose() {
    _newEmailController.dispose();
    super.dispose();
  }

  Future<void> _requestOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final message = await ref.read(profileProvider.notifier).requestEmailChangeOTP();

    setState(() {
      _isLoading = false;
      _otpRequested = message != null;
    });

    if (!mounted) return;

    if (_otpRequested) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'OTP đã được gửi')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể gửi OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleChangeEmail(String otp) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(profileProvider.notifier).changeEmail(
          newEmail: _newEmailController.text.trim(),
          otpCode: otp,
        );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đổi email thành công')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi email thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi email'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email hiện tại:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.profile.email,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _newEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email mới *',
                  border: OutlineInputBorder(),
                  hintText: 'Nhập email mới',
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !_otpRequested,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập email mới';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  if (value.trim().toLowerCase() == widget.profile.email.toLowerCase()) {
                    return 'Email mới phải khác email hiện tại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (!_otpRequested)
                ElevatedButton(
                  onPressed: _isLoading ? null : _requestOTP,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Gửi OTP'),
                )
              else
                VerifyOTPForEmailChange(
                  onVerified: _handleChangeEmail,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerifyOTPForEmailChange extends StatefulWidget {
  final Future<void> Function(String otp) onVerified;

  const VerifyOTPForEmailChange({
    super.key,
    required this.onVerified,
  });

  @override
  State<VerifyOTPForEmailChange> createState() => _VerifyOTPForEmailChangeState();
}

class _VerifyOTPForEmailChangeState extends State<VerifyOTPForEmailChange> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP phải có 6 chữ số'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await widget.onVerified(_otpController.text);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _otpController,
          decoration: const InputDecoration(
            labelText: 'Nhập OTP *',
            border: OutlineInputBorder(),
            hintText: 'Nhập 6 chữ số OTP',
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleVerify,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Xác nhận đổi email'),
        ),
      ],
    );
  }
}



