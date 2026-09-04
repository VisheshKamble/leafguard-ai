import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/data/disease_catalog.dart';
import '../../providers/history_provider.dart';
import '../../models/scan_result.dart';
import '../../models/disease_info.dart';
import '../../widgets/severity_chip.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final scans = history.scans;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.space24,
        AppConstants.space24,
        AppConstants.space24,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('historyTitle'), style: AppTextStyles.headline),
          const SizedBox(height: AppConstants.space4),
          Text(context.tr('historySubtitle'), style: AppTextStyles.body),
          const SizedBox(height: AppConstants.space24),
          Expanded(
            child: scans.isEmpty
                ? const _EmptyHistory()
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: AppConstants.space24),
                    itemCount: scans.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppConstants.space8),
                    itemBuilder: (context, index) {
                      final scan = scans[index];
                      return _HistoryTile(
                        scan: scan,
                        onDelete: () => context.read<HistoryProvider>().deleteScan(scan['id'] as String),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, color: AppColors.textSecondary, size: 36),
            const SizedBox(height: AppConstants.space12),
            Text(context.tr('nothingScannedYet'), style: AppTextStyles.title),
            const SizedBox(height: AppConstants.space4),
            Text(context.tr('historyEmptyHint'), style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Map scan;
  final VoidCallback onDelete;
  const _HistoryTile({required this.scan, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final id = scan['id'] as String;
    final className = (scan['className'] as String?) ?? '';
    final diagnosis = DiseaseCatalog.lookup(className);
    final severity = Severity.values.firstWhere(
      (s) => s.name == scan['severity'],
      orElse: () => Severity.mild,
    );
    final imagePath = scan['imagePath'] as String?;
    final timestamp = DateTime.tryParse((scan['timestamp'] as String?) ?? '');

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.space24),
        decoration: BoxDecoration(
          color: AppColors.severe.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.severe),
      ),
      child: InkWell(
        onTap: () => _showDetail(context, diagnosis, severity, imagePath, timestamp),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.space12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: imagePath != null && File(imagePath).existsSync()
                      ? Image.file(File(imagePath), fit: BoxFit.cover)
                      : Container(
                          color: AppColors.surfaceMuted,
                          child: const Icon(Icons.eco_outlined, color: AppColors.textSecondary),
                        ),
                ),
              ),
              const SizedBox(width: AppConstants.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${diagnosis.cropName} \u2014 ${diagnosis.diseaseName}', style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SeverityChip(severity: severity),
                        const SizedBox(width: AppConstants.space8),
                        if (timestamp != null)
                          Text(_relativeTime(timestamp), style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showDetail(
    BuildContext context,
    DiseaseInfo diagnosis,
    Severity severity,
    String? imagePath,
    DateTime? timestamp,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppConstants.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(diagnosis.cropName, style: AppTextStyles.caption),
            const SizedBox(height: 2),
            Text(diagnosis.diseaseName, style: AppTextStyles.headline),
            const SizedBox(height: AppConstants.space12),
            SeverityChip(severity: severity),
            const SizedBox(height: AppConstants.space16),
            Text(diagnosis.description, style: AppTextStyles.bodyLarge),
            const SizedBox(height: AppConstants.space24),
          ],
        ),
      ),
    );
  }
}
