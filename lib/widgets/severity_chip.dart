import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/localization/locale_provider.dart';
import '../models/scan_result.dart';

class SeverityChip extends StatelessWidget {
  final Severity severity;
  const SeverityChip({super.key, required this.severity});

  Color get _color => switch (severity) {
        Severity.healthy => AppColors.healthy,
        Severity.mild => AppColors.mild,
        Severity.severe => AppColors.severe,
      };

  String _label(BuildContext context) => switch (severity) {
        Severity.healthy => context.tr('severityHealthy'),
        Severity.mild => context.tr('severityMild'),
        Severity.severe => context.tr('severitySevere'),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _color.withOpacity(0.28), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(_label(context), style: AppTextStyles.label.copyWith(color: _color)),
        ],
      ),
    );
  }
}
