import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_dz.dart';
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
    Locale('dz'),
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
  /// **'AI pet assistant'**
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
  /// **'Enter Custom Amount'**
  String get enterCustomAmount;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location Services Disabled'**
  String get locationServicesDisabled;

  /// No description provided for @pleaseEnableLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services'**
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

  /// Report missing pet dialog related strings
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
  /// **'AuthService initialized: {status}'**
  String authServiceInitialized(Object status);

  /// No description provided for @authServiceLoading.
  ///
  /// In en, this message translates to:
  /// **'AuthService loading: {status}'**
  String authServiceLoading(Object status);

  /// No description provided for @authServiceAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'AuthService authenticated: {status}'**
  String authServiceAuthenticated(Object status);

  /// No description provided for @authServiceUser.
  ///
  /// In en, this message translates to:
  /// **'AuthService user: {email}'**
  String authServiceUser(Object email);

  /// No description provided for @firebaseUser.
  ///
  /// In en, this message translates to:
  /// **'Firebase user: {email}'**
  String firebaseUser(Object email);

  /// No description provided for @guestMode.
  ///
  /// In en, this message translates to:
  /// **'Guest mode: {status}'**
  String guestMode(Object status);

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
  /// **'Error: {message}'**
  String error(Object error, Object message);

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen {time}'**
  String lastSeen(Object location, Object time);

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
  /// **'vet'**
  String get vet;

  /// No description provided for @vetsNearMe.
  ///
  /// In en, this message translates to:
  /// **'Vets Near Me'**
  String get vetsNearMe;

  /// No description provided for @recommendedVets.
  ///
  /// In en, this message translates to:
  /// **'Recommended Vets'**
  String get recommendedVets;

  /// No description provided for @topVets.
  ///
  /// In en, this message translates to:
  /// **'Top Vets'**
  String get topVets;

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
  /// **'Pet Stores'**
  String get petStore;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

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
  /// **'today'**
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
  /// **'Please fill in all required fields (photo, name, and description)'**
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
  /// **'No users found'**
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
  /// **'Inappropriate Content'**
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

  /// No description provided for @useLiquidGlassEffectForTabBar.
  ///
  /// In en, this message translates to:
  /// **'Use liquid glass effect for Tab bar'**
  String get useLiquidGlassEffectForTabBar;

  /// No description provided for @enableLiquidGlassEffectOnNavigationBar.
  ///
  /// In en, this message translates to:
  /// **'Enable liquid glass effect on the navigation bar'**
  String get enableLiquidGlassEffectOnNavigationBar;

  /// No description provided for @whenDisabledLiquidGlassTabBarWillNotDistortBackground.
  ///
  /// In en, this message translates to:
  /// **'When disabled, the tab bar will not distort the background content. Works separately from the blur effect.'**
  String get whenDisabledLiquidGlassTabBarWillNotDistortBackground;

  /// No description provided for @useSolidColorForTabBar.
  ///
  /// In en, this message translates to:
  /// **'Use solid color for Tab bar'**
  String get useSolidColorForTabBar;

  /// No description provided for @enableSolidColorOnNavigationBar.
  ///
  /// In en, this message translates to:
  /// **'Enable solid color background on the navigation bar'**
  String get enableSolidColorOnNavigationBar;

  /// No description provided for @whenDisabledSolidColorTabBarWillHaveEffect.
  ///
  /// In en, this message translates to:
  /// **'When disabled, the tab bar will use one of the other visual effects. Only one effect can be active at a time.'**
  String get whenDisabledSolidColorTabBarWillHaveEffect;

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

  /// Adoption center related strings
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
  /// **'Qty: {qty}'**
  String quantity(Object qty);

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
  /// **'Orders'**
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
  /// **'this week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'this month'**
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
  /// **'Order details'**
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
  /// **'Custom'**
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
  /// **'{count} unread messages'**
  String unreadMessages(Object count);

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
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
  /// **'Clear Chat'**
  String get clearChat;

  /// No description provided for @chatCleared.
  ///
  /// In en, this message translates to:
  /// **'Chat cleared successfully'**
  String get chatCleared;

  /// No description provided for @userBlocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked successfully'**
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
  /// **'Try Again'**
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
  /// **'New listings'**
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

  /// No description provided for @clearRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'Clear Recent Searches'**
  String get clearRecentSearches;

  /// No description provided for @clearRecentSearchesConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all recent searches? This action cannot be undone.'**
  String get clearRecentSearchesConfirmation;

  /// No description provided for @recentSearchesCleared.
  ///
  /// In en, this message translates to:
  /// **'Recent searches cleared'**
  String get recentSearchesCleared;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @resultsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} results found'**
  String resultsFound(Object count);

  /// No description provided for @whatTypeOfPetDoYouHave.
  ///
  /// In en, this message translates to:
  /// **'What type of pet do you have?'**
  String get whatTypeOfPetDoYouHave;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @petsNearMe.
  ///
  /// In en, this message translates to:
  /// **'Pets near me'**
  String get petsNearMe;

  /// No description provided for @basedOnYourCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Based on your current location'**
  String get basedOnYourCurrentLocation;

  /// No description provided for @noAdoptionListingsInYourArea.
  ///
  /// In en, this message translates to:
  /// **'No adoption listings in your area'**
  String get noAdoptionListingsInYourArea;

  /// No description provided for @noAdoptionListingsYet.
  ///
  /// In en, this message translates to:
  /// **'No adoption listings yet'**
  String get noAdoptionListingsYet;

  /// No description provided for @beTheFirstToAddPetForAdoption.
  ///
  /// In en, this message translates to:
  /// **'Be the first to add a pet for adoption!'**
  String get beTheFirstToAddPetForAdoption;

  /// No description provided for @addListing.
  ///
  /// In en, this message translates to:
  /// **'Add Listing'**
  String get addListing;

  /// No description provided for @searchPets.
  ///
  /// In en, this message translates to:
  /// **'Search pets...'**
  String get searchPets;

  /// No description provided for @gettingYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get gettingYourLocation;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @unableToGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to get location'**
  String get unableToGetLocation;

  /// No description provided for @filtersApplied.
  ///
  /// In en, this message translates to:
  /// **'Filters applied: {count} active'**
  String filtersApplied(Object count);

  /// No description provided for @pleaseLoginToManageListings.
  ///
  /// In en, this message translates to:
  /// **'Please log in to manage your listings'**
  String get pleaseLoginToManageListings;

  /// No description provided for @errorLoadingListings.
  ///
  /// In en, this message translates to:
  /// **'Error loading listings'**
  String get errorLoadingListings;

  /// No description provided for @noPetsNearMe.
  ///
  /// In en, this message translates to:
  /// **'No pets near me'**
  String get noPetsNearMe;

  /// No description provided for @posting.
  ///
  /// In en, this message translates to:
  /// **'Posting...'**
  String get posting;

  /// No description provided for @postForAdoption.
  ///
  /// In en, this message translates to:
  /// **'Post for Adoption'**
  String get postForAdoption;

  /// No description provided for @listingTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing Title'**
  String get listingTitle;

  /// No description provided for @enterTitleForListing.
  ///
  /// In en, this message translates to:
  /// **'Enter a title for your listing'**
  String get enterTitleForListing;

  /// No description provided for @describePetAndAdopter.
  ///
  /// In en, this message translates to:
  /// **'Describe your pet and what you\'re looking for in an adopter'**
  String get describePetAndAdopter;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @enterLocationForAdoption.
  ///
  /// In en, this message translates to:
  /// **'Enter the location for adoption'**
  String get enterLocationForAdoption;

  /// No description provided for @petInformation.
  ///
  /// In en, this message translates to:
  /// **'Pet Information'**
  String get petInformation;

  /// No description provided for @listingDetails.
  ///
  /// In en, this message translates to:
  /// **'Listing Details'**
  String get listingDetails;

  /// No description provided for @adoptionFee.
  ///
  /// In en, this message translates to:
  /// **'Adoption Fee (DZD)'**
  String get adoptionFee;

  /// No description provided for @freeAdoption.
  ///
  /// In en, this message translates to:
  /// **'0 for free adoption'**
  String get freeAdoption;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title for the listing'**
  String get pleaseEnterTitle;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterDescription;

  /// No description provided for @pleaseEnterLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a location'**
  String get pleaseEnterLocation;

  /// No description provided for @petPostedForAdoptionSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{petName} has been posted for adoption successfully!'**
  String petPostedForAdoptionSuccessfully(Object petName);

  /// No description provided for @failedToPostAdoptionListing.
  ///
  /// In en, this message translates to:
  /// **'Failed to post adoption listing: {error}'**
  String failedToPostAdoptionListing(Object error);

  /// No description provided for @offerForAdoption.
  ///
  /// In en, this message translates to:
  /// **'Offer for Adoption'**
  String get offerForAdoption;

  /// No description provided for @deletePet.
  ///
  /// In en, this message translates to:
  /// **'Delete Pet'**
  String get deletePet;

  /// No description provided for @areYouSureDeletePet.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {petName}?'**
  String areYouSureDeletePet(Object petName);

  /// No description provided for @petDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{petName} has been deleted successfully'**
  String petDeletedSuccessfully(Object petName);

  /// No description provided for @failedToDeletePet.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete pet: {error}'**
  String failedToDeletePet(Object error);

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings;

  /// No description provided for @noListingsFound.
  ///
  /// In en, this message translates to:
  /// **'No listings found'**
  String get noListingsFound;

  /// No description provided for @editListing.
  ///
  /// In en, this message translates to:
  /// **'Edit Listing'**
  String get editListing;

  /// No description provided for @deleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete Listing'**
  String get deleteListing;

  /// No description provided for @listingDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Listing deleted successfully'**
  String get listingDeletedSuccessfully;

  /// No description provided for @failedToDeleteListing.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete listing: {error}'**
  String failedToDeleteListing(Object error);

  /// No description provided for @areYouSureDeleteListing.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this listing?'**
  String get areYouSureDeleteListing;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @postedBy.
  ///
  /// In en, this message translates to:
  /// **'Posted by'**
  String get postedBy;

  /// No description provided for @contactOwner.
  ///
  /// In en, this message translates to:
  /// **'Contact Owner'**
  String get contactOwner;

  /// No description provided for @adoptionFeeValue.
  ///
  /// In en, this message translates to:
  /// **'Adoption Fee: {fee} DZD'**
  String adoptionFeeValue(Object fee);

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @requirements.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get requirements;

  /// No description provided for @noRequirements.
  ///
  /// In en, this message translates to:
  /// **'No specific requirements'**
  String get noRequirements;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @noContactNumber.
  ///
  /// In en, this message translates to:
  /// **'No contact number provided'**
  String get noContactNumber;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created on'**
  String get createdOn;

  /// No description provided for @adoptionListingDetails.
  ///
  /// In en, this message translates to:
  /// **'Adoption Listing Details'**
  String get adoptionListingDetails;

  /// No description provided for @petDetails.
  ///
  /// In en, this message translates to:
  /// **'Pet Details'**
  String get petDetails;

  /// No description provided for @petType.
  ///
  /// In en, this message translates to:
  /// **'Pet Type'**
  String get petType;

  /// No description provided for @petAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get petAge;

  /// No description provided for @petGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get petGender;

  /// No description provided for @petColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get petColor;

  /// No description provided for @petWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get petWeight;

  /// No description provided for @petBreed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get petBreed;

  /// No description provided for @petLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get petLocation;

  /// No description provided for @petImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get petImages;

  /// No description provided for @noImages.
  ///
  /// In en, this message translates to:
  /// **'No images available'**
  String get noImages;

  /// No description provided for @viewAllImages.
  ///
  /// In en, this message translates to:
  /// **'View all images'**
  String get viewAllImages;

  /// No description provided for @adoptionProcess.
  ///
  /// In en, this message translates to:
  /// **'Adoption Process'**
  String get adoptionProcess;

  /// No description provided for @adoptionSteps.
  ///
  /// In en, this message translates to:
  /// **'Adoption Steps'**
  String get adoptionSteps;

  /// No description provided for @step1.
  ///
  /// In en, this message translates to:
  /// **'Step 1'**
  String get step1;

  /// No description provided for @step2.
  ///
  /// In en, this message translates to:
  /// **'Step 2'**
  String get step2;

  /// No description provided for @step3.
  ///
  /// In en, this message translates to:
  /// **'Step 3'**
  String get step3;

  /// No description provided for @step4.
  ///
  /// In en, this message translates to:
  /// **'Step 4'**
  String get step4;

  /// No description provided for @contactOwnerStep.
  ///
  /// In en, this message translates to:
  /// **'Contact the owner'**
  String get contactOwnerStep;

  /// No description provided for @meetPetStep.
  ///
  /// In en, this message translates to:
  /// **'Meet the pet'**
  String get meetPetStep;

  /// No description provided for @completeAdoptionStep.
  ///
  /// In en, this message translates to:
  /// **'Complete adoption'**
  String get completeAdoptionStep;

  /// No description provided for @followUpStep.
  ///
  /// In en, this message translates to:
  /// **'Follow up care'**
  String get followUpStep;

  /// No description provided for @contactOwnerDescription.
  ///
  /// In en, this message translates to:
  /// **'Reach out to the pet owner to express your interest and ask questions about the pet.'**
  String get contactOwnerDescription;

  /// No description provided for @meetPetDescription.
  ///
  /// In en, this message translates to:
  /// **'Arrange to meet the pet in person to ensure it\'s a good match for your family.'**
  String get meetPetDescription;

  /// No description provided for @completeAdoptionDescription.
  ///
  /// In en, this message translates to:
  /// **'If everything goes well, complete the adoption process with the owner.'**
  String get completeAdoptionDescription;

  /// No description provided for @followUpDescription.
  ///
  /// In en, this message translates to:
  /// **'Provide ongoing care and follow up with the owner if needed.'**
  String get followUpDescription;

  /// No description provided for @adoptionTips.
  ///
  /// In en, this message translates to:
  /// **'Adoption Tips'**
  String get adoptionTips;

  /// No description provided for @adoptionTipsDescription.
  ///
  /// In en, this message translates to:
  /// **'Here are some tips to help you through the adoption process:'**
  String get adoptionTipsDescription;

  /// No description provided for @tip1.
  ///
  /// In en, this message translates to:
  /// **'Ask lots of questions about the pet\'s history, health, and behavior'**
  String get tip1;

  /// No description provided for @tip2.
  ///
  /// In en, this message translates to:
  /// **'Meet the pet in person before making a decision'**
  String get tip2;

  /// No description provided for @tip3.
  ///
  /// In en, this message translates to:
  /// **'Consider your lifestyle and living situation'**
  String get tip3;

  /// No description provided for @tip4.
  ///
  /// In en, this message translates to:
  /// **'Be patient and don\'t rush the decision'**
  String get tip4;

  /// No description provided for @tip5.
  ///
  /// In en, this message translates to:
  /// **'Prepare your home for the new pet'**
  String get tip5;

  /// No description provided for @tip6.
  ///
  /// In en, this message translates to:
  /// **'Have a plan for ongoing care and expenses'**
  String get tip6;

  /// No description provided for @adoptionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Adoption Success'**
  String get adoptionSuccess;

  /// No description provided for @adoptionSuccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Congratulations on finding your new companion! Remember to:'**
  String get adoptionSuccessDescription;

  /// No description provided for @successTip1.
  ///
  /// In en, this message translates to:
  /// **'Give your new pet time to adjust to their new home'**
  String get successTip1;

  /// No description provided for @successTip2.
  ///
  /// In en, this message translates to:
  /// **'Schedule a vet checkup within the first week'**
  String get successTip2;

  /// No description provided for @successTip3.
  ///
  /// In en, this message translates to:
  /// **'Update microchip information if applicable'**
  String get successTip3;

  /// No description provided for @successTip4.
  ///
  /// In en, this message translates to:
  /// **'Keep in touch with the previous owner if needed'**
  String get successTip4;

  /// No description provided for @successTip5.
  ///
  /// In en, this message translates to:
  /// **'Provide lots of love and patience during the transition'**
  String get successTip5;

  /// No description provided for @adoptionResources.
  ///
  /// In en, this message translates to:
  /// **'Adoption Resources'**
  String get adoptionResources;

  /// No description provided for @adoptionResourcesDescription.
  ///
  /// In en, this message translates to:
  /// **'Here are some helpful resources for new pet parents:'**
  String get adoptionResourcesDescription;

  /// No description provided for @resource1.
  ///
  /// In en, this message translates to:
  /// **'Pet care guides and tips'**
  String get resource1;

  /// No description provided for @resource2.
  ///
  /// In en, this message translates to:
  /// **'Local vet recommendations'**
  String get resource2;

  /// No description provided for @resource3.
  ///
  /// In en, this message translates to:
  /// **'Pet training resources'**
  String get resource3;

  /// No description provided for @resource4.
  ///
  /// In en, this message translates to:
  /// **'Emergency pet care information'**
  String get resource4;

  /// No description provided for @resource5.
  ///
  /// In en, this message translates to:
  /// **'Pet-friendly housing resources'**
  String get resource5;

  /// No description provided for @adoptionSupport.
  ///
  /// In en, this message translates to:
  /// **'Adoption Support'**
  String get adoptionSupport;

  /// No description provided for @adoptionSupportDescription.
  ///
  /// In en, this message translates to:
  /// **'Need help with your adoption? We\'re here to support you:'**
  String get adoptionSupportDescription;

  /// No description provided for @support1.
  ///
  /// In en, this message translates to:
  /// **'Contact our adoption support team'**
  String get support1;

  /// No description provided for @support2.
  ///
  /// In en, this message translates to:
  /// **'Join our community forums'**
  String get support2;

  /// No description provided for @support3.
  ///
  /// In en, this message translates to:
  /// **'Access educational resources'**
  String get support3;

  /// No description provided for @support4.
  ///
  /// In en, this message translates to:
  /// **'Get vet recommendations'**
  String get support4;

  /// No description provided for @support5.
  ///
  /// In en, this message translates to:
  /// **'Find pet care services'**
  String get support5;

  /// No description provided for @adoptionFaq.
  ///
  /// In en, this message translates to:
  /// **'Adoption FAQ'**
  String get adoptionFaq;

  /// No description provided for @adoptionFaqDescription.
  ///
  /// In en, this message translates to:
  /// **'Common questions about pet adoption:'**
  String get adoptionFaqDescription;

  /// No description provided for @faq1.
  ///
  /// In en, this message translates to:
  /// **'What should I ask the pet owner?'**
  String get faq1;

  /// No description provided for @faq2.
  ///
  /// In en, this message translates to:
  /// **'How do I know if a pet is right for me?'**
  String get faq2;

  /// No description provided for @faq3.
  ///
  /// In en, this message translates to:
  /// **'What documents do I need for adoption?'**
  String get faq3;

  /// No description provided for @faq4.
  ///
  /// In en, this message translates to:
  /// **'How much does pet care cost?'**
  String get faq4;

  /// No description provided for @faq5.
  ///
  /// In en, this message translates to:
  /// **'What if the adoption doesn\'t work out?'**
  String get faq5;

  /// No description provided for @adoptionGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Adoption Guidelines'**
  String get adoptionGuidelines;

  /// No description provided for @adoptionGuidelinesDescription.
  ///
  /// In en, this message translates to:
  /// **'Please follow these guidelines for a successful adoption:'**
  String get adoptionGuidelinesDescription;

  /// No description provided for @guideline1.
  ///
  /// In en, this message translates to:
  /// **'Be honest about your experience and living situation'**
  String get guideline1;

  /// No description provided for @guideline2.
  ///
  /// In en, this message translates to:
  /// **'Ask detailed questions about the pet\'s needs'**
  String get guideline2;

  /// No description provided for @guideline3.
  ///
  /// In en, this message translates to:
  /// **'Consider the long-term commitment'**
  String get guideline3;

  /// No description provided for @guideline4.
  ///
  /// In en, this message translates to:
  /// **'Have a backup plan for emergencies'**
  String get guideline4;

  /// No description provided for @guideline5.
  ///
  /// In en, this message translates to:
  /// **'Be respectful of the owner\'s time and decision'**
  String get guideline5;

  /// No description provided for @adoptionSafety.
  ///
  /// In en, this message translates to:
  /// **'Adoption Safety'**
  String get adoptionSafety;

  /// No description provided for @adoptionSafetyDescription.
  ///
  /// In en, this message translates to:
  /// **'Stay safe during the adoption process:'**
  String get adoptionSafetyDescription;

  /// No description provided for @safety1.
  ///
  /// In en, this message translates to:
  /// **'Meet in a public place for the first meeting'**
  String get safety1;

  /// No description provided for @safety2.
  ///
  /// In en, this message translates to:
  /// **'Bring a friend or family member'**
  String get safety2;

  /// No description provided for @safety3.
  ///
  /// In en, this message translates to:
  /// **'Trust your instincts'**
  String get safety3;

  /// No description provided for @safety4.
  ///
  /// In en, this message translates to:
  /// **'Don\'t feel pressured to make a quick decision'**
  String get safety4;

  /// No description provided for @safety5.
  ///
  /// In en, this message translates to:
  /// **'Report any suspicious behavior'**
  String get safety5;

  /// No description provided for @adoptionPreparation.
  ///
  /// In en, this message translates to:
  /// **'Adoption Preparation'**
  String get adoptionPreparation;

  /// No description provided for @adoptionPreparationDescription.
  ///
  /// In en, this message translates to:
  /// **'Prepare for your new pet:'**
  String get adoptionPreparationDescription;

  /// No description provided for @preparation1.
  ///
  /// In en, this message translates to:
  /// **'Pet-proof your home'**
  String get preparation1;

  /// No description provided for @preparation2.
  ///
  /// In en, this message translates to:
  /// **'Gather necessary supplies'**
  String get preparation2;

  /// No description provided for @preparation3.
  ///
  /// In en, this message translates to:
  /// **'Research pet care requirements'**
  String get preparation3;

  /// No description provided for @preparation4.
  ///
  /// In en, this message translates to:
  /// **'Plan for ongoing expenses'**
  String get preparation4;

  /// No description provided for @preparation5.
  ///
  /// In en, this message translates to:
  /// **'Arrange for pet care when you\'re away'**
  String get preparation5;

  /// No description provided for @adoptionTimeline.
  ///
  /// In en, this message translates to:
  /// **'Adoption Timeline'**
  String get adoptionTimeline;

  /// No description provided for @adoptionTimelineDescription.
  ///
  /// In en, this message translates to:
  /// **'Typical adoption process timeline:'**
  String get adoptionTimelineDescription;

  /// No description provided for @timeline1.
  ///
  /// In en, this message translates to:
  /// **'Initial contact (1-2 days)'**
  String get timeline1;

  /// No description provided for @timeline2.
  ///
  /// In en, this message translates to:
  /// **'Meet and greet (3-7 days)'**
  String get timeline2;

  /// No description provided for @timeline3.
  ///
  /// In en, this message translates to:
  /// **'Home visit (optional, 1-2 weeks)'**
  String get timeline3;

  /// No description provided for @timeline4.
  ///
  /// In en, this message translates to:
  /// **'Adoption completion (1-4 weeks)'**
  String get timeline4;

  /// No description provided for @timeline5.
  ///
  /// In en, this message translates to:
  /// **'Follow-up care (ongoing)'**
  String get timeline5;

  /// No description provided for @adoptionCosts.
  ///
  /// In en, this message translates to:
  /// **'Adoption Costs'**
  String get adoptionCosts;

  /// No description provided for @adoptionCostsDescription.
  ///
  /// In en, this message translates to:
  /// **'Consider these costs when adopting:'**
  String get adoptionCostsDescription;

  /// No description provided for @cost1.
  ///
  /// In en, this message translates to:
  /// **'Adoption fee (if any)'**
  String get cost1;

  /// No description provided for @cost2.
  ///
  /// In en, this message translates to:
  /// **'Initial vet visit and vaccinations'**
  String get cost2;

  /// No description provided for @cost3.
  ///
  /// In en, this message translates to:
  /// **'Pet supplies and equipment'**
  String get cost3;

  /// No description provided for @cost4.
  ///
  /// In en, this message translates to:
  /// **'Ongoing food and care expenses'**
  String get cost4;

  /// No description provided for @cost5.
  ///
  /// In en, this message translates to:
  /// **'Emergency vet care fund'**
  String get cost5;

  /// No description provided for @adoptionBenefits.
  ///
  /// In en, this message translates to:
  /// **'Adoption Benefits'**
  String get adoptionBenefits;

  /// No description provided for @adoptionBenefitsDescription.
  ///
  /// In en, this message translates to:
  /// **'Benefits of adopting a pet:'**
  String get adoptionBenefitsDescription;

  /// No description provided for @benefit1.
  ///
  /// In en, this message translates to:
  /// **'Save a life and give a home to a pet in need'**
  String get benefit1;

  /// No description provided for @benefit2.
  ///
  /// In en, this message translates to:
  /// **'Often more affordable than buying from a breeder'**
  String get benefit2;

  /// No description provided for @benefit3.
  ///
  /// In en, this message translates to:
  /// **'Many adopted pets are already trained'**
  String get benefit3;

  /// No description provided for @benefit4.
  ///
  /// In en, this message translates to:
  /// **'Support animal welfare organizations'**
  String get benefit4;

  /// No description provided for @benefit5.
  ///
  /// In en, this message translates to:
  /// **'Experience the joy of pet companionship'**
  String get benefit5;

  /// No description provided for @adoptionChallenges.
  ///
  /// In en, this message translates to:
  /// **'Adoption Challenges'**
  String get adoptionChallenges;

  /// No description provided for @adoptionChallengesDescription.
  ///
  /// In en, this message translates to:
  /// **'Be prepared for these challenges:'**
  String get adoptionChallengesDescription;

  /// No description provided for @challenge1.
  ///
  /// In en, this message translates to:
  /// **'Adjustment period for the pet'**
  String get challenge1;

  /// No description provided for @challenge2.
  ///
  /// In en, this message translates to:
  /// **'Unknown health or behavior history'**
  String get challenge2;

  /// No description provided for @challenge3.
  ///
  /// In en, this message translates to:
  /// **'Potential training needs'**
  String get challenge3;

  /// No description provided for @challenge4.
  ///
  /// In en, this message translates to:
  /// **'Ongoing time and financial commitment'**
  String get challenge4;

  /// No description provided for @challenge5.
  ///
  /// In en, this message translates to:
  /// **'Emotional attachment and responsibility'**
  String get challenge5;

  /// No description provided for @adoptionSuccessStories.
  ///
  /// In en, this message translates to:
  /// **'Adoption Success Stories'**
  String get adoptionSuccessStories;

  /// No description provided for @adoptionSuccessStoriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Read inspiring adoption stories:'**
  String get adoptionSuccessStoriesDescription;

  /// No description provided for @story1.
  ///
  /// In en, this message translates to:
  /// **'How Max found his forever home'**
  String get story1;

  /// No description provided for @story2.
  ///
  /// In en, this message translates to:
  /// **'Luna\'s journey to recovery'**
  String get story2;

  /// No description provided for @story3.
  ///
  /// In en, this message translates to:
  /// **'A family\'s first adoption experience'**
  String get story3;

  /// No description provided for @story4.
  ///
  /// In en, this message translates to:
  /// **'Senior pet adoption success'**
  String get story4;

  /// No description provided for @story5.
  ///
  /// In en, this message translates to:
  /// **'Special needs pet adoption'**
  String get story5;

  /// No description provided for @adoptionCommunity.
  ///
  /// In en, this message translates to:
  /// **'Adoption Community'**
  String get adoptionCommunity;

  /// No description provided for @adoptionCommunityDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect with other pet parents:'**
  String get adoptionCommunityDescription;

  /// No description provided for @community1.
  ///
  /// In en, this message translates to:
  /// **'Join local pet groups'**
  String get community1;

  /// No description provided for @community2.
  ///
  /// In en, this message translates to:
  /// **'Share your adoption story'**
  String get community2;

  /// No description provided for @community3.
  ///
  /// In en, this message translates to:
  /// **'Get advice from experienced owners'**
  String get community3;

  /// No description provided for @community4.
  ///
  /// In en, this message translates to:
  /// **'Participate in pet events'**
  String get community4;

  /// No description provided for @community5.
  ///
  /// In en, this message translates to:
  /// **'Volunteer at animal shelters'**
  String get community5;

  /// No description provided for @adoptionEducation.
  ///
  /// In en, this message translates to:
  /// **'Adoption Education'**
  String get adoptionEducation;

  /// No description provided for @adoptionEducationDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn more about pet adoption:'**
  String get adoptionEducationDescription;

  /// No description provided for @education1.
  ///
  /// In en, this message translates to:
  /// **'Understanding pet behavior'**
  String get education1;

  /// No description provided for @education2.
  ///
  /// In en, this message translates to:
  /// **'Pet health and nutrition'**
  String get education2;

  /// No description provided for @education3.
  ///
  /// In en, this message translates to:
  /// **'Training and socialization'**
  String get education3;

  /// No description provided for @education4.
  ///
  /// In en, this message translates to:
  /// **'Emergency pet care'**
  String get education4;

  /// No description provided for @education5.
  ///
  /// In en, this message translates to:
  /// **'Pet law and regulations'**
  String get education5;

  /// No description provided for @adoptionAdvocacy.
  ///
  /// In en, this message translates to:
  /// **'Adoption Advocacy'**
  String get adoptionAdvocacy;

  /// No description provided for @adoptionAdvocacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Help promote pet adoption:'**
  String get adoptionAdvocacyDescription;

  /// No description provided for @advocacy1.
  ///
  /// In en, this message translates to:
  /// **'Share adoption stories on social media'**
  String get advocacy1;

  /// No description provided for @advocacy2.
  ///
  /// In en, this message translates to:
  /// **'Volunteer at local shelters'**
  String get advocacy2;

  /// No description provided for @advocacy3.
  ///
  /// In en, this message translates to:
  /// **'Donate to animal welfare organizations'**
  String get advocacy3;

  /// No description provided for @advocacy4.
  ///
  /// In en, this message translates to:
  /// **'Educate others about adoption benefits'**
  String get advocacy4;

  /// No description provided for @advocacy5.
  ///
  /// In en, this message translates to:
  /// **'Support spay/neuter programs'**
  String get advocacy5;

  /// No description provided for @adoptionMyths.
  ///
  /// In en, this message translates to:
  /// **'Adoption Myths'**
  String get adoptionMyths;

  /// No description provided for @adoptionMythsDescription.
  ///
  /// In en, this message translates to:
  /// **'Common misconceptions about pet adoption:'**
  String get adoptionMythsDescription;

  /// No description provided for @myth1.
  ///
  /// In en, this message translates to:
  /// **'Adopted pets have behavior problems'**
  String get myth1;

  /// No description provided for @myth2.
  ///
  /// In en, this message translates to:
  /// **'You can\'t find purebred pets for adoption'**
  String get myth2;

  /// No description provided for @myth3.
  ///
  /// In en, this message translates to:
  /// **'Adopted pets are unhealthy'**
  String get myth3;

  /// No description provided for @myth4.
  ///
  /// In en, this message translates to:
  /// **'Adoption is too complicated'**
  String get myth4;

  /// No description provided for @myth5.
  ///
  /// In en, this message translates to:
  /// **'Adopted pets don\'t bond with new owners'**
  String get myth5;

  /// No description provided for @adoptionFacts.
  ///
  /// In en, this message translates to:
  /// **'Adoption Facts'**
  String get adoptionFacts;

  /// No description provided for @adoptionFactsDescription.
  ///
  /// In en, this message translates to:
  /// **'Facts about pet adoption:'**
  String get adoptionFactsDescription;

  /// No description provided for @fact1.
  ///
  /// In en, this message translates to:
  /// **'Millions of pets are waiting for homes'**
  String get fact1;

  /// No description provided for @fact2.
  ///
  /// In en, this message translates to:
  /// **'Adopted pets are often already trained'**
  String get fact2;

  /// No description provided for @fact3.
  ///
  /// In en, this message translates to:
  /// **'Adoption fees help support animal care'**
  String get fact3;

  /// No description provided for @fact4.
  ///
  /// In en, this message translates to:
  /// **'Many adopted pets are healthy and well-behaved'**
  String get fact4;

  /// No description provided for @fact5.
  ///
  /// In en, this message translates to:
  /// **'Adoption saves lives and reduces overpopulation'**
  String get fact5;

  /// No description provided for @groomers.
  ///
  /// In en, this message translates to:
  /// **'Groomers'**
  String get groomers;

  /// No description provided for @trainers.
  ///
  /// In en, this message translates to:
  /// **'Trainers'**
  String get trainers;

  /// No description provided for @professionalGroomers.
  ///
  /// In en, this message translates to:
  /// **'Professional Groomers'**
  String get professionalGroomers;

  /// No description provided for @professionalTrainers.
  ///
  /// In en, this message translates to:
  /// **'Professional Trainers'**
  String get professionalTrainers;

  /// No description provided for @findBestGroomingServices.
  ///
  /// In en, this message translates to:
  /// **'Find the best grooming services for your pet'**
  String get findBestGroomingServices;

  /// No description provided for @findBestTrainingServices.
  ///
  /// In en, this message translates to:
  /// **'Find the best training services for your pet'**
  String get findBestTrainingServices;

  /// No description provided for @listingsNearMe.
  ///
  /// In en, this message translates to:
  /// **'Listings Near Me'**
  String get listingsNearMe;

  /// No description provided for @topListings.
  ///
  /// In en, this message translates to:
  /// **'Top Listings'**
  String get topListings;

  /// No description provided for @noGroomersNearby.
  ///
  /// In en, this message translates to:
  /// **'No groomers nearby'**
  String get noGroomersNearby;

  /// No description provided for @noTopGroomers.
  ///
  /// In en, this message translates to:
  /// **'No top groomers available'**
  String get noTopGroomers;

  /// No description provided for @noTrainersNearby.
  ///
  /// In en, this message translates to:
  /// **'No trainers nearby'**
  String get noTrainersNearby;

  /// No description provided for @noTopTrainers.
  ///
  /// In en, this message translates to:
  /// **'No top trainers available'**
  String get noTopTrainers;

  /// No description provided for @socialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get socialMedia;

  /// No description provided for @addSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Add Social Media'**
  String get addSocialMedia;

  /// No description provided for @tiktok.
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get tiktok;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @enterTikTokUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter TikTok username'**
  String get enterTikTokUsername;

  /// No description provided for @enterFacebookUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter Facebook username'**
  String get enterFacebookUsername;

  /// No description provided for @enterInstagramUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter Instagram username'**
  String get enterInstagramUsername;

  /// No description provided for @socialMediaAdded.
  ///
  /// In en, this message translates to:
  /// **'Social media account added successfully!'**
  String get socialMediaAdded;

  /// No description provided for @socialMediaUpdated.
  ///
  /// In en, this message translates to:
  /// **'Social media account updated successfully!'**
  String get socialMediaUpdated;

  /// No description provided for @socialMediaRemoved.
  ///
  /// In en, this message translates to:
  /// **'Social media account removed successfully!'**
  String get socialMediaRemoved;

  /// No description provided for @errorUpdatingSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Error updating social media: {error}'**
  String errorUpdatingSocialMedia(Object error);

  /// No description provided for @removeSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Remove Social Media'**
  String get removeSocialMedia;

  /// No description provided for @areYouSureRemoveSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this social media account?'**
  String get areYouSureRemoveSocialMedia;

  /// No description provided for @petOwners.
  ///
  /// In en, this message translates to:
  /// **'Pet Owners'**
  String get petOwners;

  /// No description provided for @addPetOwner.
  ///
  /// In en, this message translates to:
  /// **'Add Pet Owner'**
  String get addPetOwner;

  /// No description provided for @searchForUsersToAddAsOwners.
  ///
  /// In en, this message translates to:
  /// **'Search for users to add as owners of {petName}'**
  String searchForUsersToAddAsOwners(Object petName);

  /// No description provided for @petOwnershipRequests.
  ///
  /// In en, this message translates to:
  /// **'Pet Ownership Requests'**
  String get petOwnershipRequests;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'{count} pending request{count, plural, =1 {} other {s}}'**
  String pendingRequests(num count);

  /// No description provided for @moreRequests.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more requests'**
  String moreRequests(Object count);

  /// No description provided for @wantsToCoOwn.
  ///
  /// In en, this message translates to:
  /// **'{userName} wants to co-own {petName}'**
  String wantsToCoOwn(Object petName, Object userName);

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @requestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Request accepted'**
  String get requestAccepted;

  /// No description provided for @requestDeclined.
  ///
  /// In en, this message translates to:
  /// **'Request declined'**
  String get requestDeclined;

  /// No description provided for @ownershipRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Ownership request sent to {userName}'**
  String ownershipRequestSent(Object userName);

  /// No description provided for @errorSendingRequest.
  ///
  /// In en, this message translates to:
  /// **'Error sending request'**
  String get errorSendingRequest;

  /// No description provided for @petOwnershipRequest.
  ///
  /// In en, this message translates to:
  /// **'Pet Ownership Request'**
  String get petOwnershipRequest;

  /// No description provided for @petOwnershipRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Pet Ownership Request Accepted'**
  String get petOwnershipRequestAccepted;

  /// No description provided for @petOwnershipRequestDeclined.
  ///
  /// In en, this message translates to:
  /// **'Pet Ownership Request Declined'**
  String get petOwnershipRequestDeclined;

  /// No description provided for @wantsToAddYouAsOwner.
  ///
  /// In en, this message translates to:
  /// **'{userName} wants to add you as an owner of {petName}'**
  String wantsToAddYouAsOwner(Object petName, Object userName);

  /// No description provided for @checkMyPetsPageForRequests.
  ///
  /// In en, this message translates to:
  /// **'Check your My Pets page for ownership requests'**
  String get checkMyPetsPageForRequests;

  /// No description provided for @createPetProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Pet Profile'**
  String get createPetProfile;

  /// No description provided for @petProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Pet profile not found'**
  String get petProfileNotFound;

  /// No description provided for @errorCreatingPetProfile.
  ///
  /// In en, this message translates to:
  /// **'Error creating pet profile'**
  String get errorCreatingPetProfile;

  /// No description provided for @searchForPetProfiles.
  ///
  /// In en, this message translates to:
  /// **'Search for pet profiles...'**
  String get searchForPetProfiles;

  /// No description provided for @searchForPetProfilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Search for Pet Profiles'**
  String get searchForPetProfilesTitle;

  /// No description provided for @findAndFollowPublicPetAccounts.
  ///
  /// In en, this message translates to:
  /// **'Find and follow public pet accounts\nfrom around the community'**
  String get findAndFollowPublicPetAccounts;

  /// No description provided for @noPetProfilesFound.
  ///
  /// In en, this message translates to:
  /// **'No pet profiles found'**
  String get noPetProfilesFound;

  /// No description provided for @writeCaptionForPhoto.
  ///
  /// In en, this message translates to:
  /// **'Write a caption for this photo...'**
  String get writeCaptionForPhoto;

  /// No description provided for @addCaptionToPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a caption to this photo'**
  String get addCaptionToPhoto;

  /// No description provided for @noCaption.
  ///
  /// In en, this message translates to:
  /// **'No caption'**
  String get noCaption;

  /// No description provided for @captionUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Caption updated successfully!'**
  String get captionUpdatedSuccessfully;

  /// No description provided for @failedToUpdateCaption.
  ///
  /// In en, this message translates to:
  /// **'Failed to update caption: {error}'**
  String failedToUpdateCaption(Object error);

  /// No description provided for @maxCaptionLength.
  ///
  /// In en, this message translates to:
  /// **'Maximum 200 characters'**
  String get maxCaptionLength;

  /// No description provided for @searchingPetProfiles.
  ///
  /// In en, this message translates to:
  /// **'Searching pet profiles...'**
  String get searchingPetProfiles;

  /// No description provided for @noResultsFoundForPetProfiles.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\"'**
  String noResultsFoundForPetProfiles(Object query);

  /// No description provided for @errorSearchingPetProfiles.
  ///
  /// In en, this message translates to:
  /// **'Error searching pet profiles: {error}'**
  String errorSearchingPetProfiles(Object error);

  /// No description provided for @authDebugInfo.
  ///
  /// In en, this message translates to:
  /// **'Auth Debug Info'**
  String get authDebugInfo;

  /// No description provided for @maximumPhotosAllowed.
  ///
  /// In en, this message translates to:
  /// **'Maximum of 4 photos allowed'**
  String get maximumPhotosAllowed;

  /// No description provided for @photoAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Photo added successfully!'**
  String get photoAddedSuccessfully;

  /// No description provided for @failedToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Failed to add photo: {error}'**
  String failedToAddPhoto(Object error);

  /// No description provided for @reportAsLost.
  ///
  /// In en, this message translates to:
  /// **'Report as Lost'**
  String get reportAsLost;

  /// No description provided for @youMustBeLoggedInToReportLostPet.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to report a lost pet'**
  String get youMustBeLoggedInToReportLostPet;

  /// No description provided for @pleaseSignInToReportMissingPet.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to report a missing pet'**
  String get pleaseSignInToReportMissingPet;

  /// No description provided for @selectPetToReportMissing.
  ///
  /// In en, this message translates to:
  /// **'Select a pet to report missing'**
  String get selectPetToReportMissing;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @lb.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get lb;

  /// No description provided for @petName.
  ///
  /// In en, this message translates to:
  /// **'Pet Name'**
  String get petName;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @borderColor.
  ///
  /// In en, this message translates to:
  /// **'Border Color:'**
  String get borderColor;

  /// No description provided for @pickAColor.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get pickAColor;

  /// No description provided for @glassDistortionEffectForTabBar.
  ///
  /// In en, this message translates to:
  /// **'Glass Distortion Effect for Tab bar'**
  String get glassDistortionEffectForTabBar;

  /// No description provided for @enableCustomGlassDistortionEffect.
  ///
  /// In en, this message translates to:
  /// **'Enable custom glass distortion effect that bends content for realistic glass appearance'**
  String get enableCustomGlassDistortionEffect;

  /// No description provided for @customGlassDistortionShaderDescription.
  ///
  /// In en, this message translates to:
  /// **'Custom glass distortion shader that subtly bends and warps content inside the navigation bar to simulate realistic glass refraction. Creates an authentic glass-like appearance with subtle wave distortions.'**
  String get customGlassDistortionShaderDescription;

  /// No description provided for @tapSaveLocationToFinish.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Save Location\" to finish'**
  String get tapSaveLocationToFinish;

  /// No description provided for @orderPlacedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully!'**
  String get orderPlacedSuccessfully;

  /// No description provided for @selectAProductToOrder.
  ///
  /// In en, this message translates to:
  /// **'Select a product to order'**
  String get selectAProductToOrder;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'ORDER'**
  String get order;

  /// No description provided for @storeProducts.
  ///
  /// In en, this message translates to:
  /// **'{storeName}\'s Products'**
  String storeProducts(Object storeName);

  /// No description provided for @iWouldLikeToOrder.
  ///
  /// In en, this message translates to:
  /// **'I\'d like to order: {productName} - \${price}'**
  String iWouldLikeToOrder(Object price, Object productName);

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT'**
  String get product;

  /// No description provided for @trySearchingWithDifferentNameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different name or email'**
  String get trySearchingWithDifferentNameOrEmail;

  /// No description provided for @startTypingToSearchForUsers.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search for users'**
  String get startTypingToSearchForUsers;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @ownershipRequestSentTo.
  ///
  /// In en, this message translates to:
  /// **'Ownership request sent to {userName}'**
  String ownershipRequestSentTo(Object userName);

  /// No description provided for @viewAnExample.
  ///
  /// In en, this message translates to:
  /// **'View an example'**
  String get viewAnExample;

  /// No description provided for @requestAPetId.
  ///
  /// In en, this message translates to:
  /// **'Request a pet ID'**
  String get requestAPetId;

  /// No description provided for @shippingInformation.
  ///
  /// In en, this message translates to:
  /// **'Shipping Information'**
  String get shippingInformation;

  /// No description provided for @pleaseEnterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterYourFullName;

  /// No description provided for @pleaseEnterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterYourPhoneNumber;

  /// No description provided for @pleaseEnterYourAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter your address'**
  String get pleaseEnterYourAddress;

  /// No description provided for @pleaseEnterYourZipCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter your zip code'**
  String get pleaseEnterYourZipCode;

  /// No description provided for @errorLoadingPetIdImage.
  ///
  /// In en, this message translates to:
  /// **'Error loading pet ID image'**
  String get errorLoadingPetIdImage;

  /// No description provided for @tapImageToViewFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Tap the image to view in full screen'**
  String get tapImageToViewFullScreen;

  /// No description provided for @sharePetId.
  ///
  /// In en, this message translates to:
  /// **'Share Pet ID'**
  String get sharePetId;

  /// No description provided for @physicalPetIdRequestSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Physical pet ID request submitted successfully! You will be contacted for payment.'**
  String get physicalPetIdRequestSubmittedSuccessfully;

  /// No description provided for @errorRequestingPhysicalPetId.
  ///
  /// In en, this message translates to:
  /// **'Error requesting physical pet ID: {error}'**
  String errorRequestingPhysicalPetId(Object error);

  /// No description provided for @welcomeToAlifi.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ALIFI! These Terms of Service (\"Terms\") govern your use of the ALIFI mobile application and website (the \"App\"), operated by ALIFI LTD (\"we,\" \"us,\" or \"our\").'**
  String get welcomeToAlifi;

  /// No description provided for @alifiLtdValuesYourPrivacy.
  ///
  /// In en, this message translates to:
  /// **'ALIFI LTD (\"we,\" \"us,\" or \"our\") values your privacy. This Privacy Policy describes how we collect, use, disclose, and protect your personal information when you use the ALIFI mobile application and website (collectively, the \"App\").'**
  String get alifiLtdValuesYourPrivacy;

  /// No description provided for @petAdoptionsForRehomingAnimals.
  ///
  /// In en, this message translates to:
  /// **'Pet Adoptions for rehoming animals'**
  String get petAdoptionsForRehomingAnimals;

  /// No description provided for @missingPetAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Missing Pet Announcements'**
  String get missingPetAnnouncements;

  /// No description provided for @provideAccurateAndCompleteInformation.
  ///
  /// In en, this message translates to:
  /// **'Provide accurate and complete information'**
  String get provideAccurateAndCompleteInformation;

  /// No description provided for @keepYourLoginCredentialsSecure.
  ///
  /// In en, this message translates to:
  /// **'Keep your login credentials secure'**
  String get keepYourLoginCredentialsSecure;

  /// No description provided for @notifyUsImmediatelyOfUnauthorizedAccess.
  ///
  /// In en, this message translates to:
  /// **'Notify us immediately of any unauthorized access or suspicious activity'**
  String get notifyUsImmediatelyOfUnauthorizedAccess;

  /// No description provided for @youAreLufi.
  ///
  /// In en, this message translates to:
  /// **'You are Lufi, a professional pet care assistant and veterinary advisor. Your primary mission is to provide accurate, evidence-based guidance on pet health, behavior, nutrition, training, and general care.'**
  String get youAreLufi;

  /// No description provided for @thisProfileWillBePublicAndVisible.
  ///
  /// In en, this message translates to:
  /// **'This profile will be public and visible to other users'**
  String get thisProfileWillBePublicAndVisible;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @unknownProduct.
  ///
  /// In en, this message translates to:
  /// **'Unknown Product'**
  String get unknownProduct;

  /// No description provided for @nullValue.
  ///
  /// In en, this message translates to:
  /// **'null'**
  String get nullValue;

  /// No description provided for @letsGetYouStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you started!'**
  String get letsGetYouStarted;

  /// No description provided for @signUpAsVetOrStore.
  ///
  /// In en, this message translates to:
  /// **'sign up as a vet or a store'**
  String get signUpAsVetOrStore;

  /// No description provided for @signUpAsVet.
  ///
  /// In en, this message translates to:
  /// **'Sign up as a vet'**
  String get signUpAsVet;

  /// No description provided for @signUpAsStore.
  ///
  /// In en, this message translates to:
  /// **'Sign up as a store'**
  String get signUpAsStore;

  /// No description provided for @failedToStartApp.
  ///
  /// In en, this message translates to:
  /// **'Failed to start the app'**
  String get failedToStartApp;

  /// No description provided for @deleteVaccine.
  ///
  /// In en, this message translates to:
  /// **'Delete Vaccine'**
  String get deleteVaccine;

  /// No description provided for @deleteVaccineConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this vaccine?'**
  String get deleteVaccineConfirmation;

  /// No description provided for @deleteIllness.
  ///
  /// In en, this message translates to:
  /// **'Delete Illness'**
  String get deleteIllness;

  /// No description provided for @deleteIllnessConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this illness?'**
  String get deleteIllnessConfirmation;

  /// No description provided for @storeOwner.
  ///
  /// In en, this message translates to:
  /// **'Store Owner'**
  String get storeOwner;

  /// No description provided for @addPetForAdoption.
  ///
  /// In en, this message translates to:
  /// **'Add Pet for Adoption'**
  String get addPetForAdoption;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @saveListing.
  ///
  /// In en, this message translates to:
  /// **'Save Listing'**
  String get saveListing;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @tellUsAboutPetForAdoption.
  ///
  /// In en, this message translates to:
  /// **'Tell us about the pet you want to put up for adoption'**
  String get tellUsAboutPetForAdoption;

  /// No description provided for @enterPetName.
  ///
  /// In en, this message translates to:
  /// **'Enter pet name'**
  String get enterPetName;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @helpPotentialAdopters.
  ///
  /// In en, this message translates to:
  /// **'Help potential adopters understand the pet better'**
  String get helpPotentialAdopters;

  /// No description provided for @enterBreed.
  ///
  /// In en, this message translates to:
  /// **'Enter the breed'**
  String get enterBreed;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @petPhoto.
  ///
  /// In en, this message translates to:
  /// **'Pet Photo'**
  String get petPhoto;

  /// No description provided for @clearPhotoHelpsAdopters.
  ///
  /// In en, this message translates to:
  /// **'A clear photo helps potential adopters connect with the pet'**
  String get clearPhotoHelpsAdopters;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @petDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Pet Documentation'**
  String get petDocumentation;

  /// No description provided for @helpAdoptersUnderstandBackground.
  ///
  /// In en, this message translates to:
  /// **'Help potential adopters understand the pet\'s background'**
  String get helpAdoptersUnderstandBackground;

  /// No description provided for @vaccinated.
  ///
  /// In en, this message translates to:
  /// **'Vaccinated'**
  String get vaccinated;

  /// No description provided for @microchipped.
  ///
  /// In en, this message translates to:
  /// **'Microchipped'**
  String get microchipped;

  /// No description provided for @houseTrained.
  ///
  /// In en, this message translates to:
  /// **'House Trained'**
  String get houseTrained;

  /// No description provided for @goodWithKids.
  ///
  /// In en, this message translates to:
  /// **'Good with Kids'**
  String get goodWithKids;

  /// No description provided for @goodWithDogs.
  ///
  /// In en, this message translates to:
  /// **'Good with Dogs'**
  String get goodWithDogs;

  /// No description provided for @goodWithCats.
  ///
  /// In en, this message translates to:
  /// **'Good with Cats'**
  String get goodWithCats;

  /// No description provided for @yourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Your phone number'**
  String get yourPhoneNumber;

  /// No description provided for @pleaseEnterContactNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a contact number'**
  String get pleaseEnterContactNumber;

  /// No description provided for @enterLocationManually.
  ///
  /// In en, this message translates to:
  /// **'Enter location manually'**
  String get enterLocationManually;

  /// No description provided for @manualLocation.
  ///
  /// In en, this message translates to:
  /// **'Manual Location'**
  String get manualLocation;

  /// No description provided for @locationPermissionNotGranted.
  ///
  /// In en, this message translates to:
  /// **'Location permission not granted'**
  String get locationPermissionNotGranted;

  /// No description provided for @dr.
  ///
  /// In en, this message translates to:
  /// **'Dr.'**
  String get dr;

  /// No description provided for @neuteredSpayed.
  ///
  /// In en, this message translates to:
  /// **'Neutered/Spayed'**
  String get neuteredSpayed;

  /// No description provided for @healthIssuesOptional.
  ///
  /// In en, this message translates to:
  /// **'Health Issues (Optional)'**
  String get healthIssuesOptional;

  /// No description provided for @healthIssuesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Any health conditions or special needs...'**
  String get healthIssuesPlaceholder;

  /// No description provided for @additionalRequirementsOptional.
  ///
  /// In en, this message translates to:
  /// **'Additional Requirements (Optional)'**
  String get additionalRequirementsOptional;

  /// No description provided for @requirementsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Any specific requirements for potential adopters...'**
  String get requirementsPlaceholder;

  /// No description provided for @howCanAdoptersReachYou.
  ///
  /// In en, this message translates to:
  /// **'How can potential adopters reach you?'**
  String get howCanAdoptersReachYou;

  /// No description provided for @autoDetectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Auto-detected Location'**
  String get autoDetectedLocation;

  /// No description provided for @enterCityStateOrAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your city, state, or address'**
  String get enterCityStateOrAddress;

  /// No description provided for @editPet.
  ///
  /// In en, this message translates to:
  /// **'Edit Pet'**
  String get editPet;

  /// No description provided for @pleaseEnterPetName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a pet name'**
  String get pleaseEnterPetName;

  /// No description provided for @addPhotoOfYourPet.
  ///
  /// In en, this message translates to:
  /// **'Add a photo of your pet'**
  String get addPhotoOfYourPet;

  /// No description provided for @chooseColorForPetProfile.
  ///
  /// In en, this message translates to:
  /// **'Choose a color for your pet\'s profile'**
  String get chooseColorForPetProfile;

  /// No description provided for @found.
  ///
  /// In en, this message translates to:
  /// **'FOUND'**
  String get found;

  /// No description provided for @markAsFound.
  ///
  /// In en, this message translates to:
  /// **'Mark as Found'**
  String get markAsFound;

  /// No description provided for @markAsFoundConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark this pet as found?'**
  String get markAsFoundConfirmation;

  /// No description provided for @trySearchingWithDifferentName.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different name or email'**
  String get trySearchingWithDifferentName;

  /// No description provided for @startTypingToSearch.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search for users'**
  String get startTypingToSearch;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No description provided for @shipOrder.
  ///
  /// In en, this message translates to:
  /// **'Ship Order'**
  String get shipOrder;

  /// No description provided for @deliverOrder.
  ///
  /// In en, this message translates to:
  /// **'Deliver Order'**
  String get deliverOrder;

  /// No description provided for @ship.
  ///
  /// In en, this message translates to:
  /// **'Ship'**
  String get ship;

  /// No description provided for @deliver.
  ///
  /// In en, this message translates to:
  /// **'Deliver'**
  String get deliver;

  /// No description provided for @areYouSureYouWantToOrder.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to order {quantity} x \"{productName}\" for {price}?'**
  String areYouSureYouWantToOrder(Object price, Object productName, Object quantity);

  /// No description provided for @confirmThatYouWillFulfill.
  ///
  /// In en, this message translates to:
  /// **'Confirm that you will fulfill the order for \"{productName}\"?'**
  String confirmThatYouWillFulfill(Object productName);

  /// No description provided for @markOrderAsShipped.
  ///
  /// In en, this message translates to:
  /// **'Mark the order for \"{productName}\" as shipped?'**
  String markOrderAsShipped(Object productName);

  /// No description provided for @markOrderAsDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark the order for \"{productName}\" as delivered?'**
  String markOrderAsDelivered(Object productName);

  /// No description provided for @areYouSureYouWantToCancel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel the order for \"{productName}\"?'**
  String areYouSureYouWantToCancel(Object productName);

  /// No description provided for @enterPetNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your pet\'s name (Required)'**
  String get enterPetNameRequired;

  /// No description provided for @describePetFeatures.
  ///
  /// In en, this message translates to:
  /// **'Describe your pet - size, color, distinctive features... (Required)'**
  String get describePetFeatures;

  /// No description provided for @addContactNumber.
  ///
  /// In en, this message translates to:
  /// **'Add Contact Number'**
  String get addContactNumber;

  /// No description provided for @enterContactNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter contact number'**
  String get enterContactNumber;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @rewardOptional.
  ///
  /// In en, this message translates to:
  /// **'Reward (Optional)'**
  String get rewardOptional;

  /// No description provided for @enterRewardAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter reward amount'**
  String get enterRewardAmount;

  /// No description provided for @missingPetReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Missing Pet Report Submitted'**
  String get missingPetReportSubmitted;

  /// No description provided for @hopeYouFindPetSoon.
  ///
  /// In en, this message translates to:
  /// **'We hope you find your pet soon! The community will be notified.'**
  String get hopeYouFindPetSoon;

  /// No description provided for @couldNotGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get current location. Please try again.'**
  String get couldNotGetLocation;

  /// No description provided for @failedToReportLostPet.
  ///
  /// In en, this message translates to:
  /// **'Failed to report lost pet. Please try again.'**
  String get failedToReportLostPet;

  /// No description provided for @noLostPetReportFound.
  ///
  /// In en, this message translates to:
  /// **'No lost pet report found for this pet.'**
  String get noLostPetReportFound;

  /// No description provided for @greatNewsMarkAsFound.
  ///
  /// In en, this message translates to:
  /// **'Great news! Are you sure you want to mark {petName} as found? This will update the lost pet report.'**
  String greatNewsMarkAsFound(Object petName);

  /// No description provided for @petMarkedAsFound.
  ///
  /// In en, this message translates to:
  /// **'Pet marked as found successfully'**
  String get petMarkedAsFound;

  /// No description provided for @failedToMarkAsFound.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark as found: {error}'**
  String failedToMarkAsFound(Object error);

  /// No description provided for @myPetsPatients.
  ///
  /// In en, this message translates to:
  /// **'My Pets (Patients)'**
  String get myPetsPatients;

  /// No description provided for @selectProductToOrder.
  ///
  /// In en, this message translates to:
  /// **'Select a product to order'**
  String get selectProductToOrder;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @manageAddresses.
  ///
  /// In en, this message translates to:
  /// **'Manage Addresses'**
  String get manageAddresses;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addAddress;

  /// No description provided for @youDontHaveAnyAddressesToShipTo.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any addresses to ship to'**
  String get youDontHaveAnyAddressesToShipTo;

  /// No description provided for @couponCode.
  ///
  /// In en, this message translates to:
  /// **'Coupon Code'**
  String get couponCode;

  /// No description provided for @enterCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code'**
  String get enterCouponCode;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @couponFunctionalityComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coupon functionality coming soon!'**
  String get couponFunctionalityComingSoon;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal ({quantity}x)'**
  String subtotal(Object quantity);

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @appFee.
  ///
  /// In en, this message translates to:
  /// **'App Fee'**
  String get appFee;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total: '**
  String get total;

  /// No description provided for @addAddressToContinue.
  ///
  /// In en, this message translates to:
  /// **'Add Address to Continue'**
  String get addAddressToContinue;

  /// No description provided for @completePayment.
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get completePayment;

  /// No description provided for @choosePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose Payment Method'**
  String get choosePaymentMethod;

  /// No description provided for @cibEpayment.
  ///
  /// In en, this message translates to:
  /// **'CIB e-payment'**
  String get cibEpayment;

  /// No description provided for @paySecurelyWithYourCibCard.
  ///
  /// In en, this message translates to:
  /// **'Pay securely with your CIB card'**
  String get paySecurelyWithYourCibCard;

  /// No description provided for @edahabia.
  ///
  /// In en, this message translates to:
  /// **'EDAHABIA'**
  String get edahabia;

  /// No description provided for @payWithYourEdahabiaCard.
  ///
  /// In en, this message translates to:
  /// **'Pay with your EDAHABIA card'**
  String get payWithYourEdahabiaCard;

  /// No description provided for @poweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by'**
  String get poweredBy;

  /// No description provided for @paymentOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Payment on Delivery'**
  String get paymentOnDelivery;

  /// No description provided for @payWhenYourOrderArrives.
  ///
  /// In en, this message translates to:
  /// **'Pay when your order arrives'**
  String get payWhenYourOrderArrives;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @completeSecurePayment.
  ///
  /// In en, this message translates to:
  /// **'Complete Secure Payment'**
  String get completeSecurePayment;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing Payment...'**
  String get processingPayment;

  /// No description provided for @pleaseSelectAPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Please select a payment method.'**
  String get pleaseSelectAPaymentMethod;

  /// No description provided for @paymentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{methodName} payment coming soon!'**
  String paymentComingSoon(Object methodName);

  /// No description provided for @errorCreatingPayment.
  ///
  /// In en, this message translates to:
  /// **'Error creating payment: {error}'**
  String errorCreatingPayment(Object error);

  /// No description provided for @paymentWasCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment was cancelled'**
  String get paymentWasCancelled;

  /// No description provided for @processingPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing Payment'**
  String get processingPaymentTitle;

  /// No description provided for @pleaseWaitWhileWeVerifyYourPayment.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we verify your payment'**
  String get pleaseWaitWhileWeVerifyYourPayment;

  /// No description provided for @verifyingPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Verifying payment status...'**
  String get verifyingPaymentStatus;

  /// No description provided for @verifyingPayment.
  ///
  /// In en, this message translates to:
  /// **'Verifying Payment'**
  String get verifyingPayment;

  /// No description provided for @checkingPaymentStatusManually.
  ///
  /// In en, this message translates to:
  /// **'Checking payment status manually'**
  String get checkingPaymentStatusManually;

  /// No description provided for @paymentVerificationTimeout.
  ///
  /// In en, this message translates to:
  /// **'Payment verification timeout. Please check your payment status manually.'**
  String get paymentVerificationTimeout;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailed;

  /// No description provided for @errorProcessingOrder.
  ///
  /// In en, this message translates to:
  /// **'Error processing order: {error}'**
  String errorProcessingOrder(Object error);

  /// No description provided for @paymentForProductPlusAppFee.
  ///
  /// In en, this message translates to:
  /// **'Payment for {productName} + App Fee'**
  String paymentForProductPlusAppFee(Object productName);

  /// No description provided for @paymentMethodCashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Payment Method: Cash on Delivery | Status: Pending Payment'**
  String get paymentMethodCashOnDelivery;

  /// No description provided for @helloIJustPlacedAnOrder.
  ///
  /// In en, this message translates to:
  /// **'Hello! I just placed an order for {productName}. Payment on delivery. Order ID: {orderId}'**
  String helloIJustPlacedAnOrder(Object orderId, Object productName);

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmed!'**
  String get orderConfirmed;

  /// No description provided for @yourOrderOfHasBeenConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your order of {amount} has been confirmed.'**
  String yourOrderOfHasBeenConfirmed(Object amount);

  /// No description provided for @yourOrderHasBeenConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your order has been confirmed! You will pay when the product is delivered to your address.'**
  String get yourOrderHasBeenConfirmed;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount}'**
  String amount(Object amount);

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID: {id}'**
  String orderId(Object id);

  /// No description provided for @paymentProcessedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your payment has been processed successfully. You will receive a confirmation email shortly.'**
  String get paymentProcessedSuccessfully;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @paymentFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailedTitle;

  /// No description provided for @paymentCouldNotBeProcessed.
  ///
  /// In en, this message translates to:
  /// **'Your payment could not be processed. Please check your payment details and try again.'**
  String get paymentCouldNotBeProcessed;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @viewOrder.
  ///
  /// In en, this message translates to:
  /// **'View Order'**
  String get viewOrder;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled successfully'**
  String get orderCancelled;

  /// No description provided for @errorCancellingOrder.
  ///
  /// In en, this message translates to:
  /// **'Error cancelling order: {error}'**
  String errorCancellingOrder(Object error);

  /// No description provided for @noUnreadMessages.
  ///
  /// In en, this message translates to:
  /// **'No unread messages'**
  String get noUnreadMessages;

  /// No description provided for @pleaseLogInToViewOrders.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view orders'**
  String get pleaseLogInToViewOrders;

  /// No description provided for @errorLoadingOrders.
  ///
  /// In en, this message translates to:
  /// **'Error loading orders: {error}'**
  String errorLoadingOrders(Object error);

  /// No description provided for @checkConsoleForErrorDetails.
  ///
  /// In en, this message translates to:
  /// **'Check console for detailed error information'**
  String get checkConsoleForErrorDetails;

  /// No description provided for @yourOrdersWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here'**
  String get yourOrdersWillAppearHere;

  /// No description provided for @lastSeenLabel.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeenLabel;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorMessage(Object error);

  /// No description provided for @petMarkedAsFoundWithName.
  ///
  /// In en, this message translates to:
  /// **'{petName} has been marked as found!'**
  String petMarkedAsFoundWithName(Object petName);

  /// No description provided for @storeWithName.
  ///
  /// In en, this message translates to:
  /// **'Store: {storeName}'**
  String storeWithName(Object storeName);

  /// No description provided for @confirmDelivery.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delivery'**
  String get confirmDelivery;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get orderStatusPending;

  /// No description provided for @orderStatusOrdered.
  ///
  /// In en, this message translates to:
  /// **'ORDERED'**
  String get orderStatusOrdered;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'CONFIRMED'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'SHIPPED'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'DELIVERED'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusConfirmedDelivered.
  ///
  /// In en, this message translates to:
  /// **'CONFIRMED DELIVERED'**
  String get orderStatusConfirmedDelivered;

  /// No description provided for @orderStatusDisputedDelivery.
  ///
  /// In en, this message translates to:
  /// **'DISPUTED DELIVERY'**
  String get orderStatusDisputedDelivery;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get orderStatusCancelled;

  /// No description provided for @orderStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'REFUNDED'**
  String get orderStatusRefunded;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(Object days);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(Object hours);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @unknownStore.
  ///
  /// In en, this message translates to:
  /// **'Unknown Store'**
  String get unknownStore;

  /// No description provided for @errorLoadingStoreInfo.
  ///
  /// In en, this message translates to:
  /// **'Error loading store information'**
  String get errorLoadingStoreInfo;

  /// No description provided for @noDiscussionsYet.
  ///
  /// In en, this message translates to:
  /// **'No discussions yet'**
  String get noDiscussionsYet;

  /// No description provided for @conversationsWithSellersWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your conversations with sellers will appear here'**
  String get conversationsWithSellersWillAppearHere;

  /// No description provided for @errorLoadingDiscussions.
  ///
  /// In en, this message translates to:
  /// **'Error loading discussions: {error}'**
  String errorLoadingDiscussions(Object error);

  /// No description provided for @pleaseLogInToViewDiscussions.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view discussions'**
  String get pleaseLogInToViewDiscussions;

  /// No description provided for @invalidConversationData.
  ///
  /// In en, this message translates to:
  /// **'Invalid conversation data'**
  String get invalidConversationData;

  /// Order progress related strings
  ///
  /// In en, this message translates to:
  /// **'Order Progress'**
  String get orderProgress;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(Object current, Object total);

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @shareMedia.
  ///
  /// In en, this message translates to:
  /// **'Share Media'**
  String get shareMedia;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takeAPhoto;

  /// No description provided for @photoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo Library'**
  String get photoLibrary;

  /// No description provided for @chooseFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get chooseFromLibrary;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'VIDEO'**
  String get video;

  /// No description provided for @recordOrChooseVideo.
  ///
  /// In en, this message translates to:
  /// **'Record or choose video'**
  String get recordOrChooseVideo;

  /// No description provided for @errorSelectingMedia.
  ///
  /// In en, this message translates to:
  /// **'Error selecting media: {error}'**
  String errorSelectingMedia(Object error);

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading... ({current}/{total})'**
  String uploading(Object current, Object total);

  /// No description provided for @mediaAttachments.
  ///
  /// In en, this message translates to:
  /// **'Media Attachments ({count})'**
  String mediaAttachments(Object count);

  /// No description provided for @failedToUploadMedia.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload media files'**
  String get failedToUploadMedia;

  /// No description provided for @checkOutThisProduct.
  ///
  /// In en, this message translates to:
  /// **'Check out this product!'**
  String get checkOutThisProduct;

  /// No description provided for @interestedInYourService.
  ///
  /// In en, this message translates to:
  /// **'Interested in your service'**
  String get interestedInYourService;

  /// No description provided for @aboutMyLostPet.
  ///
  /// In en, this message translates to:
  /// **'About my lost pet'**
  String get aboutMyLostPet;

  /// No description provided for @petRescueConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Pet Rescue Confirmation'**
  String get petRescueConfirmation;

  /// No description provided for @didPersonHelpReunite.
  ///
  /// In en, this message translates to:
  /// **'Did {personName} successfully help you reunite with your lost pet at the scheduled meeting?'**
  String didPersonHelpReunite(Object personName);

  /// No description provided for @addToRescueCount.
  ///
  /// In en, this message translates to:
  /// **'This will add +1 to their pet rescue count and help other pet owners.'**
  String get addToRescueCount;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yesRescued.
  ///
  /// In en, this message translates to:
  /// **'Yes, Rescued!'**
  String get yesRescued;

  /// No description provided for @rescueRecorded.
  ///
  /// In en, this message translates to:
  /// **'🎉 Rescue recorded! {personName} now has +1 pets rescued.'**
  String rescueRecorded(Object personName);

  /// No description provided for @failedToRecordRescue.
  ///
  /// In en, this message translates to:
  /// **'Failed to record rescue: {error}'**
  String failedToRecordRescue(Object error);

  /// No description provided for @markMeetingAsFinished.
  ///
  /// In en, this message translates to:
  /// **'Mark Meeting as Finished?'**
  String get markMeetingAsFinished;

  /// No description provided for @markMeetingCompleted.
  ///
  /// In en, this message translates to:
  /// **'This will mark the scheduled meeting as completed and ask if your pet was successfully rescued.'**
  String get markMeetingCompleted;

  /// No description provided for @onlyOncePerMeeting.
  ///
  /// In en, this message translates to:
  /// **'You can only do this once per meeting.'**
  String get onlyOncePerMeeting;

  /// No description provided for @markAsFinished.
  ///
  /// In en, this message translates to:
  /// **'Mark as Finished'**
  String get markAsFinished;

  /// No description provided for @meetingMarkedFinished.
  ///
  /// In en, this message translates to:
  /// **'✅ Meeting marked as finished!'**
  String get meetingMarkedFinished;

  /// No description provided for @failedToFinishMeeting.
  ///
  /// In en, this message translates to:
  /// **'Failed to finish meeting: {error}'**
  String failedToFinishMeeting(Object error);

  /// No description provided for @meetingProposalSent.
  ///
  /// In en, this message translates to:
  /// **'Meeting proposal sent!'**
  String get meetingProposalSent;

  /// No description provided for @failedToProposeMeeting.
  ///
  /// In en, this message translates to:
  /// **'Failed to propose meeting'**
  String get failedToProposeMeeting;

  /// No description provided for @meetingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Meeting confirmed'**
  String get meetingConfirmed;

  /// No description provided for @failedToConfirmMeeting.
  ///
  /// In en, this message translates to:
  /// **'Failed to confirm meeting'**
  String get failedToConfirmMeeting;

  /// No description provided for @meetingRejected.
  ///
  /// In en, this message translates to:
  /// **'Meeting rejected'**
  String get meetingRejected;

  /// No description provided for @failedToRejectMeeting.
  ///
  /// In en, this message translates to:
  /// **'Failed to reject meeting'**
  String get failedToRejectMeeting;

  /// No description provided for @meetingDetailsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Meeting details updated!'**
  String get meetingDetailsUpdated;

  /// No description provided for @failedToUpdateMeetingDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to update meeting details'**
  String get failedToUpdateMeetingDetails;

  /// No description provided for @scheduleMeeting.
  ///
  /// In en, this message translates to:
  /// **'Schedule Meeting'**
  String get scheduleMeeting;

  /// No description provided for @sharingProduct.
  ///
  /// In en, this message translates to:
  /// **'Sharing product'**
  String get sharingProduct;

  /// No description provided for @sharingService.
  ///
  /// In en, this message translates to:
  /// **'Sharing {serviceType} service'**
  String sharingService(Object serviceType);

  /// No description provided for @sharingOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Sharing order details'**
  String get sharingOrderDetails;

  /// No description provided for @lostPet.
  ///
  /// In en, this message translates to:
  /// **'Lost Pet: {petName}'**
  String lostPet(Object petName);

  /// No description provided for @mixedBreed.
  ///
  /// In en, this message translates to:
  /// **'Mixed breed'**
  String get mixedBreed;

  /// No description provided for @reward.
  ///
  /// In en, this message translates to:
  /// **'Reward: \${amount}'**
  String reward(Object amount);

  /// No description provided for @lostPetInformation.
  ///
  /// In en, this message translates to:
  /// **'Lost Pet Information'**
  String get lostPetInformation;

  /// No description provided for @orderConfirmation.
  ///
  /// In en, this message translates to:
  /// **'ORDER CONFIRMATION'**
  String get orderConfirmation;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{orderId}'**
  String orderNumber(Object orderId);

  /// No description provided for @petIdentification.
  ///
  /// In en, this message translates to:
  /// **'Pet Identification'**
  String get petIdentification;

  /// No description provided for @isThisMediaOfPet.
  ///
  /// In en, this message translates to:
  /// **'Is this {mediaType} of your missing pet?'**
  String isThisMediaOfPet(Object mediaType);

  /// No description provided for @confirmedThisIsPet.
  ///
  /// In en, this message translates to:
  /// **'Confirmed: This is your pet'**
  String get confirmedThisIsPet;

  /// No description provided for @confirmedThisIsNotPet.
  ///
  /// In en, this message translates to:
  /// **'Confirmed: This is not your pet'**
  String get confirmedThisIsNotPet;

  /// No description provided for @failedToSaveIdentification.
  ///
  /// In en, this message translates to:
  /// **'Failed to save identification'**
  String get failedToSaveIdentification;

  /// No description provided for @personConfirmedPet.
  ///
  /// In en, this message translates to:
  /// **'{personName} has confirmed that this is their pet'**
  String personConfirmedPet(Object personName);

  /// No description provided for @personConfirmedNotPet.
  ///
  /// In en, this message translates to:
  /// **'{personName} has confirmed that this is not their pet'**
  String personConfirmedNotPet(Object personName);

  /// No description provided for @picture.
  ///
  /// In en, this message translates to:
  /// **'picture'**
  String get picture;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'PHOTO'**
  String get photo;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @vetConsultation.
  ///
  /// In en, this message translates to:
  /// **'VET CONSULTATION'**
  String get vetConsultation;

  /// No description provided for @storeChat.
  ///
  /// In en, this message translates to:
  /// **'STORE CHAT'**
  String get storeChat;

  /// No description provided for @customerChat.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER CHAT'**
  String get customerChat;

  /// No description provided for @serviceProvider.
  ///
  /// In en, this message translates to:
  /// **'{serviceType} PROVIDER'**
  String serviceProvider(Object serviceType);

  /// No description provided for @attachProduct.
  ///
  /// In en, this message translates to:
  /// **'Attach Product'**
  String get attachProduct;

  /// No description provided for @attachService.
  ///
  /// In en, this message translates to:
  /// **'Attach Service'**
  String get attachService;

  /// No description provided for @attachOrder.
  ///
  /// In en, this message translates to:
  /// **'Attach Order'**
  String get attachOrder;

  /// No description provided for @attachLostPet.
  ///
  /// In en, this message translates to:
  /// **'Attach Lost Pet'**
  String get attachLostPet;

  /// No description provided for @attachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Attach Photo'**
  String get attachPhoto;

  /// No description provided for @attachVideo.
  ///
  /// In en, this message translates to:
  /// **'Attach Video'**
  String get attachVideo;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @imageUploaded.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully'**
  String get imageUploaded;

  /// No description provided for @errorUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image: {error}'**
  String errorUploadingImage(Object error);

  /// No description provided for @videoUploaded.
  ///
  /// In en, this message translates to:
  /// **'Video uploaded successfully'**
  String get videoUploaded;

  /// No description provided for @errorUploadingVideo.
  ///
  /// In en, this message translates to:
  /// **'Error uploading video: {error}'**
  String errorUploadingVideo(Object error);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get yesterday;

  /// No description provided for @longTimeAgo.
  ///
  /// In en, this message translates to:
  /// **'a long time ago'**
  String get longTimeAgo;

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get messageDeleted;

  /// No description provided for @areYouSureDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message?'**
  String get areYouSureDeleteMessage;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @unblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get unblockUser;

  /// No description provided for @areYouSureBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this user?'**
  String get areYouSureBlockUser;

  /// No description provided for @areYouSureUnblockUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unblock this user?'**
  String get areYouSureUnblockUser;

  /// No description provided for @userUnblocked.
  ///
  /// In en, this message translates to:
  /// **'User unblocked successfully'**
  String get userUnblocked;

  /// No description provided for @errorBlockingUser.
  ///
  /// In en, this message translates to:
  /// **'Error blocking user: {error}'**
  String errorBlockingUser(Object error);

  /// No description provided for @errorUnblockingUser.
  ///
  /// In en, this message translates to:
  /// **'Error unblocking user: {error}'**
  String errorUnblockingUser(Object error);

  /// No description provided for @reportReason.
  ///
  /// In en, this message translates to:
  /// **'Report Reason'**
  String get reportReason;

  /// No description provided for @spam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get spam;

  /// No description provided for @harassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get harassment;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully'**
  String get reportSubmitted;

  /// No description provided for @errorSubmittingReport.
  ///
  /// In en, this message translates to:
  /// **'Error submitting report: {error}'**
  String errorSubmittingReport(Object error);

  /// No description provided for @areYouSureClearChat.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all messages in this chat?'**
  String get areYouSureClearChat;

  /// No description provided for @errorClearingChat.
  ///
  /// In en, this message translates to:
  /// **'Error clearing chat: {error}'**
  String errorClearingChat(Object error);

  /// No description provided for @meetingScheduled.
  ///
  /// In en, this message translates to:
  /// **'Meeting scheduled successfully'**
  String get meetingScheduled;

  /// No description provided for @errorSchedulingMeeting.
  ///
  /// In en, this message translates to:
  /// **'Error scheduling meeting: {error}'**
  String errorSchedulingMeeting(Object error);

  /// No description provided for @meetingDate.
  ///
  /// In en, this message translates to:
  /// **'Meeting Date'**
  String get meetingDate;

  /// No description provided for @meetingTime.
  ///
  /// In en, this message translates to:
  /// **'Meeting Time'**
  String get meetingTime;

  /// No description provided for @meetingLocation.
  ///
  /// In en, this message translates to:
  /// **'Meeting Location'**
  String get meetingLocation;

  /// No description provided for @meetingNotes.
  ///
  /// In en, this message translates to:
  /// **'Meeting Notes'**
  String get meetingNotes;

  /// No description provided for @confirmMeeting.
  ///
  /// In en, this message translates to:
  /// **'Confirm Meeting'**
  String get confirmMeeting;

  /// No description provided for @meetingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Meeting cancelled'**
  String get meetingCancelled;

  /// No description provided for @errorConfirmingMeeting.
  ///
  /// In en, this message translates to:
  /// **'Error confirming meeting: {error}'**
  String errorConfirmingMeeting(Object error);

  /// No description provided for @errorCancellingMeeting.
  ///
  /// In en, this message translates to:
  /// **'Error cancelling meeting: {error}'**
  String errorCancellingMeeting(Object error);

  /// No description provided for @coordinateMeeting.
  ///
  /// In en, this message translates to:
  /// **'Coordinate a meeting to reunite with your pet! 🐾'**
  String get coordinateMeeting;

  /// No description provided for @proposeNewMeeting.
  ///
  /// In en, this message translates to:
  /// **'Propose New Meeting'**
  String get proposeNewMeeting;

  /// No description provided for @meetingPlace.
  ///
  /// In en, this message translates to:
  /// **'Meeting Place'**
  String get meetingPlace;

  /// No description provided for @enterMeetingLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter meeting location...'**
  String get enterMeetingLocation;

  /// No description provided for @selectDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Select date and time...'**
  String get selectDateAndTime;

  /// No description provided for @updateMeeting.
  ///
  /// In en, this message translates to:
  /// **'Update Meeting'**
  String get updateMeeting;

  /// No description provided for @proposeMeeting.
  ///
  /// In en, this message translates to:
  /// **'Propose Meeting'**
  String get proposeMeeting;

  /// No description provided for @waitingForConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for confirmation...'**
  String get waitingForConfirmation;

  /// No description provided for @waitingForResponse.
  ///
  /// In en, this message translates to:
  /// **'Waiting for response...'**
  String get waitingForResponse;

  /// No description provided for @noLocationSet.
  ///
  /// In en, this message translates to:
  /// **'No location set'**
  String get noLocationSet;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @editDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Details'**
  String get editDetails;

  /// No description provided for @chooseAmount.
  ///
  /// In en, this message translates to:
  /// **'Choose Amount'**
  String get chooseAmount;

  /// No description provided for @cibBank.
  ///
  /// In en, this message translates to:
  /// **'CIB Bank'**
  String get cibBank;

  /// No description provided for @minimumAmount.
  ///
  /// In en, this message translates to:
  /// **'Minimum 300'**
  String get minimumAmount;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid Amount'**
  String get invalidAmount;

  /// No description provided for @minimumAmountIs.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount is 300'**
  String get minimumAmountIs;

  /// No description provided for @contributingVia.
  ///
  /// In en, this message translates to:
  /// **'Contributing {amount} via {method}'**
  String contributingVia(Object amount, Object method);

  /// No description provided for @raisedOfGoal.
  ///
  /// In en, this message translates to:
  /// **'raised of {goal} DZD goal'**
  String raisedOfGoal(Object goal);

  /// No description provided for @raised.
  ///
  /// In en, this message translates to:
  /// **'raised'**
  String get raised;

  /// No description provided for @contributeAmount.
  ///
  /// In en, this message translates to:
  /// **'Contribute {amount}'**
  String contributeAmount(Object amount);

  /// No description provided for @minimumAmountPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Minimum 300'**
  String get minimumAmountPlaceholder;

  /// No description provided for @customAmount.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customAmount;

  /// No description provided for @minimumAmountMessage.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount is 300'**
  String get minimumAmountMessage;

  /// No description provided for @contributingAmount.
  ///
  /// In en, this message translates to:
  /// **'Contributing {amount} via {method}'**
  String contributingAmount(Object amount, Object method);

  /// No description provided for @contributeWithAmount.
  ///
  /// In en, this message translates to:
  /// **'Contribute {amount}'**
  String contributeWithAmount(Object amount);

  /// No description provided for @raisedOfGoalAmount.
  ///
  /// In en, this message translates to:
  /// **'raised of {goal} DZD goal'**
  String raisedOfGoalAmount(Object goal);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'dz', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'dz': return AppLocalizationsDz();
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
