import 'package:flutter/material.dart';

/// Utility class for managing app fonts based on current locale
class AppFonts {
  /// Get the appropriate font family based on current locale
  /// Uses IBMPlexSansArabic for Arabic, InterDisplay for others
  static String getLocalizedFontFamily(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? 'IBMPlexSansArabic' : 'InterDisplay';
  }

  /// Get the appropriate font family for titles/headers based on current locale
  /// Previously used Montserrat, now uses locale-appropriate fonts
  static String getTitleFontFamily(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? 'IBMPlexSansArabic' : 'InterDisplay';
  }

  /// Create a TextStyle with appropriate font family for titles
  static TextStyle titleStyle(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: getTitleFontFamily(context),
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  /// Create a TextStyle with appropriate font family for body text
  static TextStyle bodyStyle(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: getLocalizedFontFamily(context),
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  /// Font families for different locales
  static const String arabicFont = 'IBMPlexSansArabic';
  static const String defaultFont = 'InterDisplay';
  
  /// Legacy Montserrat replacement - use getTitleFontFamily instead
  @Deprecated('Use getTitleFontFamily(context) instead')
  static const String montserrat = 'Montserrat';
}

/// Extension on BuildContext for easy font access
extension ContextFonts on BuildContext {
  /// Get localized font family for this context
  String get localizedFont => AppFonts.getLocalizedFontFamily(this);
  
  /// Get title font family for this context (replaces Montserrat)
  String get titleFont => AppFonts.getTitleFontFamily(this);
}
