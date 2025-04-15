import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return _buildElevatedButton(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        );
      case ButtonType.secondary:
        return _buildElevatedButton(
          backgroundColor: AppTheme.secondaryColor,
          foregroundColor: Colors.white,
        );
      case ButtonType.outline:
        return _buildOutlinedButton();
      case ButtonType.text:
        return _buildTextButton();
    }
  }

  Widget _buildElevatedButton({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _buildButtonContent(foregroundColor),
      ),
    );
  }

  Widget _buildOutlinedButton() {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height ?? 48,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: AppTheme.primaryColor),
        ),
        child: _buildButtonContent(AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildTextButton() {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height ?? 48,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: _buildButtonContent(AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildButtonContent(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      );
    }

    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold));
  }
}
