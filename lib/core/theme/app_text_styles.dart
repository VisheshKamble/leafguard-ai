import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Two-family type system. Fraunces carries the brand's warmth in the few
/// display moments (app name, screen headlines); Work Sans handles
/// everything functional. This app gets used in a field, not admired in a
/// portfolio review, so legibility wins over ornament everywhere except the
/// handful of headline spots.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _fraunces => GoogleFonts.fraunces();
  static TextStyle get _workSans => GoogleFonts.workSans();

  static TextStyle get displayLarge => _fraunces.copyWith(
        fontSize: 32,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headline => _fraunces.copyWith(
        fontSize: 24,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get title => _workSans.copyWith(
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => _workSans.copyWith(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => _workSans.copyWith(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get label => _workSans.copyWith(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => _workSans.copyWith(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get button => _workSans.copyWith(
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );
}
