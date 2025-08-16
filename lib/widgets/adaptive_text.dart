import 'package:flutter/material.dart';
import '../utils/arabic_text_style.dart';

/// A custom Text widget that automatically applies appropriate fonts based on text content
/// This widget should be used instead of the standard Text widget throughout the app
class AdaptiveText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const AdaptiveText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  @override
  Widget build(BuildContext context) {
    // Get the current theme's text style
    final defaultStyle = DefaultTextStyle.of(context).style;
    
    // Create adaptive style based on text content
    final adaptiveStyle = ArabicTextStyle.createStyle(
      data,
      fontSize: style?.fontSize ?? defaultStyle.fontSize,
      fontWeight: style?.fontWeight ?? defaultStyle.fontWeight,
      color: style?.color ?? defaultStyle.color,
      height: style?.height ?? defaultStyle.height,
      decoration: style?.decoration ?? defaultStyle.decoration,
      decorationColor: style?.decorationColor ?? defaultStyle.decorationColor,
      letterSpacing: style?.letterSpacing ?? defaultStyle.letterSpacing,
      baseStyle: style,
    );

    return Text(
      data,
      style: adaptiveStyle,
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

/// Rich text version that handles spans with different languages
class AdaptiveRichText extends StatelessWidget {
  final TextSpan textSpan;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const AdaptiveRichText({
    super.key,
    required this.textSpan,
    this.textAlign,
    this.textDirection,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: _processTextSpan(textSpan),
      textAlign: textAlign ?? TextAlign.start,
      textDirection: textDirection,
      softWrap: softWrap ?? true,
      overflow: overflow ?? TextOverflow.clip,
      textScaleFactor: textScaleFactor ?? 1.0,
      maxLines: maxLines,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis ?? TextWidthBasis.parent,
      textHeightBehavior: textHeightBehavior,
    );
  }

  TextSpan _processTextSpan(TextSpan span) {
    if (span.text != null) {
      // Apply adaptive styling to this span
      final adaptiveStyle = ArabicTextStyle.createStyle(
        span.text!,
        fontSize: span.style?.fontSize,
        fontWeight: span.style?.fontWeight,
        color: span.style?.color,
        height: span.style?.height,
        decoration: span.style?.decoration,
        decorationColor: span.style?.decorationColor,
        letterSpacing: span.style?.letterSpacing,
        baseStyle: span.style,
      );

      return TextSpan(
        text: span.text,
        style: adaptiveStyle,
        children: span.children?.map((child) => _processTextSpan(child as TextSpan)).toList(),
        recognizer: span.recognizer,
        semanticsLabel: span.semanticsLabel,
      );
    } else {
      // Process children recursively
      return TextSpan(
        style: span.style,
        children: span.children?.map((child) => _processTextSpan(child as TextSpan)).toList(),
        recognizer: span.recognizer,
        semanticsLabel: span.semanticsLabel,
      );
    }
  }
}

/// Extension to easily convert existing Text widgets
extension TextToAdaptive on Text {
  AdaptiveText toAdaptive() {
    return AdaptiveText(
      data!,
      style: style,
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
