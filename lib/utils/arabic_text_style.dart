import 'package:flutter/material.dart';

class ArabicTextStyle {
  /// Detects if text contains Arabic characters
  static bool isArabicText(String text) {
    if (text.isEmpty) return false;
    
    // Arabic Unicode range: U+0600 to U+06FF
    // Arabic Supplement: U+0750 to U+077F
    // Arabic Extended-A: U+08A0 to U+08FF
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    return arabicRegex.hasMatch(text);
  }

  /// Creates a TextStyle with appropriate font family based on text content
  /// Uses IBMPlexSansArabic for Arabic text, InterDisplay for other languages
  static TextStyle createStyle(
    String text, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? letterSpacing,
    TextStyle? baseStyle,
  }) {
    final isArabic = isArabicText(text);
    final fontFamily = isArabic ? 'IBMPlexSansArabic' : 'InterDisplay';
    
    // For Arabic text, adjust font weights to match available weights
    FontWeight? adjustedFontWeight = fontWeight;
    if (isArabic && fontWeight != null) {
      // Map common font weights to available IBM Plex Sans Arabic weights
      if (fontWeight == FontWeight.w100 || fontWeight == FontWeight.w200) {
        adjustedFontWeight = FontWeight.w200; // ExtraLight
      } else if (fontWeight == FontWeight.w300) {
        adjustedFontWeight = FontWeight.w300; // Light
      } else if (fontWeight == FontWeight.w400 || fontWeight == FontWeight.normal) {
        adjustedFontWeight = FontWeight.w400; // Regular
      } else if (fontWeight == FontWeight.w500) {
        adjustedFontWeight = FontWeight.w500; // Medium
      } else if (fontWeight == FontWeight.w600) {
        adjustedFontWeight = FontWeight.w600; // SemiBold
      } else if (fontWeight == FontWeight.w700 || fontWeight == FontWeight.bold || 
                 fontWeight == FontWeight.w800 || fontWeight == FontWeight.w900) {
        adjustedFontWeight = FontWeight.w700; // Bold
      } else {
        adjustedFontWeight = fontWeight;
      }
    }

    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: adjustedFontWeight,
      color: color,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      letterSpacing: letterSpacing,
    ).merge(baseStyle);
  }

  /// Convenience method for regular text
  static TextStyle regular(
    String text, {
    double? fontSize,
    Color? color,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? letterSpacing,
  }) {
    return createStyle(
      text,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      letterSpacing: letterSpacing,
    );
  }

  /// Convenience method for bold text
  static TextStyle bold(
    String text, {
    double? fontSize,
    Color? color,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? letterSpacing,
  }) {
    return createStyle(
      text,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      letterSpacing: letterSpacing,
    );
  }

  /// Convenience method for medium weight text
  static TextStyle medium(
    String text, {
    double? fontSize,
    Color? color,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? letterSpacing,
  }) {
    return createStyle(
      text,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      letterSpacing: letterSpacing,
    );
  }

  /// Convenience method for semibold text
  static TextStyle semiBold(
    String text, {
    double? fontSize,
    Color? color,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? letterSpacing,
  }) {
    return createStyle(
      text,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      letterSpacing: letterSpacing,
    );
  }

  /// Convenience method for light text
  static TextStyle light(
    String text, {
    double? fontSize,
    Color? color,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? letterSpacing,
  }) {
    return createStyle(
      text,
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      color: color,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      letterSpacing: letterSpacing,
    );
  }
}

/// Extension on Text widget to automatically apply appropriate font
extension ArabicText on Text {
  /// Creates a Text widget with automatic Arabic font detection
  static Text auto(
    String text, {
    Key? key,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    double? textScaleFactor,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
  }) {
    final autoStyle = ArabicTextStyle.createStyle(
      text,
      fontSize: style?.fontSize,
      fontWeight: style?.fontWeight,
      color: style?.color,
      height: style?.height,
      decoration: style?.decoration,
      decorationColor: style?.decorationColor,
      letterSpacing: style?.letterSpacing,
      baseStyle: style,
    );

    return Text(
      text,
      key: key,
      style: autoStyle,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}
