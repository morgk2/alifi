import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @continueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continueWithFacebook;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @reportAProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportAProblem;

  /// No description provided for @byClickingContinueYouAgreeToOur.
  ///
  /// In en, this message translates to:
  /// **'By clicking continue, you agree to our'**
  String get byClickingContinueYouAgreeToOur;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @aiPetAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Pet Assistant'**
  String get aiPetAssistant;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// No description provided for @alifi.
  ///
  /// In en, this message translates to:
  /// **'alifi'**
  String get alifi;

  /// No description provided for @goodAfternoonUser.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, user!'**
  String get goodAfternoonUser;

  /// No description provided for @loadingNearbyPets.
  ///
  /// In en, this message translates to:
  /// **'Loading nearby pets...'**
  String get loadingNearbyPets;

  /// No description provided for @lostPetsNearby.
  ///
  /// In en, this message translates to:
  /// **'Lost Pets Nearby'**
  String get lostPetsNearby;

  /// No description provided for @recentLostPets.
  ///
  /// In en, this message translates to:
  /// **'Recent Lost Pets'**
  String get recentLostPets;

  /// No description provided for @lost.
  ///
  /// In en, this message translates to:
  /// **'LOST'**
  String get lost;

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'years old'**
  String get yearsOld;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @affiliatePartnership.
  ///
  /// In en, this message translates to:
  /// **'Affiliate Partnership'**
  String get affiliatePartnership;

  /// No description provided for @affiliatePartnershipDescription.
  ///
  /// In en, this message translates to:
  /// **'This product is available through our affiliate partnership with AliExpress. When you make a purchase through these links, you support our app at no additional cost to you. This helps us maintain and improve our services.'**
  String get affiliatePartnershipDescription;

  /// No description provided for @reportFound.
  ///
  /// In en, this message translates to:
  /// **'Report Found'**
  String get reportFound;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @petMarkedAsFoundSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Pet marked as found successfully!'**
  String get petMarkedAsFoundSuccessfully;

  /// No description provided for @errorMarkingPetAsFound.
  ///
  /// In en, this message translates to:
  /// **'Error marking pet as found: {error}'**
  String errorMarkingPetAsFound(Object error);

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @thisWillPostYourMissingPetReport.
  ///
  /// In en, this message translates to:
  /// **'This will post your missing pet report to the community.'**
  String get thisWillPostYourMissingPetReport;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'PROCEED'**
  String get proceed;

  /// No description provided for @enterCustomAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter custom amount'**
  String get enterCustomAmount;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location Services Disabled'**
  String get locationServicesDisabled;

  /// No description provided for @pleaseEnableLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services or enter your location manually.'**
  String get pleaseEnableLocationServices;

  /// No description provided for @enterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Manually'**
  String get enterManually;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationPermissionRequired;

  /// No description provided for @locationPermissionRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to use this feature. Please enable it in your device settings.'**
  String get locationPermissionRequiredDescription;

  /// No description provided for @enterYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Location'**
  String get enterYourLocation;

  /// No description provided for @locationSetTo.
  ///
  /// In en, this message translates to:
  /// **'Location set to: {address}'**
  String locationSetTo(Object address);

  /// No description provided for @reportMissingPet.
  ///
  /// In en, this message translates to:
  /// **'Report Missing Pet'**
  String get reportMissingPet;

  /// No description provided for @addYourBusiness.
  ///
  /// In en, this message translates to:
  /// **'Add Your Business'**
  String get addYourBusiness;

  /// No description provided for @pleaseLoginToReportMissingPet.
  ///
  /// In en, this message translates to:
  /// **'Please login to report a missing pet'**
  String get pleaseLoginToReportMissingPet;

  /// No description provided for @thisVetIsAlreadyInDatabase.
  ///
  /// In en, this message translates to:
  /// **'This vet is already in the database'**
  String get thisVetIsAlreadyInDatabase;

  /// No description provided for @thisStoreIsAlreadyInDatabase.
  ///
  /// In en, this message translates to:
  /// **'This store is already in the database'**
  String get thisStoreIsAlreadyInDatabase;

  /// No description provided for @addedVetClinicToMap.
  ///
  /// In en, this message translates to:
  /// **'Added vet clinic to map'**
  String get addedVetClinicToMap;

  /// No description provided for @addedPetStoreToMap.
  ///
  /// In en, this message translates to:
  /// **'Added pet store to map'**
  String get addedPetStoreToMap;

  /// No description provided for @errorAddingBusiness.
  ///
  /// In en, this message translates to:
  /// **'Error adding business: {error}'**
  String errorAddingBusiness(Object error);

  /// No description provided for @migrateLocations.
  ///
  /// In en, this message translates to:
  /// **'Migrate Locations'**
  String get migrateLocations;

  /// No description provided for @migrateLocationsDescription.
  ///
  /// In en, this message translates to:
  /// **'This will migrate all existing pet locations to the new format. This process cannot be undone.'**
  String get migrateLocationsDescription;

  /// No description provided for @migrationComplete.
  ///
  /// In en, this message translates to:
  /// **'Migration Complete'**
  String get migrationComplete;

  /// No description provided for @migrationCompleteDescription.
  ///
  /// In en, this message translates to:
  /// **'All locations have been successfully migrated to the new format.'**
  String get migrationCompleteDescription;

  /// No description provided for @migrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Migration Failed'**
  String get migrationFailed;

  /// No description provided for @errorDuringMigration.
  ///
  /// In en, this message translates to:
  /// **'Error during migration: {error}'**
  String errorDuringMigration(Object error);

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @debugInfo.
  ///
  /// In en, this message translates to:
  /// **'Debug Info'**
  String get debugInfo;

  /// No description provided for @authServiceInitialized.
  ///
  /// In en, this message translates to:
  /// **'AuthService initialized'**
  String get authServiceInitialized;

  /// No description provided for @authServiceLoading.
  ///
  /// In en, this message translates to:
  /// **'AuthService loading'**
  String get authServiceLoading;

  /// No description provided for @authServiceAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'AuthService authenticated'**
  String get authServiceAuthenticated;

  /// No description provided for @authServiceUser.
  ///
  /// In en, this message translates to:
  /// **'AuthService user'**
  String get authServiceUser;

  /// No description provided for @firebaseUser.
  ///
  /// In en, this message translates to:
  /// **'Firebase user'**
  String get firebaseUser;

  /// No description provided for @guestMode.
  ///
  /// In en, this message translates to:
  /// **'Guest mode'**
  String get guestMode;

  /// No description provided for @forceSignOut.
  ///
  /// In en, this message translates to:
  /// **'Force Sign Out'**
  String get forceSignOut;

  /// No description provided for @signedOutOfAllServices.
  ///
  /// In en, this message translates to:
  /// **'Signed out of all services'**
  String get signedOutOfAllServices;

  /// No description provided for @failedToGetDebugInfo.
  ///
  /// In en, this message translates to:
  /// **'Failed to get debug info: {error}'**
  String failedToGetDebugInfo(Object error);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(Object error);

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeen;

  /// No description provided for @physicalPetIdFor.
  ///
  /// In en, this message translates to:
  /// **'Physical Pet ID for {petName}'**
  String physicalPetIdFor(Object petName);

  /// No description provided for @priceValue.
  ///
  /// In en, this message translates to:
  /// **'\$20.00'**
  String get priceValue;

  /// No description provided for @hiAskMeAboutPetAdvice.
  ///
  /// In en, this message translates to:
  /// **'Hi! ask me about any pet advice,\nand I\'ll do my best to help you, and\nyour little one!'**
  String get hiAskMeAboutPetAdvice;

  /// No description provided for @errorGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error getting location: {error}'**
  String errorGettingLocation(Object error);

  /// No description provided for @errorFindingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error finding location: {error}'**
  String errorFindingLocation(Object error);

  /// No description provided for @vet.
  ///
  /// In en, this message translates to:
  /// **'Vet'**
  String get vet;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @vetClinic.
  ///
  /// In en, this message translates to:
  /// **'vet clinic'**
  String get vetClinic;

  /// No description provided for @petStore.
  ///
  /// In en, this message translates to:
  /// **'pet store'**
  String get petStore;

  /// No description provided for @myPets.
  ///
  /// In en, this message translates to:
  /// **'My Pets'**
  String get myPets;

  /// No description provided for @testNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Test notifications to verify they are working on your device.'**
  String get testNotificationsDescription;

  /// No description provided for @disableNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Disable Notifications?'**
  String get disableNotificationsTitle;

  /// No description provided for @disableNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'You will no longer receive push notifications. You can re-enable them at any time.'**
  String get disableNotificationsDescription;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @manageYourNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage your notifications'**
  String get manageYourNotifications;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @updateYourInformation.
  ///
  /// In en, this message translates to:
  /// **'Update your information'**
  String get updateYourInformation;

  /// No description provided for @privacyAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyAndSecurity;

  /// No description provided for @manageYourPrivacySettings.
  ///
  /// In en, this message translates to:
  /// **'Manage your privacy settings'**
  String get manageYourPrivacySettings;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @getHelpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Get help and support'**
  String get getHelpAndSupport;

  /// No description provided for @reportABug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get reportABug;

  /// No description provided for @helpUsImproveTheApp.
  ///
  /// In en, this message translates to:
  /// **'Help us improve the app'**
  String get helpUsImproveTheApp;

  /// No description provided for @rateTheApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateTheApp;

  /// No description provided for @shareYourFeedback.
  ///
  /// In en, this message translates to:
  /// **'Share your feedback'**
  String get shareYourFeedback;

  /// No description provided for @appVersionAndInfo.
  ///
  /// In en, this message translates to:
  /// **'App version and info'**
  String get appVersionAndInfo;

  /// No description provided for @adminTools.
  ///
  /// In en, this message translates to:
  /// **'Admin Tools'**
  String get adminTools;

  /// No description provided for @addAliexpressProduct.
  ///
  /// In en, this message translates to:
  /// **'Add AliExpress Product'**
  String get addAliexpressProduct;

  /// No description provided for @addNewProductsToTheStore.
  ///
  /// In en, this message translates to:
  /// **'Add new products to the store'**
  String get addNewProductsToTheStore;

  /// No description provided for @bulkImportProducts.
  ///
  /// In en, this message translates to:
  /// **'Bulk Import Products'**
  String get bulkImportProducts;

  /// No description provided for @importMultipleProductsAtOnce.
  ///
  /// In en, this message translates to:
  /// **'Import multiple products at once'**
  String get importMultipleProductsAtOnce;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @manageUserAccounts.
  ///
  /// In en, this message translates to:
  /// **'Manage user accounts'**
  String get manageUserAccounts;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @currentLocale.
  ///
  /// In en, this message translates to:
  /// **'Current Locale'**
  String get currentLocale;

  /// No description provided for @localizedTextTest.
  ///
  /// In en, this message translates to:
  /// **'Localized Text Test'**
  String get localizedTextTest;

  /// No description provided for @addTestAppointment.
  ///
  /// In en, this message translates to:
  /// **'Add Test Appointment'**
  String get addTestAppointment;

  /// No description provided for @createAppointmentForTesting.
  ///
  /// In en, this message translates to:
  /// **'Create appointment in 1h 30min for testing'**
  String get createAppointmentForTesting;

  /// No description provided for @noSubscription.
  ///
  /// In en, this message translates to:
  /// **'No Subscription'**
  String get noSubscription;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @usd.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get usd;

  /// No description provided for @dzd.
  ///
  /// In en, this message translates to:
  /// **'DZD'**
  String get dzd;

  /// No description provided for @pleaseLoginToViewNotifications.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view notifications'**
  String get pleaseLoginToViewNotifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications'**
  String get errorLoadingNotifications;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(Object error);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @notificationsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see notifications here when you receive messages, orders, or follows'**
  String get notificationsEmptyHint;

  /// No description provided for @sendTestNotificationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send test notification'**
  String get sendTestNotificationTooltip;

  /// No description provided for @unableToOpenChatUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'Unable to open chat - user not found'**
  String get unableToOpenChatUserNotFound;

  /// No description provided for @errorOpeningChat.
  ///
  /// In en, this message translates to:
  /// **'Error opening chat: {error}'**
  String errorOpeningChat(Object error);

  /// No description provided for @unableToOpenChatSenderMissing.
  ///
  /// In en, this message translates to:
  /// **'Unable to open chat - sender information missing'**
  String get unableToOpenChatSenderMissing;

  /// No description provided for @unableToOpenOrderMissing.
  ///
  /// In en, this message translates to:
  /// **'Unable to open order - order information missing'**
  String get unableToOpenOrderMissing;

  /// No description provided for @unableToOpenProfileUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'Unable to open profile - user not found'**
  String get unableToOpenProfileUserNotFound;

  /// No description provided for @errorOpeningProfile.
  ///
  /// In en, this message translates to:
  /// **'Error opening profile: {error}'**
  String errorOpeningProfile(Object error);

  /// No description provided for @unableToOpenProfileUserMissing.
  ///
  /// In en, this message translates to:
  /// **'Unable to open profile - user information missing'**
  String get unableToOpenProfileUserMissing;

  /// No description provided for @appointmentNotificationNavigationTbd.
  ///
  /// In en, this message translates to:
  /// **'Appointment notification - navigation to be implemented'**
  String get appointmentNotificationNavigationTbd;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @errorDeletingNotification.
  ///
  /// In en, this message translates to:
  /// **'Error deleting notification: {error}'**
  String errorDeletingNotification(Object error);

  /// No description provided for @allNotificationsMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsMarkedAsRead;

  /// No description provided for @errorMarkingNotificationsAsRead.
  ///
  /// In en, this message translates to:
  /// **'Error marking notifications as read: {error}'**
  String errorMarkingNotificationsAsRead(Object error);

  /// No description provided for @testAppointmentCreated.
  ///
  /// In en, this message translates to:
  /// **'Test appointment created! ID: {id}\nTime: {time}'**
  String testAppointmentCreated(Object id, Object time);

  /// No description provided for @errorCreatingTestAppointment.
  ///
  /// In en, this message translates to:
  /// **'Error creating test appointment: {error}'**
  String errorCreatingTestAppointment(Object error);

  /// No description provided for @noUserLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'No user logged in'**
  String get noUserLoggedIn;

  /// No description provided for @todaysVetAppointment.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Vet Appointment'**
  String get todaysVetAppointment;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @pet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get pet;

  /// No description provided for @veterinarian.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian'**
  String get veterinarian;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes:'**
  String get notesLabel;

  /// No description provided for @unableToContactVet.
  ///
  /// In en, this message translates to:
  /// **'Unable to contact vet at this time'**
  String get unableToContactVet;

  /// No description provided for @contactVet.
  ///
  /// In en, this message translates to:
  /// **'Contact Vet'**
  String get contactVet;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @hoursMinutesUntilAppointment.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m until appointment'**
  String hoursMinutesUntilAppointment(Object hours, Object minutes);

  /// No description provided for @minutesUntilAppointment.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m until appointment'**
  String minutesUntilAppointment(Object minutes);

  /// No description provided for @appointmentStartingNow.
  ///
  /// In en, this message translates to:
  /// **'Appointment starting now!'**
  String get appointmentStartingNow;

  /// No description provided for @errorLoadingPets.
  ///
  /// In en, this message translates to:
  /// **'Error loading pets: {error}'**
  String errorLoadingPets(Object error);

  /// No description provided for @errorLoadingTimeSlots.
  ///
  /// In en, this message translates to:
  /// **'Error loading time slots: {error}'**
  String errorLoadingTimeSlots(Object error);

  /// No description provided for @pleaseFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get pleaseFillRequiredFields;

  /// No description provided for @appointmentRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Appointment request sent successfully!'**
  String get appointmentRequestSent;

  /// No description provided for @errorBookingAppointment.
  ///
  /// In en, this message translates to:
  /// **'Error booking appointment: {error}'**
  String errorBookingAppointment(Object error);

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectADate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectADate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @noAvailableTimeSlotsForThisDate.
  ///
  /// In en, this message translates to:
  /// **'No available time slots for this date'**
  String get noAvailableTimeSlotsForThisDate;

  /// No description provided for @selectPet.
  ///
  /// In en, this message translates to:
  /// **'Select pet'**
  String get selectPet;

  /// No description provided for @noPetsFoundPleaseAdd.
  ///
  /// In en, this message translates to:
  /// **'No pets found. Please add a pet first.'**
  String get noPetsFoundPleaseAdd;

  /// No description provided for @appointmentType.
  ///
  /// In en, this message translates to:
  /// **'Appointment Type'**
  String get appointmentType;

  /// No description provided for @reasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (Optional)'**
  String get reasonOptional;

  /// No description provided for @describeAppointmentReason.
  ///
  /// In en, this message translates to:
  /// **'Describe the reason for the appointment...'**
  String get describeAppointmentReason;

  /// No description provided for @bookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get bookAppointment;

  /// No description provided for @noPetsFound.
  ///
  /// In en, this message translates to:
  /// **'No Pets Found'**
  String get noPetsFound;

  /// No description provided for @needToAddPetBeforeBooking.
  ///
  /// In en, this message translates to:
  /// **'You need to add a pet before booking an appointment.'**
  String get needToAddPetBeforeBooking;

  /// No description provided for @addPetCta.
  ///
  /// In en, this message translates to:
  /// **'Add Pet'**
  String get addPetCta;

  /// No description provided for @drName.
  ///
  /// In en, this message translates to:
  /// **'Dr. {name}'**
  String drName(Object name);

  /// No description provided for @searchForHelp.
  ///
  /// In en, this message translates to:
  /// **'Search for help...'**
  String get searchForHelp;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @pets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get pets;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryAdjustingSearchOrCategoryFilter.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or category filter'**
  String get tryAdjustingSearchOrCategoryFilter;

  /// No description provided for @stillNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Still need help?'**
  String get stillNeedHelp;

  /// No description provided for @contactSupportTeamForPersonalizedAssistance.
  ///
  /// In en, this message translates to:
  /// **'Contact our support team for personalized assistance'**
  String get contactSupportTeamForPersonalizedAssistance;

  /// No description provided for @emailSupportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Email support coming soon!'**
  String get emailSupportComingSoon;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @liveChatComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Live chat coming soon!'**
  String get liveChatComingSoon;

  /// No description provided for @liveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// No description provided for @howToBookAppointment.
  ///
  /// In en, this message translates to:
  /// **'How do I book an appointment with a veterinarian?'**
  String get howToBookAppointment;

  /// No description provided for @bookAppointmentInstructions.
  ///
  /// In en, this message translates to:
  /// **'To book an appointment, go to the \"Find Vet\" section, search for veterinarians in your area, select one, and tap \"Book Appointment\". You can choose your preferred date and time.'**
  String get bookAppointmentInstructions;

  /// No description provided for @howToAddPets.
  ///
  /// In en, this message translates to:
  /// **'How do I add my pets to the app?'**
  String get howToAddPets;

  /// No description provided for @addPetsInstructions.
  ///
  /// In en, this message translates to:
  /// **'Go to \"My Pets\" in the bottom navigation, tap the \"+\" button, and fill in your pet\'s information including name, species, breed, and age.'**
  String get addPetsInstructions;

  /// No description provided for @howToReportLostPet.
  ///
  /// In en, this message translates to:
  /// **'How do I report a lost pet?'**
  String get howToReportLostPet;

  /// No description provided for @reportLostPetInstructions.
  ///
  /// In en, this message translates to:
  /// **'Navigate to \"Lost Pets\" section, tap \"Report Lost Pet\", fill in the details including photos, location, and contact information.'**
  String get reportLostPetInstructions;

  /// No description provided for @lostPets.
  ///
  /// In en, this message translates to:
  /// **'Lost Pets'**
  String get lostPets;

  /// No description provided for @howToOrderPetSupplies.
  ///
  /// In en, this message translates to:
  /// **'How do I order pet supplies?'**
  String get howToOrderPetSupplies;

  /// No description provided for @orderPetSuppliesInstructions.
  ///
  /// In en, this message translates to:
  /// **'Go to the \"Store\" section, browse products, add items to cart, and proceed to checkout with your payment method.'**
  String get orderPetSuppliesInstructions;

  /// No description provided for @howToContactCustomerSupport.
  ///
  /// In en, this message translates to:
  /// **'How do I contact customer support?'**
  String get howToContactCustomerSupport;

  /// No description provided for @contactCustomerSupportInstructions.
  ///
  /// In en, this message translates to:
  /// **'You can contact us through the \"Report a Bug\" feature in Settings, or email us at support@alifi.com.'**
  String get contactCustomerSupportInstructions;

  /// No description provided for @howToChangeAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'How do I change my account settings?'**
  String get howToChangeAccountSettings;

  /// No description provided for @changeAccountSettingsInstructions.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings, tap on the setting you want to change, and follow the prompts to update your information.'**
  String get changeAccountSettingsInstructions;

  /// No description provided for @howToFindVeterinariansNearMe.
  ///
  /// In en, this message translates to:
  /// **'How do I find veterinarians near me?'**
  String get howToFindVeterinariansNearMe;

  /// No description provided for @findVeterinariansInstructions.
  ///
  /// In en, this message translates to:
  /// **'Use the \"Find Vet\" feature and allow location access to see veterinarians in your area, or search by city/zip code.'**
  String get findVeterinariansInstructions;

  /// No description provided for @howToCancelAppointment.
  ///
  /// In en, this message translates to:
  /// **'How do I cancel an appointment?'**
  String get howToCancelAppointment;

  /// No description provided for @cancelAppointmentInstructions.
  ///
  /// In en, this message translates to:
  /// **'Go to \"My Appointments\", find the appointment you want to cancel, tap on it, and select \"Cancel Appointment\".'**
  String get cancelAppointmentInstructions;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @stayUpdatedWithImportantNotifications.
  ///
  /// In en, this message translates to:
  /// **'Stay updated with important notifications:'**
  String get stayUpdatedWithImportantNotifications;

  /// No description provided for @newMessages.
  ///
  /// In en, this message translates to:
  /// **'New Messages'**
  String get newMessages;

  /// No description provided for @getNotifiedWhenSomeoneSendsMessage.
  ///
  /// In en, this message translates to:
  /// **'Get notified when someone sends you a message'**
  String get getNotifiedWhenSomeoneSendsMessage;

  /// No description provided for @trackOrdersAndDeliveryStatus.
  ///
  /// In en, this message translates to:
  /// **'Track your orders and delivery status'**
  String get trackOrdersAndDeliveryStatus;

  /// No description provided for @petCareReminders.
  ///
  /// In en, this message translates to:
  /// **'Pet Care Reminders'**
  String get petCareReminders;

  /// No description provided for @neverMissImportantPetCareAppointments.
  ///
  /// In en, this message translates to:
  /// **'Never miss important pet care appointments'**
  String get neverMissImportantPetCareAppointments;

  /// No description provided for @youCanChangeThisLaterInDeviceSettings.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in your device settings'**
  String get youCanChangeThisLaterInDeviceSettings;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @toReceiveNotificationsPleaseEnableInDeviceSettings.
  ///
  /// In en, this message translates to:
  /// **'To receive notifications, please enable them in your device settings.'**
  String get toReceiveNotificationsPleaseEnableInDeviceSettings;

  /// No description provided for @errorSearchingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error searching location: {error}'**
  String errorSearchingLocation(Object error);

  /// No description provided for @errorGettingPlaceDetails.
  ///
  /// In en, this message translates to:
  /// **'Error getting place details: {error}'**
  String errorGettingPlaceDetails(Object error);

  /// No description provided for @errorSelectingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error selecting location: {error}'**
  String errorSelectingLocation(Object error);

  /// No description provided for @errorReverseGeocoding.
  ///
  /// In en, this message translates to:
  /// **'Error reverse geocoding: {error}'**
  String errorReverseGeocoding(Object error);

  /// No description provided for @searchLocation.
  ///
  /// In en, this message translates to:
  /// **'Search location...'**
  String get searchLocation;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirmLocation;

  /// No description provided for @giftToAFriend.
  ///
  /// In en, this message translates to:
  /// **'Gift to a Friend'**
  String get giftToAFriend;

  /// No description provided for @searchByNameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email'**
  String get searchByNameOrEmail;

  /// No description provided for @searchForUsersToGift.
  ///
  /// In en, this message translates to:
  /// **'Search for users to gift.'**
  String get searchForUsersToGift;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get noUsersFound;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No Email'**
  String get noEmail;

  /// No description provided for @gift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get gift;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @confirmYourGift.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your Gift'**
  String get confirmYourGift;

  /// No description provided for @areYouSureYouWantToGiftThisProductTo.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to gift this product to {userName}?'**
  String areYouSureYouWantToGiftThisProductTo(Object userName);

  /// No description provided for @youHaveAGift.
  ///
  /// In en, this message translates to:
  /// **'You Have a Gift!'**
  String get youHaveAGift;

  /// No description provided for @hasGiftedYou.
  ///
  /// In en, this message translates to:
  /// **'Has gifted you:'**
  String get hasGiftedYou;

  /// No description provided for @refuse.
  ///
  /// In en, this message translates to:
  /// **'Refuse'**
  String get refuse;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @typeToSearchForUsers.
  ///
  /// In en, this message translates to:
  /// **'Type to search for users'**
  String get typeToSearchForUsers;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @checkUp.
  ///
  /// In en, this message translates to:
  /// **'Check-up'**
  String get checkUp;

  /// No description provided for @vaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get vaccination;

  /// No description provided for @surgery.
  ///
  /// In en, this message translates to:
  /// **'Surgery'**
  String get surgery;

  /// No description provided for @consultation.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get consultation;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @followUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get followUp;

  /// No description provided for @addPet.
  ///
  /// In en, this message translates to:
  /// **'Add Pet'**
  String get addPet;

  /// No description provided for @bird.
  ///
  /// In en, this message translates to:
  /// **'Bird'**
  String get bird;

  /// No description provided for @rabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get rabbit;

  /// No description provided for @hamster.
  ///
  /// In en, this message translates to:
  /// **'Hamster'**
  String get hamster;

  /// No description provided for @fish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get fish;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent successfully!'**
  String get testNotificationSent;

  /// No description provided for @errorSendingTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Error sending test notification: {error}'**
  String errorSendingTestNotification(Object error);

  /// No description provided for @notificationPreferencesSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences saved successfully!'**
  String get notificationPreferencesSavedSuccessfully;

  /// No description provided for @errorSavingPreferences.
  ///
  /// In en, this message translates to:
  /// **'Error saving preferences: {error}'**
  String errorSavingPreferences(Object error);

  /// No description provided for @notificationsEnabledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled successfully!'**
  String get notificationsEnabledSuccessfully;

  /// No description provided for @errorRequestingPermission.
  ///
  /// In en, this message translates to:
  /// **'Error requesting permission: {error}'**
  String errorRequestingPermission(Object error);

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get notificationsDisabled;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @playSoundForNotifications.
  ///
  /// In en, this message translates to:
  /// **'Play sound for notifications'**
  String get playSoundForNotifications;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrateDeviceForNotifications.
  ///
  /// In en, this message translates to:
  /// **'Vibrate device for notifications'**
  String get vibrateDeviceForNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @receiveNotificationsViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications via email'**
  String get receiveNotificationsViaEmail;

  /// No description provided for @quietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet Hours'**
  String get quietHours;

  /// No description provided for @enableQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Enable Quiet Hours'**
  String get enableQuietHours;

  /// No description provided for @muteNotificationsDuringSpecifiedHours.
  ///
  /// In en, this message translates to:
  /// **'Mute notifications during specified hours'**
  String get muteNotificationsDuringSpecifiedHours;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @notificationTypes.
  ///
  /// In en, this message translates to:
  /// **'Notification Types'**
  String get notificationTypes;

  /// No description provided for @chatMessages.
  ///
  /// In en, this message translates to:
  /// **'Chat Messages'**
  String get chatMessages;

  /// No description provided for @newMessagesFromOtherUsers.
  ///
  /// In en, this message translates to:
  /// **'New messages from other users'**
  String get newMessagesFromOtherUsers;

  /// No description provided for @orderUpdates.
  ///
  /// In en, this message translates to:
  /// **'Order Updates'**
  String get orderUpdates;

  /// No description provided for @orderStatusChangesAndUpdates.
  ///
  /// In en, this message translates to:
  /// **'Order status changes and updates'**
  String get orderStatusChangesAndUpdates;

  /// No description provided for @appointmentRequestsAndReminders.
  ///
  /// In en, this message translates to:
  /// **'Appointment requests and reminders'**
  String get appointmentRequestsAndReminders;

  /// No description provided for @socialActivity.
  ///
  /// In en, this message translates to:
  /// **'Social Activity'**
  String get socialActivity;

  /// No description provided for @newFollowersAndSocialInteractions.
  ///
  /// In en, this message translates to:
  /// **'New followers and social interactions'**
  String get newFollowersAndSocialInteractions;

  /// No description provided for @testNotifications.
  ///
  /// In en, this message translates to:
  /// **'Test Notifications'**
  String get testNotifications;

  /// No description provided for @sendTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Send Test Notification'**
  String get sendTestNotification;

  /// No description provided for @savePreferences.
  ///
  /// In en, this message translates to:
  /// **'Save Preferences'**
  String get savePreferences;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @noLostPetsReportedNearby.
  ///
  /// In en, this message translates to:
  /// **'No lost pets reported nearby'**
  String get noLostPetsReportedNearby;

  /// No description provided for @weWillNotifyYouWhenPetsAreReported.
  ///
  /// In en, this message translates to:
  /// **'We will notify you when pets are reported in your area'**
  String get weWillNotifyYouWhenPetsAreReported;

  /// No description provided for @noRecentLostPetsReported.
  ///
  /// In en, this message translates to:
  /// **'No recent lost pets reported'**
  String get noRecentLostPetsReported;

  /// No description provided for @enableLocationToSeePetsInYourArea.
  ///
  /// In en, this message translates to:
  /// **'Enable location to see pets in your area'**
  String get enableLocationToSeePetsInYourArea;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get openNow;

  /// No description provided for @visitClinicProfile.
  ///
  /// In en, this message translates to:
  /// **'Visit Clinic Profile'**
  String get visitClinicProfile;

  /// No description provided for @visitStoreProfile.
  ///
  /// In en, this message translates to:
  /// **'Visit Store Profile'**
  String get visitStoreProfile;

  /// No description provided for @alifiFavorite.
  ///
  /// In en, this message translates to:
  /// **'Alifi Favorite'**
  String get alifiFavorite;

  /// No description provided for @alifiAffiliated.
  ///
  /// In en, this message translates to:
  /// **'Alifi Affiliated'**
  String get alifiAffiliated;

  /// No description provided for @pleaseEnableLocationServicesOrEnterManually.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services or enter your location manually.'**
  String get pleaseEnableLocationServicesOrEnterManually;

  /// No description provided for @locationPermissionRequiredForFeature.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required for this feature. Please enable it in your app settings.'**
  String get locationPermissionRequiredForFeature;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @addYourFirstPet.
  ///
  /// In en, this message translates to:
  /// **'Add your first pet'**
  String get addYourFirstPet;

  /// No description provided for @healthInformation.
  ///
  /// In en, this message translates to:
  /// **'Health Information'**
  String get healthInformation;

  /// No description provided for @snake.
  ///
  /// In en, this message translates to:
  /// **'Snake'**
  String get snake;

  /// No description provided for @lizard.
  ///
  /// In en, this message translates to:
  /// **'Lizard'**
  String get lizard;

  /// No description provided for @guineaPig.
  ///
  /// In en, this message translates to:
  /// **'Guinea Pig'**
  String get guineaPig;

  /// No description provided for @ferret.
  ///
  /// In en, this message translates to:
  /// **'Ferret'**
  String get ferret;

  /// No description provided for @turtle.
  ///
  /// In en, this message translates to:
  /// **'Turtle'**
  String get turtle;

  /// No description provided for @parrot.
  ///
  /// In en, this message translates to:
  /// **'Parrot'**
  String get parrot;

  /// No description provided for @mouse.
  ///
  /// In en, this message translates to:
  /// **'Mouse'**
  String get mouse;

  /// No description provided for @rat.
  ///
  /// In en, this message translates to:
  /// **'Rat'**
  String get rat;

  /// No description provided for @hedgehog.
  ///
  /// In en, this message translates to:
  /// **'Hedgehog'**
  String get hedgehog;

  /// No description provided for @chinchilla.
  ///
  /// In en, this message translates to:
  /// **'Chinchilla'**
  String get chinchilla;

  /// No description provided for @gerbil.
  ///
  /// In en, this message translates to:
  /// **'Gerbil'**
  String get gerbil;

  /// No description provided for @duck.
  ///
  /// In en, this message translates to:
  /// **'Duck'**
  String get duck;

  /// No description provided for @monkey.
  ///
  /// In en, this message translates to:
  /// **'Monkey'**
  String get monkey;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @notSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelected;

  /// No description provided for @appNotResponding.
  ///
  /// In en, this message translates to:
  /// **'App not responding'**
  String get appNotResponding;

  /// No description provided for @loginIssues.
  ///
  /// In en, this message translates to:
  /// **'Login issues'**
  String get loginIssues;

  /// No description provided for @paymentProblems.
  ///
  /// In en, this message translates to:
  /// **'Payment problems'**
  String get paymentProblems;

  /// No description provided for @accountAccess.
  ///
  /// In en, this message translates to:
  /// **'Account access'**
  String get accountAccess;

  /// No description provided for @missingFeatures.
  ///
  /// In en, this message translates to:
  /// **'Missing features'**
  String get missingFeatures;

  /// No description provided for @petListingIssues.
  ///
  /// In en, this message translates to:
  /// **'Pet listing issues'**
  String get petListingIssues;

  /// No description provided for @mapNotWorking.
  ///
  /// In en, this message translates to:
  /// **'Map not working'**
  String get mapNotWorking;

  /// No description provided for @inappropriateContent.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get inappropriateContent;

  /// No description provided for @technicalProblems.
  ///
  /// In en, this message translates to:
  /// **'Technical problems'**
  String get technicalProblems;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @selectProblemType.
  ///
  /// In en, this message translates to:
  /// **'Select problem type'**
  String get selectProblemType;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @interface.
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get interface;

  /// No description provided for @useBlurEffectForTabBar.
  ///
  /// In en, this message translates to:
  /// **'Use blur effect for Tab bar'**
  String get useBlurEffectForTabBar;

  /// No description provided for @enableGlassLikeBlurEffectOnNavigationBar.
  ///
  /// In en, this message translates to:
  /// **'Enable glass-like blur effect on the navigation bar'**
  String get enableGlassLikeBlurEffectOnNavigationBar;

  /// No description provided for @whenDisabledTabBarWillHaveSolidWhiteBackground.
  ///
  /// In en, this message translates to:
  /// **'When disabled, the tab bar will have a solid white background instead of the glass-like blur effect.'**
  String get whenDisabledTabBarWillHaveSolidWhiteBackground;

  /// No description provided for @customizeAppAppearanceAndInterface.
  ///
  /// In en, this message translates to:
  /// **'Customize app appearance and interface'**
  String get customizeAppAppearanceAndInterface;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @tapToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to change photo'**
  String get tapToChangePhoto;

  /// No description provided for @coverPhotoOptional.
  ///
  /// In en, this message translates to:
  /// **'Cover photo (optional)'**
  String get coverPhotoOptional;

  /// No description provided for @changeCover.
  ///
  /// In en, this message translates to:
  /// **'Change cover'**
  String get changeCover;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enterUsername;

  /// No description provided for @usernameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty'**
  String get usernameCannotBeEmpty;

  /// No description provided for @invalidUsername.
  ///
  /// In en, this message translates to:
  /// **'Invalid username (3-20 chars, letters, numbers, _)'**
  String get invalidUsername;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @enterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Enter display name'**
  String get enterDisplayName;

  /// No description provided for @displayNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Display name cannot be empty'**
  String get displayNameCannotBeEmpty;

  /// No description provided for @professionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Professional Info'**
  String get professionalInfo;

  /// No description provided for @enterYourQualificationsExperience.
  ///
  /// In en, this message translates to:
  /// **'Enter your qualifications, experience, etc.'**
  String get enterYourQualificationsExperience;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @requestToBeAVet.
  ///
  /// In en, this message translates to:
  /// **'Request to be a Vet'**
  String get requestToBeAVet;

  /// No description provided for @joinOurVeterinaryNetwork.
  ///
  /// In en, this message translates to:
  /// **'Join our veterinary network'**
  String get joinOurVeterinaryNetwork;

  /// No description provided for @requestToBeAStore.
  ///
  /// In en, this message translates to:
  /// **'Request to be a Store'**
  String get requestToBeAStore;

  /// No description provided for @sellPetProductsAndServices.
  ///
  /// In en, this message translates to:
  /// **'Sell pet products and services'**
  String get sellPetProductsAndServices;

  /// No description provided for @linkedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Linked Accounts'**
  String get linkedAccounts;

  /// No description provided for @linked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get linked;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @areYouSureYouWantToDeleteYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get areYouSureYouWantToDeleteYourAccount;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String failedToUpdateProfile(Object error);

  /// No description provided for @errorSelectingCover.
  ///
  /// In en, this message translates to:
  /// **'Error selecting cover: {error}'**
  String errorSelectingCover(Object error);

  /// No description provided for @savingChanges.
  ///
  /// In en, this message translates to:
  /// **'Saving changes...'**
  String get savingChanges;

  /// No description provided for @locationSharing.
  ///
  /// In en, this message translates to:
  /// **'Location Sharing'**
  String get locationSharing;

  /// No description provided for @allowAppToAccessYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow app to access your location for nearby services'**
  String get allowAppToAccessYourLocation;

  /// No description provided for @dataAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Data Analytics'**
  String get dataAnalytics;

  /// No description provided for @helpUsImproveBySharingAnonymousUsageData.
  ///
  /// In en, this message translates to:
  /// **'Help us improve by sharing anonymous usage data'**
  String get helpUsImproveBySharingAnonymousUsageData;

  /// No description provided for @profileVisibility.
  ///
  /// In en, this message translates to:
  /// **'Profile Visibility'**
  String get profileVisibility;

  /// No description provided for @controlWhoCanSeeYourProfileInformation.
  ///
  /// In en, this message translates to:
  /// **'Control who can see your profile information'**
  String get controlWhoCanSeeYourProfileInformation;

  /// No description provided for @dataAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataAndPrivacy;

  /// No description provided for @manageYourDataAndPrivacySettings.
  ///
  /// In en, this message translates to:
  /// **'Manage your data and privacy settings.'**
  String get manageYourDataAndPrivacySettings;

  /// No description provided for @receiveNotificationsAboutAppointmentsAndUpdates.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications about appointments and updates'**
  String get receiveNotificationsAboutAppointmentsAndUpdates;

  /// No description provided for @receiveImportantUpdatesViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Receive important updates via email'**
  String get receiveImportantUpdatesViaEmail;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// No description provided for @customizeWhatNotificationsYouReceive.
  ///
  /// In en, this message translates to:
  /// **'Customize what notifications you receive.'**
  String get customizeWhatNotificationsYouReceive;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @biometricAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricAuthentication;

  /// No description provided for @useFingerprintOrFaceIdToUnlockTheApp.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face ID to unlock the app'**
  String get useFingerprintOrFaceIdToUnlockTheApp;

  /// No description provided for @twoFactorAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuthentication;

  /// No description provided for @addAnExtraLayerOfSecurityToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Add an extra layer of security to your account'**
  String get addAnExtraLayerOfSecurityToYourAccount;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @updateYourAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get updateYourAccountPassword;

  /// No description provided for @activeSessions.
  ///
  /// In en, this message translates to:
  /// **'Active Sessions'**
  String get activeSessions;

  /// No description provided for @manageDevicesLoggedIntoYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage devices logged into your account.'**
  String get manageDevicesLoggedIntoYourAccount;

  /// No description provided for @dataAndStorage.
  ///
  /// In en, this message translates to:
  /// **'Data & Storage'**
  String get dataAndStorage;

  /// No description provided for @storageUsage.
  ///
  /// In en, this message translates to:
  /// **'Storage Usage'**
  String get storageUsage;

  /// No description provided for @manageAppDataAndCache.
  ///
  /// In en, this message translates to:
  /// **'Manage app data and cache.'**
  String get manageAppDataAndCache;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @downloadACopyOfYourData.
  ///
  /// In en, this message translates to:
  /// **'Download a copy of your data.'**
  String get downloadACopyOfYourData;

  /// No description provided for @permanentlyDeleteYourAccountAndData.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and data'**
  String get permanentlyDeleteYourAccountAndData;

  /// No description provided for @chooseWhoCanSeeYourProfileInformation.
  ///
  /// In en, this message translates to:
  /// **'Choose who can see your profile information.'**
  String get chooseWhoCanSeeYourProfileInformation;

  /// No description provided for @enterYourNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password.'**
  String get enterYourNewPassword;

  /// No description provided for @thisActionCannotBeUndoneAllYourDataWillBePermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data will be permanently deleted.'**
  String get thisActionCannotBeUndoneAllYourDataWillBePermanentlyDeleted;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @yourPetsFavouriteApp.
  ///
  /// In en, this message translates to:
  /// **'Your Pet\'s Favourite App'**
  String get yourPetsFavouriteApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @aboutAlifi.
  ///
  /// In en, this message translates to:
  /// **'About Alifi'**
  String get aboutAlifi;

  /// No description provided for @alifiIsAComprehensivePetCarePlatform.
  ///
  /// In en, this message translates to:
  /// **'Alifi is a comprehensive pet care platform that connects pet owners with veterinarians, pet stores, and other pet care services. Our mission is to make pet care accessible, convenient, and reliable for everyone.'**
  String get alifiIsAComprehensivePetCarePlatform;

  /// No description provided for @verifiedServices.
  ///
  /// In en, this message translates to:
  /// **'Verified Services'**
  String get verifiedServices;

  /// No description provided for @allVeterinariansAndPetStoresOnOurPlatformAreVerified.
  ///
  /// In en, this message translates to:
  /// **'All veterinarians and pet stores on our platform are verified to ensure the highest quality of care for your beloved pets.'**
  String get allVeterinariansAndPetStoresOnOurPlatformAreVerified;

  /// No description provided for @secureAndPrivate.
  ///
  /// In en, this message translates to:
  /// **'Secure & Private'**
  String get secureAndPrivate;

  /// No description provided for @yourDataAndYourPetsInformationAreProtected.
  ///
  /// In en, this message translates to:
  /// **'Your data and your pets\' information are protected with industry-standard security measures.'**
  String get yourDataAndYourPetsInformationAreProtected;

  /// No description provided for @contactAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact & Support'**
  String get contactAndSupport;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @phoneSupport.
  ///
  /// In en, this message translates to:
  /// **'Phone Support'**
  String get phoneSupport;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @readOurTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Read our terms and conditions'**
  String get readOurTermsAndConditions;

  /// No description provided for @learnAboutOurPrivacyPractices.
  ///
  /// In en, this message translates to:
  /// **'Learn about our privacy practices'**
  String get learnAboutOurPrivacyPractices;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developedBy;

  /// No description provided for @alifiDevelopmentTeam.
  ///
  /// In en, this message translates to:
  /// **'Alifi Development Team'**
  String get alifiDevelopmentTeam;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get copyright;

  /// No description provided for @copyrightText.
  ///
  /// In en, this message translates to:
  /// **'© 2024 Alifi. All rights reserved.'**
  String get copyrightText;

  /// No description provided for @phoneSupportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Phone support coming soon!'**
  String get phoneSupportComingSoon;

  /// No description provided for @websiteComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Website coming soon!'**
  String get websiteComingSoon;

  /// No description provided for @termsOfServiceComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service coming soon!'**
  String get termsOfServiceComingSoon;

  /// No description provided for @privacyPolicyComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy coming soon!'**
  String get privacyPolicyComingSoon;

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressBackAgainToExit;

  /// No description provided for @lostPetDetails.
  ///
  /// In en, this message translates to:
  /// **'Lost Pet Details'**
  String get lostPetDetails;

  /// No description provided for @fundraising.
  ///
  /// In en, this message translates to:
  /// **'Fundraising'**
  String get fundraising;

  /// No description provided for @animalShelterExpansion.
  ///
  /// In en, this message translates to:
  /// **'Animal Shelter Expansion'**
  String get animalShelterExpansion;

  /// No description provided for @helpUsExpandOurShelter.
  ///
  /// In en, this message translates to:
  /// **'Help us expand our shelter to accommodate more animals in need.'**
  String get helpUsExpandOurShelter;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @adoptionCenter.
  ///
  /// In en, this message translates to:
  /// **'Adoption Center'**
  String get adoptionCenter;

  /// No description provided for @ordersAndMessages.
  ///
  /// In en, this message translates to:
  /// **'Orders & Messages'**
  String get ordersAndMessages;

  /// No description provided for @becomeAVet.
  ///
  /// In en, this message translates to:
  /// **'Become a Vet'**
  String get becomeAVet;

  /// No description provided for @becomeAStore.
  ///
  /// In en, this message translates to:
  /// **'Become a Store'**
  String get becomeAStore;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @storeDashboard.
  ///
  /// In en, this message translates to:
  /// **'Store Dashboard'**
  String get storeDashboard;

  /// No description provided for @errorLoadingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Error loading dashboard'**
  String get errorLoadingDashboard;

  /// No description provided for @noDashboardDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No dashboard data available'**
  String get noDashboardDataAvailable;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @engagement.
  ///
  /// In en, this message translates to:
  /// **'Engagement'**
  String get engagement;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// No description provided for @activeOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get activeOrders;

  /// No description provided for @viewAllSellerTools.
  ///
  /// In en, this message translates to:
  /// **'View All Seller Tools'**
  String get viewAllSellerTools;

  /// No description provided for @vetDashboard.
  ///
  /// In en, this message translates to:
  /// **'Vet Dashboard'**
  String get vetDashboard;

  /// No description provided for @freeShipping.
  ///
  /// In en, this message translates to:
  /// **'Free Shipping'**
  String get freeShipping;

  /// No description provided for @viewStore.
  ///
  /// In en, this message translates to:
  /// **'View Store'**
  String get viewStore;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @addToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Add to wishlist'**
  String get addToWishlist;

  /// No description provided for @removeFromWishlist.
  ///
  /// In en, this message translates to:
  /// **'Remove from Wishlist'**
  String get removeFromWishlist;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @relatedProducts.
  ///
  /// In en, this message translates to:
  /// **'Related Products'**
  String get relatedProducts;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @selectQuantity.
  ///
  /// In en, this message translates to:
  /// **'Select Quantity'**
  String get selectQuantity;

  /// No description provided for @productImages.
  ///
  /// In en, this message translates to:
  /// **'Product Images'**
  String get productImages;

  /// No description provided for @shareProduct.
  ///
  /// In en, this message translates to:
  /// **'Share Product'**
  String get shareProduct;

  /// No description provided for @reportProduct.
  ///
  /// In en, this message translates to:
  /// **'Report Product'**
  String get reportProduct;

  /// No description provided for @sellerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Seller Dashboard'**
  String get sellerDashboard;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'orders'**
  String get orders;

  /// No description provided for @pleaseLogIn.
  ///
  /// In en, this message translates to:
  /// **'Please log in.'**
  String get pleaseLogIn;

  /// No description provided for @revenueAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Revenue Analytics'**
  String get revenueAnalytics;

  /// No description provided for @todaysSales.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sales'**
  String get todaysSales;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @keyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Key Metrics'**
  String get keyMetrics;

  /// No description provided for @uniqueCustomers.
  ///
  /// In en, this message translates to:
  /// **'Unique Customers'**
  String get uniqueCustomers;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @manageProducts.
  ///
  /// In en, this message translates to:
  /// **'Manage Products'**
  String get manageProducts;

  /// No description provided for @productAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Product Analytics'**
  String get productAnalytics;

  /// No description provided for @totalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get totalProducts;

  /// No description provided for @activeProducts.
  ///
  /// In en, this message translates to:
  /// **'Active Products'**
  String get activeProducts;

  /// No description provided for @soldProducts.
  ///
  /// In en, this message translates to:
  /// **'Sold Products'**
  String get soldProducts;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @createYourFirstProduct.
  ///
  /// In en, this message translates to:
  /// **'Create your first product'**
  String get createYourFirstProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @productDescription.
  ///
  /// In en, this message translates to:
  /// **'Product Description'**
  String get productDescription;

  /// No description provided for @productPrice.
  ///
  /// In en, this message translates to:
  /// **'Product Price'**
  String get productPrice;

  /// No description provided for @productCategory.
  ///
  /// In en, this message translates to:
  /// **'Product Category'**
  String get productCategory;

  /// No description provided for @saveProduct.
  ///
  /// In en, this message translates to:
  /// **'Save Product'**
  String get saveProduct;

  /// No description provided for @updateProduct.
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProduct;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @areYouSureDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get areYouSureDeleteProduct;

  /// No description provided for @productSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product saved successfully!'**
  String get productSavedSuccessfully;

  /// No description provided for @productUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully!'**
  String get productUpdatedSuccessfully;

  /// No description provided for @productDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully!'**
  String get productDeletedSuccessfully;

  /// No description provided for @errorSavingProduct.
  ///
  /// In en, this message translates to:
  /// **'Error saving product: {error}'**
  String errorSavingProduct(Object error);

  /// No description provided for @errorUpdatingProduct.
  ///
  /// In en, this message translates to:
  /// **'Error updating product: {error}'**
  String errorUpdatingProduct(Object error);

  /// No description provided for @errorDeletingProduct.
  ///
  /// In en, this message translates to:
  /// **'Error deleting product: {error}'**
  String errorDeletingProduct(Object error);

  /// No description provided for @noMessagesFound.
  ///
  /// In en, this message translates to:
  /// **'No messages found'**
  String get noMessagesFound;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get startConversation;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrdersFound;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get orderDate;

  /// No description provided for @orderTotal.
  ///
  /// In en, this message translates to:
  /// **'Order Total'**
  String get orderTotal;

  /// No description provided for @customerInfo.
  ///
  /// In en, this message translates to:
  /// **'Customer Info'**
  String get customerInfo;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get orderItems;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get shipped;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @readyForPickup.
  ///
  /// In en, this message translates to:
  /// **'Ready for Pickup'**
  String get readyForPickup;

  /// No description provided for @updateOrderStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Order Status'**
  String get updateOrderStatus;

  /// No description provided for @markAsShipped.
  ///
  /// In en, this message translates to:
  /// **'Mark as Shipped'**
  String get markAsShipped;

  /// No description provided for @markAsDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark as Delivered'**
  String get markAsDelivered;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @orderUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order updated successfully!'**
  String get orderUpdatedSuccessfully;

  /// No description provided for @errorUpdatingOrder.
  ///
  /// In en, this message translates to:
  /// **'Error updating order: {error}'**
  String errorUpdatingOrder(Object error);

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom...'**
  String get custom;

  /// No description provided for @enterAmountInDZD.
  ///
  /// In en, this message translates to:
  /// **'Enter amount in DZD'**
  String get enterAmountInDZD;

  /// No description provided for @payVia.
  ///
  /// In en, this message translates to:
  /// **'Pay via :'**
  String get payVia;

  /// No description provided for @discussion.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get discussion;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'typing...'**
  String get typing;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent'**
  String get messageSent;

  /// No description provided for @messageDelivered.
  ///
  /// In en, this message translates to:
  /// **'Message delivered'**
  String get messageDelivered;

  /// No description provided for @messageRead.
  ///
  /// In en, this message translates to:
  /// **'Message read'**
  String get messageRead;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessage;

  /// No description provided for @unreadMessages.
  ///
  /// In en, this message translates to:
  /// **'Unread messages'**
  String get unreadMessages;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get deleteMessage;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get reportUser;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get clearChat;

  /// No description provided for @chatCleared.
  ///
  /// In en, this message translates to:
  /// **'Chat cleared'**
  String get chatCleared;

  /// No description provided for @userBlocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked'**
  String get userBlocked;

  /// No description provided for @userReported.
  ///
  /// In en, this message translates to:
  /// **'User reported'**
  String get userReported;

  /// No description provided for @errorSendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Error sending message: {error}'**
  String errorSendingMessage(Object error);

  /// No description provided for @errorLoadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Error loading messages: {error}'**
  String errorLoadingMessages(Object error);

  /// No description provided for @appointmentInProgress.
  ///
  /// In en, this message translates to:
  /// **'Appointment in Progress'**
  String get appointmentInProgress;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @endNow.
  ///
  /// In en, this message translates to:
  /// **'End Now'**
  String get endNow;

  /// No description provided for @elapsedTime.
  ///
  /// In en, this message translates to:
  /// **'Elapsed Time'**
  String get elapsedTime;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @delay.
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get delay;

  /// No description provided for @appointmentStarting.
  ///
  /// In en, this message translates to:
  /// **'Appointment Starting'**
  String get appointmentStarting;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @startAppointment.
  ///
  /// In en, this message translates to:
  /// **'Start Appointment'**
  String get startAppointment;

  /// No description provided for @appointmentStarted.
  ///
  /// In en, this message translates to:
  /// **'Appointment started for {petName}'**
  String appointmentStarted(Object petName);

  /// No description provided for @errorStartingAppointment.
  ///
  /// In en, this message translates to:
  /// **'Error starting appointment: {error}'**
  String errorStartingAppointment(Object error);

  /// No description provided for @appointmentRevenue.
  ///
  /// In en, this message translates to:
  /// **'Appointment Revenue'**
  String get appointmentRevenue;

  /// No description provided for @howMuchEarned.
  ///
  /// In en, this message translates to:
  /// **'How much did you earn from {petName}\'s appointment?'**
  String howMuchEarned(Object petName);

  /// No description provided for @revenueAmount.
  ///
  /// In en, this message translates to:
  /// **'Revenue Amount'**
  String get revenueAmount;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount (e.g., 150)'**
  String get enterAmount;

  /// No description provided for @revenueAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Revenue of {amount} added successfully!'**
  String revenueAddedSuccessfully(Object amount);

  /// No description provided for @pleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterValidAmount;

  /// No description provided for @errorAddingRevenue.
  ///
  /// In en, this message translates to:
  /// **'Error adding revenue: {error}'**
  String errorAddingRevenue(Object error);

  /// No description provided for @noAppointmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No appointments found'**
  String get noAppointmentsFound;

  /// No description provided for @yourScheduleIsClear.
  ///
  /// In en, this message translates to:
  /// **'Your schedule is clear'**
  String get yourScheduleIsClear;

  /// No description provided for @upcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointments'**
  String get upcomingAppointments;

  /// No description provided for @completedAppointments.
  ///
  /// In en, this message translates to:
  /// **'Completed Appointments'**
  String get completedAppointments;

  /// No description provided for @cancelledAppointments.
  ///
  /// In en, this message translates to:
  /// **'Cancelled Appointments'**
  String get cancelledAppointments;

  /// No description provided for @searchPatients.
  ///
  /// In en, this message translates to:
  /// **'Search patients...'**
  String get searchPatients;

  /// No description provided for @activePatients.
  ///
  /// In en, this message translates to:
  /// **'Active Patients'**
  String get activePatients;

  /// No description provided for @newThisMonth.
  ///
  /// In en, this message translates to:
  /// **'New This Month'**
  String get newThisMonth;

  /// No description provided for @myPatients.
  ///
  /// In en, this message translates to:
  /// **'My Patients'**
  String get myPatients;

  /// No description provided for @noPatientsFound.
  ///
  /// In en, this message translates to:
  /// **'No patients found'**
  String get noPatientsFound;

  /// No description provided for @avgAppointmentDuration.
  ///
  /// In en, this message translates to:
  /// **'Avg. Appointment Duration'**
  String get avgAppointmentDuration;

  /// No description provided for @patientSatisfaction.
  ///
  /// In en, this message translates to:
  /// **'Patient Satisfaction'**
  String get patientSatisfaction;

  /// No description provided for @appointmentStatus.
  ///
  /// In en, this message translates to:
  /// **'Appointment Status'**
  String get appointmentStatus;

  /// No description provided for @appointmentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Appointment completed'**
  String get appointmentCompleted;

  /// No description provided for @newPatientRegistered.
  ///
  /// In en, this message translates to:
  /// **'New patient registered'**
  String get newPatientRegistered;

  /// No description provided for @vaccinationGiven.
  ///
  /// In en, this message translates to:
  /// **'Vaccination given'**
  String get vaccinationGiven;

  /// No description provided for @surgeryScheduled.
  ///
  /// In en, this message translates to:
  /// **'Surgery scheduled'**
  String get surgeryScheduled;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get accessDenied;

  /// No description provided for @thisPageIsOnlyAvailableForVeterinaryAccounts.
  ///
  /// In en, this message translates to:
  /// **'This page is only available for veterinary accounts.'**
  String get thisPageIsOnlyAvailableForVeterinaryAccounts;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @patients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patients;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @todaysAppoint.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Appoint.'**
  String get todaysAppoint;

  /// No description provided for @totalPatients.
  ///
  /// In en, this message translates to:
  /// **'Total Patients'**
  String get totalPatients;

  /// No description provided for @revenueToday.
  ///
  /// In en, this message translates to:
  /// **'Revenue Today'**
  String get revenueToday;

  /// No description provided for @nextAppoint.
  ///
  /// In en, this message translates to:
  /// **'Next Appoint.'**
  String get nextAppoint;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @scheduleAppointment.
  ///
  /// In en, this message translates to:
  /// **'Schedule Appointment'**
  String get scheduleAppointment;

  /// No description provided for @addPatient.
  ///
  /// In en, this message translates to:
  /// **'Add Patient'**
  String get addPatient;

  /// No description provided for @viewRecords.
  ///
  /// In en, this message translates to:
  /// **'View Records'**
  String get viewRecords;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @affiliateDisclosureText.
  ///
  /// In en, this message translates to:
  /// **'This product is available through our affiliate partnership with AliExpress. When you make a purchase through these links, you help support our app at no additional cost to you. Thank you for helping us keep this app running!'**
  String get affiliateDisclosureText;

  /// No description provided for @customerReviews.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews'**
  String get customerReviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @beTheFirstToReviewThisProduct.
  ///
  /// In en, this message translates to:
  /// **'Be the first to review this product'**
  String get beTheFirstToReviewThisProduct;

  /// No description provided for @errorLoadingReviews.
  ///
  /// In en, this message translates to:
  /// **'Error loading reviews: {error}'**
  String errorLoadingReviews(Object error);

  /// No description provided for @noRelatedProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No related products found'**
  String get noRelatedProductsFound;

  /// No description provided for @iDontHaveACreditCard.
  ///
  /// In en, this message translates to:
  /// **'(i don\'t have a credit card)'**
  String get iDontHaveACreditCard;

  /// No description provided for @howDoesItWork.
  ///
  /// In en, this message translates to:
  /// **'How does it work'**
  String get howDoesItWork;

  /// No description provided for @howItWorksText.
  ///
  /// In en, this message translates to:
  /// **'You enter your address, and your city and then you make sure you send MONEY_AMOUNT to this ccp address 000000000000000000000000000000 and then send the proof of payment in this email payment@alifi.app, we\'ll make sure to get your product shipped as soon as possible'**
  String get howItWorksText;

  /// No description provided for @enterYourAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your address'**
  String get enterYourAddress;

  /// No description provided for @selectYourCity.
  ///
  /// In en, this message translates to:
  /// **'Select your city'**
  String get selectYourCity;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @ordered.
  ///
  /// In en, this message translates to:
  /// **'Ordered'**
  String get ordered;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @searchStores.
  ///
  /// In en, this message translates to:
  /// **'Search stores...'**
  String get searchStores;

  /// No description provided for @searchVets.
  ///
  /// In en, this message translates to:
  /// **'Search vets...'**
  String get searchVets;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @storeProfile.
  ///
  /// In en, this message translates to:
  /// **'Store Profile'**
  String get storeProfile;

  /// No description provided for @vetProfile.
  ///
  /// In en, this message translates to:
  /// **'Vet Profile'**
  String get vetProfile;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get contactInfo;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get thisActionCannotBeUndone;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @errorDeletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account: {error}'**
  String errorDeletingAccount(Object error);

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @errorChangingPassword.
  ///
  /// In en, this message translates to:
  /// **'Error changing password: {error}'**
  String errorChangingPassword(Object error);

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @errorUpdatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile: {error}'**
  String errorUpdatingProfile(Object error);

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get weakPassword;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later'**
  String get tooManyRequests;

  /// No description provided for @operationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Operation not allowed'**
  String get operationNotAllowed;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection'**
  String get networkError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @searchPeoplePetsVets.
  ///
  /// In en, this message translates to:
  /// **'Search people, pets, vets...'**
  String get searchPeoplePetsVets;

  /// No description provided for @recommendedVetsAndStores.
  ///
  /// In en, this message translates to:
  /// **'Recommended Vets and Stores'**
  String get recommendedVetsAndStores;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @noRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'No recent searches'**
  String get noRecentSearches;

  /// No description provided for @trySearchingWithDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try searching with different keywords'**
  String get trySearchingWithDifferentKeywords;

  /// No description provided for @errorSearchingUsers.
  ///
  /// In en, this message translates to:
  /// **'Error searching users: {error}'**
  String errorSearchingUsers(Object error);

  /// No description provided for @myMessages.
  ///
  /// In en, this message translates to:
  /// **'My Messages'**
  String get myMessages;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @startDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Start a discussion'**
  String get startDiscussion;

  /// No description provided for @sendMessageToStore.
  ///
  /// In en, this message translates to:
  /// **'Send a message to {storeName}'**
  String sendMessageToStore(Object storeName);

  /// No description provided for @failedToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message: {error}'**
  String failedToSendMessage(Object error);

  /// No description provided for @pleaseSignInToFollowUsers.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to follow users'**
  String get pleaseSignInToFollowUsers;

  /// No description provided for @errorUpdatingFollowStatus.
  ///
  /// In en, this message translates to:
  /// **'Error updating follow status: {error}'**
  String errorUpdatingFollowStatus(Object error);

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @viewInMap.
  ///
  /// In en, this message translates to:
  /// **'View in Map'**
  String get viewInMap;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @mutualFriends.
  ///
  /// In en, this message translates to:
  /// **'Mutual Friends'**
  String get mutualFriends;

  /// No description provided for @shareProfile.
  ///
  /// In en, this message translates to:
  /// **'Share Profile'**
  String get shareProfile;

  /// No description provided for @copyProfileLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Profile Link'**
  String get copyProfileLink;

  /// No description provided for @profileLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Profile link copied to clipboard'**
  String get profileLinkCopied;

  /// No description provided for @errorCopyingProfileLink.
  ///
  /// In en, this message translates to:
  /// **'Error copying profile link'**
  String get errorCopyingProfileLink;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPostsYet;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get noPhotosYet;

  /// No description provided for @noVideosYet.
  ///
  /// In en, this message translates to:
  /// **'No videos yet'**
  String get noVideosYet;

  /// No description provided for @noFriendsYet.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get noFriendsYet;

  /// No description provided for @noMutualFriends.
  ///
  /// In en, this message translates to:
  /// **'No mutual friends'**
  String get noMutualFriends;

  /// No description provided for @loadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get loadingProfile;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile: {error}'**
  String errorLoadingProfile(Object error);

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get profileNotFound;

  /// No description provided for @accountSuspended.
  ///
  /// In en, this message translates to:
  /// **'Account suspended'**
  String get accountSuspended;

  /// No description provided for @accountPrivate.
  ///
  /// In en, this message translates to:
  /// **'This account is private'**
  String get accountPrivate;

  /// No description provided for @followToSeeContent.
  ///
  /// In en, this message translates to:
  /// **'Follow to see content'**
  String get followToSeeContent;

  /// No description provided for @requestToFollow.
  ///
  /// In en, this message translates to:
  /// **'Request to Follow'**
  String get requestToFollow;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get requestSent;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @acceptRequest.
  ///
  /// In en, this message translates to:
  /// **'Accept Request'**
  String get acceptRequest;

  /// No description provided for @declineRequest.
  ///
  /// In en, this message translates to:
  /// **'Decline Request'**
  String get declineRequest;

  /// No description provided for @removeFollower.
  ///
  /// In en, this message translates to:
  /// **'Remove Follower'**
  String get removeFollower;

  /// No description provided for @muteUser.
  ///
  /// In en, this message translates to:
  /// **'Mute User'**
  String get muteUser;

  /// No description provided for @unmuteUser.
  ///
  /// In en, this message translates to:
  /// **'Unmute User'**
  String get unmuteUser;

  /// No description provided for @userMuted.
  ///
  /// In en, this message translates to:
  /// **'User muted'**
  String get userMuted;

  /// No description provided for @userUnmuted.
  ///
  /// In en, this message translates to:
  /// **'User unmuted'**
  String get userUnmuted;

  /// No description provided for @errorMutingUser.
  ///
  /// In en, this message translates to:
  /// **'Error muting user: {error}'**
  String errorMutingUser(Object error);

  /// No description provided for @errorUnmutingUser.
  ///
  /// In en, this message translates to:
  /// **'Error unmuting user: {error}'**
  String errorUnmutingUser(Object error);

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @yourRecentProfileVisitsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your recent profile visits will appear here'**
  String get yourRecentProfileVisitsWillAppearHere;

  /// No description provided for @noProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsYet;

  /// No description provided for @noPetsYet.
  ///
  /// In en, this message translates to:
  /// **'No pets yet'**
  String get noPetsYet;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @sendAMessage.
  ///
  /// In en, this message translates to:
  /// **'Send a message'**
  String get sendAMessage;

  /// No description provided for @reportAccount.
  ///
  /// In en, this message translates to:
  /// **'Report account'**
  String get reportAccount;

  /// No description provided for @pleaseSignInToSendMessages.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to send messages'**
  String get pleaseSignInToSendMessages;

  /// No description provided for @helpUsUnderstandWhatsHappening.
  ///
  /// In en, this message translates to:
  /// **'Help us understand what\'s happening'**
  String get helpUsUnderstandWhatsHappening;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @whyAreYouReportingThisAccount.
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this account?'**
  String get whyAreYouReportingThisAccount;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @spamOrUnwantedContent.
  ///
  /// In en, this message translates to:
  /// **'Spam or unwanted content'**
  String get spamOrUnwantedContent;

  /// No description provided for @inappropriateBehavior.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate behavior'**
  String get inappropriateBehavior;

  /// No description provided for @fakeOrMisleadingInformation.
  ///
  /// In en, this message translates to:
  /// **'Fake or misleading information'**
  String get fakeOrMisleadingInformation;

  /// No description provided for @harassmentOrBullying.
  ///
  /// In en, this message translates to:
  /// **'Harassment or bullying'**
  String get harassmentOrBullying;

  /// No description provided for @scamOrFraud.
  ///
  /// In en, this message translates to:
  /// **'Scam or fraud'**
  String get scamOrFraud;

  /// No description provided for @hateSpeechOrSymbols.
  ///
  /// In en, this message translates to:
  /// **'Hate speech or symbols'**
  String get hateSpeechOrSymbols;

  /// No description provided for @violenceOrDangerousContent.
  ///
  /// In en, this message translates to:
  /// **'Violence or dangerous content'**
  String get violenceOrDangerousContent;

  /// No description provided for @intellectualPropertyViolation.
  ///
  /// In en, this message translates to:
  /// **'Intellectual property violation'**
  String get intellectualPropertyViolation;

  /// No description provided for @reportSubmittedFor.
  ///
  /// In en, this message translates to:
  /// **'Report submitted for {user}'**
  String reportSubmittedFor(Object user);

  /// No description provided for @marketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// No description provided for @searchItemsProducts.
  ///
  /// In en, this message translates to:
  /// **'Search items, products...'**
  String get searchItemsProducts;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @toys.
  ///
  /// In en, this message translates to:
  /// **'Toys'**
  String get toys;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @beds.
  ///
  /// In en, this message translates to:
  /// **'Beds'**
  String get beds;

  /// No description provided for @hygiene.
  ///
  /// In en, this message translates to:
  /// **'Hygiene'**
  String get hygiene;

  /// No description provided for @mostOrders.
  ///
  /// In en, this message translates to:
  /// **'Most Orders'**
  String get mostOrders;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get priceHighToLow;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategory;

  /// No description provided for @newListings.
  ///
  /// In en, this message translates to:
  /// **'New Listings'**
  String get newListings;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @popularProducts.
  ///
  /// In en, this message translates to:
  /// **'Popular Products'**
  String get popularProducts;

  /// No description provided for @noProductsFoundFor.
  ///
  /// In en, this message translates to:
  /// **'No products found for \"{query}\"'**
  String noProductsFoundFor(Object query);

  /// No description provided for @noRecommendedProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No recommended products available'**
  String get noRecommendedProductsAvailable;

  /// No description provided for @noPopularProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No popular products available'**
  String get noPopularProductsAvailable;

  /// No description provided for @viewAllVetTools.
  ///
  /// In en, this message translates to:
  /// **'View All Vet Tools'**
  String get viewAllVetTools;

  /// No description provided for @weveRaised.
  ///
  /// In en, this message translates to:
  /// **'We\'ve raised {amount} DZD!'**
  String weveRaised(Object amount);

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @contribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get contribute;

  /// No description provided for @hiAskMeAboutAnyPetAdvice.
  ///
  /// In en, this message translates to:
  /// **'Hi! ask me about any pet advice,\nand I\'ll do my best to help you, and\nyour little one!'**
  String get hiAskMeAboutAnyPetAdvice;

  /// No description provided for @tapToChat.
  ///
  /// In en, this message translates to:
  /// **'Tap to chat...'**
  String get tapToChat;

  /// No description provided for @sorryIEncounteredAnError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I encountered an error. Please try again.'**
  String get sorryIEncounteredAnError;

  /// No description provided for @youMayBeInterested.
  ///
  /// In en, this message translates to:
  /// **'You may be Interested'**
  String get youMayBeInterested;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @errorLoadingProducts.
  ///
  /// In en, this message translates to:
  /// **'Error loading products'**
  String get errorLoadingProducts;

  /// No description provided for @noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No products available'**
  String get noProductsAvailable;

  /// No description provided for @loadingCombinedProducts.
  ///
  /// In en, this message translates to:
  /// **'Loading combined products...'**
  String get loadingCombinedProducts;

  /// No description provided for @loadedAliExpressProducts.
  ///
  /// In en, this message translates to:
  /// **'Loaded {count} AliExpress products'**
  String loadedAliExpressProducts(Object count);

  /// No description provided for @errorLoadingAliExpressProducts.
  ///
  /// In en, this message translates to:
  /// **'Error loading AliExpress products: {error}'**
  String errorLoadingAliExpressProducts(Object error);

  /// No description provided for @loadedStoreProducts.
  ///
  /// In en, this message translates to:
  /// **'Loaded {count} store products'**
  String loadedStoreProducts(Object count);

  /// No description provided for @errorLoadingStoreProducts.
  ///
  /// In en, this message translates to:
  /// **'Error loading store products: {error}'**
  String errorLoadingStoreProducts(Object error);

  /// No description provided for @noProductsFoundFromEitherSource.
  ///
  /// In en, this message translates to:
  /// **'No products found from either source'**
  String get noProductsFoundFromEitherSource;

  /// No description provided for @creatingMockDataForTesting.
  ///
  /// In en, this message translates to:
  /// **'Creating mock data for testing...'**
  String get creatingMockDataForTesting;

  /// No description provided for @totalCombinedProducts.
  ///
  /// In en, this message translates to:
  /// **'Total combined products: {count}'**
  String totalCombinedProducts(Object count);

  /// No description provided for @errorInGetCombinedProducts.
  ///
  /// In en, this message translates to:
  /// **'Error in _getCombinedProducts: {error}'**
  String errorInGetCombinedProducts(Object error);

  /// No description provided for @petToySet.
  ///
  /// In en, this message translates to:
  /// **'Pet Toy Set'**
  String get petToySet;

  /// No description provided for @interactiveToysForPets.
  ///
  /// In en, this message translates to:
  /// **'Interactive toys for pets'**
  String get interactiveToysForPets;

  /// No description provided for @petFoodBowl.
  ///
  /// In en, this message translates to:
  /// **'Pet Food Bowl'**
  String get petFoodBowl;

  /// No description provided for @stainlessSteelFoodBowl.
  ///
  /// In en, this message translates to:
  /// **'Stainless steel food bowl'**
  String get stainlessSteelFoodBowl;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minute;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @ago.
  ///
  /// In en, this message translates to:
  /// **'ago'**
  String get ago;

  /// No description provided for @totalAppointments.
  ///
  /// In en, this message translates to:
  /// **'Total Appointments'**
  String get totalAppointments;

  /// No description provided for @newPatients.
  ///
  /// In en, this message translates to:
  /// **'New Patients'**
  String get newPatients;

  /// No description provided for @emergencyCases.
  ///
  /// In en, this message translates to:
  /// **'Emergency Cases'**
  String get emergencyCases;

  /// No description provided for @noAppointmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No appointments yet'**
  String get noAppointmentsYet;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @howMuchDidYouEarnFromAppointment.
  ///
  /// In en, this message translates to:
  /// **'How much did you earn from {petName}\'s appointment?'**
  String howMuchDidYouEarnFromAppointment(Object petName);

  /// No description provided for @pleaseEnterAValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterAValidAmount;

  /// No description provided for @revenueOfAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Revenue of {amount} added successfully!'**
  String revenueOfAddedSuccessfully(Object amount);

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// No description provided for @appointmentStartedFor.
  ///
  /// In en, this message translates to:
  /// **'Appointment started for {petName}'**
  String appointmentStartedFor(Object petName);

  /// No description provided for @errorCompletingAppointment.
  ///
  /// In en, this message translates to:
  /// **'Error completing appointment: {error}'**
  String errorCompletingAppointment(Object error);

  /// No description provided for @salesAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Sales Analytics'**
  String get salesAnalytics;

  /// No description provided for @youHaveNoProductsYet.
  ///
  /// In en, this message translates to:
  /// **'You have no products yet.'**
  String get youHaveNoProductsYet;

  /// No description provided for @contributeWith.
  ///
  /// In en, this message translates to:
  /// **'Contribute with :'**
  String get contributeWith;

  /// No description provided for @shippingFeeApplies.
  ///
  /// In en, this message translates to:
  /// **'Shipping fee applies'**
  String get shippingFeeApplies;

  /// No description provided for @deliveryInDays.
  ///
  /// In en, this message translates to:
  /// **'Delivery in {days} days'**
  String deliveryInDays(Object days);

  /// No description provided for @storeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Store not found'**
  String get storeNotFound;

  /// No description provided for @buyAsAGift.
  ///
  /// In en, this message translates to:
  /// **'Buy as a Gift'**
  String get buyAsAGift;

  /// No description provided for @affiliateDisclosure.
  ///
  /// In en, this message translates to:
  /// **'Affiliate Disclosure'**
  String get affiliateDisclosure;

  /// No description provided for @youMayBeInterestedToo.
  ///
  /// In en, this message translates to:
  /// **'You may be interested too'**
  String get youMayBeInterestedToo;

  /// No description provided for @contactStore.
  ///
  /// In en, this message translates to:
  /// **'Contact Store'**
  String get contactStore;

  /// No description provided for @buyItForMe.
  ///
  /// In en, this message translates to:
  /// **'Buy it for me'**
  String get buyItForMe;

  /// No description provided for @vetInformation.
  ///
  /// In en, this message translates to:
  /// **'Vet Information'**
  String get vetInformation;

  /// No description provided for @petId.
  ///
  /// In en, this message translates to:
  /// **'Pet ID'**
  String get petId;

  /// No description provided for @editPets.
  ///
  /// In en, this message translates to:
  /// **'Edit Pets'**
  String get editPets;

  /// No description provided for @editExistingPet.
  ///
  /// In en, this message translates to:
  /// **'Edit existing pet'**
  String get editExistingPet;

  /// No description provided for @whatsYourPetsName.
  ///
  /// In en, this message translates to:
  /// **'What\'s your pet\'s name?'**
  String get whatsYourPetsName;

  /// No description provided for @petsName.
  ///
  /// In en, this message translates to:
  /// **'Pet\'s name'**
  String get petsName;

  /// No description provided for @whatBreedIsYourPet.
  ///
  /// In en, this message translates to:
  /// **'What breed is your pet?'**
  String get whatBreedIsYourPet;

  /// No description provided for @petsBreed.
  ///
  /// In en, this message translates to:
  /// **'Pet\'s breed'**
  String get petsBreed;

  /// No description provided for @selectPetType.
  ///
  /// In en, this message translates to:
  /// **'Select Pet Type'**
  String get selectPetType;

  /// No description provided for @dog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get dog;

  /// No description provided for @cat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get cat;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @selectBirthday.
  ///
  /// In en, this message translates to:
  /// **'Select Birthday'**
  String get selectBirthday;

  /// No description provided for @selectWeight.
  ///
  /// In en, this message translates to:
  /// **'Select Weight'**
  String get selectWeight;

  /// No description provided for @selectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Select Photo'**
  String get selectPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @lbs.
  ///
  /// In en, this message translates to:
  /// **'lbs'**
  String get lbs;

  /// No description provided for @monthsOld.
  ///
  /// In en, this message translates to:
  /// **'months old'**
  String get monthsOld;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @pleaseFillInAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillInAllFields;

  /// No description provided for @startingSaveProcess.
  ///
  /// In en, this message translates to:
  /// **'Starting save process...'**
  String get startingSaveProcess;

  /// No description provided for @uploadingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo...'**
  String get uploadingPhoto;

  /// No description provided for @savingToDatabase.
  ///
  /// In en, this message translates to:
  /// **'Saving to database...'**
  String get savingToDatabase;

  /// No description provided for @errorAddingPet.
  ///
  /// In en, this message translates to:
  /// **'Error adding pet: {error}'**
  String errorAddingPet(Object error);

  /// No description provided for @vaccines.
  ///
  /// In en, this message translates to:
  /// **'Vaccines'**
  String get vaccines;

  /// No description provided for @illness.
  ///
  /// In en, this message translates to:
  /// **'Illness'**
  String get illness;

  /// No description provided for @coreVaccines.
  ///
  /// In en, this message translates to:
  /// **'Core Vaccines'**
  String get coreVaccines;

  /// No description provided for @nonCoreVaccines.
  ///
  /// In en, this message translates to:
  /// **'Non-Core Vaccines'**
  String get nonCoreVaccines;

  /// No description provided for @addVaccine.
  ///
  /// In en, this message translates to:
  /// **'Add Vaccine'**
  String get addVaccine;

  /// No description provided for @logAnIllness.
  ///
  /// In en, this message translates to:
  /// **'Log an Illness'**
  String get logAnIllness;

  /// No description provided for @noLoggedVaccines.
  ///
  /// In en, this message translates to:
  /// **'No logged vaccines for this pet'**
  String get noLoggedVaccines;

  /// No description provided for @noLoggedIllnesses.
  ///
  /// In en, this message translates to:
  /// **'No logged illnesses for this pet'**
  String get noLoggedIllnesses;

  /// No description provided for @noLoggedChronicIllnesses.
  ///
  /// In en, this message translates to:
  /// **'No logged chronic illnesses for this pet'**
  String get noLoggedChronicIllnesses;

  /// No description provided for @vaccineAdded.
  ///
  /// In en, this message translates to:
  /// **'Vaccine added!'**
  String get vaccineAdded;

  /// No description provided for @failedToAddVaccine.
  ///
  /// In en, this message translates to:
  /// **'Failed to add vaccine: {error}'**
  String failedToAddVaccine(Object error);

  /// No description provided for @illnessAdded.
  ///
  /// In en, this message translates to:
  /// **'Illness added!'**
  String get illnessAdded;

  /// No description provided for @failedToAddIllness.
  ///
  /// In en, this message translates to:
  /// **'Failed to add illness: {error}'**
  String failedToAddIllness(Object error);

  /// No description provided for @vaccineUpdated.
  ///
  /// In en, this message translates to:
  /// **'Vaccine updated!'**
  String get vaccineUpdated;

  /// No description provided for @failedToUpdateVaccine.
  ///
  /// In en, this message translates to:
  /// **'Failed to update vaccine: {error}'**
  String failedToUpdateVaccine(Object error);

  /// No description provided for @illnessUpdated.
  ///
  /// In en, this message translates to:
  /// **'Illness updated!'**
  String get illnessUpdated;

  /// No description provided for @failedToUpdateIllness.
  ///
  /// In en, this message translates to:
  /// **'Failed to update illness: {error}'**
  String failedToUpdateIllness(Object error);

  /// No description provided for @vaccineDeleted.
  ///
  /// In en, this message translates to:
  /// **'Vaccine deleted!'**
  String get vaccineDeleted;

  /// No description provided for @failedToDeleteVaccine.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete vaccine: {error}'**
  String failedToDeleteVaccine(Object error);

  /// No description provided for @illnessDeleted.
  ///
  /// In en, this message translates to:
  /// **'Illness deleted!'**
  String get illnessDeleted;

  /// No description provided for @failedToDeleteIllness.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete illness: {error}'**
  String failedToDeleteIllness(Object error);

  /// No description provided for @selectVaccineType.
  ///
  /// In en, this message translates to:
  /// **'Select Vaccine Type'**
  String get selectVaccineType;

  /// No description provided for @selectIllnessType.
  ///
  /// In en, this message translates to:
  /// **'Select Illness Type'**
  String get selectIllnessType;

  /// No description provided for @addNotes.
  ///
  /// In en, this message translates to:
  /// **'Add Notes'**
  String get addNotes;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @chronicIllnesses.
  ///
  /// In en, this message translates to:
  /// **'Chronic Illnesses'**
  String get chronicIllnesses;

  /// No description provided for @illnesses.
  ///
  /// In en, this message translates to:
  /// **'Illnesses'**
  String get illnesses;

  /// No description provided for @selectPetForPetId.
  ///
  /// In en, this message translates to:
  /// **'Select the pet you want to request the pet ID for'**
  String get selectPetForPetId;

  /// No description provided for @pleaseSelectPetFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a pet first'**
  String get pleaseSelectPetFirst;

  /// No description provided for @petIdRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Pet ID request submitted successfully!'**
  String get petIdRequestSubmitted;

  /// No description provided for @yourPetIdIsBeingProcessed.
  ///
  /// In en, this message translates to:
  /// **'Your pet ID is being processed and made, please remain patient'**
  String get yourPetIdIsBeingProcessed;

  /// No description provided for @petIdManagement.
  ///
  /// In en, this message translates to:
  /// **'Pet ID Management'**
  String get petIdManagement;

  /// No description provided for @digitalPetIds.
  ///
  /// In en, this message translates to:
  /// **'Digital Pet IDs'**
  String get digitalPetIds;

  /// No description provided for @physicalPetIds.
  ///
  /// In en, this message translates to:
  /// **'Physical Pet IDs'**
  String get physicalPetIds;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @editPhysicalPetId.
  ///
  /// In en, this message translates to:
  /// **'Edit Physical Pet ID'**
  String get editPhysicalPetId;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @processingStatus.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processingStatus;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @petIdStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Pet ID status updated successfully'**
  String get petIdStatusUpdated;

  /// No description provided for @errorUpdatingPetId.
  ///
  /// In en, this message translates to:
  /// **'Error updating pet ID: {error}'**
  String errorUpdatingPetId(Object error);

  /// No description provided for @physicalPetIdRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Physical pet ID request submitted successfully! You will be contacted for payment.'**
  String get physicalPetIdRequestSubmitted;

  /// No description provided for @requestPhysicalPetId.
  ///
  /// In en, this message translates to:
  /// **'Request Physical Pet ID'**
  String get requestPhysicalPetId;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @zipCode.
  ///
  /// In en, this message translates to:
  /// **'Zip Code'**
  String get zipCode;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @errorCheckingPetIdStatus.
  ///
  /// In en, this message translates to:
  /// **'Error checking pet ID status: {error}'**
  String errorCheckingPetIdStatus(Object error);

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @resultsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} results found'**
  String resultsFound(Object count);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
