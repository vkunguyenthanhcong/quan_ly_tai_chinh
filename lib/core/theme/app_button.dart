import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/core/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  /// màu nền button
  final Color? color;

  /// màu chữ
  final Color? textColor;

  /// trạng thái loading (khuyến nghị có)
  final bool loading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
        foregroundColor: textColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
