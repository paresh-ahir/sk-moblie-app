import 'package:flutter/material.dart';
import 'package:saleskido/core/theme/app_colors.dart';

class SkTextField extends StatefulWidget {
  const SkTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefix,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int maxLines;

  @override
  State<SkTextField> createState() => _SkTextFieldState();
}

class _SkTextFieldState extends State<SkTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefix,
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textHint,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
