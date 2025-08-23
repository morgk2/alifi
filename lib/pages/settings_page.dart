import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../models/user.dart';
import '../dialogs/report_problem_dialog.dart';
import 'edit_profile_page.dart';
import 'about_page.dart';
import 'privacy_security_page.dart';
import 'help_center_page.dart';
import 'admin/add_product_page.dart';
import 'admin/bulk_import_page.dart';
import 'admin/user_management_page.dart';
import 'subscription_management_page.dart';
import 'notification_settings_page.dart';
import 'display_settings_page.dart';
import '../utils/locale_notifier.dart';
import '../utils/arabic_text_style.dart';
import '../utils/app_fonts.dart';
import '../l10n/app_localizations.dart';
import '../widgets/ios_toggle.dart';
// import removed: not used
import '../services/currency_service.dart';
import '../services/database_service.dart';
import '../services/user_preferences_service.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/cache_stats_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? _subscriptionData;
  bool _isLoadingSubscription = false;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    
    if (user == null || (user.accountType != 'vet' && user.accountType != 'store')) return;

    setState(() {
      _isLoadingSubscription = true;
    });

    try {
      final subscription = await DatabaseService().getSubscription(user.id);
      if (mounted) {
        setState(() {
          _subscriptionData = subscription;
          _isLoadingSubscription = false;
        });
      }
    } catch (e) {
      print('Error loading subscription data: $e');
      if (mounted) {
        setState(() {
          _isLoadingSubscription = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final localeNotifierState = LocaleNotifier.of(context);
    final user = authService.currentUser;
    
    // Force rebuild when locale changes
    final currentLocale = localeNotifierState?.localeNotifier.locale ?? const Locale('en');
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(), // Bouncy scroll physics
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text(
                AppLocalizations.of(context)!.settings,
                style: TextStyle(
                  fontFamily: context.titleFont,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              centerTitle: true,
              pinned: true, // Keep app bar visible when scrolling
              floating: false, // Don't show app bar when scrolling up
              snap: false, // Don't snap app bar
              forceElevated: false, // Never add elevation/shadow
              surfaceTintColor: Colors.transparent, // Prevent color changes
              shadowColor: Colors.transparent, // No shadow
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
          ];
        },
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // Bouncy scroll physics for body too
          child: Column(
          children: [
            const SizedBox(height: 16),
            
            // User Profile Card
            if (user != null) _buildUserProfileCard(user),
            
            const SizedBox(height: 24),
            
            // App Settings Section
            _buildSettingsSection(
              title: AppLocalizations.of(context)!.appSettings,
              children: [
                _SettingsTile(
                  icon: CupertinoIcons.globe,
                  iconColor: Colors.blue,
                  title: AppLocalizations.of(context)!.language,
                  subtitle: _getLanguageName(context),
                  onTap: () async {
                    final selected = await showDialog<Locale>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: ArabicText.auto(
                          AppLocalizations.of(context)!.selectLanguage,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        children: [
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, const Locale('en'));
                            },
                            child: ArabicText.auto(
                              AppLocalizations.of(context)!.english,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, const Locale('ar'));
                            },
                            child: ArabicText.auto(
                              AppLocalizations.of(context)!.arabic,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, const Locale('fr'));
                            },
                            child: ArabicText.auto(
                              AppLocalizations.of(context)!.french,
                              style: const TextStyle(fontSize: 16),
                            ),
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
                      
                      // Also update the UserPreferencesService
                      final userPreferences = Provider.of<UserPreferencesService>(context, listen: false);
                      await userPreferences.setLanguage(selected);
                    }
                  },
                ),
                _SettingsTile(
                  icon: CupertinoIcons.moon,
                  iconColor: Colors.purple,
                  title: AppLocalizations.of(context)!.darkMode,
                  trailing: IOSToggle(
                    value: false, // TODO: Implement dark mode
                    onChanged: (value) {
                      // TODO: Implement dark mode toggle
                      CustomSnackBarHelper.showInfo(
                        context,
                        AppLocalizations.of(context)!.comingSoon,
                        duration: const Duration(seconds: 1),
                      );
                    },
                  ),
                  onTap: () {}, // Empty onTap since we're using the toggle
                ),
                _SettingsTile(
                  icon: CupertinoIcons.bell,
                  iconColor: Colors.orange,
                  title: AppLocalizations.of(context)!.notifications,
                  subtitle: AppLocalizations.of(context)!.manageYourNotifications,
                  onTap: () {
                    NavigationService.push(
                      context,
                      const NotificationSettingsPage(),
                    );
                  },
                ),
                Consumer<CurrencyService>(
                  builder: (context, currencyService, child) {
                    return _SettingsTile(
                      icon: CupertinoIcons.money_dollar,
                      iconColor: Colors.green,
                      title: AppLocalizations.of(context)!.currency,
                      subtitle: currencyService.currencyName,
                      onTap: () {
                        _showCurrencyDialog(context);
                      },
                    );
                  },
                ),
                _SettingsTile(
                  icon: CupertinoIcons.device_phone_portrait,
                  iconColor: Colors.purple,
                  title: AppLocalizations.of(context)!.display,
                  subtitle: AppLocalizations.of(context)!.customizeAppAppearanceAndInterface,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DisplaySettingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Account Section
            _buildSettingsSection(
              title: AppLocalizations.of(context)!.account,
              children: [
                _SettingsTile(
                  icon: CupertinoIcons.person_circle,
                  iconColor: Colors.green,
                  title: AppLocalizations.of(context)!.editProfile,
                  subtitle: AppLocalizations.of(context)!.updateYourInformation,
                  onTap: () {
                    NavigationService.push(
                      context,
                      const EditProfilePage(),
                    );
                  },
                ),
                _SettingsTile(
                  icon: CupertinoIcons.lock_shield,
                  iconColor: Colors.red,
                  title: AppLocalizations.of(context)!.privacyAndSecurity,
                  subtitle: AppLocalizations.of(context)!.manageYourPrivacySettings,
                  onTap: () {
                    NavigationService.push(
                      context,
                      const PrivacySecurityPage(),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Support Section
            _buildSettingsSection(
              title: AppLocalizations.of(context)!.support,
              children: [
                _SettingsTile(
                  icon: CupertinoIcons.question_circle,
                  iconColor: Colors.blue,
                  title: AppLocalizations.of(context)!.helpCenter,
                  subtitle: AppLocalizations.of(context)!.getHelpAndSupport,
                  onTap: () {
                    NavigationService.push(
                      context,
                      const HelpCenterPage(),
                    );
                  },
                ),
                _SettingsTile(
                  icon: CupertinoIcons.exclamationmark_triangle,
                  iconColor: Colors.orange,
                  title: AppLocalizations.of(context)!.reportABug,
                  subtitle: AppLocalizations.of(context)!.helpUsImproveTheApp,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ReportProblemDialog(),
                    );
                  },
                ),
                _SettingsTile(
                  icon: CupertinoIcons.star,
                  iconColor: Colors.amber,
                  title: AppLocalizations.of(context)!.rateTheApp,
                  subtitle: AppLocalizations.of(context)!.shareYourFeedback,
                  onTap: () {
                    CustomSnackBarHelper.showInfo(
                      context,
                      AppLocalizations.of(context)!.comingSoon,
                      duration: const Duration(seconds: 1),
                    );
                  },
                ),
                _SettingsTile(
                  icon: CupertinoIcons.info_circle,
                  iconColor: Colors.grey,
                  title: AppLocalizations.of(context)!.about,
                  subtitle: AppLocalizations.of(context)!.appVersionAndInfo,
                  onTap: () {
                    NavigationService.push(
                      context,
                      const AboutPage(),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Admin Tools Section (only for admins)
            if (authService.currentUser?.isAdmin ?? false)
              _buildSettingsSection(
                title: AppLocalizations.of(context)!.adminTools,
                children: [
                  _SettingsTile(
                    icon: CupertinoIcons.cart_badge_plus,
                    iconColor: Colors.green,
                    title: AppLocalizations.of(context)!.addAliexpressProduct,
                    subtitle: AppLocalizations.of(context)!.addNewProductsToTheStore,
                    onTap: () {
                      NavigationService.push(
                        context,
                        const AddProductPage(),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: CupertinoIcons.arrow_up_doc,
                    iconColor: Colors.blue,
                    title: AppLocalizations.of(context)!.bulkImportProducts,
                    subtitle: AppLocalizations.of(context)!.importMultipleProductsAtOnce,
                    onTap: () {
                      NavigationService.push(
                        context,
                        const BulkImportPage(),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: CupertinoIcons.person_2,
                    iconColor: Colors.purple,
                    title: AppLocalizations.of(context)!.userManagement,
                    subtitle: AppLocalizations.of(context)!.manageUserAccounts,
                    onTap: () {
                      NavigationService.push(
                        context,
                        const UserManagementPage(),
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
                    icon: CupertinoIcons.square_arrow_right,
                    iconColor: Colors.red,
                    title: AppLocalizations.of(context)!.signOut,
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
                title: AppLocalizations.of(context)!.debugInfo,
                children: [
                  _SettingsTile(
                    icon: CupertinoIcons.info_circle,
                    iconColor: Colors.grey,
                    title: AppLocalizations.of(context)!.currentLocale,
                    subtitle: '${currentLocale.languageCode} (${currentLocale.countryCode ?? 'no country'})',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: CupertinoIcons.text_bubble,
                    iconColor: Colors.grey,
                    title: AppLocalizations.of(context)!.localizedTextTest,
                    subtitle: AppLocalizations.of(context)?.myPets ?? 'My Pets (fallback)',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: CupertinoIcons.calendar,
                    iconColor: Colors.blue,
                    title: AppLocalizations.of(context)!.addTestAppointment,
                    subtitle: AppLocalizations.of(context)!.createAppointmentForTesting,
                    onTap: () => _createTestAppointment(),
                  ),
                  // Cache Stats Widget
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: const CacheStatsWidget(showDetails: true),
                  ),
                ],
              ),
            
            const SizedBox(height: 24),
          ],
        ),
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
                      CupertinoIcons.person,
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: context.localizedFont,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: context.localizedFont,
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
                          fontWeight: FontWeight.w500,
                          color: _getAccountTypeColor(user.accountType),
                          fontFamily: context.localizedFont,
                        ),
                      ),
                    ),
                  ],
                  
                  // Subscription Info (for vet and store accounts)
                  if (user.accountType == 'vet' || user.accountType == 'store') ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        NavigationService.push(
                          context,
                          const SubscriptionManagementPage(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFF6B35).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.star_fill,
                              size: 16,
                              color: const Color(0xFFFF6B35),
                            ),
                            const SizedBox(width: 8),
                                                         Text(
                               _isLoadingSubscription 
                                 ? AppLocalizations.of(context)!.loading
                                 : _subscriptionData?['plan'] ?? AppLocalizations.of(context)!.noSubscription,
                               style: TextStyle(
                                 fontSize: 12,
                                 fontWeight: FontWeight.w600,
                                 color: const Color(0xFFFF6B35),
                                 fontFamily: context.localizedFont,
                               ),
                             ),
                            const SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.chevron_right,
                              size: 12,
                              color: const Color(0xFFFF6B35),
                            ),
                          ],
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
                NavigationService.push(
                  context,
                  const EditProfilePage(),
                );
              },
              icon: Icon(
                CupertinoIcons.pencil,
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
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                letterSpacing: 0.5,
                fontFamily: context.localizedFont,
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
        return AppLocalizations.of(context)!.veterinarian;
      case 'store':
        return AppLocalizations.of(context)!.storeOwner;
      default:
        return AppLocalizations.of(context)!.user;
    }
  }

  Future<void> _createTestAppointment() async {
    try {
      final authService = context.read<AuthService>();
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        CustomSnackBarHelper.showError(
          context,
          AppLocalizations.of(context)!.noUserLoggedIn,
        );
        return;
      }

      // Calculate appointment time (1 hour and 30 minutes from now)
      final now = DateTime.now();
      final appointmentTime = now.add(const Duration(hours: 1, minutes: 30));
      
      // Format time slot (e.g., "14:30-15:00")
      final hour = appointmentTime.hour.toString().padLeft(2, '0');
      final minute = appointmentTime.minute.toString().padLeft(2, '0');
      
      // Calculate end time (30 minutes later)
      final endMinute = (appointmentTime.minute + 30) % 60;
      final endHour = appointmentTime.minute + 30 >= 60 
          ? (appointmentTime.hour + 1) % 24 
          : appointmentTime.hour;
      final endHourStr = endHour.toString().padLeft(2, '0');
      final endMinuteStr = endMinute.toString().padLeft(2, '0');
      
      final timeSlot = '$hour:$minute-$endHourStr:$endMinuteStr';

      print('🔍 [TestAppointment] Creating appointment for today at $timeSlot');
      print('🔍 [TestAppointment] User ID: ${currentUser.id}');

      // Create appointment data directly for Firestore
      final appointmentData = {
        'vetId': 'test_vet_id',
        'userId': currentUser.id,
        'petId': 'test_pet_id',
        'petName': 'Test Pet',
        'appointmentDate': Timestamp.fromDate(DateTime.now()), // Use Timestamp for Firestore
        'timeSlot': timeSlot,
        'type': 'checkup',
        'status': 'confirmed',
        'notes': 'Test appointment for today',
        'reason': 'Testing appointment reminder functionality',
        'price': 50.0,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      // Add directly to Firestore collection
      final docRef = await FirebaseFirestore.instance
          .collection('appointments')
          .add(appointmentData);
      
      print('🔍 [TestAppointment] Appointment created with ID: ${docRef.id}');
      
      if (mounted) {
        CustomSnackBarHelper.showSuccess(
          context,
          AppLocalizations.of(context)!.testAppointmentCreated(
            docRef.id,
            '${appointmentTime.hour}:${appointmentTime.minute.toString().padLeft(2, '0')}',
          ),
          duration: const Duration(seconds: 5),
        );
        
        // Force a rebuild of the home page
        setState(() {});
      }
    } catch (e) {
      print('🔍 [TestAppointment] Error: $e');
      if (mounted) {
        CustomSnackBarHelper.showError(
          context,
          AppLocalizations.of(context)!.errorCreatingTestAppointment(e.toString()),
        );
      }
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
                      fontWeight: FontWeight.w400,
                      color: titleColor ?? Colors.black,
                      fontFamily: context.localizedFont,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: context.localizedFont,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Trailing Widget
            trailing ??
                Icon(
                  CupertinoIcons.chevron_right,
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

// _getCurrencyName not used

void _showCurrencyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        AppLocalizations.of(context)!.selectCurrency,
        style: TextStyle(
          fontFamily: context.titleFont,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CurrencyOption(
            currency: Currency.USD,
            symbol: '\$',
            name: AppLocalizations.of(context)!.usd,
            onTap: () {
              final currencyService = Provider.of<CurrencyService>(context, listen: false);
              currencyService.changeCurrency(Currency.USD);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          _CurrencyOption(
            currency: Currency.DZD,
            symbol: '£',
            name: AppLocalizations.of(context)!.dzd,
            onTap: () {
              final currencyService = Provider.of<CurrencyService>(context, listen: false);
              currencyService.changeCurrency(Currency.DZD);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}

class _CurrencyOption extends StatelessWidget {
  final Currency currency;
  final String symbol;
  final String name;
  final VoidCallback onTap;

  const _CurrencyOption({
    required this.currency,
    required this.symbol,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyService>(
      builder: (context, currencyService, child) {
        final isSelected = currencyService.currentCurrency == currency;
        
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green[50] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.green : Colors.grey[700],
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.check_mark,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
} 