// Export file for adaptive font utilities
// Import this file to access all adaptive font functionality

export 'arabic_text_style.dart';
export 'adaptive_theme.dart';
export '../widgets/adaptive_text.dart';

// Re-export the ArabicText extension for easy access
import '../widgets/adaptive_text.dart';

// Global typedef for easier usage
typedef AppText = AdaptiveText;

/// Helper class for quick font styling throughout the app
class AppTextStyles {
  /// Get font family based on text content
  static String getFontFamily(String text) {
    final isArabic = text.isNotEmpty && 
        RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]').hasMatch(text);
    return isArabic ? 'IBMPlexSansArabic' : 'InterDisplay';
  }
  
  /// Check if text contains Arabic characters
  static bool isArabic(String text) {
    return text.isNotEmpty && 
        RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]').hasMatch(text);
  }
}







