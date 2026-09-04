import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/localization/locale_provider.dart';
import '../models/scan_result.dart';

class ConfidenceMeter extends StatelessWidget {
  final double confidence; // 0.0 - 1.0
  final Severity severity;

  const ConfidenceMeter({super.key, required this.confidence, required this.severity});

  Color get _color => switch (severity) {
        Severity.healthy => AppColors.healthy,
        Severity.mild => AppColors.mild,
        Severity.severe => AppColors.severe,
      };

  @override
  Widget build(BuildContext context) {
    final pct = (confidence.clamp(0.0, 1.0) * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.tr('confidence'), style: AppTextStyles.caption),
            Text('$pct%', style: AppTextStyles.label.copyWith(color: _color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 10,
            color: AppColors.surfaceMuted,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: confidence.clamp(0.0, 1.0),
                heightFactor: 1.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_color.withOpacity(0.65), _color]),
                    boxShadow: [BoxShadow(color: _color.withOpacity(0.35), blurRadius: 6)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
