import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/services/auth_service.dart';
import 'package:saleskido/shared/widgets/sk_button.dart';

class EmailSentScreen extends StatefulWidget {
  const EmailSentScreen({super.key, required this.email});

  final String email;

  @override
  State<EmailSentScreen> createState() => _EmailSentScreenState();
}

class _EmailSentScreenState extends State<EmailSentScreen> {
  bool _loading = false;

  Future<void> _resend() async {
    setState(() => _loading = true);
    try {
      final res = await AuthService().verifyEmailAgain(widget.email);
      Fluttertoast.showToast(
        msg: (res['message'] ?? 'Link sent').toString(),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  children: [
                    TextSpan(
                      text: 'Sales',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    TextSpan(
                      text: 'Kido',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Join the SalesKido Community!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your Sales Success Starts Here.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              Text(
                'Thank you for choosing us! Your password setup link will be sent to ${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Check your email to get started!',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Text("Didn't get link?"),
              const SizedBox(height: 8),
              SkButton(label: 'Send again', loading: _loading, onPressed: _resend),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Have you an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
