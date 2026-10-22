import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/services/auth_service.dart';
import 'package:saleskido/shared/widgets/sk_button.dart';
import 'package:saleskido/shared/widgets/sk_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _company = TextEditingController();
  String _companySize = '0';
  bool _loading = false;

  final _sizes = const ['0', '1-10', '11-50', '51-200', '200+'];

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    _phone.dispose();
    _company.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await AuthService().verifyEmail({
        'email': _email.text.trim(),
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'companyName': _company.text.trim(),
        'companySize': _companySize,
      });
      if (!mounted) return;
      if (res['status'] == true) {
        context.push('/email-sent', extra: _email.text.trim());
      } else {
        Fluttertoast.showToast(msg: (res['message'] ?? 'Signup failed').toString());
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Get Started',
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
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              SkTextField(
                label: 'Name',
                controller: _name,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              SkTextField(
                label: 'Phone Number',
                controller: _phone,
                keyboardType: TextInputType.phone,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🇮🇳', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 6),
                      Text('+91', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SkTextField(
                      label: 'Company Name',
                      controller: _company,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Company Size',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _companySize,
                          items: _sizes
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _companySize = v ?? '0'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SkButton(label: 'Sign up', loading: _loading, onPressed: _submit),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Have you an account? ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text(
                      'Sign In',
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
    );
  }
}
