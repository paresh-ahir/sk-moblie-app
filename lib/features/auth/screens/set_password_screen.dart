import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/services/auth_service.dart';
import 'package:saleskido/shared/widgets/sk_button.dart';
import 'package:saleskido/shared/widgets/sk_text_field.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({
    super.key,
    this.token,
    this.isReset = false,
  });

  final String? token;
  final bool isReset;

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _success = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_password.text.isEmpty || _confirm.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Enter password and confirm password');
      return;
    }
    if (_password.text != _confirm.text) {
      Fluttertoast.showToast(msg: 'Passwords do not match');
      return;
    }
    if (widget.token == null || widget.token!.isEmpty) {
      Fluttertoast.showToast(msg: 'Invalid or missing reset token');
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await AuthService().resetPassword(
        token: widget.token!,
        password: _password.text,
        confirmPassword: _confirm.text,
      );
      if (!mounted) return;
      if (res['status'] == true) {
        if (widget.isReset) {
          context.go('/password-changed');
        } else {
          setState(() => _success = true);
        }
      } else {
        Fluttertoast.showToast(msg: (res['message'] ?? 'Failed').toString());
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text('Back'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                children: [
                  TextSpan(text: 'Sales', style: TextStyle(color: AppColors.textPrimary)),
                  TextSpan(text: 'Kido', style: TextStyle(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_outline, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isReset ? 'Set a new password' : 'Set a password',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a secure password to set up your account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SkTextField(
              label: 'Password',
              controller: _password,
              obscureText: true,
            ),
            const SizedBox(height: 14),
            SkTextField(
              label: 'Confirm password',
              controller: _confirm,
              obscureText: true,
            ),
            const SizedBox(height: 28),
            SkButton(
              label: widget.isReset ? 'Reset Password' : 'Set Password',
              loading: _loading,
              onPressed: _submit,
            ),
            if (_success) ...[
              const SizedBox(height: 16),
              const Text(
                'Your password has been set up successfully!',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('← Back to log in'),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordChangedScreen extends StatelessWidget {
  const PasswordChangedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text('Back'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                children: [
                  TextSpan(text: 'Sales', style: TextStyle(color: AppColors.textPrimary)),
                  TextSpan(text: 'Kido', style: TextStyle(color: AppColors.primary)),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.success, width: 2),
              ),
              child: const Icon(Icons.check, color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Password changed',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your password is successfully changed',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const Spacer(),
            SkButton(
              label: 'Back to login',
              onPressed: () => context.go('/login'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
