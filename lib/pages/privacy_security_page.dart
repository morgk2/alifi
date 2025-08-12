import 'package:flutter/material.dart';
import '../widgets/ios_toggle.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          l10n.privacyAndSecurity,
          style: const TextStyle(
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
              title: l10n.privacy,
              children: [
                _SettingsTile(
                  icon: Icons.location_on_outlined,
                  iconColor: Colors.blue,
                  title: l10n.locationSharing,
                  subtitle: l10n.allowAppToAccessYourLocation,
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
                  title: l10n.dataAnalytics,
                  subtitle: l10n.helpUsImproveBySharingAnonymousUsageData,
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
                  title: l10n.profileVisibility,
                  subtitle: l10n.controlWhoCanSeeYourProfileInformation,
                  onTap: () {
                    _showProfileVisibilityDialog();
                  },
                ),
                _SettingsTile(
                  icon: Icons.delete_outline,
                  iconColor: Colors.red,
                  title: l10n.dataAndPrivacy,
                  subtitle: l10n.manageYourDataAndPrivacySettings,
                  onTap: () {
                    _showDataPrivacyDialog();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notifications
            _buildSettingsSection(
              title: l10n.notifications,
              children: [
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  iconColor: Colors.blue,
                  title: l10n.pushNotifications,
                  subtitle: l10n.receiveNotificationsAboutAppointmentsAndUpdates,
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
                  title: l10n.emailNotifications,
                  subtitle: l10n.receiveImportantUpdatesViaEmail,
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
                  title: l10n.notificationPreferences,
                  subtitle: l10n.customizeWhatNotificationsYouReceive,
                  onTap: () {
                    _showNotificationPreferencesDialog();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Security
            _buildSettingsSection(
              title: l10n.security,
              children: [
                _SettingsTile(
                  icon: Icons.fingerprint_outlined,
                  iconColor: Colors.blue,
                  title: l10n.biometricAuthentication,
                  subtitle: l10n.useFingerprintOrFaceIdToUnlockTheApp,
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
                  title: l10n.twoFactorAuthentication,
                  subtitle: l10n.addAnExtraLayerOfSecurityToYourAccount,
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
                  title: l10n.changePassword,
                  subtitle: l10n.updateYourAccountPassword,
                  onTap: () {
                    _showChangePasswordDialog();
                  },
                ),
                _SettingsTile(
                  icon: Icons.devices_outlined,
                  iconColor: Colors.grey,
                  title: l10n.activeSessions,
                  subtitle: l10n.manageDevicesLoggedIntoYourAccount,
                  onTap: () {
                    _showActiveSessionsDialog();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Data & Storage
            _buildSettingsSection(
              title: l10n.dataAndStorage,
              children: [
                _SettingsTile(
                  icon: Icons.storage_outlined,
                  iconColor: Colors.blue,
                  title: l10n.storageUsage,
                  subtitle: l10n.manageAppDataAndCache,
                  onTap: () {
                    _showStorageUsageDialog();
                  },
                ),
                _SettingsTile(
                  icon: Icons.download_outlined,
                  iconColor: Colors.green,
                  title: l10n.exportData,
                  subtitle: l10n.downloadACopyOfYourData,
                  onTap: () {
                    _showExportDataDialog();
                  },
                ),
                _SettingsTile(
                  icon: Icons.delete_forever_outlined,
                  iconColor: Colors.red,
                  title: l10n.deleteAccount,
                  subtitle: l10n.permanentlyDeleteYourAccountAndData,
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileVisibility),
        content: Text(l10n.chooseWhoCanSeeYourProfileInformation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDataPrivacyDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dataAndPrivacy),
        content: Text(l10n.manageYourDataAndPrivacySettings),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showNotificationPreferencesDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.notificationPreferences),
        content: Text(l10n.customizeWhatNotificationsYouReceive),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changePassword),
        content: Text(l10n.enterYourNewPassword),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showActiveSessionsDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.activeSessions),
        content: Text(l10n.manageDevicesLoggedIntoYourAccount),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showStorageUsageDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.storageUsage),
        content: Text(l10n.manageAppDataAndCache),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exportData),
        content: Text(l10n.downloadACopyOfYourData),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.export),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.thisActionCannotBeUndoneAllYourDataWillBePermanentlyDeleted),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
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
                      fontWeight: FontWeight.w400,
                      fontFamily: 'InterDisplay',
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