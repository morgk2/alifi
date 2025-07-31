import 'package:flutter/material.dart';
import '../widgets/ios_toggle.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool _locationSharing = true;
  bool _dataAnalytics = false;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _biometricAuth = false;
  bool _twoFactorAuth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Privacy & Security',
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
            const SizedBox(height: 24),
            
            // Privacy Settings
            _buildSettingsSection(
              title: 'Privacy',
              children: [
                _SettingsTile(
                  icon: Icons.location_on_outlined,
                  iconColor: Colors.blue,
                  title: 'Location Sharing',
                  subtitle: 'Allow app to access your location for nearby services',
                  trailing: IOSToggle(
                    value: _locationSharing,
                    onChanged: (value) {
                      setState(() {
                        _locationSharing = value;
                      });
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Icons.analytics_outlined,
                  iconColor: Colors.green,
                  title: 'Data Analytics',
                  subtitle: 'Help us improve by sharing anonymous usage data',
                  trailing: IOSToggle(
                    value: _dataAnalytics,
                    onChanged: (value) {
                      setState(() {
                        _dataAnalytics = value;
                      });
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Icons.visibility_outlined,
                  iconColor: Colors.orange,
                  title: 'Profile Visibility',
                  subtitle: 'Control who can see your profile information',
                  onTap: () {
                    _showProfileVisibilityDialog();
                  },
                ),
                _SettingsTile(
                  icon: Icons.delete_outline,
                  iconColor: Colors.red,
                  title: 'Data & Privacy',
                  subtitle: 'Manage your data and privacy settings',
                  onTap: () {
                    _showDataPrivacyDialog();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notifications
            _buildSettingsSection(
              title: 'Notifications',
              children: [
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  iconColor: Colors.blue,
                  title: 'Push Notifications',
                  subtitle: 'Receive notifications about appointments and updates',
                  trailing: IOSToggle(
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Icons.email_outlined,
                  iconColor: Colors.green,
                  title: 'Email Notifications',
                  subtitle: 'Receive important updates via email',
                  trailing: IOSToggle(
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Icons.settings_outlined,
                  iconColor: Colors.purple,
                  title: 'Notification Preferences',
                  subtitle: 'Customize what notifications you receive',
                  onTap: () {
                    _showNotificationPreferencesDialog();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Security
            _buildSettingsSection(
              title: 'Security',
              children: [
                _SettingsTile(
                  icon: Icons.fingerprint_outlined,
                  iconColor: Colors.blue,
                  title: 'Biometric Authentication',
                  subtitle: 'Use fingerprint or face ID to unlock the app',
                  trailing: IOSToggle(
                    value: _biometricAuth,
                    onChanged: (value) {
                      setState(() {
                        _biometricAuth = value;
                      });
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Icons.security_outlined,
                  iconColor: Colors.orange,
                  title: 'Two-Factor Authentication',
                  subtitle: 'Add an extra layer of security to your account',
                  trailing: IOSToggle(
                    value: _twoFactorAuth,
                    onChanged: (value) {
                      setState(() {
                        _twoFactorAuth = value;
                      });
                    },
                  ),
                ),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  iconColor: Colors.red,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () {
                    _showChangePasswordDialog();
                  },
                ),
                _SettingsTile(
                  icon: Icons.devices_outlined,
                  iconColor: Colors.grey,
                  title: 'Active Sessions',
                  subtitle: 'Manage devices logged into your account',
                  onTap: () {
                    _showActiveSessionsDialog();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Data & Storage
            _buildSettingsSection(
              title: 'Data & Storage',
              children: [
                _SettingsTile(
                  icon: Icons.storage_outlined,
                  iconColor: Colors.blue,
                  title: 'Storage Usage',
                  subtitle: 'Manage app data and cache',
                  onTap: () {
                    _showStorageUsageDialog();
                  },
                ),
                _SettingsTile(
                  icon: Icons.download_outlined,
                  iconColor: Colors.green,
                  title: 'Export Data',
                  subtitle: 'Download a copy of your data',
                  onTap: () {
                    _showExportDataDialog();
                  },
                ),
                _SettingsTile(
                  icon: Icons.delete_forever_outlined,
                  iconColor: Colors.red,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account and data',
                  onTap: () {
                    _showDeleteAccountDialog();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
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

  void _showProfileVisibilityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Visibility'),
        content: const Text('Choose who can see your profile information.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDataPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data & Privacy'),
        content: const Text('Manage your data and privacy settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNotificationPreferencesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Preferences'),
        content: const Text('Customize what notifications you receive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('Enter your new password.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Active Sessions'),
        content: const Text('Manage devices logged into your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showStorageUsageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Usage'),
        content: const Text('Manage app data and cache.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Download a copy of your data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone. All your data will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
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
            trailing ??
                (onTap != null
                    ? Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                        size: 20,
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
} 