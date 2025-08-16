// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get continueWithFacebook => 'Continue with Facebook';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get reportAProblem => 'Report a problem';

  @override
  String get byClickingContinueYouAgreeToOur => 'By clicking continue, you agree to our';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => 'and';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get aiPetAssistant => 'AI Pet Assistant';

  @override
  String get typeYourMessage => 'Type your message...';

  @override
  String get alifi => 'alifi';

  @override
  String get goodAfternoonUser => 'Good afternoon, user!';

  @override
  String get loadingNearbyPets => 'Loading nearby pets...';

  @override
  String get lostPetsNearby => 'Lost Pets Nearby';

  @override
  String get recentLostPets => 'Recent Lost Pets';

  @override
  String get lost => 'LOST';

  @override
  String get yearsOld => 'years old';

  @override
  String get description => 'Description';

  @override
  String get price => 'Price';

  @override
  String get affiliatePartnership => 'Affiliate Partnership';

  @override
  String get affiliatePartnershipDescription => 'This product is available through our affiliate partnership with AliExpress. When you make a purchase through these links, you support our app at no additional cost to you. This helps us maintain and improve our services.';

  @override
  String get reportFound => 'Report Found';

  @override
  String get openInMaps => 'Open in Maps';

  @override
  String get contact => 'Contact';

  @override
  String get petMarkedAsFoundSuccessfully => 'Pet marked as found successfully!';

  @override
  String errorMarkingPetAsFound(Object error) {
    return 'Error marking pet as found: $error';
  }

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get thisWillPostYourMissingPetReport => 'This will post your missing pet report to the community.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get search => 'Search';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get proceed => 'PROCEED';

  @override
  String get enterCustomAmount => 'Enter custom amount';

  @override
  String get locationServicesDisabled => 'Location Services Disabled';

  @override
  String get pleaseEnableLocationServices => 'Please enable location services or enter your location manually.';

  @override
  String get enterManually => 'Enter Manually';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get locationPermissionRequired => 'Location Permission Required';

  @override
  String get locationPermissionRequiredDescription => 'Location permission is required to use this feature. Please enable it in your device settings.';

  @override
  String get enterYourLocation => 'Enter Your Location';

  @override
  String locationSetTo(Object address) {
    return 'Location set to: $address';
  }

  @override
  String get reportMissingPet => 'Report Missing Pet';

  @override
  String get addYourBusiness => 'Add Your Business';

  @override
  String get pleaseLoginToReportMissingPet => 'Please login to report a missing pet';

  @override
  String get thisVetIsAlreadyInDatabase => 'This vet is already in the database';

  @override
  String get thisStoreIsAlreadyInDatabase => 'This store is already in the database';

  @override
  String get addedVetClinicToMap => 'Added vet clinic to map';

  @override
  String get addedPetStoreToMap => 'Added pet store to map';

  @override
  String errorAddingBusiness(Object error) {
    return 'Error adding business: $error';
  }

  @override
  String get migrateLocations => 'Migrate Locations';

  @override
  String get migrateLocationsDescription => 'This will migrate all existing pet locations to the new format. This process cannot be undone.';

  @override
  String get migrationComplete => 'Migration Complete';

  @override
  String get migrationCompleteDescription => 'All locations have been successfully migrated to the new format.';

  @override
  String get migrationFailed => 'Migration Failed';

  @override
  String errorDuringMigration(Object error) {
    return 'Error during migration: $error';
  }

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get french => 'Français';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy => 'Privacy';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';

  @override
  String get logout => 'Logout';

  @override
  String get debugInfo => 'Debug Info';

  @override
  String get authServiceInitialized => 'AuthService initialized';

  @override
  String get authServiceLoading => 'AuthService loading';

  @override
  String get authServiceAuthenticated => 'AuthService authenticated';

  @override
  String get authServiceUser => 'AuthService user';

  @override
  String get firebaseUser => 'Firebase user';

  @override
  String get guestMode => 'Guest mode';

  @override
  String get forceSignOut => 'Force Sign Out';

  @override
  String get signedOutOfAllServices => 'Signed out of all services';

  @override
  String failedToGetDebugInfo(Object error) {
    return 'Failed to get debug info: $error';
  }

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get lastSeen => 'Last seen';

  @override
  String physicalPetIdFor(Object petName) {
    return 'Physical Pet ID for $petName';
  }

  @override
  String get priceValue => '\$20.00';

  @override
  String get hiAskMeAboutPetAdvice => 'Hi! ask me about any pet advice,\nand I\'ll do my best to help you, and\nyour little one!';

  @override
  String errorGettingLocation(Object error) {
    return 'Error getting location: $error';
  }

  @override
  String errorFindingLocation(Object error) {
    return 'Error finding location: $error';
  }

  @override
  String get vet => 'Vets';

  @override
  String get vetsNearMe => 'Vets Near Me';

  @override
  String get recommendedVets => 'Recommended Vets';

  @override
  String get topVets => 'Top Vets';

  @override
  String get store => 'Store';

  @override
  String get vetClinic => 'vet clinic';

  @override
  String get petStore => 'Pet Stores';

  @override
  String get services => 'Services';

  @override
  String get myPets => 'My Pets';

  @override
  String get testNotificationsDescription => 'Test notifications to verify they are working on your device.';

  @override
  String get disableNotificationsTitle => 'Disable Notifications?';

  @override
  String get disableNotificationsDescription => 'You will no longer receive push notifications. You can re-enable them at any time.';

  @override
  String get appSettings => 'App Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get manageYourNotifications => 'Manage your notifications';

  @override
  String get currency => 'Currency';

  @override
  String get account => 'Account';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get updateYourInformation => 'Update your information';

  @override
  String get privacyAndSecurity => 'Privacy & Security';

  @override
  String get manageYourPrivacySettings => 'Manage your privacy settings';

  @override
  String get support => 'Support';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get getHelpAndSupport => 'Get help and support';

  @override
  String get reportABug => 'Report a Bug';

  @override
  String get helpUsImproveTheApp => 'Help us improve the app';

  @override
  String get rateTheApp => 'Rate the App';

  @override
  String get shareYourFeedback => 'Share your feedback';

  @override
  String get appVersionAndInfo => 'App version and info';

  @override
  String get adminTools => 'Admin Tools';

  @override
  String get addAliexpressProduct => 'Add AliExpress Product';

  @override
  String get addNewProductsToTheStore => 'Add new products to the store';

  @override
  String get bulkImportProducts => 'Bulk Import Products';

  @override
  String get importMultipleProductsAtOnce => 'Import multiple products at once';

  @override
  String get userManagement => 'User Management';

  @override
  String get manageUserAccounts => 'Manage user accounts';

  @override
  String get signOut => 'Sign Out';

  @override
  String get currentLocale => 'Current Locale';

  @override
  String get localizedTextTest => 'Localized Text Test';

  @override
  String get addTestAppointment => 'Add Test Appointment';

  @override
  String get createAppointmentForTesting => 'Create appointment in 1h 30min for testing';

  @override
  String get noSubscription => 'No Subscription';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get usd => 'USD';

  @override
  String get dzd => 'DZD';

  @override
  String get pleaseLoginToViewNotifications => 'Please log in to view notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get errorLoadingNotifications => 'Error loading notifications';

  @override
  String errorWithMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get notificationsEmptyHint => 'You\'ll see notifications here when you receive messages, orders, or follows';

  @override
  String get sendTestNotificationTooltip => 'Send test notification';

  @override
  String get unableToOpenChatUserNotFound => 'Unable to open chat - user not found';

  @override
  String errorOpeningChat(Object error) {
    return 'Error opening chat: $error';
  }

  @override
  String get unableToOpenChatSenderMissing => 'Unable to open chat - sender information missing';

  @override
  String get unableToOpenOrderMissing => 'Unable to open order - order information missing';

  @override
  String get unableToOpenProfileUserNotFound => 'Unable to open profile - user not found';

  @override
  String errorOpeningProfile(Object error) {
    return 'Error opening profile: $error';
  }

  @override
  String get unableToOpenProfileUserMissing => 'Unable to open profile - user information missing';

  @override
  String get appointmentNotificationNavigationTbd => 'Appointment notification - navigation to be implemented';

  @override
  String get notificationDeleted => 'Notification deleted';

  @override
  String errorDeletingNotification(Object error) {
    return 'Error deleting notification: $error';
  }

  @override
  String get allNotificationsMarkedAsRead => 'All notifications marked as read';

  @override
  String errorMarkingNotificationsAsRead(Object error) {
    return 'Error marking notifications as read: $error';
  }

  @override
  String testAppointmentCreated(Object id, Object time) {
    return 'Test appointment created! ID: $id\nTime: $time';
  }

  @override
  String errorCreatingTestAppointment(Object error) {
    return 'Error creating test appointment: $error';
  }

  @override
  String get noUserLoggedIn => 'No user logged in';

  @override
  String get todaysVetAppointment => 'Today\'s Vet Appointment';

  @override
  String get soon => 'Soon';

  @override
  String get past => 'Past';

  @override
  String get today => 'Today';

  @override
  String get pet => 'Pet';

  @override
  String get veterinarian => 'Veterinarian';

  @override
  String get notesLabel => 'Notes:';

  @override
  String get unableToContactVet => 'Unable to contact vet at this time';

  @override
  String get contactVet => 'Contact Vet';

  @override
  String get viewDetails => 'View Details';

  @override
  String hoursMinutesUntilAppointment(Object hours, Object minutes) {
    return '${hours}h ${minutes}m until appointment';
  }

  @override
  String minutesUntilAppointment(Object minutes) {
    return '${minutes}m until appointment';
  }

  @override
  String get appointmentStartingNow => 'Appointment starting now!';

  @override
  String errorLoadingPets(Object error) {
    return 'Error loading pets: $error';
  }

  @override
  String errorLoadingTimeSlots(Object error) {
    return 'Error loading time slots: $error';
  }

  @override
  String get pleaseFillRequiredFields => 'Please fill in all required fields';

  @override
  String get appointmentRequestSent => 'Appointment request sent successfully!';

  @override
  String errorBookingAppointment(Object error) {
    return 'Error booking appointment: $error';
  }

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectADate => 'Select a date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get noAvailableTimeSlotsForThisDate => 'No available time slots for this date';

  @override
  String get selectPet => 'Select pet';

  @override
  String get noPetsFoundPleaseAdd => 'No pets found. Please add a pet first.';

  @override
  String get appointmentType => 'Appointment Type';

  @override
  String get reasonOptional => 'Reason (Optional)';

  @override
  String get describeAppointmentReason => 'Describe the reason for the appointment...';

  @override
  String get bookAppointment => 'Book Appointment';

  @override
  String get noPetsFound => 'No Pets Found';

  @override
  String get needToAddPetBeforeBooking => 'You need to add a pet before booking an appointment.';

  @override
  String get addPetCta => 'Add Pet';

  @override
  String drName(Object name) {
    return 'Dr. $name';
  }

  @override
  String get searchForHelp => 'Search for help...';

  @override
  String get all => 'All';

  @override
  String get appointments => 'Appointments';

  @override
  String get pets => 'Pets';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryAdjustingSearchOrCategoryFilter => 'Try adjusting your search or category filter';

  @override
  String get stillNeedHelp => 'Still need help?';

  @override
  String get contactSupportTeamForPersonalizedAssistance => 'Contact our support team for personalized assistance';

  @override
  String get emailSupportComingSoon => 'Email support coming soon!';

  @override
  String get email => 'Email';

  @override
  String get liveChatComingSoon => 'Live chat coming soon!';

  @override
  String get liveChat => 'Live Chat';

  @override
  String get howToBookAppointment => 'How do I book an appointment with a veterinarian?';

  @override
  String get bookAppointmentInstructions => 'To book an appointment, go to the \"Find Vet\" section, search for veterinarians in your area, select one, and tap \"Book Appointment\". You can choose your preferred date and time.';

  @override
  String get howToAddPets => 'How do I add my pets to the app?';

  @override
  String get addPetsInstructions => 'Go to \"My Pets\" in the bottom navigation, tap the \"+\" button, and fill in your pet\'s information including name, species, breed, and age.';

  @override
  String get howToReportLostPet => 'How do I report a lost pet?';

  @override
  String get reportLostPetInstructions => 'Navigate to \"Lost Pets\" section, tap \"Report Lost Pet\", fill in the details including photos, location, and contact information.';

  @override
  String get lostPets => 'Lost Pets';

  @override
  String get howToOrderPetSupplies => 'How do I order pet supplies?';

  @override
  String get orderPetSuppliesInstructions => 'Go to the \"Store\" section, browse products, add items to cart, and proceed to checkout with your payment method.';

  @override
  String get howToContactCustomerSupport => 'How do I contact customer support?';

  @override
  String get contactCustomerSupportInstructions => 'You can contact us through the \"Report a Bug\" feature in Settings, or email us at support@alifi.com.';

  @override
  String get howToChangeAccountSettings => 'How do I change my account settings?';

  @override
  String get changeAccountSettingsInstructions => 'Go to Settings, tap on the setting you want to change, and follow the prompts to update your information.';

  @override
  String get howToFindVeterinariansNearMe => 'How do I find veterinarians near me?';

  @override
  String get findVeterinariansInstructions => 'Use the \"Find Vet\" feature and allow location access to see veterinarians in your area, or search by city/zip code.';

  @override
  String get howToCancelAppointment => 'How do I cancel an appointment?';

  @override
  String get cancelAppointmentInstructions => 'Go to \"My Appointments\", find the appointment you want to cancel, tap on it, and select \"Cancel Appointment\".';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get stayUpdatedWithImportantNotifications => 'Stay updated with important notifications:';

  @override
  String get newMessages => 'New Messages';

  @override
  String get getNotifiedWhenSomeoneSendsMessage => 'Get notified when someone sends you a message';

  @override
  String get trackOrdersAndDeliveryStatus => 'Track your orders and delivery status';

  @override
  String get petCareReminders => 'Pet Care Reminders';

  @override
  String get neverMissImportantPetCareAppointments => 'Never miss important pet care appointments';

  @override
  String get youCanChangeThisLaterInDeviceSettings => 'You can change this later in your device settings';

  @override
  String get notNow => 'Not Now';

  @override
  String get enable => 'Enable';

  @override
  String get toReceiveNotificationsPleaseEnableInDeviceSettings => 'To receive notifications, please enable them in your device settings.';

  @override
  String errorSearchingLocation(Object error) {
    return 'Error searching location: $error';
  }

  @override
  String errorGettingPlaceDetails(Object error) {
    return 'Error getting place details: $error';
  }

  @override
  String errorSelectingLocation(Object error) {
    return 'Error selecting location: $error';
  }

  @override
  String errorReverseGeocoding(Object error) {
    return 'Error reverse geocoding: $error';
  }

  @override
  String get searchLocation => 'Search location...';

  @override
  String get confirmLocation => 'Confirm Location';

  @override
  String get giftToAFriend => 'Gift to a Friend';

  @override
  String get searchByNameOrEmail => 'Search by name or email';

  @override
  String get searchForUsersToGift => 'Search for users to gift.';

  @override
  String get noUsersFound => 'No users found.';

  @override
  String get noName => 'No Name';

  @override
  String get noEmail => 'No Email';

  @override
  String get gift => 'Gift';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get confirmYourGift => 'Confirm Your Gift';

  @override
  String areYouSureYouWantToGiftThisProductTo(Object userName) {
    return 'Are you sure you want to gift this product to $userName?';
  }

  @override
  String get youHaveAGift => 'You Have a Gift!';

  @override
  String get hasGiftedYou => 'Has gifted you:';

  @override
  String get refuse => 'Refuse';

  @override
  String get accept => 'Accept';

  @override
  String get searchUsers => 'Search users...';

  @override
  String get typeToSearchForUsers => 'Type to search for users';

  @override
  String get select => 'Select';

  @override
  String get checkUp => 'Check-up';

  @override
  String get vaccination => 'Vaccination';

  @override
  String get surgery => 'Surgery';

  @override
  String get consultation => 'Consultation';

  @override
  String get emergency => 'Emergency';

  @override
  String get followUp => 'Follow-up';

  @override
  String get addPet => 'Add Pet';

  @override
  String get bird => 'Bird';

  @override
  String get rabbit => 'Rabbit';

  @override
  String get hamster => 'Hamster';

  @override
  String get fish => 'Fish';

  @override
  String get testNotificationSent => 'Test notification sent successfully!';

  @override
  String errorSendingTestNotification(Object error) {
    return 'Error sending test notification: $error';
  }

  @override
  String get notificationPreferencesSavedSuccessfully => 'Notification preferences saved successfully!';

  @override
  String errorSavingPreferences(Object error) {
    return 'Error saving preferences: $error';
  }

  @override
  String get notificationsEnabledSuccessfully => 'Notifications enabled successfully!';

  @override
  String errorRequestingPermission(Object error) {
    return 'Error requesting permission: $error';
  }

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get notificationsEnabled => 'Enabled';

  @override
  String get notificationsDisabled => 'Disabled';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get sound => 'Sound';

  @override
  String get playSoundForNotifications => 'Play sound for notifications';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrateDeviceForNotifications => 'Vibrate device for notifications';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get receiveNotificationsViaEmail => 'Receive notifications via email';

  @override
  String get quietHours => 'Quiet Hours';

  @override
  String get enableQuietHours => 'Enable Quiet Hours';

  @override
  String get muteNotificationsDuringSpecifiedHours => 'Mute notifications during specified hours';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get notificationTypes => 'Notification Types';

  @override
  String get chatMessages => 'Chat Messages';

  @override
  String get newMessagesFromOtherUsers => 'New messages from other users';

  @override
  String get orderUpdates => 'Order Updates';

  @override
  String get orderStatusChangesAndUpdates => 'Order status changes and updates';

  @override
  String get appointmentRequestsAndReminders => 'Appointment requests and reminders';

  @override
  String get socialActivity => 'Social Activity';

  @override
  String get newFollowersAndSocialInteractions => 'New followers and social interactions';

  @override
  String get testNotifications => 'Test Notifications';

  @override
  String get sendTestNotification => 'Send Test Notification';

  @override
  String get savePreferences => 'Save Preferences';

  @override
  String get disable => 'Disable';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get user => 'User';

  @override
  String get noLostPetsReportedNearby => 'No lost pets reported nearby';

  @override
  String get weWillNotifyYouWhenPetsAreReported => 'We will notify you when pets are reported in your area';

  @override
  String get noRecentLostPetsReported => 'No recent lost pets reported';

  @override
  String get enableLocationToSeePetsInYourArea => 'Enable location to see pets in your area';

  @override
  String get navigate => 'Navigate';

  @override
  String get open => 'Open';

  @override
  String get closed => 'Closed';

  @override
  String get openNow => 'Open Now';

  @override
  String get visitClinicProfile => 'Visit Clinic Profile';

  @override
  String get visitStoreProfile => 'Visit Store Profile';

  @override
  String get alifiFavorite => 'Alifi Favorite';

  @override
  String get alifiAffiliated => 'Alifi Affiliated';

  @override
  String get pleaseEnableLocationServicesOrEnterManually => 'Please enable location services or enter your location manually.';

  @override
  String get locationPermissionRequiredForFeature => 'Location permission is required for this feature. Please enable it in your app settings.';

  @override
  String get unknown => 'Unknown';

  @override
  String get addYourFirstPet => 'Add your first pet';

  @override
  String get healthInformation => 'Health Information';

  @override
  String get snake => 'Snake';

  @override
  String get lizard => 'Lizard';

  @override
  String get guineaPig => 'Guinea Pig';

  @override
  String get ferret => 'Ferret';

  @override
  String get turtle => 'Turtle';

  @override
  String get parrot => 'Parrot';

  @override
  String get mouse => 'Mouse';

  @override
  String get rat => 'Rat';

  @override
  String get hedgehog => 'Hedgehog';

  @override
  String get chinchilla => 'Chinchilla';

  @override
  String get gerbil => 'Gerbil';

  @override
  String get duck => 'Duck';

  @override
  String get monkey => 'Monkey';

  @override
  String get selected => 'Selected';

  @override
  String get notSelected => 'Not selected';

  @override
  String get appNotResponding => 'App not responding';

  @override
  String get loginIssues => 'Login issues';

  @override
  String get paymentProblems => 'Payment problems';

  @override
  String get accountAccess => 'Account access';

  @override
  String get missingFeatures => 'Missing features';

  @override
  String get petListingIssues => 'Pet listing issues';

  @override
  String get mapNotWorking => 'Map not working';

  @override
  String get inappropriateContent => 'Inappropriate content';

  @override
  String get technicalProblems => 'Technical problems';

  @override
  String get other => 'Other';

  @override
  String get selectProblemType => 'Select problem type';

  @override
  String get submit => 'Submit';

  @override
  String get display => 'Display';

  @override
  String get interface => 'Interface';

  @override
  String get useBlurEffectForTabBar => 'Use blur effect for Tab bar';

  @override
  String get enableGlassLikeBlurEffectOnNavigationBar => 'Enable glass-like blur effect on the navigation bar';

  @override
  String get whenDisabledTabBarWillHaveSolidWhiteBackground => 'When disabled, the tab bar will have a solid white background instead of the glass-like blur effect.';

  @override
  String get customizeAppAppearanceAndInterface => 'Customize app appearance and interface';

  @override
  String get save => 'Save';

  @override
  String get tapToChangePhoto => 'Tap to change photo';

  @override
  String get coverPhotoOptional => 'Cover photo (optional)';

  @override
  String get changeCover => 'Change cover';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Enter username';

  @override
  String get usernameCannotBeEmpty => 'Username cannot be empty';

  @override
  String get invalidUsername => 'Invalid username (3-20 chars, letters, numbers, _)';

  @override
  String get displayName => 'Display Name';

  @override
  String get enterDisplayName => 'Enter display name';

  @override
  String get displayNameCannotBeEmpty => 'Display name cannot be empty';

  @override
  String get professionalInfo => 'Professional Info';

  @override
  String get enterYourQualificationsExperience => 'Enter your qualifications, experience, etc.';

  @override
  String get accountType => 'Account Type';

  @override
  String get requestToBeAVet => 'Request to be a Vet';

  @override
  String get joinOurVeterinaryNetwork => 'Join our veterinary network';

  @override
  String get requestToBeAStore => 'Request to be a Store';

  @override
  String get sellPetProductsAndServices => 'Sell pet products and services';

  @override
  String get linkedAccounts => 'Linked Accounts';

  @override
  String get linked => 'Linked';

  @override
  String get link => 'Link';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get areYouSureYouWantToDeleteYourAccount => 'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String failedToUpdateProfile(Object error) {
    return 'Failed to update profile: $error';
  }

  @override
  String errorSelectingCover(Object error) {
    return 'Error selecting cover: $error';
  }

  @override
  String get savingChanges => 'Saving changes...';

  @override
  String get locationSharing => 'Location Sharing';

  @override
  String get allowAppToAccessYourLocation => 'Allow app to access your location for nearby services';

  @override
  String get dataAnalytics => 'Data Analytics';

  @override
  String get helpUsImproveBySharingAnonymousUsageData => 'Help us improve by sharing anonymous usage data';

  @override
  String get profileVisibility => 'Profile Visibility';

  @override
  String get controlWhoCanSeeYourProfileInformation => 'Control who can see your profile information';

  @override
  String get dataAndPrivacy => 'Data & Privacy';

  @override
  String get manageYourDataAndPrivacySettings => 'Manage your data and privacy settings.';

  @override
  String get receiveNotificationsAboutAppointmentsAndUpdates => 'Receive notifications about appointments and updates';

  @override
  String get receiveImportantUpdatesViaEmail => 'Receive important updates via email';

  @override
  String get notificationPreferences => 'Notification Preferences';

  @override
  String get customizeWhatNotificationsYouReceive => 'Customize what notifications you receive.';

  @override
  String get security => 'Security';

  @override
  String get biometricAuthentication => 'Biometric Authentication';

  @override
  String get useFingerprintOrFaceIdToUnlockTheApp => 'Use fingerprint or face ID to unlock the app';

  @override
  String get twoFactorAuthentication => 'Two-Factor Authentication';

  @override
  String get addAnExtraLayerOfSecurityToYourAccount => 'Add an extra layer of security to your account';

  @override
  String get changePassword => 'Change Password';

  @override
  String get updateYourAccountPassword => 'Update your account password';

  @override
  String get activeSessions => 'Active Sessions';

  @override
  String get manageDevicesLoggedIntoYourAccount => 'Manage devices logged into your account.';

  @override
  String get dataAndStorage => 'Data & Storage';

  @override
  String get storageUsage => 'Storage Usage';

  @override
  String get manageAppDataAndCache => 'Manage app data and cache.';

  @override
  String get exportData => 'Export Data';

  @override
  String get downloadACopyOfYourData => 'Download a copy of your data.';

  @override
  String get permanentlyDeleteYourAccountAndData => 'Permanently delete your account and data';

  @override
  String get chooseWhoCanSeeYourProfileInformation => 'Choose who can see your profile information.';

  @override
  String get enterYourNewPassword => 'Enter your new password.';

  @override
  String get thisActionCannotBeUndoneAllYourDataWillBePermanentlyDeleted => 'This action cannot be undone. All your data will be permanently deleted.';

  @override
  String get export => 'Export';

  @override
  String get yourPetsFavouriteApp => 'Your Pet\'s Favourite App';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get aboutAlifi => 'About Alifi';

  @override
  String get alifiIsAComprehensivePetCarePlatform => 'Alifi is a comprehensive pet care platform that connects pet owners with veterinarians, pet stores, and other pet care services. Our mission is to make pet care accessible, convenient, and reliable for everyone.';

  @override
  String get verifiedServices => 'Verified Services';

  @override
  String get allVeterinariansAndPetStoresOnOurPlatformAreVerified => 'All veterinarians and pet stores on our platform are verified to ensure the highest quality of care for your beloved pets.';

  @override
  String get secureAndPrivate => 'Secure & Private';

  @override
  String get yourDataAndYourPetsInformationAreProtected => 'Your data and your pets\' information are protected with industry-standard security measures.';

  @override
  String get contactAndSupport => 'Contact & Support';

  @override
  String get emailSupport => 'Email Support';

  @override
  String get phoneSupport => 'Phone Support';

  @override
  String get website => 'Website';

  @override
  String get legal => 'Legal';

  @override
  String get readOurTermsAndConditions => 'Read our terms and conditions';

  @override
  String get learnAboutOurPrivacyPractices => 'Learn about our privacy practices';

  @override
  String get developer => 'Developer';

  @override
  String get developedBy => 'Developed by';

  @override
  String get alifiDevelopmentTeam => 'Alifi Development Team';

  @override
  String get copyright => 'Copyright';

  @override
  String get copyrightText => '© 2024 Alifi. All rights reserved.';

  @override
  String get phoneSupportComingSoon => 'Phone support coming soon!';

  @override
  String get websiteComingSoon => 'Website coming soon!';

  @override
  String get termsOfServiceComingSoon => 'Terms of Service coming soon!';

  @override
  String get privacyPolicyComingSoon => 'Privacy Policy coming soon!';

  @override
  String get pressBackAgainToExit => 'Press back again to exit';

  @override
  String get lostPetDetails => 'Lost Pet Details';

  @override
  String get fundraising => 'Fundraising';

  @override
  String get animalShelterExpansion => 'Animal Shelter Expansion';

  @override
  String get helpUsExpandOurShelter => 'Help us expand our shelter to accommodate more animals in need.';

  @override
  String get profile => 'Profile';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get adoptionCenter => 'Adoption Center';

  @override
  String get ordersAndMessages => 'Orders & Messages';

  @override
  String get becomeAVet => 'Become a Vet';

  @override
  String get becomeAStore => 'Become a Store';

  @override
  String get logOut => 'Log out';

  @override
  String get storeDashboard => 'Store Dashboard';

  @override
  String get errorLoadingDashboard => 'Error loading dashboard';

  @override
  String get noDashboardDataAvailable => 'No dashboard data available';

  @override
  String get totalSales => 'Total Sales';

  @override
  String get engagement => 'Engagement';

  @override
  String get totalOrders => 'Total Orders';

  @override
  String get activeOrders => 'Active Orders';

  @override
  String get viewAllSellerTools => 'View All Seller Tools';

  @override
  String get vetDashboard => 'Vet Dashboard';

  @override
  String get freeShipping => 'Free Shipping';

  @override
  String get viewStore => 'View Store';

  @override
  String get buyNow => 'Buy Now';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get addToWishlist => 'Add to wishlist';

  @override
  String get removeFromWishlist => 'Remove from Wishlist';

  @override
  String get productDetails => 'Product Details';

  @override
  String get specifications => 'Specifications';

  @override
  String get reviews => 'Reviews';

  @override
  String get relatedProducts => 'Related Products';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get inStock => 'In Stock';

  @override
  String get quantity => 'Quantity';

  @override
  String get selectQuantity => 'Select Quantity';

  @override
  String get productImages => 'Product Images';

  @override
  String get shareProduct => 'Share Product';

  @override
  String get reportProduct => 'Report Product';

  @override
  String get sellerDashboard => 'Seller Dashboard';

  @override
  String get products => 'Products';

  @override
  String get messages => 'Messages';

  @override
  String get orders => 'orders';

  @override
  String get pleaseLogIn => 'Please log in.';

  @override
  String get revenueAnalytics => 'Revenue Analytics';

  @override
  String get todaysSales => 'Today\'s Sales';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get keyMetrics => 'Key Metrics';

  @override
  String get uniqueCustomers => 'Unique Customers';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get addProduct => 'Add Product';

  @override
  String get manageProducts => 'Manage Products';

  @override
  String get productAnalytics => 'Product Analytics';

  @override
  String get totalProducts => 'Total Products';

  @override
  String get activeProducts => 'Active Products';

  @override
  String get soldProducts => 'Sold Products';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get createYourFirstProduct => 'Create your first product';

  @override
  String get productName => 'Product Name';

  @override
  String get productDescription => 'Product Description';

  @override
  String get productPrice => 'Product Price';

  @override
  String get productCategory => 'Product Category';

  @override
  String get saveProduct => 'Save Product';

  @override
  String get updateProduct => 'Update Product';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String get areYouSureDeleteProduct => 'Are you sure you want to delete this product?';

  @override
  String get productSavedSuccessfully => 'Product saved successfully!';

  @override
  String get productUpdatedSuccessfully => 'Product updated successfully!';

  @override
  String get productDeletedSuccessfully => 'Product deleted successfully!';

  @override
  String errorSavingProduct(Object error) {
    return 'Error saving product: $error';
  }

  @override
  String errorUpdatingProduct(Object error) {
    return 'Error updating product: $error';
  }

  @override
  String errorDeletingProduct(Object error) {
    return 'Error deleting product: $error';
  }

  @override
  String get noMessagesFound => 'No messages found';

  @override
  String get startConversation => 'Start a conversation';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get send => 'Send';

  @override
  String get noOrdersFound => 'No orders found';

  @override
  String get orderHistory => 'Order History';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get orderStatus => 'Order Status';

  @override
  String get orderDate => 'Order Date';

  @override
  String get orderTotal => 'Order Total';

  @override
  String get customerInfo => 'Customer Info';

  @override
  String get shippingAddress => 'Shipping Address';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get orderItems => 'Order Items';

  @override
  String get pending => 'Pending';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get shipped => 'Shipped';

  @override
  String get delivered => 'Delivered';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get processing => 'Processing';

  @override
  String get readyForPickup => 'Ready for Pickup';

  @override
  String get updateOrderStatus => 'Update Order Status';

  @override
  String get markAsShipped => 'Mark as Shipped';

  @override
  String get markAsDelivered => 'Mark as Delivered';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get orderUpdatedSuccessfully => 'Order updated successfully!';

  @override
  String errorUpdatingOrder(Object error) {
    return 'Error updating order: $error';
  }

  @override
  String get custom => 'Custom...';

  @override
  String get enterAmountInDZD => 'Enter amount in DZD';

  @override
  String get payVia => 'Pay via :';

  @override
  String get discussion => 'Discussion';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get typing => 'typing...';

  @override
  String get messageSent => 'Message sent';

  @override
  String get messageDelivered => 'Message delivered';

  @override
  String get messageRead => 'Message read';

  @override
  String get newMessage => 'New message';

  @override
  String get unreadMessages => 'Unread messages';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get deleteMessage => 'Delete message';

  @override
  String get blockUser => 'Block User';

  @override
  String get reportUser => 'Report User';

  @override
  String get clearChat => 'Clear chat';

  @override
  String get chatCleared => 'Chat cleared';

  @override
  String get userBlocked => 'User blocked';

  @override
  String get userReported => 'User reported';

  @override
  String errorSendingMessage(Object error) {
    return 'Error sending message: $error';
  }

  @override
  String errorLoadingMessages(Object error) {
    return 'Error loading messages: $error';
  }

  @override
  String get appointmentInProgress => 'Appointment in Progress';

  @override
  String get live => 'LIVE';

  @override
  String get endNow => 'End Now';

  @override
  String get elapsedTime => 'Elapsed Time';

  @override
  String get remaining => 'Remaining';

  @override
  String get minutes => 'Minutes';

  @override
  String get start => 'Start';

  @override
  String get delay => 'Delay';

  @override
  String get appointmentStarting => 'Appointment Starting';

  @override
  String get time => 'Time';

  @override
  String get duration => 'Duration';

  @override
  String get startAppointment => 'Start Appointment';

  @override
  String appointmentStarted(Object petName) {
    return 'Appointment started for $petName';
  }

  @override
  String errorStartingAppointment(Object error) {
    return 'Error starting appointment: $error';
  }

  @override
  String get appointmentRevenue => 'Appointment Revenue';

  @override
  String howMuchEarned(Object petName) {
    return 'How much did you earn from $petName\'s appointment?';
  }

  @override
  String get revenueAmount => 'Revenue Amount';

  @override
  String get enterAmount => 'Enter amount (e.g., 150)';

  @override
  String revenueAddedSuccessfully(Object amount) {
    return 'Revenue of $amount added successfully!';
  }

  @override
  String get pleaseEnterValidAmount => 'Please enter a valid amount';

  @override
  String errorAddingRevenue(Object error) {
    return 'Error adding revenue: $error';
  }

  @override
  String get noAppointmentsFound => 'No appointments found';

  @override
  String get yourScheduleIsClear => 'Your schedule is clear';

  @override
  String get upcomingAppointments => 'Upcoming Appointments';

  @override
  String get completedAppointments => 'Completed Appointments';

  @override
  String get cancelledAppointments => 'Cancelled Appointments';

  @override
  String get searchPatients => 'Search patients...';

  @override
  String get activePatients => 'Active Patients';

  @override
  String get newThisMonth => 'New This Month';

  @override
  String get myPatients => 'My Patients';

  @override
  String get noPatientsFound => 'No patients found';

  @override
  String get avgAppointmentDuration => 'Avg. Appointment Duration';

  @override
  String get patientSatisfaction => 'Patient Satisfaction';

  @override
  String get appointmentStatus => 'Appointment Status';

  @override
  String get appointmentCompleted => 'Appointment completed';

  @override
  String get newPatientRegistered => 'New patient registered';

  @override
  String get vaccinationGiven => 'Vaccination given';

  @override
  String get surgeryScheduled => 'Surgery scheduled';

  @override
  String get accessDenied => 'Access Denied';

  @override
  String get thisPageIsOnlyAvailableForVeterinaryAccounts => 'This page is only available for veterinary accounts.';

  @override
  String get overview => 'Overview';

  @override
  String get patients => 'Patients';

  @override
  String get analytics => 'Analytics';

  @override
  String get todaysAppoint => 'Today\'s Appoint.';

  @override
  String get totalPatients => 'Total Patients';

  @override
  String get revenueToday => 'Revenue Today';

  @override
  String get nextAppoint => 'Next Appoint.';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get scheduleAppointment => 'Schedule Appointment';

  @override
  String get addPatient => 'Add Patient';

  @override
  String get viewRecords => 'View Records';

  @override
  String get emergencyContact => 'Emergency Contact';

  @override
  String get affiliateDisclosureText => 'This product is available through our affiliate partnership with AliExpress. When you make a purchase through these links, you help support our app at no additional cost to you. Thank you for helping us keep this app running!';

  @override
  String get customerReviews => 'Customer Reviews';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get beTheFirstToReviewThisProduct => 'Be the first to review this product';

  @override
  String errorLoadingReviews(Object error) {
    return 'Error loading reviews: $error';
  }

  @override
  String get noRelatedProductsFound => 'No related products found';

  @override
  String get iDontHaveACreditCard => '(i don\'t have a credit card)';

  @override
  String get howDoesItWork => 'How does it work';

  @override
  String get howItWorksText => 'You enter your address, and your city and then you make sure you send MONEY_AMOUNT to this ccp address 000000000000000000000000000000 and then send the proof of payment in this email payment@alifi.app, we\'ll make sure to get your product shipped as soon as possible';

  @override
  String get enterYourAddress => 'Enter your address';

  @override
  String get selectYourCity => 'Select your city';

  @override
  String get done => 'Done';

  @override
  String get ordered => 'Ordered';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get searchStores => 'Search stores...';

  @override
  String get searchVets => 'Search vets...';

  @override
  String get userProfile => 'User Profile';

  @override
  String get storeProfile => 'Store Profile';

  @override
  String get vetProfile => 'Vet Profile';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get contactInfo => 'Contact Info';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get thisActionCannotBeUndone => 'This action cannot be undone';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String errorDeletingAccount(Object error) {
    return 'Error deleting account: $error';
  }

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String errorChangingPassword(Object error) {
    return 'Error changing password: $error';
  }

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String errorUpdatingProfile(Object error) {
    return 'Error updating profile: $error';
  }

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get emailAlreadyInUse => 'Email already in use';

  @override
  String get weakPassword => 'Password is too weak';

  @override
  String get userNotFound => 'User not found';

  @override
  String get wrongPassword => 'Wrong password';

  @override
  String get tooManyRequests => 'Too many requests. Please try again later';

  @override
  String get operationNotAllowed => 'Operation not allowed';

  @override
  String get networkError => 'Network error. Please check your connection';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get tryAgain => 'Try again';

  @override
  String get loading => 'Loading...';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get searching => 'Searching...';

  @override
  String get searchPeoplePetsVets => 'Search people, pets, vets...';

  @override
  String get recommendedVetsAndStores => 'Recommended Vets and Stores';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get noRecentSearches => 'No recent searches';

  @override
  String get trySearchingWithDifferentKeywords => 'Try searching with different keywords';

  @override
  String errorSearchingUsers(Object error) {
    return 'Error searching users: $error';
  }

  @override
  String get myMessages => 'My Messages';

  @override
  String get myOrders => 'My Orders';

  @override
  String get startDiscussion => 'Start a discussion';

  @override
  String sendMessageToStore(Object storeName) {
    return 'Send a message to $storeName';
  }

  @override
  String failedToSendMessage(Object error) {
    return 'Failed to send message: $error';
  }

  @override
  String get pleaseSignInToFollowUsers => 'Please sign in to follow users';

  @override
  String errorUpdatingFollowStatus(Object error) {
    return 'Error updating follow status: $error';
  }

  @override
  String get followers => 'Followers';

  @override
  String get following => 'Following';

  @override
  String get follow => 'Follow';

  @override
  String get unfollow => 'Unfollow';

  @override
  String get viewInMap => 'View in Map';

  @override
  String get message => 'Message';

  @override
  String get call => 'Call';

  @override
  String get address => 'Address';

  @override
  String get phone => 'Phone';

  @override
  String get bio => 'Bio';

  @override
  String get posts => 'Posts';

  @override
  String get photos => 'Photos';

  @override
  String get videos => 'Videos';

  @override
  String get friends => 'Friends';

  @override
  String get mutualFriends => 'Mutual Friends';

  @override
  String get shareProfile => 'Share Profile';

  @override
  String get copyProfileLink => 'Copy Profile Link';

  @override
  String get profileLinkCopied => 'Profile link copied to clipboard';

  @override
  String get errorCopyingProfileLink => 'Error copying profile link';

  @override
  String get noPostsYet => 'No posts yet';

  @override
  String get noPhotosYet => 'No photos yet';

  @override
  String get noVideosYet => 'No videos yet';

  @override
  String get noFriendsYet => 'No friends yet';

  @override
  String get noMutualFriends => 'No mutual friends';

  @override
  String get loadingProfile => 'Loading profile...';

  @override
  String errorLoadingProfile(Object error) {
    return 'Error loading profile: $error';
  }

  @override
  String get profileNotFound => 'Profile not found';

  @override
  String get accountSuspended => 'Account suspended';

  @override
  String get accountPrivate => 'This account is private';

  @override
  String get followToSeeContent => 'Follow to see content';

  @override
  String get requestToFollow => 'Request to Follow';

  @override
  String get requestSent => 'Request sent';

  @override
  String get cancelRequest => 'Cancel Request';

  @override
  String get acceptRequest => 'Accept Request';

  @override
  String get declineRequest => 'Decline Request';

  @override
  String get removeFollower => 'Remove Follower';

  @override
  String get muteUser => 'Mute User';

  @override
  String get unmuteUser => 'Unmute User';

  @override
  String get userMuted => 'User muted';

  @override
  String get userUnmuted => 'User unmuted';

  @override
  String errorMutingUser(Object error) {
    return 'Error muting user: $error';
  }

  @override
  String errorUnmutingUser(Object error) {
    return 'Error unmuting user: $error';
  }

  @override
  String get you => 'You';

  @override
  String get yourRecentProfileVisitsWillAppearHere => 'Your recent profile visits will appear here';

  @override
  String get noProductsYet => 'No products yet';

  @override
  String get noPetsYet => 'No pets yet';

  @override
  String get rating => 'Rating';

  @override
  String get sendAMessage => 'Send a message';

  @override
  String get reportAccount => 'Report account';

  @override
  String get pleaseSignInToSendMessages => 'Please sign in to send messages';

  @override
  String get helpUsUnderstandWhatsHappening => 'Help us understand what\'s happening';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get whyAreYouReportingThisAccount => 'Why are you reporting this account?';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get spamOrUnwantedContent => 'Spam or unwanted content';

  @override
  String get inappropriateBehavior => 'Inappropriate behavior';

  @override
  String get fakeOrMisleadingInformation => 'Fake or misleading information';

  @override
  String get harassmentOrBullying => 'Harassment or bullying';

  @override
  String get scamOrFraud => 'Scam or fraud';

  @override
  String get hateSpeechOrSymbols => 'Hate speech or symbols';

  @override
  String get violenceOrDangerousContent => 'Violence or dangerous content';

  @override
  String get intellectualPropertyViolation => 'Intellectual property violation';

  @override
  String reportSubmittedFor(Object user) {
    return 'Report submitted for $user';
  }

  @override
  String get marketplace => 'Marketplace';

  @override
  String get searchItemsProducts => 'Search items, products...';

  @override
  String get food => 'Food';

  @override
  String get toys => 'Toys';

  @override
  String get health => 'Health';

  @override
  String get beds => 'Beds';

  @override
  String get hygiene => 'Hygiene';

  @override
  String get mostOrders => 'Most Orders';

  @override
  String get priceLowToHigh => 'Price: Low to High';

  @override
  String get priceHighToLow => 'Price: High to Low';

  @override
  String get newestFirst => 'Newest First';

  @override
  String get sortBy => 'Sort by';

  @override
  String get allCategories => 'All Categories';

  @override
  String get filterByCategory => 'Filter by Category';

  @override
  String get newListings => 'New listings';

  @override
  String get recommended => 'Recommended';

  @override
  String get popularProducts => 'Popular Products';

  @override
  String noProductsFoundFor(Object query) {
    return 'No products found for \"$query\"';
  }

  @override
  String get noRecommendedProductsAvailable => 'No recommended products available';

  @override
  String get noPopularProductsAvailable => 'No popular products available';

  @override
  String get viewAllVetTools => 'View All Vet Tools';

  @override
  String weveRaised(Object amount) {
    return 'We\'ve raised $amount DZD!';
  }

  @override
  String get goal => 'Goal';

  @override
  String get contribute => 'Contribute';

  @override
  String get hiAskMeAboutAnyPetAdvice => 'Hi! ask me about any pet advice,\nand I\'ll do my best to help you, and\nyour little one!';

  @override
  String get tapToChat => 'Tap to chat...';

  @override
  String get sorryIEncounteredAnError => 'Sorry, I encountered an error. Please try again.';

  @override
  String get youMayBeInterested => 'You may be Interested';

  @override
  String get seeAll => 'See all';

  @override
  String get errorLoadingProducts => 'Error loading products';

  @override
  String get noProductsAvailable => 'No products available';

  @override
  String get loadingCombinedProducts => 'Loading combined products...';

  @override
  String loadedAliExpressProducts(Object count) {
    return 'Loaded $count AliExpress products';
  }

  @override
  String errorLoadingAliExpressProducts(Object error) {
    return 'Error loading AliExpress products: $error';
  }

  @override
  String loadedStoreProducts(Object count) {
    return 'Loaded $count store products';
  }

  @override
  String errorLoadingStoreProducts(Object error) {
    return 'Error loading store products: $error';
  }

  @override
  String get noProductsFoundFromEitherSource => 'No products found from either source';

  @override
  String get creatingMockDataForTesting => 'Creating mock data for testing...';

  @override
  String totalCombinedProducts(Object count) {
    return 'Total combined products: $count';
  }

  @override
  String errorInGetCombinedProducts(Object error) {
    return 'Error in _getCombinedProducts: $error';
  }

  @override
  String get petToySet => 'Pet Toy Set';

  @override
  String get interactiveToysForPets => 'Interactive toys for pets';

  @override
  String get petFoodBowl => 'Pet Food Bowl';

  @override
  String get stainlessSteelFoodBowl => 'Stainless steel food bowl';

  @override
  String get days => 'days';

  @override
  String get day => 'day';

  @override
  String get hour => 'hour';

  @override
  String get hours => 'hours';

  @override
  String get minute => 'minute';

  @override
  String get justNow => 'Just now';

  @override
  String get ago => 'ago';

  @override
  String get totalAppointments => 'Total Appointments';

  @override
  String get newPatients => 'New Patients';

  @override
  String get emergencyCases => 'Emergency Cases';

  @override
  String get noAppointmentsYet => 'No appointments yet';

  @override
  String get completed => 'Completed';

  @override
  String get complete => 'Complete';

  @override
  String howMuchDidYouEarnFromAppointment(Object petName) {
    return 'How much did you earn from $petName\'s appointment?';
  }

  @override
  String get pleaseEnterAValidAmount => 'Please enter a valid amount';

  @override
  String revenueOfAddedSuccessfully(Object amount) {
    return 'Revenue of $amount added successfully!';
  }

  @override
  String get markComplete => 'Mark Complete';

  @override
  String appointmentStartedFor(Object petName) {
    return 'Appointment started for $petName';
  }

  @override
  String errorCompletingAppointment(Object error) {
    return 'Error completing appointment: $error';
  }

  @override
  String get salesAnalytics => 'Sales Analytics';

  @override
  String get youHaveNoProductsYet => 'You have no products yet.';

  @override
  String get contributeWith => 'Contribute with :';

  @override
  String get shippingFeeApplies => 'Shipping fee applies';

  @override
  String deliveryInDays(Object days) {
    return 'Delivery in $days days';
  }

  @override
  String get storeNotFound => 'Store not found';

  @override
  String get buyAsAGift => 'Buy as a Gift';

  @override
  String get affiliateDisclosure => 'Affiliate Disclosure';

  @override
  String get youMayBeInterestedToo => 'You may be interested too';

  @override
  String get contactStore => 'Contact Store';

  @override
  String get buyItForMe => 'Buy it for me';

  @override
  String get vetInformation => 'Vet Information';

  @override
  String get petId => 'Pet ID';

  @override
  String get editPets => 'Edit Pets';

  @override
  String get editExistingPet => 'Edit existing pet';

  @override
  String get whatsYourPetsName => 'What\'s your pet\'s name?';

  @override
  String get petsName => 'Pet\'s name';

  @override
  String get whatBreedIsYourPet => 'What breed is your pet?';

  @override
  String get petsBreed => 'Pet\'s breed';

  @override
  String get selectPetType => 'Select Pet Type';

  @override
  String get dog => 'Dog';

  @override
  String get cat => 'Cat';

  @override
  String get selectGender => 'Select Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get selectBirthday => 'Select Birthday';

  @override
  String get selectWeight => 'Select Weight';

  @override
  String get selectPhoto => 'Select Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get selectColor => 'Select Color';

  @override
  String get kg => 'kg';

  @override
  String get lbs => 'lbs';

  @override
  String get monthsOld => 'months old';

  @override
  String get month => 'month';

  @override
  String get months => 'months';

  @override
  String get year => 'year';

  @override
  String get years => 'years';

  @override
  String get pleaseFillInAllFields => 'Please fill in all fields';

  @override
  String get startingSaveProcess => 'Starting save process...';

  @override
  String get uploadingPhoto => 'Uploading photo...';

  @override
  String get savingToDatabase => 'Saving to database...';

  @override
  String errorAddingPet(Object error) {
    return 'Error adding pet: $error';
  }

  @override
  String get vaccines => 'Vaccines';

  @override
  String get illness => 'Illness';

  @override
  String get coreVaccines => 'Core Vaccines';

  @override
  String get nonCoreVaccines => 'Non-Core Vaccines';

  @override
  String get addVaccine => 'Add Vaccine';

  @override
  String get logAnIllness => 'Log an Illness';

  @override
  String get noLoggedVaccines => 'No logged vaccines for this pet';

  @override
  String get noLoggedIllnesses => 'No logged illnesses for this pet';

  @override
  String get noLoggedChronicIllnesses => 'No logged chronic illnesses for this pet';

  @override
  String get vaccineAdded => 'Vaccine added!';

  @override
  String failedToAddVaccine(Object error) {
    return 'Failed to add vaccine: $error';
  }

  @override
  String get illnessAdded => 'Illness added!';

  @override
  String failedToAddIllness(Object error) {
    return 'Failed to add illness: $error';
  }

  @override
  String get vaccineUpdated => 'Vaccine updated!';

  @override
  String failedToUpdateVaccine(Object error) {
    return 'Failed to update vaccine: $error';
  }

  @override
  String get illnessUpdated => 'Illness updated!';

  @override
  String failedToUpdateIllness(Object error) {
    return 'Failed to update illness: $error';
  }

  @override
  String get vaccineDeleted => 'Vaccine deleted!';

  @override
  String failedToDeleteVaccine(Object error) {
    return 'Failed to delete vaccine: $error';
  }

  @override
  String get illnessDeleted => 'Illness deleted!';

  @override
  String failedToDeleteIllness(Object error) {
    return 'Failed to delete illness: $error';
  }

  @override
  String get selectVaccineType => 'Select Vaccine Type';

  @override
  String get selectIllnessType => 'Select Illness Type';

  @override
  String get addNotes => 'Add Notes';

  @override
  String get notes => 'Notes';

  @override
  String get edit => 'Edit';

  @override
  String get chronicIllnesses => 'Chronic Illnesses';

  @override
  String get illnesses => 'Illnesses';

  @override
  String get selectPetForPetId => 'Select the pet you want to request the pet ID for';

  @override
  String get pleaseSelectPetFirst => 'Please select a pet first';

  @override
  String get petIdRequestSubmitted => 'Pet ID request submitted successfully!';

  @override
  String get yourPetIdIsBeingProcessed => 'Your pet ID is being processed and made, please remain patient';

  @override
  String get petIdManagement => 'Pet ID Management';

  @override
  String get digitalPetIds => 'Digital Pet IDs';

  @override
  String get physicalPetIds => 'Physical Pet IDs';

  @override
  String get ready => 'Ready';

  @override
  String get editPhysicalPetId => 'Edit Physical Pet ID';

  @override
  String get customer => 'Customer';

  @override
  String get status => 'Status';

  @override
  String get processingStatus => 'Processing';

  @override
  String get update => 'Update';

  @override
  String get petIdStatusUpdated => 'Pet ID status updated successfully';

  @override
  String errorUpdatingPetId(Object error) {
    return 'Error updating pet ID: $error';
  }

  @override
  String get physicalPetIdRequestSubmitted => 'Physical pet ID request submitted successfully! You will be contacted for payment.';

  @override
  String get requestPhysicalPetId => 'Request Physical Pet ID';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get zipCode => 'Zip Code';

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get pleaseFillAllFields => 'Please fill in all fields';

  @override
  String errorCheckingPetIdStatus(Object error) {
    return 'Error checking pet ID status: $error';
  }

  @override
  String get age => 'Age';

  @override
  String get weight => 'Weight';

  @override
  String get breed => 'Breed';

  @override
  String get gender => 'Gender';

  @override
  String get color => 'Color';

  @override
  String get species => 'Species';

  @override
  String get name => 'Name';

  @override
  String resultsFound(Object count) {
    return '$count results found';
  }

  @override
  String get whatTypeOfPetDoYouHave => 'What type of pet do you have?';

  @override
  String get next => 'Next';

  @override
  String get petsNearMe => 'Pets near me';

  @override
  String get basedOnYourCurrentLocation => 'Based on your current location';

  @override
  String get noAdoptionListingsInYourArea => 'No adoption listings in your area';

  @override
  String get noAdoptionListingsYet => 'No adoption listings yet';

  @override
  String get beTheFirstToAddPetForAdoption => 'Be the first to add a pet for adoption!';

  @override
  String get addListing => 'Add Listing';

  @override
  String get searchPets => 'Search pets...';

  @override
  String get gettingYourLocation => 'Getting your location...';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationPermissionPermanentlyDenied => 'Location permission permanently denied';

  @override
  String get unableToGetLocation => 'Unable to get location';

  @override
  String filtersApplied(Object count) {
    return 'Filters applied: $count active';
  }

  @override
  String get pleaseLoginToManageListings => 'Please log in to manage your listings';

  @override
  String get errorLoadingListings => 'Error loading listings';

  @override
  String get noPetsNearMe => 'No pets near me';

  @override
  String get posting => 'Posting...';

  @override
  String get postForAdoption => 'Post for Adoption';

  @override
  String get listingTitle => 'Listing Title';

  @override
  String get enterTitleForListing => 'Enter a title for your listing';

  @override
  String get describePetAndAdopter => 'Describe your pet and what you\'re looking for in an adopter';

  @override
  String get location => 'Location';

  @override
  String get enterLocationForAdoption => 'Enter the location for adoption';

  @override
  String get petInformation => 'Pet Information';

  @override
  String get listingDetails => 'Listing Details';

  @override
  String get adoptionFee => 'Adoption Fee (DZD)';

  @override
  String get freeAdoption => '0 for free adoption';

  @override
  String get pleaseEnterTitle => 'Please enter a title for the listing';

  @override
  String get pleaseEnterDescription => 'Please enter a description for the listing';

  @override
  String get pleaseEnterLocation => 'Please enter a location for the listing';

  @override
  String petPostedForAdoptionSuccessfully(Object petName) {
    return '$petName has been posted for adoption successfully!';
  }

  @override
  String failedToPostAdoptionListing(Object error) {
    return 'Failed to post adoption listing: $error';
  }

  @override
  String get offerForAdoption => 'Offer for Adoption';

  @override
  String get deletePet => 'Delete Pet';

  @override
  String areYouSureDeletePet(Object petName) {
    return 'Are you sure you want to delete $petName?';
  }

  @override
  String petDeletedSuccessfully(Object petName) {
    return '$petName has been deleted successfully';
  }

  @override
  String failedToDeletePet(Object error) {
    return 'Failed to delete pet: $error';
  }

  @override
  String get myListings => 'My Listings';

  @override
  String get noListingsFound => 'No listings found';

  @override
  String get editListing => 'Edit Listing';

  @override
  String get deleteListing => 'Delete Listing';

  @override
  String get listingDeletedSuccessfully => 'Listing deleted successfully';

  @override
  String failedToDeleteListing(Object error) {
    return 'Failed to delete listing: $error';
  }

  @override
  String get areYouSureDeleteListing => 'Are you sure you want to delete this listing?';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get postedBy => 'Posted by';

  @override
  String get contactOwner => 'Contact Owner';

  @override
  String adoptionFeeValue(Object fee) {
    return 'Adoption Fee: $fee DZD';
  }

  @override
  String get free => 'Free';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get requirements => 'Requirements';

  @override
  String get noRequirements => 'No specific requirements';

  @override
  String get contactNumber => 'Contact Number';

  @override
  String get noContactNumber => 'No contact number provided';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get createdOn => 'Created on';

  @override
  String get adoptionListingDetails => 'Adoption Listing Details';

  @override
  String get petDetails => 'Pet Details';

  @override
  String get petType => 'Pet Type';

  @override
  String get petAge => 'Age';

  @override
  String get petGender => 'Gender';

  @override
  String get petColor => 'Color';

  @override
  String get petWeight => 'Weight';

  @override
  String get petBreed => 'Breed';

  @override
  String get petLocation => 'Location';

  @override
  String get petImages => 'Images';

  @override
  String get noImages => 'No images available';

  @override
  String get viewAllImages => 'View all images';

  @override
  String get adoptionProcess => 'Adoption Process';

  @override
  String get adoptionSteps => 'Adoption Steps';

  @override
  String get step1 => 'Step 1';

  @override
  String get step2 => 'Step 2';

  @override
  String get step3 => 'Step 3';

  @override
  String get step4 => 'Step 4';

  @override
  String get contactOwnerStep => 'Contact the owner';

  @override
  String get meetPetStep => 'Meet the pet';

  @override
  String get completeAdoptionStep => 'Complete adoption';

  @override
  String get followUpStep => 'Follow up care';

  @override
  String get contactOwnerDescription => 'Reach out to the pet owner to express your interest and ask questions about the pet.';

  @override
  String get meetPetDescription => 'Arrange to meet the pet in person to ensure it\'s a good match for your family.';

  @override
  String get completeAdoptionDescription => 'If everything goes well, complete the adoption process with the owner.';

  @override
  String get followUpDescription => 'Provide ongoing care and follow up with the owner if needed.';

  @override
  String get adoptionTips => 'Adoption Tips';

  @override
  String get adoptionTipsDescription => 'Here are some tips to help you through the adoption process:';

  @override
  String get tip1 => 'Ask lots of questions about the pet\'s history, health, and behavior';

  @override
  String get tip2 => 'Meet the pet in person before making a decision';

  @override
  String get tip3 => 'Consider your lifestyle and living situation';

  @override
  String get tip4 => 'Be patient and don\'t rush the decision';

  @override
  String get tip5 => 'Prepare your home for the new pet';

  @override
  String get tip6 => 'Have a plan for ongoing care and expenses';

  @override
  String get adoptionSuccess => 'Adoption Success';

  @override
  String get adoptionSuccessDescription => 'Congratulations on finding your new companion! Remember to:';

  @override
  String get successTip1 => 'Give your new pet time to adjust to their new home';

  @override
  String get successTip2 => 'Schedule a vet checkup within the first week';

  @override
  String get successTip3 => 'Update microchip information if applicable';

  @override
  String get successTip4 => 'Keep in touch with the previous owner if needed';

  @override
  String get successTip5 => 'Provide lots of love and patience during the transition';

  @override
  String get adoptionResources => 'Adoption Resources';

  @override
  String get adoptionResourcesDescription => 'Here are some helpful resources for new pet parents:';

  @override
  String get resource1 => 'Pet care guides and tips';

  @override
  String get resource2 => 'Local vet recommendations';

  @override
  String get resource3 => 'Pet training resources';

  @override
  String get resource4 => 'Emergency pet care information';

  @override
  String get resource5 => 'Pet-friendly housing resources';

  @override
  String get adoptionSupport => 'Adoption Support';

  @override
  String get adoptionSupportDescription => 'Need help with your adoption? We\'re here to support you:';

  @override
  String get support1 => 'Contact our adoption support team';

  @override
  String get support2 => 'Join our community forums';

  @override
  String get support3 => 'Access educational resources';

  @override
  String get support4 => 'Get vet recommendations';

  @override
  String get support5 => 'Find pet care services';

  @override
  String get adoptionFaq => 'Adoption FAQ';

  @override
  String get adoptionFaqDescription => 'Common questions about pet adoption:';

  @override
  String get faq1 => 'What should I ask the pet owner?';

  @override
  String get faq2 => 'How do I know if a pet is right for me?';

  @override
  String get faq3 => 'What documents do I need for adoption?';

  @override
  String get faq4 => 'How much does pet care cost?';

  @override
  String get faq5 => 'What if the adoption doesn\'t work out?';

  @override
  String get adoptionGuidelines => 'Adoption Guidelines';

  @override
  String get adoptionGuidelinesDescription => 'Please follow these guidelines for a successful adoption:';

  @override
  String get guideline1 => 'Be honest about your experience and living situation';

  @override
  String get guideline2 => 'Ask detailed questions about the pet\'s needs';

  @override
  String get guideline3 => 'Consider the long-term commitment';

  @override
  String get guideline4 => 'Have a backup plan for emergencies';

  @override
  String get guideline5 => 'Be respectful of the owner\'s time and decision';

  @override
  String get adoptionSafety => 'Adoption Safety';

  @override
  String get adoptionSafetyDescription => 'Stay safe during the adoption process:';

  @override
  String get safety1 => 'Meet in a public place for the first meeting';

  @override
  String get safety2 => 'Bring a friend or family member';

  @override
  String get safety3 => 'Trust your instincts';

  @override
  String get safety4 => 'Don\'t feel pressured to make a quick decision';

  @override
  String get safety5 => 'Report any suspicious behavior';

  @override
  String get adoptionPreparation => 'Adoption Preparation';

  @override
  String get adoptionPreparationDescription => 'Prepare for your new pet:';

  @override
  String get preparation1 => 'Pet-proof your home';

  @override
  String get preparation2 => 'Gather necessary supplies';

  @override
  String get preparation3 => 'Research pet care requirements';

  @override
  String get preparation4 => 'Plan for ongoing expenses';

  @override
  String get preparation5 => 'Arrange for pet care when you\'re away';

  @override
  String get adoptionTimeline => 'Adoption Timeline';

  @override
  String get adoptionTimelineDescription => 'Typical adoption process timeline:';

  @override
  String get timeline1 => 'Initial contact (1-2 days)';

  @override
  String get timeline2 => 'Meet and greet (3-7 days)';

  @override
  String get timeline3 => 'Home visit (optional, 1-2 weeks)';

  @override
  String get timeline4 => 'Adoption completion (1-4 weeks)';

  @override
  String get timeline5 => 'Follow-up care (ongoing)';

  @override
  String get adoptionCosts => 'Adoption Costs';

  @override
  String get adoptionCostsDescription => 'Consider these costs when adopting:';

  @override
  String get cost1 => 'Adoption fee (if any)';

  @override
  String get cost2 => 'Initial vet visit and vaccinations';

  @override
  String get cost3 => 'Pet supplies and equipment';

  @override
  String get cost4 => 'Ongoing food and care expenses';

  @override
  String get cost5 => 'Emergency vet care fund';

  @override
  String get adoptionBenefits => 'Adoption Benefits';

  @override
  String get adoptionBenefitsDescription => 'Benefits of adopting a pet:';

  @override
  String get benefit1 => 'Save a life and give a home to a pet in need';

  @override
  String get benefit2 => 'Often more affordable than buying from a breeder';

  @override
  String get benefit3 => 'Many adopted pets are already trained';

  @override
  String get benefit4 => 'Support animal welfare organizations';

  @override
  String get benefit5 => 'Experience the joy of pet companionship';

  @override
  String get adoptionChallenges => 'Adoption Challenges';

  @override
  String get adoptionChallengesDescription => 'Be prepared for these challenges:';

  @override
  String get challenge1 => 'Adjustment period for the pet';

  @override
  String get challenge2 => 'Unknown health or behavior history';

  @override
  String get challenge3 => 'Potential training needs';

  @override
  String get challenge4 => 'Ongoing time and financial commitment';

  @override
  String get challenge5 => 'Emotional attachment and responsibility';

  @override
  String get adoptionSuccessStories => 'Adoption Success Stories';

  @override
  String get adoptionSuccessStoriesDescription => 'Read inspiring adoption stories:';

  @override
  String get story1 => 'How Max found his forever home';

  @override
  String get story2 => 'Luna\'s journey to recovery';

  @override
  String get story3 => 'A family\'s first adoption experience';

  @override
  String get story4 => 'Senior pet adoption success';

  @override
  String get story5 => 'Special needs pet adoption';

  @override
  String get adoptionCommunity => 'Adoption Community';

  @override
  String get adoptionCommunityDescription => 'Connect with other pet parents:';

  @override
  String get community1 => 'Join local pet groups';

  @override
  String get community2 => 'Share your adoption story';

  @override
  String get community3 => 'Get advice from experienced owners';

  @override
  String get community4 => 'Participate in pet events';

  @override
  String get community5 => 'Volunteer at animal shelters';

  @override
  String get adoptionEducation => 'Adoption Education';

  @override
  String get adoptionEducationDescription => 'Learn more about pet adoption:';

  @override
  String get education1 => 'Understanding pet behavior';

  @override
  String get education2 => 'Pet health and nutrition';

  @override
  String get education3 => 'Training and socialization';

  @override
  String get education4 => 'Emergency pet care';

  @override
  String get education5 => 'Pet law and regulations';

  @override
  String get adoptionAdvocacy => 'Adoption Advocacy';

  @override
  String get adoptionAdvocacyDescription => 'Help promote pet adoption:';

  @override
  String get advocacy1 => 'Share adoption stories on social media';

  @override
  String get advocacy2 => 'Volunteer at local shelters';

  @override
  String get advocacy3 => 'Donate to animal welfare organizations';

  @override
  String get advocacy4 => 'Educate others about adoption benefits';

  @override
  String get advocacy5 => 'Support spay/neuter programs';

  @override
  String get adoptionMyths => 'Adoption Myths';

  @override
  String get adoptionMythsDescription => 'Common misconceptions about pet adoption:';

  @override
  String get myth1 => 'Adopted pets have behavior problems';

  @override
  String get myth2 => 'You can\'t find purebred pets for adoption';

  @override
  String get myth3 => 'Adopted pets are unhealthy';

  @override
  String get myth4 => 'Adoption is too complicated';

  @override
  String get myth5 => 'Adopted pets don\'t bond with new owners';

  @override
  String get adoptionFacts => 'Adoption Facts';

  @override
  String get adoptionFactsDescription => 'Facts about pet adoption:';

  @override
  String get fact1 => 'Millions of pets are waiting for homes';

  @override
  String get fact2 => 'Adopted pets are often already trained';

  @override
  String get fact3 => 'Adoption fees help support animal care';

  @override
  String get fact4 => 'Many adopted pets are healthy and well-behaved';

  @override
  String get fact5 => 'Adoption saves lives and reduces overpopulation';

  @override
  String get groomers => 'Groomers';

  @override
  String get trainers => 'Trainers';

  @override
  String get professionalGroomers => 'Professional Groomers';

  @override
  String get professionalTrainers => 'Professional Trainers';

  @override
  String get findBestGroomingServices => 'Find the best grooming services for your pet';

  @override
  String get findBestTrainingServices => 'Find the best training services for your pet';

  @override
  String get listingsNearMe => 'Listings Near Me';

  @override
  String get topListings => 'Top Listings';

  @override
  String get noGroomersNearby => 'No groomers nearby';

  @override
  String get noTopGroomers => 'No top groomers available';

  @override
  String get noTrainersNearby => 'No trainers nearby';

  @override
  String get noTopTrainers => 'No top trainers available';
}
