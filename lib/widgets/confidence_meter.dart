import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
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
            Text('Confidence', style: AppTextStyles.caption),
            Text('$pct%', style: AppTextStyles.label),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: confidence.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.surfaceMuted,
            valueColor: AlwaysStoppedAnimation(_color),
          ),
        ),
      ],
    );
  }
}
