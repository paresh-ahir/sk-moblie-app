import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:saleskido/core/constants/api_constants.dart';
import 'package:saleskido/core/network/api_client.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/features/auth/providers/auth_provider.dart';
import 'package:saleskido/shared/widgets/sk_button.dart';
import 'package:saleskido/shared/widgets/sk_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  bool _loading = false;
  late final TextEditingController _name;
  late final TextEditingController _designation;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _name = TextEditingController(text: auth.userName);
    _designation = TextEditingController(text: auth.designation);
    _email = TextEditingController(text: auth.email);
    _phone = TextEditingController(text: auth.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _designation.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    if (auth.userId.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ApiClient().put(
        ApiConstants.updateUser(auth.userId),
        data: {
          'name': _name.text.trim(),
          'designation': _designation.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim(),
        },
      );
      await auth.loadSession();
      if (!mounted) return;
      setState(() => _editing = false);
      Fluttertoast.showToast(msg: 'Profile updated');
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    backgroundImage: auth.profileImage != null &&
                            auth.profileImage!.isNotEmpty
                        ? NetworkImage(auth.profileImage!)
                        : null,
                    child: auth.profileImage == null || auth.profileImage!.isEmpty
                        ? Text(
                            auth.userName.isNotEmpty
                                ? auth.userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 28,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    auth.userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    auth.designation.isEmpty ? 'Team Member' : auth.designation,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SkTextField(
              label: 'Name',
              controller: _name,
              enabled: _editing,
            ),
            const SizedBox(height: 14),
            SkTextField(
              label: 'Designation',
              controller: _designation,
              enabled: _editing,
            ),
            const SizedBox(height: 14),
            SkTextField(
              label: 'Email',
              controller: _email,
              enabled: _editing,
            ),
            const SizedBox(height: 14),
            SkTextField(
              label: 'Phone Number',
              controller: _phone,
              enabled: _editing,
              prefix: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text('🇮🇳 +91'),
              ),
            ),
            const SizedBox(height: 28),
            if (!_editing)
              SkButton(
                label: 'EDIT PROFILE',
                onPressed: () => setState(() => _editing = true),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: SkButton(
                      label: 'CANCEL',
                      outlined: true,
                      onPressed: () => setState(() => _editing = false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SkButton(
                      label: 'SAVE DETAILS',
                      loading: _loading,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
