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
  /// **'Lost pets nearby'**
  String get lostPetsNearby;

  /// No description provided for @recentLostPets.
  ///
  /// In en, this message translates to:
  /// **'Recent lost pets'**
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
  /// **'Error'**
  String get error;

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
  /// **'vet'**
  String get vet;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'store'**
  String get store;

  /// No description provided for @vetClinic.
  ///
  /// In en, this message translates to:
  /// **'vet clinic'**
  String get vetClinic;

  /// No description provided for @petStore.
  ///
  /// In en, this message translates to:
  /// **'Pet Store'**
  String get petStore;

  /// No description provided for @myPets.
  ///
  /// In en, this message translates to:
  /// **'My Pets'**
  String get myPets;

  /// No description provided for @addPet.
  ///
  /// In en, this message translates to:
  /// **'Add Pet'**
  String get addPet;

  /// No description provided for @editPet.
  ///
  /// In en, this message translates to:
  /// **'Edit Pet'**
  String get editPet;

  /// No description provided for @petName.
  ///
  /// In en, this message translates to:
  /// **'Pet Name'**
  String get petName;

  /// No description provided for @petType.
  ///
  /// In en, this message translates to:
  /// **'Pet Type'**
  String get petType;

  /// No description provided for @petBreed.
  ///
  /// In en, this message translates to:
  /// **'Pet Breed'**
  String get petBreed;

  /// No description provided for @petAge.
  ///
  /// In en, this message translates to:
  /// **'Pet Age'**
  String get petAge;

  /// No description provided for @petWeight.
  ///
  /// In en, this message translates to:
  /// **'Pet Weight'**
  String get petWeight;

  /// No description provided for @petColor.
  ///
  /// In en, this message translates to:
  /// **'Pet Color'**
  String get petColor;

  /// No description provided for @petGender.
  ///
  /// In en, this message translates to:
  /// **'Pet Gender'**
  String get petGender;

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

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deletePet.
  ///
  /// In en, this message translates to:
  /// **'Delete Pet'**
  String get deletePet;

  /// No description provided for @deletePetConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this pet?'**
  String get deletePetConfirmation;

  /// No description provided for @petDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Pet deleted successfully'**
  String get petDeletedSuccessfully;

  /// No description provided for @petSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Pet saved successfully'**
  String get petSavedSuccessfully;

  /// No description provided for @errorSavingPet.
  ///
  /// In en, this message translates to:
  /// **'Error saving pet: {error}'**
  String errorSavingPet(Object error);

  /// No description provided for @errorDeletingPet.
  ///
  /// In en, this message translates to:
  /// **'Error deleting pet: {error}'**
  String errorDeletingPet(Object error);

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

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

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageSelected;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noPetsFound.
  ///
  /// In en, this message translates to:
  /// **'No pets found'**
  String get noPetsFound;

  /// No description provided for @addYourFirstPet.
  ///
  /// In en, this message translates to:
  /// **'Add your first pet'**
  String get addYourFirstPet;

  /// No description provided for @petDetails.
  ///
  /// In en, this message translates to:
  /// **'Pet Details'**
  String get petDetails;

  /// No description provided for @petPhotos.
  ///
  /// In en, this message translates to:
  /// **'Pet Photos'**
  String get petPhotos;

  /// No description provided for @petMedicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get petMedicalHistory;

  /// No description provided for @petVaccinations.
  ///
  /// In en, this message translates to:
  /// **'Vaccinations'**
  String get petVaccinations;

  /// No description provided for @petMedications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get petMedications;

  /// No description provided for @petAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get petAllergies;

  /// No description provided for @petBehavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get petBehavior;

  /// No description provided for @petDiet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get petDiet;

  /// No description provided for @petExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get petExercise;

  /// No description provided for @petGrooming.
  ///
  /// In en, this message translates to:
  /// **'Grooming'**
  String get petGrooming;

  /// No description provided for @petTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get petTraining;

  /// No description provided for @petInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get petInsurance;

  /// No description provided for @petMicrochip.
  ///
  /// In en, this message translates to:
  /// **'Microchip'**
  String get petMicrochip;

  /// No description provided for @petLicense.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get petLicense;

  /// No description provided for @petRegistration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get petRegistration;

  /// No description provided for @petEmergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get petEmergencyContact;

  /// No description provided for @petVet.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian'**
  String get petVet;

  /// No description provided for @petGroomer.
  ///
  /// In en, this message translates to:
  /// **'Groomer'**
  String get petGroomer;

  /// No description provided for @petTrainer.
  ///
  /// In en, this message translates to:
  /// **'Trainer'**
  String get petTrainer;

  /// No description provided for @petSitter.
  ///
  /// In en, this message translates to:
  /// **'Pet Sitter'**
  String get petSitter;

  /// No description provided for @petWalker.
  ///
  /// In en, this message translates to:
  /// **'Pet Walker'**
  String get petWalker;

  /// No description provided for @petBoarding.
  ///
  /// In en, this message translates to:
  /// **'Boarding'**
  String get petBoarding;

  /// No description provided for @petDaycare.
  ///
  /// In en, this message translates to:
  /// **'Daycare'**
  String get petDaycare;

  /// No description provided for @petAdoption.
  ///
  /// In en, this message translates to:
  /// **'Adoption'**
  String get petAdoption;

  /// No description provided for @petFoster.
  ///
  /// In en, this message translates to:
  /// **'Foster'**
  String get petFoster;

  /// No description provided for @petRescue.
  ///
  /// In en, this message translates to:
  /// **'Rescue'**
  String get petRescue;

  /// No description provided for @petShelter.
  ///
  /// In en, this message translates to:
  /// **'Shelter'**
  String get petShelter;

  /// No description provided for @petBreeder.
  ///
  /// In en, this message translates to:
  /// **'Breeder'**
  String get petBreeder;

  /// No description provided for @petClinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get petClinic;

  /// No description provided for @petHospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get petHospital;

  /// No description provided for @petPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get petPharmacy;

  /// No description provided for @petFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get petFood;

  /// No description provided for @petToys.
  ///
  /// In en, this message translates to:
  /// **'Toys'**
  String get petToys;

  /// No description provided for @petBeds.
  ///
  /// In en, this message translates to:
  /// **'Beds'**
  String get petBeds;

  /// No description provided for @petCrates.
  ///
  /// In en, this message translates to:
  /// **'Crates'**
  String get petCrates;

  /// No description provided for @petCarriers.
  ///
  /// In en, this message translates to:
  /// **'Carriers'**
  String get petCarriers;

  /// No description provided for @petCollars.
  ///
  /// In en, this message translates to:
  /// **'Collars'**
  String get petCollars;

  /// No description provided for @petLeashes.
  ///
  /// In en, this message translates to:
  /// **'Leashes'**
  String get petLeashes;

  /// No description provided for @petHarnesses.
  ///
  /// In en, this message translates to:
  /// **'Harnesses'**
  String get petHarnesses;

  /// No description provided for @petTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get petTags;

  /// No description provided for @petClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get petClothing;

  /// No description provided for @petShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get petShoes;

  /// No description provided for @petAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get petAccessories;

  /// No description provided for @petSupplies.
  ///
  /// In en, this message translates to:
  /// **'Supplies'**
  String get petSupplies;

  /// No description provided for @petEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get petEquipment;

  /// No description provided for @petTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get petTools;

  /// No description provided for @petMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get petMedicine;

  /// No description provided for @petVitamins.
  ///
  /// In en, this message translates to:
  /// **'Vitamins'**
  String get petVitamins;

  /// No description provided for @petSupplements.
  ///
  /// In en, this message translates to:
  /// **'Supplements'**
  String get petSupplements;

  /// No description provided for @petTreats.
  ///
  /// In en, this message translates to:
  /// **'Treats'**
  String get petTreats;

  /// No description provided for @petSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get petSnacks;

  /// No description provided for @petWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get petWater;

  /// No description provided for @petBowl.
  ///
  /// In en, this message translates to:
  /// **'Bowl'**
  String get petBowl;

  /// No description provided for @petFeeder.
  ///
  /// In en, this message translates to:
  /// **'Feeder'**
  String get petFeeder;

  /// No description provided for @petFountain.
  ///
  /// In en, this message translates to:
  /// **'Fountain'**
  String get petFountain;

  /// No description provided for @petLitter.
  ///
  /// In en, this message translates to:
  /// **'Litter'**
  String get petLitter;

  /// No description provided for @petLitterBox.
  ///
  /// In en, this message translates to:
  /// **'Litter Box'**
  String get petLitterBox;

  /// No description provided for @petScratchingPost.
  ///
  /// In en, this message translates to:
  /// **'Scratching Post'**
  String get petScratchingPost;

  /// No description provided for @petTree.
  ///
  /// In en, this message translates to:
  /// **'Cat Tree'**
  String get petTree;

  /// No description provided for @petCage.
  ///
  /// In en, this message translates to:
  /// **'Cage'**
  String get petCage;

  /// No description provided for @petAquarium.
  ///
  /// In en, this message translates to:
  /// **'Aquarium'**
  String get petAquarium;

  /// No description provided for @petTerrarium.
  ///
  /// In en, this message translates to:
  /// **'Terrarium'**
  String get petTerrarium;

  /// No description provided for @petHutch.
  ///
  /// In en, this message translates to:
  /// **'Hutch'**
  String get petHutch;

  /// No description provided for @petCoop.
  ///
  /// In en, this message translates to:
  /// **'Coop'**
  String get petCoop;

  /// No description provided for @petStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get petStable;

  /// No description provided for @petBarn.
  ///
  /// In en, this message translates to:
  /// **'Barn'**
  String get petBarn;

  /// No description provided for @petKennel.
  ///
  /// In en, this message translates to:
  /// **'Kennel'**
  String get petKennel;

  /// No description provided for @petRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get petRun;

  /// No description provided for @petFence.
  ///
  /// In en, this message translates to:
  /// **'Fence'**
  String get petFence;

  /// No description provided for @petGate.
  ///
  /// In en, this message translates to:
  /// **'Gate'**
  String get petGate;

  /// No description provided for @petDoor.
  ///
  /// In en, this message translates to:
  /// **'Pet Door'**
  String get petDoor;

  /// No description provided for @petRamp.
  ///
  /// In en, this message translates to:
  /// **'Ramp'**
  String get petRamp;

  /// No description provided for @petStairs.
  ///
  /// In en, this message translates to:
  /// **'Stairs'**
  String get petStairs;

  /// No description provided for @petElevator.
  ///
  /// In en, this message translates to:
  /// **'Elevator'**
  String get petElevator;

  /// No description provided for @petEscalator.
  ///
  /// In en, this message translates to:
  /// **'Escalator'**
  String get petEscalator;

  /// No description provided for @petSlide.
  ///
  /// In en, this message translates to:
  /// **'Slide'**
  String get petSlide;

  /// No description provided for @petSwing.
  ///
  /// In en, this message translates to:
  /// **'Swing'**
  String get petSwing;

  /// No description provided for @petSeesaw.
  ///
  /// In en, this message translates to:
  /// **'Seesaw'**
  String get petSeesaw;

  /// No description provided for @petMerryGoRound.
  ///
  /// In en, this message translates to:
  /// **'Merry-go-round'**
  String get petMerryGoRound;

  /// No description provided for @petFerrisWheel.
  ///
  /// In en, this message translates to:
  /// **'Ferris Wheel'**
  String get petFerrisWheel;

  /// No description provided for @petRollerCoaster.
  ///
  /// In en, this message translates to:
  /// **'Roller Coaster'**
  String get petRollerCoaster;

  /// No description provided for @petCarousel.
  ///
  /// In en, this message translates to:
  /// **'Carousel'**
  String get petCarousel;

  /// No description provided for @petBumperCars.
  ///
  /// In en, this message translates to:
  /// **'Bumper Cars'**
  String get petBumperCars;

  /// No description provided for @petGoKarts.
  ///
  /// In en, this message translates to:
  /// **'Go-karts'**
  String get petGoKarts;

  /// No description provided for @petMiniGolf.
  ///
  /// In en, this message translates to:
  /// **'Mini Golf'**
  String get petMiniGolf;

  /// No description provided for @petBowling.
  ///
  /// In en, this message translates to:
  /// **'Bowling'**
  String get petBowling;

  /// No description provided for @petArcade.
  ///
  /// In en, this message translates to:
  /// **'Arcade'**
  String get petArcade;

  /// No description provided for @petCinema.
  ///
  /// In en, this message translates to:
  /// **'Cinema'**
  String get petCinema;

  /// No description provided for @petTheater.
  ///
  /// In en, this message translates to:
  /// **'Theater'**
  String get petTheater;

  /// No description provided for @petConcert.
  ///
  /// In en, this message translates to:
  /// **'Concert'**
  String get petConcert;

  /// No description provided for @petFestival.
  ///
  /// In en, this message translates to:
  /// **'Festival'**
  String get petFestival;

  /// No description provided for @petCarnival.
  ///
  /// In en, this message translates to:
  /// **'Carnival'**
  String get petCarnival;

  /// No description provided for @petCircus.
  ///
  /// In en, this message translates to:
  /// **'Circus'**
  String get petCircus;

  /// No description provided for @petZoo.
  ///
  /// In en, this message translates to:
  /// **'Zoo'**
  String get petZoo;

  /// No description provided for @petMuseum.
  ///
  /// In en, this message translates to:
  /// **'Museum'**
  String get petMuseum;

  /// No description provided for @petLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get petLibrary;

  /// No description provided for @petSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get petSchool;

  /// No description provided for @petUniversity.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get petUniversity;

  /// No description provided for @petCollege.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get petCollege;

  /// No description provided for @petAcademy.
  ///
  /// In en, this message translates to:
  /// **'Academy'**
  String get petAcademy;

  /// No description provided for @petInstitute.
  ///
  /// In en, this message translates to:
  /// **'Institute'**
  String get petInstitute;

  /// No description provided for @petCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get petCenter;

  /// No description provided for @petFoundation.
  ///
  /// In en, this message translates to:
  /// **'Foundation'**
  String get petFoundation;

  /// No description provided for @petAssociation.
  ///
  /// In en, this message translates to:
  /// **'Association'**
  String get petAssociation;

  /// No description provided for @petSociety.
  ///
  /// In en, this message translates to:
  /// **'Society'**
  String get petSociety;

  /// No description provided for @petClub.
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get petClub;

  /// No description provided for @petGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get petGroup;

  /// No description provided for @petTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get petTeam;

  /// No description provided for @petSquad.
  ///
  /// In en, this message translates to:
  /// **'Squad'**
  String get petSquad;

  /// No description provided for @petGang.
  ///
  /// In en, this message translates to:
  /// **'Gang'**
  String get petGang;

  /// No description provided for @petPack.
  ///
  /// In en, this message translates to:
  /// **'Pack'**
  String get petPack;

  /// No description provided for @petHerd.
  ///
  /// In en, this message translates to:
  /// **'Herd'**
  String get petHerd;

  /// No description provided for @petFlock.
  ///
  /// In en, this message translates to:
  /// **'Flock'**
  String get petFlock;

  /// No description provided for @petSwarm.
  ///
  /// In en, this message translates to:
  /// **'Swarm'**
  String get petSwarm;

  /// No description provided for @petColony.
  ///
  /// In en, this message translates to:
  /// **'Colony'**
  String get petColony;

  /// No description provided for @petNest.
  ///
  /// In en, this message translates to:
  /// **'Nest'**
  String get petNest;

  /// No description provided for @petDen.
  ///
  /// In en, this message translates to:
  /// **'Den'**
  String get petDen;

  /// No description provided for @petLair.
  ///
  /// In en, this message translates to:
  /// **'Lair'**
  String get petLair;

  /// No description provided for @petCave.
  ///
  /// In en, this message translates to:
  /// **'Cave'**
  String get petCave;

  /// No description provided for @petBurrow.
  ///
  /// In en, this message translates to:
  /// **'Burrow'**
  String get petBurrow;

  /// No description provided for @petHole.
  ///
  /// In en, this message translates to:
  /// **'Hole'**
  String get petHole;

  /// No description provided for @petTunnel.
  ///
  /// In en, this message translates to:
  /// **'Tunnel'**
  String get petTunnel;

  /// No description provided for @petMaze.
  ///
  /// In en, this message translates to:
  /// **'Maze'**
  String get petMaze;

  /// No description provided for @petLabyrinth.
  ///
  /// In en, this message translates to:
  /// **'Labyrinth'**
  String get petLabyrinth;

  /// No description provided for @petPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Puzzle'**
  String get petPuzzle;

  /// No description provided for @petGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get petGame;

  /// No description provided for @petPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get petPlay;

  /// No description provided for @petFun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get petFun;

  /// No description provided for @petHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get petHappy;

  /// No description provided for @petSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get petSad;

  /// No description provided for @petAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get petAngry;

  /// No description provided for @petScared.
  ///
  /// In en, this message translates to:
  /// **'Scared'**
  String get petScared;

  /// No description provided for @petExcited.
  ///
  /// In en, this message translates to:
  /// **'Excited'**
  String get petExcited;

  /// No description provided for @petCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get petCalm;

  /// No description provided for @petSleepy.
  ///
  /// In en, this message translates to:
  /// **'Sleepy'**
  String get petSleepy;

  /// No description provided for @petHungry.
  ///
  /// In en, this message translates to:
  /// **'Hungry'**
  String get petHungry;

  /// No description provided for @petThirsty.
  ///
  /// In en, this message translates to:
  /// **'Thirsty'**
  String get petThirsty;

  /// No description provided for @petTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get petTired;

  /// No description provided for @petEnergetic.
  ///
  /// In en, this message translates to:
  /// **'Energetic'**
  String get petEnergetic;

  /// No description provided for @petLazy.
  ///
  /// In en, this message translates to:
  /// **'Lazy'**
  String get petLazy;

  /// No description provided for @petActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get petActive;

  /// No description provided for @petQuiet.
  ///
  /// In en, this message translates to:
  /// **'Quiet'**
  String get petQuiet;

  /// No description provided for @petLoud.
  ///
  /// In en, this message translates to:
  /// **'Loud'**
  String get petLoud;

  /// No description provided for @petNoisy.
  ///
  /// In en, this message translates to:
  /// **'Noisy'**
  String get petNoisy;

  /// No description provided for @petSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get petSilent;

  /// No description provided for @petTalkative.
  ///
  /// In en, this message translates to:
  /// **'Talkative'**
  String get petTalkative;

  /// No description provided for @petShy.
  ///
  /// In en, this message translates to:
  /// **'Shy'**
  String get petShy;

  /// No description provided for @petFriendly.
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get petFriendly;

  /// No description provided for @petAggressive.
  ///
  /// In en, this message translates to:
  /// **'Aggressive'**
  String get petAggressive;

  /// No description provided for @petGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get petGentle;

  /// No description provided for @petRough.
  ///
  /// In en, this message translates to:
  /// **'Rough'**
  String get petRough;

  /// No description provided for @petSoft.
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get petSoft;

  /// No description provided for @petHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get petHard;

  /// No description provided for @petSmooth.
  ///
  /// In en, this message translates to:
  /// **'Smooth'**
  String get petSmooth;

  /// No description provided for @petWarm.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get petWarm;

  /// No description provided for @petCold.
  ///
  /// In en, this message translates to:
  /// **'Cold'**
  String get petCold;

  /// No description provided for @petHot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get petHot;

  /// No description provided for @petCool.
  ///
  /// In en, this message translates to:
  /// **'Cool'**
  String get petCool;

  /// No description provided for @petWet.
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get petWet;

  /// No description provided for @petDry.
  ///
  /// In en, this message translates to:
  /// **'Dry'**
  String get petDry;

  /// No description provided for @petClean.
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get petClean;

  /// No description provided for @petDirty.
  ///
  /// In en, this message translates to:
  /// **'Dirty'**
  String get petDirty;

  /// No description provided for @petFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get petFresh;

  /// No description provided for @petStale.
  ///
  /// In en, this message translates to:
  /// **'Stale'**
  String get petStale;

  /// No description provided for @petNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get petNew;

  /// No description provided for @petOld.
  ///
  /// In en, this message translates to:
  /// **'Old'**
  String get petOld;

  /// No description provided for @petYoung.
  ///
  /// In en, this message translates to:
  /// **'Young'**
  String get petYoung;

  /// No description provided for @petBaby.
  ///
  /// In en, this message translates to:
  /// **'Baby'**
  String get petBaby;

  /// No description provided for @petPuppy.
  ///
  /// In en, this message translates to:
  /// **'Puppy'**
  String get petPuppy;

  /// No description provided for @petKitten.
  ///
  /// In en, this message translates to:
  /// **'Kitten'**
  String get petKitten;

  /// No description provided for @petCub.
  ///
  /// In en, this message translates to:
  /// **'Cub'**
  String get petCub;

  /// No description provided for @petChick.
  ///
  /// In en, this message translates to:
  /// **'Chick'**
  String get petChick;

  /// No description provided for @petFoal.
  ///
  /// In en, this message translates to:
  /// **'Foal'**
  String get petFoal;

  /// No description provided for @petCalf.
  ///
  /// In en, this message translates to:
  /// **'Calf'**
  String get petCalf;

  /// No description provided for @petLamb.
  ///
  /// In en, this message translates to:
  /// **'Lamb'**
  String get petLamb;

  /// No description provided for @petKid.
  ///
  /// In en, this message translates to:
  /// **'Kid'**
  String get petKid;

  /// No description provided for @petPiglet.
  ///
  /// In en, this message translates to:
  /// **'Piglet'**
  String get petPiglet;

  /// No description provided for @petDuckling.
  ///
  /// In en, this message translates to:
  /// **'Duckling'**
  String get petDuckling;

  /// No description provided for @petGosling.
  ///
  /// In en, this message translates to:
  /// **'Gosling'**
  String get petGosling;

  /// No description provided for @petCygnets.
  ///
  /// In en, this message translates to:
  /// **'Cygnets'**
  String get petCygnets;

  /// No description provided for @petTadpole.
  ///
  /// In en, this message translates to:
  /// **'Tadpole'**
  String get petTadpole;

  /// No description provided for @petFry.
  ///
  /// In en, this message translates to:
  /// **'Fry'**
  String get petFry;

  /// No description provided for @petFingerling.
  ///
  /// In en, this message translates to:
  /// **'Fingerling'**
  String get petFingerling;

  /// No description provided for @petSmolt.
  ///
  /// In en, this message translates to:
  /// **'Smolt'**
  String get petSmolt;

  /// No description provided for @petParr.
  ///
  /// In en, this message translates to:
  /// **'Parr'**
  String get petParr;

  /// No description provided for @petAlevin.
  ///
  /// In en, this message translates to:
  /// **'Alevin'**
  String get petAlevin;

  /// No description provided for @petSpawn.
  ///
  /// In en, this message translates to:
  /// **'Spawn'**
  String get petSpawn;

  /// No description provided for @petRoe.
  ///
  /// In en, this message translates to:
  /// **'Roe'**
  String get petRoe;

  /// No description provided for @petCaviar.
  ///
  /// In en, this message translates to:
  /// **'Caviar'**
  String get petCaviar;

  /// No description provided for @petEgg.
  ///
  /// In en, this message translates to:
  /// **'Egg'**
  String get petEgg;

  /// No description provided for @petLarva.
  ///
  /// In en, this message translates to:
  /// **'Larva'**
  String get petLarva;

  /// No description provided for @petPupa.
  ///
  /// In en, this message translates to:
  /// **'Pupa'**
  String get petPupa;

  /// No description provided for @petCaterpillar.
  ///
  /// In en, this message translates to:
  /// **'Caterpillar'**
  String get petCaterpillar;

  /// No description provided for @petChrysalis.
  ///
  /// In en, this message translates to:
  /// **'Chrysalis'**
  String get petChrysalis;

  /// No description provided for @petCocoon.
  ///
  /// In en, this message translates to:
  /// **'Cocoon'**
  String get petCocoon;

  /// No description provided for @petMaggot.
  ///
  /// In en, this message translates to:
  /// **'Maggot'**
  String get petMaggot;

  /// No description provided for @petGrub.
  ///
  /// In en, this message translates to:
  /// **'Grub'**
  String get petGrub;

  /// No description provided for @petWorm.
  ///
  /// In en, this message translates to:
  /// **'Worm'**
  String get petWorm;

  /// No description provided for @petSlug.
  ///
  /// In en, this message translates to:
  /// **'Slug'**
  String get petSlug;

  /// No description provided for @petSnail.
  ///
  /// In en, this message translates to:
  /// **'Snail'**
  String get petSnail;

  /// No description provided for @petClam.
  ///
  /// In en, this message translates to:
  /// **'Clam'**
  String get petClam;

  /// No description provided for @petOyster.
  ///
  /// In en, this message translates to:
  /// **'Oyster'**
  String get petOyster;

  /// No description provided for @petMussel.
  ///
  /// In en, this message translates to:
  /// **'Mussel'**
  String get petMussel;

  /// No description provided for @petScallop.
  ///
  /// In en, this message translates to:
  /// **'Scallop'**
  String get petScallop;

  /// No description provided for @petAbalone.
  ///
  /// In en, this message translates to:
  /// **'Abalone'**
  String get petAbalone;

  /// No description provided for @petConch.
  ///
  /// In en, this message translates to:
  /// **'Conch'**
  String get petConch;

  /// No description provided for @petWhelk.
  ///
  /// In en, this message translates to:
  /// **'Whelk'**
  String get petWhelk;

  /// No description provided for @petPeriwinkle.
  ///
  /// In en, this message translates to:
  /// **'Periwinkle'**
  String get petPeriwinkle;

  /// No description provided for @petLimpets.
  ///
  /// In en, this message translates to:
  /// **'Limpets'**
  String get petLimpets;

  /// No description provided for @petBarnacles.
  ///
  /// In en, this message translates to:
  /// **'Barnacles'**
  String get petBarnacles;

  /// No description provided for @petCrabs.
  ///
  /// In en, this message translates to:
  /// **'Crabs'**
  String get petCrabs;

  /// No description provided for @petLobsters.
  ///
  /// In en, this message translates to:
  /// **'Lobsters'**
  String get petLobsters;

  /// No description provided for @petShrimp.
  ///
  /// In en, this message translates to:
  /// **'Shrimp'**
  String get petShrimp;

  /// No description provided for @petPrawns.
  ///
  /// In en, this message translates to:
  /// **'Prawns'**
  String get petPrawns;

  /// No description provided for @petCrayfish.
  ///
  /// In en, this message translates to:
  /// **'Crayfish'**
  String get petCrayfish;

  /// No description provided for @petKrill.
  ///
  /// In en, this message translates to:
  /// **'Krill'**
  String get petKrill;

  /// No description provided for @petCopepods.
  ///
  /// In en, this message translates to:
  /// **'Copepods'**
  String get petCopepods;

  /// No description provided for @petAmphipods.
  ///
  /// In en, this message translates to:
  /// **'Amphipods'**
  String get petAmphipods;

  /// No description provided for @petIsopods.
  ///
  /// In en, this message translates to:
  /// **'Isopods'**
  String get petIsopods;

  /// No description provided for @petOstracods.
  ///
  /// In en, this message translates to:
  /// **'Ostracods'**
  String get petOstracods;

  /// No description provided for @petBranchiopods.
  ///
  /// In en, this message translates to:
  /// **'Branchiopods'**
  String get petBranchiopods;

  /// No description provided for @petRemipedes.
  ///
  /// In en, this message translates to:
  /// **'Remipedes'**
  String get petRemipedes;

  /// No description provided for @petCephalocarids.
  ///
  /// In en, this message translates to:
  /// **'Cephalocarids'**
  String get petCephalocarids;

  /// No description provided for @petMalacostracans.
  ///
  /// In en, this message translates to:
  /// **'Malacostracans'**
  String get petMalacostracans;

  /// No description provided for @petMaxillopods.
  ///
  /// In en, this message translates to:
  /// **'Maxillopods'**
  String get petMaxillopods;

  /// No description provided for @petThecostracans.
  ///
  /// In en, this message translates to:
  /// **'Thecostracans'**
  String get petThecostracans;

  /// No description provided for @petTantulocarids.
  ///
  /// In en, this message translates to:
  /// **'Tantulocarids'**
  String get petTantulocarids;

  /// No description provided for @petMystacocarids.
  ///
  /// In en, this message translates to:
  /// **'Mystacocarids'**
  String get petMystacocarids;

  /// No description provided for @petBranchiurans.
  ///
  /// In en, this message translates to:
  /// **'Branchiurans'**
  String get petBranchiurans;

  /// No description provided for @petPentastomids.
  ///
  /// In en, this message translates to:
  /// **'Pentastomids'**
  String get petPentastomids;

  /// No description provided for @petTardigrades.
  ///
  /// In en, this message translates to:
  /// **'Tardigrades'**
  String get petTardigrades;

  /// No description provided for @petRotifers.
  ///
  /// In en, this message translates to:
  /// **'Rotifers'**
  String get petRotifers;

  /// No description provided for @petGastrotrichs.
  ///
  /// In en, this message translates to:
  /// **'Gastrotrichs'**
  String get petGastrotrichs;

  /// No description provided for @petKinorhynchs.
  ///
  /// In en, this message translates to:
  /// **'Kinorhynchs'**
  String get petKinorhynchs;

  /// No description provided for @petLoriciferans.
  ///
  /// In en, this message translates to:
  /// **'Loriciferans'**
  String get petLoriciferans;

  /// No description provided for @petPriapulids.
  ///
  /// In en, this message translates to:
  /// **'Priapulids'**
  String get petPriapulids;

  /// No description provided for @petNematodes.
  ///
  /// In en, this message translates to:
  /// **'Nematodes'**
  String get petNematodes;

  /// No description provided for @petNematomorphs.
  ///
  /// In en, this message translates to:
  /// **'Nematomorphs'**
  String get petNematomorphs;

  /// No description provided for @petAcanthocephalans.
  ///
  /// In en, this message translates to:
  /// **'Acanthocephalans'**
  String get petAcanthocephalans;

  /// No description provided for @petEntoprocts.
  ///
  /// In en, this message translates to:
  /// **'Entoprocts'**
  String get petEntoprocts;

  /// No description provided for @petCycliophorans.
  ///
  /// In en, this message translates to:
  /// **'Cycliophorans'**
  String get petCycliophorans;

  /// No description provided for @petMicrognathozoans.
  ///
  /// In en, this message translates to:
  /// **'Micrognathozoans'**
  String get petMicrognathozoans;

  /// No description provided for @petGnathostomulids.
  ///
  /// In en, this message translates to:
  /// **'Gnathostomulids'**
  String get petGnathostomulids;

  /// No description provided for @petPlatyhelminthes.
  ///
  /// In en, this message translates to:
  /// **'Platyhelminthes'**
  String get petPlatyhelminthes;

  /// No description provided for @petCestodes.
  ///
  /// In en, this message translates to:
  /// **'Cestodes'**
  String get petCestodes;

  /// No description provided for @petTrematodes.
  ///
  /// In en, this message translates to:
  /// **'Trematodes'**
  String get petTrematodes;

  /// No description provided for @petMonogeneans.
  ///
  /// In en, this message translates to:
  /// **'Monogeneans'**
  String get petMonogeneans;

  /// No description provided for @petTurbellarians.
  ///
  /// In en, this message translates to:
  /// **'Turbellarians'**
  String get petTurbellarians;

  /// No description provided for @petCatenulids.
  ///
  /// In en, this message translates to:
  /// **'Catenulids'**
  String get petCatenulids;

  /// No description provided for @petRhabditophorans.
  ///
  /// In en, this message translates to:
  /// **'Rhabditophorans'**
  String get petRhabditophorans;

  /// No description provided for @petNeodermata.
  ///
  /// In en, this message translates to:
  /// **'Neodermata'**
  String get petNeodermata;

  /// No description provided for @petAspidogastrea.
  ///
  /// In en, this message translates to:
  /// **'Aspidogastrea'**
  String get petAspidogastrea;

  /// No description provided for @petDigenea.
  ///
  /// In en, this message translates to:
  /// **'Digenea'**
  String get petDigenea;

  /// No description provided for @petMonopisthocotylea.
  ///
  /// In en, this message translates to:
  /// **'Monopisthocotylea'**
  String get petMonopisthocotylea;

  /// No description provided for @petPolyopisthocotylea.
  ///
  /// In en, this message translates to:
  /// **'Polyopisthocotylea'**
  String get petPolyopisthocotylea;

  /// No description provided for @petGyrocotylidea.
  ///
  /// In en, this message translates to:
  /// **'Gyrocotylidea'**
  String get petGyrocotylidea;

  /// No description provided for @petAmphilinidea.
  ///
  /// In en, this message translates to:
  /// **'Amphilinidea'**
  String get petAmphilinidea;

  /// No description provided for @petCaryophyllidea.
  ///
  /// In en, this message translates to:
  /// **'Caryophyllidea'**
  String get petCaryophyllidea;

  /// No description provided for @petDiphyllobothriidea.
  ///
  /// In en, this message translates to:
  /// **'Diphyllobothriidea'**
  String get petDiphyllobothriidea;

  /// No description provided for @petHaplobothriidea.
  ///
  /// In en, this message translates to:
  /// **'Haplobothriidea'**
  String get petHaplobothriidea;

  /// No description provided for @petBothriocephalidea.
  ///
  /// In en, this message translates to:
  /// **'Bothriocephalidea'**
  String get petBothriocephalidea;

  /// No description provided for @petLitobothriidea.
  ///
  /// In en, this message translates to:
  /// **'Litobothriidea'**
  String get petLitobothriidea;

  /// No description provided for @petLecanicephalidea.
  ///
  /// In en, this message translates to:
  /// **'Lecanicephalidea'**
  String get petLecanicephalidea;

  /// No description provided for @petRhinebothriidea.
  ///
  /// In en, this message translates to:
  /// **'Rhinebothriidea'**
  String get petRhinebothriidea;

  /// No description provided for @petTetraphyllidea.
  ///
  /// In en, this message translates to:
  /// **'Tetraphyllidea'**
  String get petTetraphyllidea;

  /// No description provided for @petOnchoproteocephalidea.
  ///
  /// In en, this message translates to:
  /// **'Onchoproteocephalidea'**
  String get petOnchoproteocephalidea;

  /// No description provided for @petProteocephalidea.
  ///
  /// In en, this message translates to:
  /// **'Proteocephalidea'**
  String get petProteocephalidea;

  /// No description provided for @petTrypanorhyncha.
  ///
  /// In en, this message translates to:
  /// **'Trypanorhyncha'**
  String get petTrypanorhyncha;

  /// No description provided for @petDiphyllidea.
  ///
  /// In en, this message translates to:
  /// **'Diphyllidea'**
  String get petDiphyllidea;

  /// No description provided for @petSpathebothriidea.
  ///
  /// In en, this message translates to:
  /// **'Spathebothriidea'**
  String get petSpathebothriidea;
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
