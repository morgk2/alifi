import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/push_notification_service.dart';
import '../dialogs/notification_permission_dialog.dart';
import '../models/notification.dart';
import '../widgets/custom_snackbar.dart';
import '../l10n/app_localizations.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final PushNotificationService _notificationService = PushNotificationService();
  bool _notificationsEnabled = false;
  bool _isLoading = false;
  
  // Notification type preferences
  Map<NotificationType, bool> _notificationPreferences = {};
  
  // General notification settings
  bool _emailNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _initializeNotificationPreferences();
    _checkNotificationStatus();
  }

  void _initializeNotificationPreferences() {
    for (NotificationType type in NotificationType.values) {
      _notificationPreferences[type] = true;
    }
  }

  Future<void> _checkNotificationStatus() async {
    final enabled = await _notificationService.areNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Save to database or local storage
      // This would typically save to Firestore or SharedPreferences
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate save
      
      if (mounted) {
        CustomSnackBarHelper.showSuccess(
          context,
          AppLocalizations.of(context)!.notificationPreferencesSavedSuccessfully,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBarHelper.showError(
          context,
          AppLocalizations.of(context)!.errorSavingPreferences(e),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _testNotification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _notificationService.testNotification();
      if (mounted) {
        CustomSnackBarHelper.showSuccess(
          context,
          AppLocalizations.of(context)!.testNotificationSent,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBarHelper.showError(
          context,
          AppLocalizations.of(context)!.errorSendingTestNotification(e),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final granted = await _notificationService.requestPermissionAgain();
      setState(() {
        _notificationsEnabled = granted;
      });

      if (granted) {
        if (mounted) {
          CustomSnackBarHelper.showSuccess(
            context,
            AppLocalizations.of(context)!.notificationsEnabledSuccessfully,
          );
        }
      } else {
        if (mounted) {
          _showPermissionDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBarHelper.showError(
          context,
          AppLocalizations.of(context)!.errorRequestingPermission(e),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => const NotificationPermissionDialog(),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _quietHoursStart : _quietHoursEnd,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _quietHoursStart = picked;
        } else {
          _quietHoursEnd = picked;
        }
      });
    }
  }

  Widget _buildNotificationTypeTile(NotificationType type, String title, String subtitle, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
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
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: CupertinoSwitch(
          value: _notificationPreferences[type] ?? true,
          onChanged: (value) {
            setState(() {
              _notificationPreferences[type] = value;
            });
          },
          activeColor: Colors.orange,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.notificationSettings,
          style: const TextStyle(
            fontFamily: 'Inter',
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
            child: Icon(
              CupertinoIcons.chevron_left,
              color: Colors.black,
              size: 24,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main notification toggle
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.bell_fill,
                        color: _notificationsEnabled ? Colors.orange : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.pushNotifications,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              _notificationsEnabled 
                                ? AppLocalizations.of(context)!.notificationsEnabled
                                : AppLocalizations.of(context)!.notificationsDisabled,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: _notificationsEnabled ? Colors.green : Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoSwitch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          if (value) {
                            _requestPermission();
                          } else {
                            // Show dialog to disable
                            _showDisableDialog();
                          }
                        },
                        activeColor: Colors.orange,
                      ),
                    ],
                  ),
                  if (!_notificationsEnabled) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _requestPermission,
                        icon: const Icon(CupertinoIcons.settings),
                        label: Text(
                          AppLocalizations.of(context)!.enableNotifications,
                          style: const TextStyle(fontFamily: 'Inter'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // General Settings Section
            _buildSectionHeader(AppLocalizations.of(context)!.generalSettings, CupertinoIcons.gear),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    AppLocalizations.of(context)!.sound,
                    AppLocalizations.of(context)!.playSoundForNotifications,
                    CupertinoIcons.speaker_2,
                    Colors.blue,
                    _soundEnabled,
                    (value) => setState(() => _soundEnabled = value),
                  ),
                  _buildSettingTile(
                    AppLocalizations.of(context)!.vibration,
                    AppLocalizations.of(context)!.vibrateDeviceForNotifications,
                    CupertinoIcons.device_phone_portrait,
                    Colors.green,
                    _vibrationEnabled,
                    (value) => setState(() => _vibrationEnabled = value),
                  ),
                  _buildSettingTile(
                    AppLocalizations.of(context)!.emailNotifications,
                    AppLocalizations.of(context)!.receiveNotificationsViaEmail,
                    CupertinoIcons.mail,
                    Colors.purple,
                    _emailNotifications,
                    (value) => setState(() => _emailNotifications = value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quiet Hours Section
            _buildSectionHeader(AppLocalizations.of(context)!.quietHours, CupertinoIcons.moon),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    AppLocalizations.of(context)!.enableQuietHours,
                    AppLocalizations.of(context)!.muteNotificationsDuringSpecifiedHours,
                    CupertinoIcons.moon_fill,
                    Colors.indigo,
                    _quietHoursEnabled,
                    (value) => setState(() => _quietHoursEnabled = value),
                  ),
                  if (_quietHoursEnabled) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                                                       Expanded(
                                 child: _buildTimeSelector(
                                   AppLocalizations.of(context)!.startTime,
                                   _quietHoursStart,
                                   () => _selectTime(context, true),
                                 ),
                               ),
                               const SizedBox(width: 16),
                               Expanded(
                                 child: _buildTimeSelector(
                                   AppLocalizations.of(context)!.endTime,
                                   _quietHoursEnd,
                                   () => _selectTime(context, false),
                                 ),
                               ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notification Types Section
            _buildSectionHeader(AppLocalizations.of(context)!.notificationTypes, CupertinoIcons.list_bullet),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildNotificationTypeTile(
                    NotificationType.chatMessage,
                    AppLocalizations.of(context)!.chatMessages,
                    AppLocalizations.of(context)!.newMessagesFromOtherUsers,
                    CupertinoIcons.chat_bubble_text,
                    Colors.blue,
                  ),
                  _buildNotificationTypeTile(
                    NotificationType.orderPlaced,
                    AppLocalizations.of(context)!.orderUpdates,
                    AppLocalizations.of(context)!.orderStatusChangesAndUpdates,
                    CupertinoIcons.cart,
                    Colors.green,
                  ),
                  _buildNotificationTypeTile(
                    NotificationType.appointmentRequest,
                    AppLocalizations.of(context)!.appointments,
                    AppLocalizations.of(context)!.appointmentRequestsAndReminders,
                    CupertinoIcons.calendar,
                    Colors.orange,
                  ),
                  _buildNotificationTypeTile(
                    NotificationType.follow,
                    AppLocalizations.of(context)!.socialActivity,
                    AppLocalizations.of(context)!.newFollowersAndSocialInteractions,
                    CupertinoIcons.person_add,
                    Colors.purple,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

                               // Test Section
                   _buildSectionHeader(AppLocalizations.of(context)!.testNotifications, CupertinoIcons.lab_flask),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testNotification,
                      icon: const Icon(CupertinoIcons.bell),
                      label: Text(
                        AppLocalizations.of(context)!.sendTestNotification,
                        style: const TextStyle(fontFamily: 'Inter'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.testNotificationsDescription,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : Text(
                        AppLocalizations.of(context)!.savePreferences,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(String label, TimeOfDay time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          AppLocalizations.of(context)!.disableNotificationsTitle,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.disableNotificationsDescription,
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(fontFamily: 'Inter'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _notificationsEnabled = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              AppLocalizations.of(context)!.disable,
              style: const TextStyle(fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );
  }
}
