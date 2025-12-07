import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/ui/profile/profile_viewmodel.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/services/translation_cache_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _otpRequested = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final message = await ref.read(profileProvider.notifier).requestPasswordChangeOTP();

    setState(() {
      _isLoading = false;
      _otpRequested = message != null;
    });

    if (!mounted) return;

    if (_otpRequested) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? context.tr('otp_sent'))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('cannot_send_otp')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleChangePassword(String otp) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(profileProvider.notifier).changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
          otp: otp,
        );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('change_password_success'))),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('change_password_failed')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        title: Text(
          context.tr('change_password_title'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _currentPasswordController,
                label: context.tr('current_password'),
                icon: Icons.lock_outline,
                iconColor: Colors.orange,
                obscureText: _obscureCurrentPassword,
                onToggleVisibility: () {
                  setState(() => _obscureCurrentPassword = !_obscureCurrentPassword);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('please_enter_current_password');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _newPasswordController,
                label: context.tr('new_password'),
                icon: Icons.lock_outline,
                iconColor: Colors.green,
                obscureText: _obscureNewPassword,
                onToggleVisibility: () {
                  setState(() => _obscureNewPassword = !_obscureNewPassword);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('please_enter_new_password');
                  }
                  if (value.length < 6) {
                    return context.tr('password_min_length');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _confirmPasswordController,
                label: context.tr('confirm_new_password'),
                icon: Icons.lock_outline,
                iconColor: Colors.purple,
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('please_confirm_password');
                  }
                  if (value != _newPasswordController.text) {
                    return context.tr('password_mismatch');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (!_otpRequested)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send_outlined, size: 20),
                    label: Text(
                      _isLoading ? context.tr('sending') : context.tr('send_otp'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _isLoading ? null : _requestOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                )
              else
                VerifyOTPForPasswordChange(
                  onVerified: _handleChangePassword,
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: '$label *',
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.grey.shade600,
            ),
            onPressed: onToggleVisibility,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: iconColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class VerifyOTPForPasswordChange extends ConsumerStatefulWidget {
  final Future<void> Function(String otp) onVerified;

  const VerifyOTPForPasswordChange({
    super.key,
    required this.onVerified,
  });

  @override
  ConsumerState<VerifyOTPForPasswordChange> createState() => _VerifyOTPForPasswordChangeState();
}

class _VerifyOTPForPasswordChangeState extends ConsumerState<VerifyOTPForPasswordChange> {
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
        SnackBar(
          content: Text(context.tr('otp_must_be_6_digits')),
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
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.shade200,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 48,
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 12),
              Text(
                context.tr('enter_otp'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('otp_sent_to_email'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _otpController,
            decoration: InputDecoration(
              labelText: context.tr('otp_code'),
              hintText: context.tr('enter_6_digits'),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blue.shade600,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
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
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check_circle_outline, size: 20),
            label: Text(
              _isLoading ? context.tr('verifying') : context.tr('confirm_change_password'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: _isLoading ? null : _handleVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }
}

