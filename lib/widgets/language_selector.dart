import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/app_languages.dart';
import '../core/localization/app_strings.dart';
import '../core/localization/locale_provider.dart';

/// A bottom sheet listing every language LeafGuard offers, each written in
/// itself so a farmer can find their own language by sight rather than by
/// reading English. Selecting one applies and persists immediately.
Future<void> showLanguageSelector(BuildContext context) {
  final locale = context.read<LocaleProvider>();
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: AnimatedBuilder(
          animation: locale,
          builder: (context, _) {
            final current = locale.languageCode;
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.space24,
                AppConstants.space16,
                AppConstants.space24,
                AppConstants.space16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppConstants.space16),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Text(AppStrings.t(current, 'chooseLanguage'), style: AppTextStyles.title),
                  const SizedBox(height: AppConstants.space12),
                  ...AppLanguages.supported.map((lang) {
                    final selected = lang.code == current;
                    return InkWell(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      onTap: () {
                        locale.setLanguage(lang.code);
                        Navigator.of(sheetContext).pop();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppConstants.space8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.space16,
                          vertical: AppConstants.space12,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          border: Border.all(
                            color: selected ? AppColors.primary.withOpacity(0.4) : AppColors.divider,
                          ),
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
                            if (selected)
                              const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
