import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/localization/app_languages.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/leaf_motif.dart';
import '../home/home_screen.dart';

/// First-run setup: pick a language, then optionally enter a location.
/// Shown once, before the farmer ever sees the home screen -- see the
/// [LocaleProvider.onboardingComplete] gate in app.dart. Both steps can be
/// skipped; this app never blocks on a choice the way an account-first
/// design would.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _step = 0;
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final locale = context.read<LocaleProvider>();
    await locale.setLocation(_locationController.text);
    await locale.completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: AppConstants.animMedium,
                child: _step == 0
                    ? _LanguageStep(key: const ValueKey('lang'), onNext: () => setState(() => _step = 1))
                    : _LocationStep(
                        key: const ValueKey('loc'),
                        controller: _locationController,
                        onBack: () => setState(() => _step = 0),
                        onDone: _finish,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageStep extends StatelessWidget {
  final VoidCallback onNext;
  const _LanguageStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final current = locale.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppConstants.radiusXL),
            bottomRight: Radius.circular(AppConstants.radiusXL),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppConstants.space24,
              AppConstants.space32,
              AppConstants.space24,
              AppConstants.space32,
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.16),
                        border: Border.all(color: Colors.white.withOpacity(0.35)),
                      ),
                      child: const Icon(Icons.eco_rounded, color: AppColors.textOnPrimary, size: 28),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    Text(
                      context.tr('setupWelcomeTitle'),
                      style: AppTextStyles.headline.copyWith(color: AppColors.textOnPrimary),
                    ),
                    const SizedBox(height: AppConstants.space8),
                    Text(
                      context.tr('setupLanguagePrompt'),
                      style: AppTextStyles.body.copyWith(color: AppColors.textOnPrimary.withOpacity(0.85)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.space24,
              AppConstants.space24,
              AppConstants.space24,
              AppConstants.space16,
            ),
            children: AppLanguages.supported.map((lang) {
              final selected = lang.code == current;
              return InkWell(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                onTap: () => locale.setLanguage(lang.code),
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppConstants.space8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.space16,
                    vertical: AppConstants.space12,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(color: selected ? AppColors.primary.withOpacity(0.4) : AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang.nativeName, style: AppTextStyles.bodyLarge),
                            Text(lang.englishName, style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.space24,
            0,
            AppConstants.space24,
            AppConstants.space24,
          ),
          child: PrimaryButton(label: context.tr('continueLabel'), onPressed: onNext),
        ),
      ],
    );
  }
}

class _LocationStep extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onBack;
  final VoidCallback onDone;
  const _LocationStep({super.key, required this.controller, required this.onBack, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppConstants.space16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: AppConstants.space16),
          Text(context.tr('setupLocationTitle'), style: AppTextStyles.headline),
          const SizedBox(height: AppConstants.space8),
          Text(context.tr('setupLocationPrompt'), style: AppTextStyles.body),
          const SizedBox(height: AppConstants.space24),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(hintText: context.tr('setupLocationHint')),
          ),
          const Spacer(),
          PrimaryButton(label: context.tr('continueLabel'), onPressed: onDone),
          const SizedBox(height: AppConstants.space12),
          Center(
            child: TextButton(
              onPressed: onDone,
              child: Text(context.tr('skipForNow'), style: AppTextStyles.body.copyWith(color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}
