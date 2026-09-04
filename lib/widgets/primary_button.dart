import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_constants.dart';

enum ButtonVariant { primary, secondary }

/// The app's one call-to-action treatment. Primary variant carries a subtle
/// brand-green gradient and a matching glow shadow -- the single "premium"
/// flourish spent on the element that earns it (the thing a farmer taps
/// most), while secondary stays flat and quiet so it doesn't compete.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonVariant variant;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = ButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == ButtonVariant.primary;
    final isDisabled = onPressed == null || isLoading;
    final foreground = isPrimary ? AppColors.textOnPrimary : AppColors.textPrimary;

    final content = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(foreground),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: foreground),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTextStyles.button.copyWith(color: foreground)),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Opacity(
        opacity: isDisabled && !isLoading ? 0.55 : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isPrimary ? null : AppColors.surfaceMuted,
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              onTap: isDisabled ? null : onPressed,
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
