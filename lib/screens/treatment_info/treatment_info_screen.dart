import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/data/disease_catalog.dart';
import '../../models/disease_info.dart';
import '../../widgets/app_card.dart';

/// A browsable reference guide of everything LeafGuard can identify --
/// useful on its own, independent of taking a photo, since a farmer may
/// want to check symptoms before a scan or after one.
class TreatmentInfoScreen extends StatelessWidget {
  const TreatmentInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = DiseaseCatalog.curatedEntries.where((e) => !e.isHealthy).toList();
    final byCrop = <String, List<DiseaseInfo>>{};
    for (final entry in entries) {
      byCrop.putIfAbsent(entry.cropName, () => []).add(entry);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.tr('diseaseGuideTitle'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.space24,
          AppConstants.space8,
          AppConstants.space24,
          AppConstants.space32,
        ),
        children: byCrop.entries.expand((cropGroup) {
          return [
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.space24, bottom: AppConstants.space12),
              child: Text(cropGroup.key, style: AppTextStyles.title),
            ),
            ...cropGroup.value.map(
              (disease) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.space8),
                child: _DiseaseExpansionCard(disease: disease),
              ),
            ),
          ];
        }).toList(),
      ),
    );
  }
}

class _DiseaseExpansionCard extends StatelessWidget {
  final DiseaseInfo disease;
  const _DiseaseExpansionCard({required this.disease});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: AppConstants.space16),
            childrenPadding: const EdgeInsets.fromLTRB(
              AppConstants.space16,
              0,
              AppConstants.space16,
              AppConstants.space16,
            ),
            title: Text(disease.diseaseName, style: AppTextStyles.label),
            children: [
              Text(disease.description, style: AppTextStyles.body),
              const SizedBox(height: AppConstants.space12),
              _Section(title: context.tr('organicTreatment'), items: disease.organicTreatment),
              _Section(title: context.tr('chemicalTreatment'), items: disease.chemicalTreatment),
              _Section(title: context.tr('preventionTips'), items: disease.preventionTips),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<String> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.label.copyWith(color: AppColors.primary)),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(Icons.circle, size: 4, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: AppTextStyles.body)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
