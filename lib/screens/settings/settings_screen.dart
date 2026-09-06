import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/localization/app_languages.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/language_selector.dart';
import '../../widgets/primary_button.dart';
import '../auth/login_screen.dart';

/// Settings: change language, edit location, manage account. Reachable
/// from the home screen's top bar. Every change here applies and persists
/// immediately -- there's no separate "save" step, matching how
/// [LocaleProvider] already behaves elsewhere in the app.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: context.read<LocaleProvider>().location ?? '');
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _editLocation() async {
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('yourLocation')),
        content: TextField(
          controller: _locationController,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
          decoration: InputDecoration(hintText: context.tr('setupLocationHint')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.tr('goBack')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(_locationController.text),
            child: Text(context.tr('continueLabel')),
          ),
        ],
      ),
    );
    if (result != null && mounted) {
      await context.read<LocaleProvider>().setLocation(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();
    final currentLang = AppLanguages.byCode(locale.languageCode);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.tr('settingsTitle'))),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.space16),
        children: [
          Text(context.tr('settingsGeneral'), style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppConstants.space8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.translate_rounded,
                  title: context.tr('changeLanguage'),
                  subtitle: '${currentLang.nativeName} (${currentLang.englishName})',
                  onTap: () => showLanguageSelector(context),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.location_on_rounded,
                  title: context.tr('yourLocation'),
                  subtitle: locale.location ?? context.tr('locationNotSet'),
                  onTap: _editLocation,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.space24),
          Text(context.tr('settingsAccount'), style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppConstants.space8),
          AppCard(
            child: auth.isSignedIn
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_circle_rounded, color: AppColors.primary, size: 32),
                          const SizedBox(width: AppConstants.space12),
                          Expanded(
                            child: Text(context.tr('signedIn'), style: AppTextStyles.bodyLarge),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.space16),
                      PrimaryButton(
                        label: context.tr('signOut'),
                        variant: ButtonVariant.secondary,
                        onPressed: () => context.read<AuthProvider>().signOut(),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('notSignedInHint'), style: AppTextStyles.body),
                      const SizedBox(height: AppConstants.space16),
                      PrimaryButton(
                        label: context.tr('signIn'),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AppConstants.space24),
          Center(
            child: Text(context.tr('appVersionLabel'), style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.space16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: AppConstants.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.label),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
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
