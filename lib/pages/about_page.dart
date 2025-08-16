import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          l10n.about,
          style: TextStyle(fontFamily: context.titleFont,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // App Logo and Name
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    // App Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo_cropped.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // App Name
                    Text(
                      'Alifi',
                      style: TextStyle(fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFamily: context.titleFont,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // App Tagline
                    Text(
                      l10n.yourPetsFavouriteApp,
                      style: TextStyle(fontSize: 16,
                        color: Colors.grey[600],
                        fontFamily: context.titleFont,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Version
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.version,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // App Description
            _buildInfoSection(
              title: l10n.aboutAlifi,
              children: [
                _InfoTile(
                  icon: Icons.info_outline,
                  iconColor: Colors.blue,
                  title: l10n.description,
                  subtitle: l10n.alifiIsAComprehensivePetCarePlatform,
                ),
                _InfoTile(
                  icon: Icons.verified_outlined,
                  iconColor: Colors.green,
                  title: l10n.verifiedServices,
                  subtitle: l10n.allVeterinariansAndPetStoresOnOurPlatformAreVerified,
                ),
                _InfoTile(
                  icon: Icons.security,
                  iconColor: Colors.orange,
                  title: l10n.secureAndPrivate,
                  subtitle: l10n.yourDataAndYourPetsInformationAreProtected,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Contact & Support
            _buildInfoSection(
              title: l10n.contactAndSupport,
              children: [
                _InfoTile(
                  icon: Icons.email_outlined,
                  iconColor: Colors.blue,
                  title: l10n.emailSupport,
                  subtitle: 'support@alifi.com',
                  onTap: () {
                    // TODO: Open email client
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.emailSupportComingSoon),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  iconColor: Colors.green,
                  title: l10n.phoneSupport,
                  subtitle: '+1 (555) 123-4567',
                  onTap: () {
                    // TODO: Open phone dialer
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.phoneSupportComingSoon),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _InfoTile(
                  icon: Icons.web_outlined,
                  iconColor: Colors.purple,
                  title: l10n.website,
                  subtitle: 'www.alifi.com',
                  onTap: () {
                    // TODO: Open website
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.websiteComingSoon),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Legal
            _buildInfoSection(
              title: l10n.legal,
              children: [
                _InfoTile(
                  icon: Icons.description_outlined,
                  iconColor: Colors.grey,
                  title: l10n.termsOfService,
                  subtitle: l10n.readOurTermsAndConditions,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.termsOfServiceComingSoon),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _InfoTile(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: Colors.grey,
                  title: l10n.privacyPolicy,
                  subtitle: l10n.learnAboutOurPrivacyPractices,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.privacyPolicyComingSoon),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Developer Info
            _buildInfoSection(
              title: l10n.developer,
              children: [
                _InfoTile(
                  icon: Icons.code_outlined,
                  iconColor: Colors.indigo,
                  title: l10n.developedBy,
                  subtitle: l10n.alifiDevelopmentTeam,
                ),
                _InfoTile(
                  icon: Icons.copyright_outlined,
                  iconColor: Colors.grey,
                  title: l10n.copyright,
                  subtitle: l10n.copyrightText,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: context.localizedFont,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
} 