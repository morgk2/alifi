// Example usage of ArabicTextStyle utility for implementing Arabic fonts

import 'package:flutter/material.dart';
import 'arabic_text_style.dart';
import '../l10n/app_localizations.dart';

class ArabicTextUsageExamples extends StatelessWidget {
  const ArabicTextUsageExamples({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: ArabicText.auto(
          'Arabic Font Examples',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Using ArabicText.auto() extension
            ArabicText.auto(
              l10n.aiPetAssistant, // This will be "مساعد الحيوانات الأليفة الذكي" in Arabic
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 16),
            
            // Example 2: Using ArabicTextStyle.bold() method
            Text(
              l10n.selectLanguage, // This will be "Select Language" in English or Arabic equivalent
              style: ArabicTextStyle.bold(
                l10n.selectLanguage,
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Example 3: Using ArabicTextStyle.regular() method
            Text(
              l10n.english, // This will show "English" or "الإنجليزية" in Arabic
              style: ArabicTextStyle.regular(
                l10n.english,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Example 4: Using ArabicTextStyle.createStyle() with custom weights
            Text(
              l10n.arabic, // This will show "العربية"
              style: ArabicTextStyle.createStyle(
                l10n.arabic,
                fontSize: 16,
                fontWeight: FontWeight.w600, // SemiBold
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Example 5: Mixed content - English and Arabic in same widget
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ArabicText.auto(
                  'Settings', // English - will use InterDisplay
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ArabicText.auto(
                  'الإعدادات', // Arabic - will use IBMPlexSansArabic
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Example 6: Usage in buttons and other widgets
            ElevatedButton(
              onPressed: () {},
              child: ArabicText.auto(
                l10n.continueWithGoogle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Example 7: Usage in lists
            ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: ArabicText.auto(
                    l10n.language,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: ArabicText.auto(
                    l10n.arabic,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                ListTile(
                  title: ArabicText.auto(
                    l10n.notifications,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: ArabicText.auto(
                    'Manage your notification preferences',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*
USAGE GUIDELINES:

1. For automatic font detection based on text content:
   - Use ArabicText.auto(text, style: TextStyle(...))
   - This automatically detects Arabic characters and applies IBMPlexSansArabic font

2. For explicit font styling:
   - Use ArabicTextStyle.regular(text, fontSize: 16, color: Colors.black)
   - Use ArabicTextStyle.bold(text, fontSize: 18, color: Colors.blue)
   - Use ArabicTextStyle.medium(text, fontSize: 16)
   - Use ArabicTextStyle.semiBold(text, fontSize: 16)
   - Use ArabicTextStyle.light(text, fontSize: 16)

3. For custom styling:
   - Use ArabicTextStyle.createStyle(text, fontSize: 16, fontWeight: FontWeight.w600, ...)

4. Font Weight Mapping for Arabic:
   - FontWeight.w200 → IBMPlexSansArabic ExtraLight
   - FontWeight.w300 → IBMPlexSansArabic Light  
   - FontWeight.w400 → IBMPlexSansArabic Regular
   - FontWeight.w500 → IBMPlexSansArabic Medium
   - FontWeight.w600 → IBMPlexSansArabic SemiBold
   - FontWeight.w700+ → IBMPlexSansArabic Bold

5. For non-Arabic text (English, French):
   - Uses InterDisplay font family
   - All font weights are preserved as-is

6. Best Practices:
   - Always pass the actual text string to the style methods for proper detection
   - Use localized strings from AppLocalizations for automatic language detection
   - Prefer ArabicText.auto() for simplicity in most cases
   - Use explicit methods (regular, bold, etc.) when you need specific font weights
*/




