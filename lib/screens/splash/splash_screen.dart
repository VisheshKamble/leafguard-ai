import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.scale(scale: 0.9 + (0.1 * value), child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.eco_rounded, color: AppColors.textOnPrimary, size: 56),
              const SizedBox(height: 16),
              Text(
                'LeafGuard',
                style: AppTextStyles.displayLarge.copyWith(color: AppColors.textOnPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Loading the on-device model...',
                style: AppTextStyles.body.copyWith(color: AppColors.textOnPrimary.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
