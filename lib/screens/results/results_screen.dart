import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../providers/scan_provider.dart';
import '../../models/scan_result.dart';
import '../../widgets/severity_chip.dart';
import '../../widgets/confidence_meter.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';
import '../chat/chat_screen.dart';

class ResultsScreen extends StatefulWidget {
  final File imageFile;
  const ResultsScreen({super.key, required this.imageFile});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(vsync: this, duration: AppConstants.animMedium);
    WidgetsBinding.instance.addPostFrameCallback((_) => _analyze());
  }

  Future<void> _analyze() async {
    await context.read<ScanProvider>().analyzeImage(widget.imageFile);
    if (mounted) _revealController.forward();
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: switch (scanProvider.status) {
          ScanStatus.idle || ScanStatus.analyzing => _AnalyzingView(imageFile: widget.imageFile),
          ScanStatus.error => _ErrorView(
              message: scanProvider.errorMessage ?? context.tr('errorGeneric'),
              onRetry: () => Navigator.of(context).pop(),
            ),
          ScanStatus.done => FadeTransition(
              opacity: _revealController,
              child: ScaleTransition(
                scale: Tween(begin: 0.97, end: 1.0).animate(
                  CurvedAnimation(parent: _revealController, curve: Curves.easeOut),
                ),
                child: _ResultView(result: scanProvider.lastResult!),
              ),
            ),
        },
      ),
    );
  }
}

class _AnalyzingView extends StatelessWidget {
  final File imageFile;
  const _AnalyzingView({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            child: Image.file(imageFile, fit: BoxFit.cover, width: double.infinity),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.space32),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
              ),
              const SizedBox(height: AppConstants.space16),
              Text(context.tr('analyzing'), style: AppTextStyles.title),
              const SizedBox(height: AppConstants.space4),
              Text(context.tr('runningOnDevice'), style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.severe, size: 40),
            const SizedBox(height: AppConstants.space16),
            Text(message, style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppConstants.space24),
            PrimaryButton(label: context.tr('tryAgain'), onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final ScanResult result;
  const _ResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    final diagnosis = result.diagnosis;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 240,
                        width: double.infinity,
                        child: Image.file(File(result.imagePath), fit: BoxFit.cover),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.28)],
                              stops: const [0.6, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.space24,
                        AppConstants.space24,
                        AppConstants.space24,
                        AppConstants.space24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(diagnosis.cropName, style: AppTextStyles.caption),
                          const SizedBox(height: 2),
                          Text(diagnosis.diseaseName, style: AppTextStyles.headline),
                          const SizedBox(height: AppConstants.space12),
                          Row(
                            children: [
                              SeverityChip(severity: result.severity),
                            ],
                          ),
                          const SizedBox(height: AppConstants.space16),
                          ConfidenceMeter(confidence: result.confidence, severity: result.severity),
                          const SizedBox(height: AppConstants.space24),
                          Text(diagnosis.description, style: AppTextStyles.bodyLarge),
                          if (!diagnosis.isHealthy) ...[
                            const SizedBox(height: AppConstants.space24),
                            TabBar(
                              labelColor: AppColors.primary,
                              unselectedLabelColor: AppColors.textSecondary,
                              indicatorColor: AppColors.primary,
                              labelStyle: AppTextStyles.label,
                              tabs: [
                                Tab(text: context.tr('tabOrganic')),
                                Tab(text: context.tr('tabChemical')),
                                Tab(text: context.tr('tabPrevention')),
                              ],
                            ),
                            SizedBox(
                              height: 220,
                              child: TabBarView(
                                children: [
                                  _TreatmentList(items: diagnosis.organicTreatment),
                                  _TreatmentList(items: diagnosis.chemicalTreatment),
                                  _TreatmentList(items: diagnosis.preventionTips),
                                ],
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: AppConstants.space24),
                            Text(context.tr('keepItThatWay'), style: AppTextStyles.title),
                            const SizedBox(height: AppConstants.space12),
                            _TreatmentList(items: diagnosis.preventionTips),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.space24,
              AppConstants.space12,
              AppConstants.space24,
              AppConstants.space24,
            ),
            child: Column(
              children: [
                PrimaryButton(
                  label: context.tr('askAiAboutThis'),
                  icon: Icons.auto_awesome_rounded,
                  variant: ButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ChatScreen(scanContext: result)),
                  ),
                ),
                const SizedBox(height: AppConstants.space12),
                PrimaryButton(
                  label: context.tr('scanAnother'),
                  icon: Icons.camera_alt_rounded,
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TreatmentList extends StatelessWidget {
  final List<String> items;
  const _TreatmentList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: AppConstants.space16),
        child: Text('No specific guidance for this category.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: AppConstants.space12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppConstants.space12),
      itemBuilder: (context, index) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(Icons.circle, size: 5, color: AppColors.primary),
          ),
          const SizedBox(width: AppConstants.space12),
          Expanded(child: Text(items[index], style: AppTextStyles.bodyLarge)),
        ],
      ),
    );
  }
}
