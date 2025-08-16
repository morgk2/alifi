import 'package:flutter/material.dart';

class AdaptiveTheme {
  /// Creates a ThemeData that automatically uses appropriate fonts based on locale
  static ThemeData createTheme(Locale locale) {
    final isArabic = locale.languageCode == 'ar';
    final fontFamily = isArabic ? 'IBMPlexSansArabic' : 'InterDisplay';
    
    return ThemeData(
      fontFamily: fontFamily,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      
      // Custom text theme for Arabic support
      textTheme: _createTextTheme(fontFamily, isArabic),
      
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      
      appBarTheme: AppBarTheme(
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: isArabic ? FontWeight.w600 : FontWeight.w700,
          color: Colors.black,
        ),
      ),
      
      dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: isArabic ? FontWeight.w600 : FontWeight.w700,
          color: Colors.black,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
      
      listTileTheme: ListTileThemeData(
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
        ),
      ),
    );
  }

  /// Creates a custom text theme with appropriate font weights for Arabic
  static TextTheme _createTextTheme(String fontFamily, bool isArabic) {
    // Adjust font weights for Arabic fonts
    final regularWeight = FontWeight.w400;
    final mediumWeight = FontWeight.w500;
    
    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 57,
        fontWeight: regularWeight,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 45,
        fontWeight: regularWeight,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        fontWeight: regularWeight,
      ),
      
      // Headline styles
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: regularWeight,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: regularWeight,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: regularWeight,
      ),
      
      // Title styles
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: mediumWeight,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: mediumWeight,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: mediumWeight,
        letterSpacing: 0.1,
      ),
      
      // Body styles
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: regularWeight,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: regularWeight,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: regularWeight,
        letterSpacing: 0.4,
      ),
      
      // Label styles
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: mediumWeight,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: mediumWeight,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: mediumWeight,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Extension to get adaptive font family based on locale
extension LocaleFont on Locale {
  String get fontFamily {
    switch (languageCode) {
      case 'ar':
        return 'IBMPlexSansArabic';
      case 'en':
      case 'fr':
      default:
        return 'InterDisplay';
    }
  }
  
  bool get isArabic => languageCode == 'ar';
}
