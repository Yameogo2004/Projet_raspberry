import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final String? label;  // ← AJOUTÉ (alias pour text)
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final IconData? leadingIcon;  // ← AJOUTÉ
  final IconData? trailingIcon; // ← AJOUTÉ

  const CustomButton({
    super.key,
    this.text = '',
    this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.leadingIcon,
    this.trailingIcon,
  });

  String get _text => label ?? text;

  @override
  Widget build(BuildContext context) {
    final buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(_text),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: 18),
        ],
      ],
    );

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: color ?? Colors.blue),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : buttonContent,
      );
    }
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: color ?? Colors.blue,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : buttonContent,
    );
  }
}