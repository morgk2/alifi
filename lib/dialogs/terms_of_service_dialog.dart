import 'package:flutter/material.dart';
import 'base_dialog.dart';

class TermsOfServiceDialog extends StatelessWidget {
  const TermsOfServiceDialog({super.key});

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
                  'Terms of Service',
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
                      'Welcome to ALIFI! These Terms of Service ("Terms") govern your use of the ALIFI mobile application and website (the "App"), operated by ALIFI LTD ("we," "us," or "our").',
                    ),
                    _buildSection(
                      '1. About ALIFI',
                      'ALIFI is a platform that connects pet lovers and professionals. Key features include:',
                      [
                        'A Marketplace for pet-related products and services',
                        'Pet Adoptions for rehoming animals',
                        'Missing Pet Announcements',
                        'A Map to find missing pets, local pet businesses, and events',
                        'Fundraising for pet-related causes',
                        'User Profiles for rescuers, veterinarians, trainers, and pet owners',
                      ],
                    ),
                    _buildSection(
                      '2. Eligibility',
                      'To use ALIFI, you must be at least 13 years old. If you are under 18, you may use the App only under the supervision of a parent or legal guardian.',
                    ),
                    _buildSection(
                      '3. User Accounts',
                      'To access most features, you must register an account. You agree to:',
                      [
                        'Provide accurate and complete information',
                        'Keep your login credentials secure',
                        'Notify us immediately of any unauthorized access or suspicious activity',
                      ],
                    ),
                    // Add all other sections similarly...
                    _buildSection(
                      '17. Contact Information',
                      'If you have questions or need support, you can reach us at:',
                      [
                        'Company: ALIFI LTD',
                        'Email: support@alifi.app',
                        'Website: www.alifi.app',
                      ],
                    ),
                    _buildSection(
                      '18. Feedback',
                      'We welcome suggestions and ideas. By submitting feedback, you grant ALIFI LTD the right to use it freely without any obligation or compensation.',
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

  Widget _buildSection(String title, String description,
      [List<String>? bullets]) {
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
        ],
      ),
    );
  }
}
