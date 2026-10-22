import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/services/auth_service.dart';
import 'package:saleskido/shared/widgets/sk_button.dart';
import 'package:saleskido/shared/widgets/sk_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Enter email');
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await AuthService().forgotPassword(_email.text.trim());
      if (!mounted) return;
      if (res['status'] == true) {
        context.push('/reset-link-sent', extra: _email.text.trim());
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
      backgroundColor: Colors.black54,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lock_outline, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your registered email address below to get password reset link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 20),
                SkTextField(
                  label: 'Enter Email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                SkButton(
                  label: 'Reset password',
                  loading: _loading,
                  onPressed: _submit,
                ),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResetLinkSentScreen extends StatefulWidget {
  const ResetLinkSentScreen({super.key, required this.email});

  final String email;

  @override
  State<ResetLinkSentScreen> createState() => _ResetLinkSentScreenState();
}

class _ResetLinkSentScreenState extends State<ResetLinkSentScreen> {
  bool _loading = false;

  Future<void> _resend() async {
    setState(() => _loading = true);
    try {
      final res = await AuthService().forgotPasswordAgain(widget.email);
      Fluttertoast.showToast(msg: (res['message'] ?? 'Sent').toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "We've sent a password reset link to ${widget.email}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.5, fontSize: 15),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please check your inbox and follow the instructions to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                const Text("Didn't get link?"),
                const SizedBox(height: 8),
                SkButton(label: 'Send again', loading: _loading, onPressed: _resend),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Back to login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
