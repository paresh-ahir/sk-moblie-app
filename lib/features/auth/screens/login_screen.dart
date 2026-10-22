import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saleskido/core/storage/token_storage.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/features/auth/providers/auth_provider.dart';
import 'package:saleskido/shared/widgets/sk_button.dart';
import 'package:saleskido/shared/widgets/sk_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = false;

  @override
  void initState() {
    super.initState();
    _loadRemembered();
  }

  Future<void> _loadRemembered() async {
    final storage = TokenStorage();
    final remember = await storage.getRememberMe();
    final email = await storage.getRememberedEmail();
    if (!mounted) return;
    setState(() {
      _remember = remember;
      if (email != null) _email.text = email;
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      email: _email.text,
      password: _password.text,
      rememberMe: _remember,
    );
    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      Fluttertoast.showToast(msg: auth.error ?? 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: CustomPaint(
                painter: _CirclePatternPainter(),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SkTextField(
                          label: 'Email ID',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SkTextField(
                          label: 'Password',
                          controller: _password,
                          obscureText: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: _remember,
                              onChanged: (v) =>
                                  setState(() => _remember = v ?? false),
                            ),
                            const Text('Remember Me'),
                            const Spacer(),
                            TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              child: const Text('Forget Password'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SkButton(
                          label: 'Sign In',
                          loading: auth.isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/signup'),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.75, size.height * 0.35),
        i * 28.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
