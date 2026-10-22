import 'package:flutter/material.dart';
import 'package:saleskido/core/theme/app_colors.dart';

class SkButton extends StatelessWidget {
  const SkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: backgroundColor ?? AppColors.primary,
            side: BorderSide(color: backgroundColor ?? AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? Colors.white,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}
