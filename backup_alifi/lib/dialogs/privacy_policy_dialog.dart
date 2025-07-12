import 'package:flutter/material.dart';
import 'base_dialog.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Effective Date: July 8, 2025',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ALIFI LTD ("we," "us," or "our") values your privacy. This Privacy Policy describes how we collect, use, disclose, and protect your personal information when you use the ALIFI mobile application and website (collectively, the "App").',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'By using ALIFI, you agree to the terms of this Privacy Policy. If you do not agree, please do not use the App.',
                    ),
                    _buildSection(
                      '1. Information We Collect',
                      'We collect the following types of information when you use the App:',
                      subsections: {
                        'a. Information You Provide': [
                          'Name, email, phone number',
                          'Location (optional or when reporting/locating pets)',
                          'Profile details (e.g., vet, rescuer, trainer, general user)',
                          'Photos, messages, and pet listings',
                          'Fundraising or missing pet campaign information',
                        ],
                        'b. Automatically Collected Information': [
                          'Device type and operating system',
                          'IP address and general location',
                          'App usage data (e.g., screen views, clicks)',
                          'Error and crash reports',
                        ],
                        'c. Optional Location Data': [
                          'Showing nearby lost pets or businesses',
                          'Mapping adoption and rescue opportunities',
                        ],
                      },
                    ),
                    _buildSection(
                      '2. How We Use Your Information',
                      'We use your information to:',
                      bullets: [
                        'Provide and personalize the App',
                        'Facilitate connections between users',
                        'Display lost pets, adoptions, and listings relevant to your area',
                        'Allow fundraising and campaign sharing',
                        'Improve and troubleshoot the App',
                        'Send notifications or updates (you can opt out)',
                      ],
                    ),
                    _buildSection(
                      '3. How We Share Information',
                      'We do not sell your personal data. We may share your information:',
                      bullets: [
                        'With other users: When you create a public listing, your username and contact info (if shared) are visible.',
                        'With service providers: We use trusted third-party providers for app hosting, analytics, and crash reporting.',
                        'When legally required: To comply with laws, regulations, or legal processes.',
                        'To protect users or enforce policies: If there is suspected fraud, abuse, or safety risk.',
                      ],
                    ),
                    _buildSection(
                      '10. Contact Us',
                      'If you have questions, concerns, or privacy requests, please contact:',
                      bullets: [
                        'ALIFI LTD',
                        '📧 Email: privacy@alifi.app',
                        '🌐 Website: www.alifi.app',
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String description, {
    List<String>? bullets,
    Map<String, List<String>>? subsections,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(description),
          if (bullets != null) ...[
            const SizedBox(height: 8),
            ...bullets.map((bullet) => Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(bullet)),
                    ],
                  ),
                )),
          ],
          if (subsections != null) ...[
            const SizedBox(height: 8),
            ...subsections.entries.map((entry) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    ...entry.value.map((bullet) => Padding(
                          padding: const EdgeInsets.only(left: 24.0, top: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(child: Text(bullet)),
                            ],
                          ),
                        )),
                  ],
                )),
          ],
        ],
      ),
    );
  }
}
