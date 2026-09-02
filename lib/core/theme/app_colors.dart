import 'package:flutter/material.dart';

/// LeafGuard's color system.
///
/// Grounded in the subject matter: a field-guide / almanac feel rather than
/// a typical SaaS dashboard, since this gets read outdoors in bright sunlight
/// by someone who needs an answer fast, not a polished dashboard. Warm paper
/// background, deep moss green as the single brand color, and a warm ochre
/// accent reserved only for calls to action. Severity colors are functional,
/// not decorative -- they're how a farmer reads a result at a glance.
class AppColors {
  AppColors._();

  // Core surfaces
  static const Color background = Color(0xFFF6F5EE); // warm linen paper
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEFEDE2);

  // Brand
  static const Color primary = Color(0xFF2F5233); // deep moss green
  static const Color primaryDark = Color(0xFF1F3A23);
  static const Color primaryLight = Color(0xFF7C9473); // sage

  static const Color accent = Color(0xFFC97B2E); // ochre -- used sparingly

  // Text
  static const Color textPrimary = Color(0xFF2B2820); // warm charcoal
  static const Color textSecondary = Color(0xFF615C4F);
  static const Color textOnPrimary = Color(0xFFFAF9F3);

  static const Color divider = Color(0xFFE1DECE);

  // Severity states -- read at a glance, not decoration
  static const Color healthy = Color(0xFF4A7A52);
  static const Color mild = Color(0xFFC97B2E);
  static const Color severe = Color(0xFFA63D2F);

  static const Color error = Color(0xFFA63D2F);
}
