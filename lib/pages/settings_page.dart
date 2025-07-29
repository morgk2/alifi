import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../dialogs/report_problem_dialog.dart';
import 'edit_profile_page.dart';
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
    
    // Force rebuild when locale changes
    final currentLocale = localeNotifierState?.localeNotifier.locale ?? const Locale('en');
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildSection(
              title: 'App Settings',
              children: [
                _SettingsTile(
                  icon: Icons.language,
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
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Support',
              children: [
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  onTap: () {
                    // TODO: Implement help center
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Coming soon!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.bug_report_outlined,
                  title: 'Report a Bug',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ReportProblemDialog(),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.star_border,
                  title: 'Rate the App',
                  onTap: () {
                    // TODO: Implement app store link
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
            if (authService.currentUser?.isAdmin ?? false) // Add admin check
              _buildSection(
                title: 'Admin Tools',
                children: [
                  _SettingsTile(
                    icon: Icons.add_shopping_cart,
                    title: 'Add AliExpress Product',
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
                    title: 'Bulk Import Products',
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
                    title: 'User Management',
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
            if (authService.isAuthenticated)
              _buildSection(
                title: '',
                children: [
                  _SettingsTile(
                    icon: Icons.logout,
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
            _buildSection(
              title: 'Debug Info',
              children: [
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'Current Locale',
                  subtitle: '${currentLocale.languageCode} (${currentLocale.countryCode ?? 'no country'})',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.translate,
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

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[200]!),
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: titleColor ?? Colors.black,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
      onTap: onTap,
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