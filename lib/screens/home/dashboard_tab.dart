import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../providers/history_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/severity_chip.dart';
import '../../widgets/leaf_motif.dart';
import '../../models/scan_result.dart';
import '../treatment_info/treatment_info_screen.dart';

class DashboardTab extends StatelessWidget {
  final VoidCallback? onScanTap;
  final VoidCallback? onAskAiTap;
  const DashboardTab({super.key, this.onScanTap, this.onAskAiTap});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final scans = history.scans;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.space16,
        AppConstants.space16,
        AppConstants.space16,
        AppConstants.space32,
      ),
      children: [
        _HeroHeader(onScanTap: onScanTap),
        const SizedBox(height: AppConstants.space24),
        const _CropCoverageRow(),
        const SizedBox(height: AppConstants.space16),
        if (onAskAiTap != null) ...[
          _AskAiCard(onTap: onAskAiTap!),
          const SizedBox(height: AppConstants.space12),
        ],
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
                    Text(context.tr('diseaseGuideTitle'), style: AppTextStyles.title),
                    Text(context.tr('diseaseGuideSubtitle'), style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.space32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.space8),
          child: Text(context.tr('recentScans'), style: AppTextStyles.title),
        ),
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

/// A gradient-bordered call-out for the AI assistant -- the "entire app
/// is AI powered" idea needs one clear, findable door into it beyond the
/// top bar icon, and the dashboard is where a farmer already expects to
/// look for what LeafGuard can do for them.
class _AskAiCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AskAiCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.space16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.08), AppColors.accent.withOpacity(0.10)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.primary.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDeep]),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.textOnPrimary, size: 20),
            ),
            const SizedBox(width: AppConstants.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('askAiCardTitle'), style: AppTextStyles.title),
                  Text(context.tr('askAiCardSubtitle'), style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// The one bold moment on this screen: a deep-gradient banner carrying the
/// brand mark, tagline, language switcher, and the primary "scan" call to
/// action -- everything below it stays deliberately calm.
class _HeroHeader extends StatelessWidget {
  final VoidCallback? onScanTap;
  const _HeroHeader({this.onScanTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.space24,
          AppConstants.space24,
          AppConstants.space24,
          AppConstants.space24,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: LeafPatternBackground(color: Color(0x1AFFFFFF))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LeafGuard',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.textOnPrimary,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: AppConstants.space8),
                Text(
                  context.tr('appTagline'),
                  style: AppTextStyles.body.copyWith(color: AppColors.textOnPrimary.withOpacity(0.85)),
                ),
                if (onScanTap != null) ...[
                  const SizedBox(height: AppConstants.space16),
                  InkWell(
                    onTap: onScanTap,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.space16,
                        vertical: AppConstants.space12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(color: Colors.white.withOpacity(0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt_rounded, color: AppColors.textOnPrimary, size: 18),
                          const SizedBox(width: AppConstants.space8),
                          Text(
                            context.tr('scanLeaf'),
                            style: AppTextStyles.label.copyWith(color: AppColors.textOnPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CropCoverageRow extends StatelessWidget {
  const _CropCoverageRow();

  @override
  Widget build(BuildContext context) {
    final crops = [
      (label: context.tr('cropTomato'), icon: Icons.eco_outlined),
      (label: context.tr('cropPotato'), icon: Icons.eco_outlined),
      (label: context.tr('cropCorn'), icon: Icons.eco_outlined),
    ];

    return Row(
      children: crops
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
          Text(context.tr('noScansYet'), style: AppTextStyles.title, textAlign: TextAlign.center),
          const SizedBox(height: AppConstants.space4),
          Text(
            context.tr('noScansHint'),
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
