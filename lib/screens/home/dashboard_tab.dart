import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/history_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/severity_chip.dart';
import '../../models/scan_result.dart';
import '../treatment_info/treatment_info_screen.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final scans = history.scans;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.space24,
        AppConstants.space24,
        AppConstants.space24,
        AppConstants.space32,
      ),
      children: [
        Text('LeafGuard', style: AppTextStyles.displayLarge),
        const SizedBox(height: AppConstants.space4),
        Text(
          'Point your camera at a leaf. Get a diagnosis in seconds -- no signal needed.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: AppConstants.space32),
        const _CropCoverageRow(),
        const SizedBox(height: AppConstants.space16),
        AppCard(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TreatmentInfoScreen()),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppConstants.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Disease guide', style: AppTextStyles.title),
                    Text('Browse what LeafGuard can identify', style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.space32),
        Text('Recent scans', style: AppTextStyles.title),
        const SizedBox(height: AppConstants.space12),
        if (scans.isEmpty)
          const _EmptyScansCard()
        else
          ...scans.take(5).map((scan) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.space8),
                child: _RecentScanTile(scan: scan),
              )),
      ],
    );
  }
}

class _CropCoverageRow extends StatelessWidget {
  const _CropCoverageRow();

  static const _crops = [
    (label: 'Tomato', icon: Icons.eco_outlined),
    (label: 'Potato', icon: Icons.eco_outlined),
    (label: 'Corn', icon: Icons.eco_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _crops
          .map(
            (crop) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: AppConstants.space8),
                padding: const EdgeInsets.symmetric(vertical: AppConstants.space12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Column(
                  children: [
                    Icon(crop.icon, color: AppColors.primary, size: 20),
                    const SizedBox(height: 4),
                    Text(crop.label, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EmptyScansCard extends StatelessWidget {
  const _EmptyScansCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.space32, horizontal: AppConstants.space16),
      child: Column(
        children: [
          const Icon(Icons.camera_alt_outlined, color: AppColors.textSecondary, size: 32),
          const SizedBox(height: AppConstants.space12),
          Text('No scans yet', style: AppTextStyles.title, textAlign: TextAlign.center),
          const SizedBox(height: AppConstants.space4),
          Text(
            'Tap the camera button below to scan your first leaf.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecentScanTile extends StatelessWidget {
  final Map scan;
  const _RecentScanTile({required this.scan});

  Severity get _severity => Severity.values.firstWhere(
        (s) => s.name == scan['severity'],
        orElse: () => Severity.mild,
      );

  @override
  Widget build(BuildContext context) {
    final imagePath = scan['imagePath'] as String?;
    final className = (scan['className'] as String?) ?? 'Unknown';
    final cropAndDisease = className.split('___');
    final displayName = cropAndDisease.length > 1
        ? '${cropAndDisease[0].replaceAll('_', ' ')} — ${cropAndDisease[1].replaceAll('_', ' ')}'
        : className;

    return AppCard(
      padding: const EdgeInsets.all(AppConstants.space12),
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
                Text(displayName, style: AppTextStyles.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                SeverityChip(severity: _severity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
