import 'package:flutter/material.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticsLabel;
  final String variant;
  final String size;
  final bool fullWidth;
  final bool isLoading;
  final bool disabled;
  final double? minHeight;

  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticsLabel,
    this.variant = 'primary',
    this.size = 'medium',
    this.fullWidth = false,
    this.isLoading = false,
    this.disabled = false,
    this.minHeight,
  });

  double get _minHeight {
    if (size == 'small') return 40.0;
    if (size == 'medium') return 48.0;
    if (size == 'large') return 56.0;
    if (size == 'xl') return 64.0;
    return minHeight ?? 48.0;
  }

  Color _backgroundColor() {
    if (variant == 'primary') return AppColors.blue600;
    if (variant == 'secondary') return AppColors.gray700;
    if (variant == 'danger') return Colors.red.shade600;
    return Colors.transparent;
  }

  Color _textColor() {
    if (variant == 'secondary') return Colors.white;
    if (variant == 'ghost') return AppColors.gray300;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _backgroundColor(),
        minimumSize: Size(fullWidth ? double.infinity : 0, _minHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      onPressed: (disabled || isLoading) ? null : onPressed,
      child: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _textColor(),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Yükleniyor...', style: TextStyle(color: _textColor())),
              ],
            )
          : DefaultTextStyle(
              style: TextStyle(color: _textColor()),
              child: child,
            ),
    );

    if (semanticsLabel != null && semanticsLabel!.isNotEmpty) {
      return Semantics(label: semanticsLabel, button: true, child: button);
    }
    return button;
  }
}
