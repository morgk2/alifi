import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../dialogs/report_problem_dialog.dart';
import 'edit_profile_page.dart';
import 'about_page.dart';
import 'privacy_security_page.dart';
import 'help_center_page.dart';
import 'admin/add_product_page.dart';
import 'admin/bulk_import_page.dart';
import 'admin/user_management_page.dart';
import '../utils/locale_notifier.dart';
import '../l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final localeNotifierState = LocaleNotifier.of(context);
    final user = authService.currentUser;
    
    // Force rebuild when locale changes
    final currentLocale = localeNotifierState?.localeNotifier.locale ?? const Locale('en');
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Montserrat',
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
            const SizedBox(height: 16),
            
            // User Profile Card
            if (user != null) _buildUserProfileCard(user),
            
            const SizedBox(height: 24),
            
            // App Settings Section
            _buildSettingsSection(
              title: 'App Settings',
              children: [
                _SettingsTile(
                  icon: Icons.language,
                  iconColor: Colors.blue,
                  title: 'Language',
                  subtitle: _getLanguageName(context),
                  onTap: () async {
                    final selected = await showDialog<Locale>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Select Language'),
                        children: [
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, const Locale('en'));
                            },
                            child: const Text('English'),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, const Locale('ar'));
                            },
                            child: const Text('العربية'),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, const Locale('fr'));
                            },
                            child: const Text('Français'),
                          ),
                        ],
                      ),
                    );
                    if (selected != null) {
                      print('Language selected: ${selected.languageCode}');
                      final localeNotifierState = LocaleNotifier.of(context);
                      if (localeNotifierState != null) {
                        localeNotifierState.changeLocale(selected);
                        print('Locale changed to: ${selected.languageCode}');
                      } else {
                        print('ERROR: LocaleNotifier state is null!');
                      }
                    }
                  },
                ),
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  iconColor: Colors.purple,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: false, // TODO: Implement dark mode
                    onChanged: (value) {
                      // TODO: Implement dark mode toggle
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coming soon!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  onTap: () {}, // Empty onTap since we're using the switch
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  iconColor: Colors.orange,
                  title: 'Notifications',
                  subtitle: 'Manage your notifications',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Coming soon!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Account Section
            _buildSettingsSection(
              title: 'Account',
              children: [
                _SettingsTile(
                  icon: Icons.person_outline,
                  iconColor: Colors.green,
                  title: 'Edit Profile',
                  subtitle: 'Update your information',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.security,
                  iconColor: Colors.red,
                  title: 'Privacy & Security',
                  subtitle: 'Manage your privacy settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacySecurityPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Support Section
            _buildSettingsSection(
              title: 'Support',
              children: [
                _SettingsTile(
                  icon: Icons.help_outline,
                  iconColor: Colors.blue,
                  title: 'Help Center',
                  subtitle: 'Get help and support',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpCenterPage(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.bug_report_outlined,
                  iconColor: Colors.orange,
                  title: 'Report a Bug',
                  subtitle: 'Help us improve the app',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ReportProblemDialog(),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.star_border,
                  iconColor: Colors.amber,
                  title: 'Rate the App',
                  subtitle: 'Share your feedback',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Coming soon!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  iconColor: Colors.grey,
                  title: 'About',
                  subtitle: 'App version and info',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Admin Tools Section (only for admins)
            if (authService.currentUser?.isAdmin ?? false)
              _buildSettingsSection(
                title: 'Admin Tools',
                children: [
                  _SettingsTile(
                    icon: Icons.add_shopping_cart,
                    iconColor: Colors.green,
                    title: 'Add AliExpress Product',
                    subtitle: 'Add new products to the store',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddProductPage(),
                        ),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.upload_file,
                    iconColor: Colors.blue,
                    title: 'Bulk Import Products',
                    subtitle: 'Import multiple products at once',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BulkImportPage(),
                        ),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.manage_accounts,
                    iconColor: Colors.purple,
                    title: 'User Management',
                    subtitle: 'Manage user accounts',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserManagementPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            
            const SizedBox(height: 24),
            
            // Sign Out Section
            if (authService.isAuthenticated)
              _buildSettingsSection(
                title: '',
                children: [
                  _SettingsTile(
                    icon: Icons.logout,
                    iconColor: Colors.red,
                    title: 'Sign Out',
                    titleColor: Colors.red,
                    onTap: () async {
                      await authService.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            
            const SizedBox(height: 24),
            
            // Debug Info Section (only in debug mode)
            if (authService.currentUser?.isAdmin ?? false)
              _buildSettingsSection(
                title: 'Debug Info',
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline,
                    iconColor: Colors.grey,
                    title: 'Current Locale',
                    subtitle: '${currentLocale.languageCode} (${currentLocale.countryCode ?? 'no country'})',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.translate,
                    iconColor: Colors.grey,
                    title: 'Localized Text Test',
                    subtitle: AppLocalizations.of(context)?.myPets ?? 'My Pets (fallback)',
                    onTap: () {},
                  ),
                ],
              ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(User user) {
    return Container(
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
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Profile Picture
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey[200],
              ),
              child: user.photoURL != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        user.photoURL!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey[600],
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.grey[600],
                    ),
            ),
            
            const SizedBox(width: 16),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? user.email,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Account Type Badge
                  if (user.accountType != 'normal') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getAccountTypeColor(user.accountType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getAccountTypeColor(user.accountType).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getAccountTypeLabel(user.accountType),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getAccountTypeColor(user.accountType),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Edit Button
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
              icon: Icon(
                Icons.edit_outlined,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
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

  Color _getAccountTypeColor(String accountType) {
    switch (accountType) {
      case 'vet':
        return Colors.blue;
      case 'store':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getAccountTypeLabel(String accountType) {
    switch (accountType) {
      case 'vet':
        return 'Veterinarian';
      case 'store':
        return 'Store Owner';
      default:
        return 'User';
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.titleColor,
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
            // Icon
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
            
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? Colors.black,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Trailing Widget
            trailing ??
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

String _getLanguageName(BuildContext context) {
  final localeNotifierState = LocaleNotifier.of(context);
  final locale = localeNotifierState?.localeNotifier.locale ?? const Locale('en');
  
  switch (locale.languageCode) {
    case 'ar':
      return 'العربية';
    case 'fr':
      return 'Français';
    case 'en':
    default:
      return 'English';
  }
} 