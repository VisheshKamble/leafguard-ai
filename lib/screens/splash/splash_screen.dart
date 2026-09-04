import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/leaf_motif.dart';

/// Shown while services are still initializing -- including the language
/// preference itself -- so this screen intentionally doesn't call
/// `context.tr()`: no [LocaleProvider] exists in the tree yet at this
/// point, and there's no language to translate into until init finishes.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: LeafPatternBackground(color: Color(0x1AFFFFFF)),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.scale(scale: 0.88 + (0.12 * value), child: child),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.14),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.4),
                      ),
                      child: const Icon(Icons.eco_rounded, color: AppColors.textOnPrimary, size: 44),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'LeafGuard',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: AppColors.textOnPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Loading the on-device model…',
                      style: AppTextStyles.body.copyWith(color: AppColors.textOnPrimary.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
