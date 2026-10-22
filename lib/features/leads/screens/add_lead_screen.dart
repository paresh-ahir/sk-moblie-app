import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saleskido/features/auth/providers/auth_provider.dart';
import 'package:saleskido/services/lead_service.dart';
import 'package:saleskido/shared/widgets/sk_button.dart';
import 'package:saleskido/shared/widgets/sk_text_field.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  final _notes = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _city.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    try {
      final res = await LeadService().create({
        'company_id': auth.companyId,
        'createBy': auth.userId,
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'email': _email.text.trim(),
        'city': _city.text.trim(),
        'notes': _notes.text.trim(),
      });
      if (!mounted) return;
      if (res['status'] == true) {
        Fluttertoast.showToast(msg: 'Lead created');
        context.pop();
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
      appBar: AppBar(title: const Text('Add Lead')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SkTextField(
                label: 'Name',
                controller: _name,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              SkTextField(
                label: 'Phone',
                controller: _phone,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              SkTextField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              SkTextField(label: 'City', controller: _city),
              const SizedBox(height: 14),
              SkTextField(label: 'Notes', controller: _notes, maxLines: 3),
              const SizedBox(height: 28),
              SkButton(label: 'Save', loading: _loading, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
