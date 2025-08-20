import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/user_preferences_service.dart';
import '../widgets/ios_toggle.dart';
import '../utils/app_fonts.dart';

class DisplaySettingsPage extends StatelessWidget {
  const DisplaySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          l10n.display,
          style: TextStyle(fontFamily: context.titleFont,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/images/back_icon.png',
              width: 24,
              height: 24,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              
              // Interface Section
              _buildSettingsSection(
                context: context,
                title: l10n.interface,
                children: [
                  Consumer<UserPreferencesService>(
                    builder: (context, userPreferences, child) {
                      return _DisplaySettingsTile(
                        icon: CupertinoIcons.rectangle_on_rectangle,
                        iconColor: Colors.blue,
                        title: l10n.useBlurEffectForTabBar,
                        subtitle: l10n.enableGlassLikeBlurEffectOnNavigationBar,
                        trailing: IOSToggle(
                          key: ValueKey(userPreferences.tabBarBlurEnabled),
                          value: userPreferences.tabBarBlurEnabled,
                          onChanged: (value) async {
                            await userPreferences.setTabBarBlurEnabled(value);
                          },
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E5E5)),
                  Consumer<UserPreferencesService>(
                    builder: (context, userPreferences, child) {
                      return _DisplaySettingsTile(
                        icon: CupertinoIcons.drop_triangle,
                        iconColor: Colors.purple, // Always show as available
                        title: "Glass Distortion Effect for Tab bar", // Updated title
                        subtitle: "Enable custom glass distortion effect that bends content for realistic glass appearance",
                        trailing: IOSToggle(
                          key: ValueKey(userPreferences.tabBarLiquidGlassEnabled),
                          value: userPreferences.tabBarLiquidGlassEnabled, // Always functional
                          onChanged: (value) async {
                            await userPreferences.setTabBarLiquidGlassEnabled(value);
                          },
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E5E5)),
                  Consumer<UserPreferencesService>(
                    builder: (context, userPreferences, child) {
                      return _DisplaySettingsTile(
                        icon: CupertinoIcons.rectangle_fill,
                        iconColor: Colors.green,
                        title: l10n.useSolidColorForTabBar,
                        subtitle: l10n.enableSolidColorOnNavigationBar,
                        trailing: IOSToggle(
                          key: ValueKey(userPreferences.tabBarSolidColorEnabled),
                          value: userPreferences.tabBarSolidColorEnabled,
                          onChanged: (value) async {
                            await userPreferences.setTabBarSolidColorEnabled(value);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Info section explaining the blur effect
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.info_circle,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.whenDisabledTabBarWillHaveSolidWhiteBackground,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Info section explaining the enhanced glass effect
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.info_circle,
                      color: Colors.purple,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Custom glass distortion shader that subtly bends and warps content inside the navigation bar to simulate realistic glass refraction. Creates an authentic glass-like appearance with subtle wave distortions.",
                        style: TextStyle(
                          color: Colors.purple.shade700,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Info section explaining the solid color effect
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.info_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.whenDisabledSolidColorTabBarWillHaveEffect,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              title,
              style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontFamily: context.titleFont,
              ),
            ),
          ),
        Container(
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

class _DisplaySettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _DisplaySettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 18,
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
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: context.localizedFont,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontFamily: context.localizedFont,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
