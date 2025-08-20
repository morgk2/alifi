// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get continueWithFacebook => 'Continuer avec Facebook';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get continueAsGuest => 'Continuer en tant qu\'invité';

  @override
  String get reportAProblem => 'Signaler un problème';

  @override
  String get byClickingContinueYouAgreeToOur => 'En cliquant sur continuer, vous acceptez nos';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get and => 'et';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get aiPetAssistant => 'Assistant IA pour animaux';

  @override
  String get typeYourMessage => 'Tapez votre message...';

  @override
  String get alifi => 'alifi';

  @override
  String get goodAfternoonUser => 'Bon après-midi, utilisateur !';

  @override
  String get loadingNearbyPets => 'Chargement des animaux à proximité...';

  @override
  String get lostPetsNearby => 'Animaux perdus à proximité';

  @override
  String get recentLostPets => 'Animaux perdus récemment';

  @override
  String get lost => 'PERDU';

  @override
  String get yearsOld => 'ans';

  @override
  String get description => 'Description';

  @override
  String get price => 'Prix';

  @override
  String get affiliatePartnership => 'Partenariat d\'affiliation';

  @override
  String get affiliatePartnershipDescription => 'Ce produit est disponible grâce à notre partenariat d\'affiliation avec AliExpress. Lorsque vous effectuez un achat via ces liens, vous soutenez notre application sans coût supplémentaire pour vous. Cela nous aide à maintenir et améliorer nos services.';

  @override
  String get reportFound => 'Signaler trouvé';

  @override
  String get openInMaps => 'Ouvrir dans les cartes';

  @override
  String get contact => 'Contact';

  @override
  String get petMarkedAsFoundSuccessfully => 'Animal marqué comme trouvé avec succès !';

  @override
  String errorMarkingPetAsFound(Object error) {
    return 'Erreur lors du marquage de l\'animal comme trouvé : $error';
  }

  @override
  String get areYouSure => 'Êtes-vous sûr ?';

  @override
  String get thisWillPostYourMissingPetReport => 'Cela publiera votre rapport d\'animal perdu dans la communauté.';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get search => 'Rechercher';

  @override
  String get close => 'Fermer';

  @override
  String get ok => 'OK';

  @override
  String get proceed => 'PROCÉDER';

  @override
  String get enterCustomAmount => 'Entrer un montant personnalisé';

  @override
  String get locationServicesDisabled => 'Services de localisation désactivés';

  @override
  String get pleaseEnableLocationServices => 'Veuillez activer les services de localisation';

  @override
  String get enterManually => 'Saisir manuellement';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get locationPermissionRequired => 'Autorisation de localisation requise';

  @override
  String get locationPermissionRequiredDescription => 'L\'autorisation de localisation est requise pour cette fonctionnalité. Veuillez l\'activer dans les paramètres de l\'application.';

  @override
  String get enterYourLocation => 'Entrez votre emplacement';

  @override
  String locationSetTo(Object address) {
    return 'Emplacement défini sur : $address';
  }

  @override
  String get reportMissingPet => 'Signaler un animal perdu';

  @override
  String get addYourBusiness => 'Ajouter votre entreprise';

  @override
  String get pleaseLoginToReportMissingPet => 'Veuillez vous connecter pour signaler un animal perdu';

  @override
  String get thisVetIsAlreadyInDatabase => 'Ce vétérinaire est déjà dans la base de données';

  @override
  String get thisStoreIsAlreadyInDatabase => 'Ce magasin est déjà dans la base de données';

  @override
  String get addedVetClinicToMap => 'Clinique vétérinaire ajoutée à la carte';

  @override
  String get addedPetStoreToMap => 'Animalerie ajoutée à la carte';

  @override
  String errorAddingBusiness(Object error) {
    return 'Erreur lors de l\'ajout de l\'entreprise : $error';
  }

  @override
  String get migrateLocations => 'Migrer les emplacements';

  @override
  String get migrateLocationsDescription => 'Cela migrera tous les emplacements d\'animaux existants vers le nouveau format. Ce processus ne peut pas être annulé.';

  @override
  String get migrationComplete => 'Migration terminée';

  @override
  String get migrationCompleteDescription => 'Tous les emplacements ont été migrés avec succès vers le nouveau format.';

  @override
  String get migrationFailed => 'Migration échouée';

  @override
  String errorDuringMigration(Object error) {
    return 'Erreur lors de la migration : $error';
  }

  @override
  String get adminDashboard => 'Tableau de bord administrateur';

  @override
  String get comingSoon => 'Bientôt disponible !';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get french => 'Français';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get help => 'Aide';

  @override
  String get about => 'À propos';

  @override
  String get logout => 'Se Déconnecter';

  @override
  String get debugInfo => 'Informations de débogage';

  @override
  String authServiceInitialized(Object status) {
    return 'Service d\'authentification initialisé : $status';
  }

  @override
  String authServiceLoading(Object status) {
    return 'Service d\'authentification en cours de chargement : $status';
  }

  @override
  String authServiceAuthenticated(Object status) {
    return 'Service d\'authentification authentifié : $status';
  }

  @override
  String authServiceUser(Object email) {
    return 'Utilisateur du service d\'authentification : $email';
  }

  @override
  String firebaseUser(Object email) {
    return 'Utilisateur Firebase : $email';
  }

  @override
  String guestMode(Object status) {
    return 'Mode invité : $status';
  }

  @override
  String get forceSignOut => 'Forcer la déconnexion';

  @override
  String get signedOutOfAllServices => 'Déconnecté de tous les services';

  @override
  String failedToGetDebugInfo(Object error) {
    return 'Échec de l\'obtention des informations de débogage : $error';
  }

  @override
  String error(Object error, Object errorMessage) {
    return 'Erreur : $errorMessage';
  }

  @override
  String get lastSeen => 'Dernière fois vu';

  @override
  String physicalPetIdFor(Object petName) {
    return 'ID physique de l\'animal pour $petName';
  }

  @override
  String get priceValue => '20,00 €';

  @override
  String get hiAskMeAboutPetAdvice => 'Salut ! Demandez-moi des conseils sur les animaux,\net je ferai de mon mieux pour vous aider, vous et\nvotre petit !';

  @override
  String errorGettingLocation(Object error) {
    return 'Erreur lors de l\'obtention de l\'emplacement : $error';
  }

  @override
  String errorFindingLocation(Object error) {
    return 'Erreur lors de la recherche de l\'emplacement : $error';
  }

  @override
  String get vet => 'vétérinaire';

  @override
  String get vetsNearMe => 'Vétérinaires Près de Moi';

  @override
  String get recommendedVets => 'Vétérinaires Recommandés';

  @override
  String get topVets => 'Meilleurs Vétérinaires';

  @override
  String get store => 'Magasin';

  @override
  String get vetClinic => 'clinique vétérinaire';

  @override
  String get petStore => 'Animalerie';

  @override
  String get services => 'Services';

  @override
  String get myPets => 'Mes Animaux';

  @override
  String get testNotificationsDescription => 'Testez les notifications pour vérifier qu\'elles fonctionnent sur votre appareil.';

  @override
  String get disableNotificationsTitle => 'Désactiver les notifications ?';

  @override
  String get disableNotificationsDescription => 'Vous ne recevrez plus de notifications push. Vous pouvez les réactiver à tout moment.';

  @override
  String get appSettings => 'Paramètres de l\'application';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get manageYourNotifications => 'Gérer vos notifications';

  @override
  String get currency => 'Devise';

  @override
  String get account => 'Compte';

  @override
  String get editProfile => 'Modifier le Profil';

  @override
  String get updateYourInformation => 'Mettre à jour vos informations';

  @override
  String get privacyAndSecurity => 'Confidentialité et sécurité';

  @override
  String get manageYourPrivacySettings => 'Gérer vos paramètres de confidentialité';

  @override
  String get support => 'Support';

  @override
  String get helpCenter => 'Centre d\'aide';

  @override
  String get getHelpAndSupport => 'Obtenez de l\'aide et du support';

  @override
  String get reportABug => 'Signaler un bug';

  @override
  String get helpUsImproveTheApp => 'Aidez-nous à améliorer l\'application';

  @override
  String get rateTheApp => 'Noter l\'application';

  @override
  String get shareYourFeedback => 'Partagez vos commentaires';

  @override
  String get appVersionAndInfo => 'Version de l\'application et informations';

  @override
  String get adminTools => 'Outils d\'administration';

  @override
  String get addAliexpressProduct => 'Ajouter un produit AliExpress';

  @override
  String get addNewProductsToTheStore => 'Ajouter de nouveaux produits au magasin';

  @override
  String get bulkImportProducts => 'Importation en masse de produits';

  @override
  String get importMultipleProductsAtOnce => 'Importer plusieurs produits à la fois';

  @override
  String get userManagement => 'Gestion des utilisateurs';

  @override
  String get manageUserAccounts => 'Gérer les comptes utilisateurs';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get currentLocale => 'Langue actuelle';

  @override
  String get localizedTextTest => 'Test de texte localisé';

  @override
  String get addTestAppointment => 'Ajouter un rendez-vous de test';

  @override
  String get createAppointmentForTesting => 'Créer un rendez-vous dans 1h 30min pour test';

  @override
  String get noSubscription => 'Aucun abonnement';

  @override
  String get selectCurrency => 'Sélectionner la devise';

  @override
  String get usd => 'USD';

  @override
  String get dzd => 'DZD';

  @override
  String get pleaseLoginToViewNotifications => 'Veuillez vous connecter pour voir les notifications';

  @override
  String get markAllAsRead => 'Tout marquer comme lu';

  @override
  String get errorLoadingNotifications => 'Erreur lors du chargement des notifications';

  @override
  String errorWithMessage(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get retry => 'Réessayer';

  @override
  String get noNotificationsYet => 'Aucune notification pour le moment';

  @override
  String get notificationsEmptyHint => 'Vous verrez des notifications ici lorsque vous recevrez des messages, des commandes ou des abonnements';

  @override
  String get sendTestNotificationTooltip => 'Envoyer une notification de test';

  @override
  String get unableToOpenChatUserNotFound => 'Impossible d\'ouvrir le chat - utilisateur introuvable';

  @override
  String errorOpeningChat(Object error) {
    return 'Erreur lors de l\'ouverture du chat : $error';
  }

  @override
  String get unableToOpenChatSenderMissing => 'Impossible d\'ouvrir le chat - informations sur l\'expéditeur manquantes';

  @override
  String get unableToOpenOrderMissing => 'Impossible d\'ouvrir la commande - informations manquantes';

  @override
  String get unableToOpenProfileUserNotFound => 'Impossible d\'ouvrir le profil - utilisateur introuvable';

  @override
  String errorOpeningProfile(Object error) {
    return 'Erreur lors de l\'ouverture du profil : $error';
  }

  @override
  String get unableToOpenProfileUserMissing => 'Impossible d\'ouvrir le profil - informations utilisateur manquantes';

  @override
  String get appointmentNotificationNavigationTbd => 'Notification de rendez-vous - navigation à implémenter';

  @override
  String get notificationDeleted => 'Notification supprimée';

  @override
  String errorDeletingNotification(Object error) {
    return 'Erreur lors de la suppression de la notification : $error';
  }

  @override
  String get allNotificationsMarkedAsRead => 'Toutes les notifications marquées comme lues';

  @override
  String errorMarkingNotificationsAsRead(Object error) {
    return 'Erreur lors du marquage des notifications comme lues : $error';
  }

  @override
  String testAppointmentCreated(Object id, Object time) {
    return 'Rendez-vous de test créé ! ID : $id\nHeure : $time';
  }

  @override
  String errorCreatingTestAppointment(Object error) {
    return 'Erreur lors de la création du rendez-vous de test : $error';
  }

  @override
  String get noUserLoggedIn => 'Aucun utilisateur connecté';

  @override
  String get todaysVetAppointment => 'Rendez-vous vétérinaire d\'aujourd\'hui';

  @override
  String get soon => 'Bientôt';

  @override
  String get past => 'Passé';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get pet => 'Animal';

  @override
  String get veterinarian => 'Vétérinaire';

  @override
  String get notesLabel => 'Notes :';

  @override
  String get unableToContactVet => 'Impossible de contacter le vétérinaire pour le moment';

  @override
  String get contactVet => 'Contacter le vétérinaire';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String hoursMinutesUntilAppointment(Object hours, Object minutes) {
    return '${hours}h ${minutes}m jusqu\'au rendez-vous';
  }

  @override
  String minutesUntilAppointment(Object minutes) {
    return '${minutes}m jusqu\'au rendez-vous';
  }

  @override
  String get appointmentStartingNow => 'Le rendez-vous commence maintenant !';

  @override
  String errorLoadingPets(Object error) {
    return 'Erreur lors du chargement des animaux : $error';
  }

  @override
  String errorLoadingTimeSlots(Object error) {
    return 'Erreur lors du chargement des créneaux : $error';
  }

  @override
  String get pleaseFillRequiredFields => 'Veuillez remplir tous les champs requis (photo, nom et description)';

  @override
  String get appointmentRequestSent => 'Demande de rendez-vous envoyée avec succès !';

  @override
  String errorBookingAppointment(Object error) {
    return 'Erreur lors de la réservation du rendez-vous : $error';
  }

  @override
  String get selectDate => 'Sélectionner la Date';

  @override
  String get selectADate => 'Sélectionner une date';

  @override
  String get selectTime => 'Sélectionner l\'heure';

  @override
  String get noAvailableTimeSlotsForThisDate => 'Aucun créneau disponible pour cette date';

  @override
  String get selectPet => 'Sélectionner l\'animal';

  @override
  String get noPetsFoundPleaseAdd => 'Aucun animal trouvé. Veuillez d\'abord ajouter un animal.';

  @override
  String get appointmentType => 'Type de rendez-vous';

  @override
  String get reasonOptional => 'Raison (facultatif)';

  @override
  String get describeAppointmentReason => 'Décrivez la raison du rendez-vous...';

  @override
  String get bookAppointment => 'Réserver un rendez-vous';

  @override
  String get noPetsFound => 'Aucun animal trouvé';

  @override
  String get needToAddPetBeforeBooking => 'Vous devez ajouter un animal avant de prendre rendez-vous.';

  @override
  String get addPetCta => 'Ajouter un animal';

  @override
  String drName(Object name) {
    return 'Dr. $name';
  }

  @override
  String get searchForHelp => 'Rechercher de l\'aide...';

  @override
  String get all => 'Tout';

  @override
  String get appointments => 'Rendez-vous';

  @override
  String get pets => 'Animaux';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get tryAdjustingSearchOrCategoryFilter => 'Essayez d\'ajuster votre recherche ou le filtre de catégorie';

  @override
  String get stillNeedHelp => 'Vous avez encore besoin d\'aide ?';

  @override
  String get contactSupportTeamForPersonalizedAssistance => 'Contactez notre équipe de support pour une assistance personnalisée';

  @override
  String get emailSupportComingSoon => 'Support par e-mail bientôt disponible !';

  @override
  String get email => 'E-mail';

  @override
  String get liveChatComingSoon => 'Chat en direct bientôt disponible !';

  @override
  String get liveChat => 'Chat en direct';

  @override
  String get howToBookAppointment => 'Comment prendre rendez-vous avec un vétérinaire ?';

  @override
  String get bookAppointmentInstructions => 'Pour prendre rendez-vous, allez dans la section \"Trouver un vétérinaire\", recherchez des vétérinaires dans votre région, sélectionnez-en un et appuyez sur \"Prendre rendez-vous\". Vous pouvez choisir votre date et heure préférées.';

  @override
  String get howToAddPets => 'Comment ajouter mes animaux de compagnie à l\'application ?';

  @override
  String get addPetsInstructions => 'Allez dans \"Mes animaux\" dans la navigation du bas, appuyez sur le bouton \"+\" et remplissez les informations de votre animal, y compris le nom, l\'espèce, la race et l\'âge.';

  @override
  String get howToReportLostPet => 'Comment signaler un animal perdu ?';

  @override
  String get reportLostPetInstructions => 'Naviguez vers la section \"Animaux perdus\", appuyez sur \"Signaler un animal perdu\", remplissez les détails, y compris les photos, l\'emplacement et les informations de contact.';

  @override
  String get lostPets => 'Animaux perdus';

  @override
  String get howToOrderPetSupplies => 'Comment commander des fournitures pour animaux ?';

  @override
  String get orderPetSuppliesInstructions => 'Allez dans la section \"Boutique\", parcourez les produits, ajoutez des articles au panier et procédez au paiement avec votre méthode de paiement.';

  @override
  String get howToContactCustomerSupport => 'Comment contacter le support client ?';

  @override
  String get contactCustomerSupportInstructions => 'Vous pouvez nous contacter via la fonction \"Signaler un bug\" dans les Paramètres, ou nous envoyer un email à support@alifi.com.';

  @override
  String get howToChangeAccountSettings => 'Comment modifier les paramètres de mon compte ?';

  @override
  String get changeAccountSettingsInstructions => 'Allez dans Paramètres, appuyez sur le paramètre que vous voulez modifier et suivez les instructions pour mettre à jour vos informations.';

  @override
  String get howToFindVeterinariansNearMe => 'Comment trouver des vétérinaires près de chez moi ?';

  @override
  String get findVeterinariansInstructions => 'Utilisez la fonction \"Trouver un vétérinaire\" et autorisez l\'accès à la localisation pour voir les vétérinaires de votre région, ou recherchez par ville/code postal.';

  @override
  String get howToCancelAppointment => 'Comment annuler un rendez-vous ?';

  @override
  String get cancelAppointmentInstructions => 'Allez dans \"Mes rendez-vous\", trouvez le rendez-vous que vous voulez annuler, appuyez dessus et sélectionnez \"Annuler le rendez-vous\".';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get stayUpdatedWithImportantNotifications => 'Restez informé des notifications importantes :';

  @override
  String get newMessages => 'Nouveaux messages';

  @override
  String get getNotifiedWhenSomeoneSendsMessage => 'Soyez notifié quand quelqu\'un vous envoie un message';

  @override
  String get trackOrdersAndDeliveryStatus => 'Suivez vos commandes et le statut de livraison';

  @override
  String get petCareReminders => 'Rappels de soins pour animaux';

  @override
  String get neverMissImportantPetCareAppointments => 'Ne manquez jamais les rendez-vous importants de soins pour animaux';

  @override
  String get youCanChangeThisLaterInDeviceSettings => 'Vous pouvez changer cela plus tard dans les paramètres de votre appareil';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get enable => 'Activer';

  @override
  String get toReceiveNotificationsPleaseEnableInDeviceSettings => 'Pour recevoir des notifications, veuillez les activer dans les paramètres de votre appareil.';

  @override
  String errorSearchingLocation(Object error) {
    return 'Erreur lors de la recherche d\'emplacement : $error';
  }

  @override
  String errorGettingPlaceDetails(Object error) {
    return 'Erreur lors de l\'obtention des détails du lieu : $error';
  }

  @override
  String errorSelectingLocation(Object error) {
    return 'Erreur lors de la sélection de l\'emplacement : $error';
  }

  @override
  String errorReverseGeocoding(Object error) {
    return 'Erreur lors du géocodage inverse : $error';
  }

  @override
  String get searchLocation => 'Rechercher un emplacement...';

  @override
  String get confirmLocation => 'Confirmer l\'emplacement';

  @override
  String get giftToAFriend => 'Offrir à un ami';

  @override
  String get searchByNameOrEmail => 'Rechercher par nom ou email';

  @override
  String get searchForUsersToGift => 'Rechercher des utilisateurs à qui offrir.';

  @override
  String get noUsersFound => 'Aucun utilisateur trouvé';

  @override
  String get noName => 'Aucun Nom';

  @override
  String get noEmail => 'Aucun email';

  @override
  String get gift => 'Offrir';

  @override
  String get anonymous => 'Anonyme';

  @override
  String get confirmYourGift => 'Confirmer votre cadeau';

  @override
  String areYouSureYouWantToGiftThisProductTo(Object userName) {
    return 'Êtes-vous sûr de vouloir offrir ce produit à $userName ?';
  }

  @override
  String get youHaveAGift => 'Vous avez un cadeau !';

  @override
  String get hasGiftedYou => 'Vous a offert :';

  @override
  String get refuse => 'Refuser';

  @override
  String get accept => 'Accepter';

  @override
  String get searchUsers => 'Rechercher des utilisateurs...';

  @override
  String get typeToSearchForUsers => 'Tapez pour rechercher des utilisateurs';

  @override
  String get select => 'Sélectionner';

  @override
  String get checkUp => 'Examen général';

  @override
  String get vaccination => 'Vaccination';

  @override
  String get surgery => 'Chirurgie';

  @override
  String get consultation => 'Consultation';

  @override
  String get emergency => 'Urgence';

  @override
  String get followUp => 'Suivi';

  @override
  String get addPet => 'Ajouter un animal';

  @override
  String get bird => 'Oiseau';

  @override
  String get rabbit => 'Lapin';

  @override
  String get hamster => 'Hamster';

  @override
  String get fish => 'Poisson';

  @override
  String get testNotificationSent => 'Notification de test envoyée avec succès !';

  @override
  String errorSendingTestNotification(Object error) {
    return 'Erreur lors de l\'envoi de la notification de test : $error';
  }

  @override
  String get notificationPreferencesSavedSuccessfully => 'Préférences de notification enregistrées avec succès !';

  @override
  String errorSavingPreferences(Object error) {
    return 'Erreur lors de l\'enregistrement des préférences : $error';
  }

  @override
  String get notificationsEnabledSuccessfully => 'Notifications activées avec succès !';

  @override
  String errorRequestingPermission(Object error) {
    return 'Erreur lors de la demande d\'autorisation : $error';
  }

  @override
  String get notificationSettings => 'Paramètres de notification';

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get notificationsEnabled => 'Activé';

  @override
  String get notificationsDisabled => 'Désactivé';

  @override
  String get generalSettings => 'Paramètres généraux';

  @override
  String get sound => 'Son';

  @override
  String get playSoundForNotifications => 'Jouer un son pour les notifications';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrateDeviceForNotifications => 'Faire vibrer l\'appareil pour les notifications';

  @override
  String get emailNotifications => 'Notifications par e-mail';

  @override
  String get receiveNotificationsViaEmail => 'Recevoir les notifications par e-mail';

  @override
  String get quietHours => 'Heures silencieuses';

  @override
  String get enableQuietHours => 'Activer les heures silencieuses';

  @override
  String get muteNotificationsDuringSpecifiedHours => 'Muet les notifications pendant les heures spécifiées';

  @override
  String get startTime => 'Heure de début';

  @override
  String get endTime => 'Heure de fin';

  @override
  String get notificationTypes => 'Types de notification';

  @override
  String get chatMessages => 'Messages de chat';

  @override
  String get newMessagesFromOtherUsers => 'Nouveaux messages d\'autres utilisateurs';

  @override
  String get orderUpdates => 'Mises à jour de commande';

  @override
  String get orderStatusChangesAndUpdates => 'Changements de statut de commande et mises à jour';

  @override
  String get appointmentRequestsAndReminders => 'Demandes de rendez-vous et rappels';

  @override
  String get socialActivity => 'Activité sociale';

  @override
  String get newFollowersAndSocialInteractions => 'Nouveaux abonnés et interactions sociales';

  @override
  String get testNotifications => 'Tester les notifications';

  @override
  String get sendTestNotification => 'Envoyer une notification de test';

  @override
  String get savePreferences => 'Enregistrer les préférences';

  @override
  String get disable => 'Désactiver';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get user => 'Utilisateur';

  @override
  String get noLostPetsReportedNearby => 'Aucun animal perdu signalé à proximité';

  @override
  String get weWillNotifyYouWhenPetsAreReported => 'Nous vous notifierons quand des animaux seront signalés dans votre région';

  @override
  String get noRecentLostPetsReported => 'Aucun animal perdu récemment signalé';

  @override
  String get enableLocationToSeePetsInYourArea => 'Activez la localisation pour voir les animaux dans votre région';

  @override
  String get navigate => 'Naviguer';

  @override
  String get open => 'Ouvert';

  @override
  String get closed => 'Fermé';

  @override
  String get openNow => 'Ouvert maintenant';

  @override
  String get visitClinicProfile => 'Visiter le profil de la clinique';

  @override
  String get visitStoreProfile => 'Visiter le profil du magasin';

  @override
  String get alifiFavorite => 'Alifi Favori';

  @override
  String get alifiAffiliated => 'Alifi Affilié';

  @override
  String get pleaseEnableLocationServicesOrEnterManually => 'Veuillez activer les services de localisation ou saisir votre emplacement manuellement.';

  @override
  String get locationPermissionRequiredForFeature => 'L\'autorisation de localisation est requise pour cette fonctionnalité. Veuillez l\'activer dans les paramètres de l\'application.';

  @override
  String get unknown => 'Inconnu';

  @override
  String get addYourFirstPet => 'Ajoutez votre premier animal';

  @override
  String get healthInformation => 'Informations de Santé';

  @override
  String get snake => 'Serpent';

  @override
  String get lizard => 'Lézard';

  @override
  String get guineaPig => 'Cochon d\'Inde';

  @override
  String get ferret => 'Furet';

  @override
  String get turtle => 'Tortue';

  @override
  String get parrot => 'Perroquet';

  @override
  String get mouse => 'Souris';

  @override
  String get rat => 'Rat';

  @override
  String get hedgehog => 'Hérisson';

  @override
  String get chinchilla => 'Chinchilla';

  @override
  String get gerbil => 'Gerbille';

  @override
  String get duck => 'Canard';

  @override
  String get monkey => 'Singe';

  @override
  String get selected => 'Sélectionné';

  @override
  String get notSelected => 'Non sélectionné';

  @override
  String get appNotResponding => 'L\'application ne répond pas';

  @override
  String get loginIssues => 'Problèmes de connexion';

  @override
  String get paymentProblems => 'Problèmes de paiement';

  @override
  String get accountAccess => 'Accès au compte';

  @override
  String get missingFeatures => 'Fonctionnalités manquantes';

  @override
  String get petListingIssues => 'Problèmes de liste d\'animaux';

  @override
  String get mapNotWorking => 'La carte ne fonctionne pas';

  @override
  String get inappropriateContent => 'Contenu inapproprié';

  @override
  String get technicalProblems => 'Problèmes techniques';

  @override
  String get other => 'Autre';

  @override
  String get selectProblemType => 'Sélectionner le type de problème';

  @override
  String get submit => 'Soumettre';

  @override
  String get display => 'Affichage';

  @override
  String get interface => 'Interface';

  @override
  String get useBlurEffectForTabBar => 'Utiliser l\'effet de flou pour la barre d\'onglets';

  @override
  String get enableGlassLikeBlurEffectOnNavigationBar => 'Activer l\'effet de flou vitré sur la barre de navigation';

  @override
  String get whenDisabledTabBarWillHaveSolidWhiteBackground => 'Lorsqu\'il est désactivé, la barre d\'onglets aura un arrière-plan blanc solide au lieu de l\'effet de flou vitré.';

  @override
  String get useLiquidGlassEffectForTabBar => 'Utiliser l\'effet de verre liquide pour la barre d\'onglets';

  @override
  String get enableLiquidGlassEffectOnNavigationBar => 'Activer l\'effet de verre liquide sur la barre de navigation';

  @override
  String get whenDisabledLiquidGlassTabBarWillNotDistortBackground => 'Lorsque désactivé, la barre d\'onglets ne déformera pas le contenu d\'arrière-plan. Fonctionne séparément de l\'effet de flou.';

  @override
  String get useSolidColorForTabBar => 'Utiliser une couleur unie pour la barre d\'onglets';

  @override
  String get enableSolidColorOnNavigationBar => 'Activer l\'arrière-plan de couleur unie sur la barre de navigation';

  @override
  String get whenDisabledSolidColorTabBarWillHaveEffect => 'Lorsque désactivé, la barre d\'onglets utilisera l\'un des autres effets visuels. Un seul effet peut être actif à la fois.';

  @override
  String get customizeAppAppearanceAndInterface => 'Personnaliser l\'apparence et l\'interface de l\'application';

  @override
  String get save => 'Enregistrer';

  @override
  String get tapToChangePhoto => 'Appuyez pour changer la photo';

  @override
  String get coverPhotoOptional => 'Photo de couverture (optionnel)';

  @override
  String get changeCover => 'Changer la couverture';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get enterUsername => 'Entrez le nom d\'utilisateur';

  @override
  String get usernameCannotBeEmpty => 'Le nom d\'utilisateur ne peut pas être vide';

  @override
  String get invalidUsername => 'Nom d\'utilisateur invalide (3-20 caractères, lettres, chiffres, _)';

  @override
  String get displayName => 'Nom d\'affichage';

  @override
  String get enterDisplayName => 'Entrez le nom d\'affichage';

  @override
  String get displayNameCannotBeEmpty => 'Le nom d\'affichage ne peut pas être vide';

  @override
  String get professionalInfo => 'Informations professionnelles';

  @override
  String get enterYourQualificationsExperience => 'Entrez vos qualifications, expérience, etc.';

  @override
  String get accountType => 'Type de compte';

  @override
  String get requestToBeAVet => 'Demander à être vétérinaire';

  @override
  String get joinOurVeterinaryNetwork => 'Rejoignez notre réseau vétérinaire';

  @override
  String get requestToBeAStore => 'Demander à être magasin';

  @override
  String get sellPetProductsAndServices => 'Vendre des produits et services pour animaux';

  @override
  String get linkedAccounts => 'Comptes liés';

  @override
  String get linked => 'Lié';

  @override
  String get link => 'Lier';

  @override
  String get deleteAccount => 'Supprimer le Compte';

  @override
  String get areYouSureYouWantToDeleteYourAccount => 'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action ne peut pas être annulée.';

  @override
  String get delete => 'Supprimer';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès !';

  @override
  String failedToUpdateProfile(Object error) {
    return 'Échec de la mise à jour du profil : $error';
  }

  @override
  String errorSelectingCover(Object error) {
    return 'Erreur lors de la sélection de la couverture : $error';
  }

  @override
  String get savingChanges => 'Enregistrement des modifications...';

  @override
  String get locationSharing => 'Partage de localisation';

  @override
  String get allowAppToAccessYourLocation => 'Autoriser l\'application à accéder à votre localisation pour les services à proximité';

  @override
  String get dataAnalytics => 'Analyse des données';

  @override
  String get helpUsImproveBySharingAnonymousUsageData => 'Aidez-nous à nous améliorer en partageant des données d\'utilisation anonymes';

  @override
  String get profileVisibility => 'Visibilité du profil';

  @override
  String get controlWhoCanSeeYourProfileInformation => 'Contrôlez qui peut voir les informations de votre profil';

  @override
  String get dataAndPrivacy => 'Données et confidentialité';

  @override
  String get manageYourDataAndPrivacySettings => 'Gérez vos données et paramètres de confidentialité.';

  @override
  String get receiveNotificationsAboutAppointmentsAndUpdates => 'Recevoir des notifications sur les rendez-vous et mises à jour';

  @override
  String get receiveImportantUpdatesViaEmail => 'Recevoir des mises à jour importantes par e-mail';

  @override
  String get notificationPreferences => 'Préférences de notification';

  @override
  String get customizeWhatNotificationsYouReceive => 'Personnalisez les notifications que vous recevez.';

  @override
  String get security => 'Sécurité';

  @override
  String get biometricAuthentication => 'Authentification biométrique';

  @override
  String get useFingerprintOrFaceIdToUnlockTheApp => 'Utiliser l\'empreinte digitale ou Face ID pour déverrouiller l\'application';

  @override
  String get twoFactorAuthentication => 'Authentification à deux facteurs';

  @override
  String get addAnExtraLayerOfSecurityToYourAccount => 'Ajouter une couche de sécurité supplémentaire à votre compte';

  @override
  String get changePassword => 'Changer le Mot de Passe';

  @override
  String get updateYourAccountPassword => 'Mettre à jour le mot de passe de votre compte';

  @override
  String get activeSessions => 'Sessions actives';

  @override
  String get manageDevicesLoggedIntoYourAccount => 'Gérer les appareils connectés à votre compte.';

  @override
  String get dataAndStorage => 'Données et stockage';

  @override
  String get storageUsage => 'Utilisation du stockage';

  @override
  String get manageAppDataAndCache => 'Gérer les données et le cache de l\'application.';

  @override
  String get exportData => 'Exporter les données';

  @override
  String get downloadACopyOfYourData => 'Télécharger une copie de vos données.';

  @override
  String get permanentlyDeleteYourAccountAndData => 'Supprimer définitivement votre compte et vos données';

  @override
  String get chooseWhoCanSeeYourProfileInformation => 'Choisissez qui peut voir les informations de votre profil.';

  @override
  String get enterYourNewPassword => 'Entrez votre nouveau mot de passe.';

  @override
  String get thisActionCannotBeUndoneAllYourDataWillBePermanentlyDeleted => 'Cette action ne peut pas être annulée. Toutes vos données seront définitivement supprimées.';

  @override
  String get export => 'Exporter';

  @override
  String get yourPetsFavouriteApp => 'L\'application préférée de votre animal';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get aboutAlifi => 'À propos d\'Alifi';

  @override
  String get alifiIsAComprehensivePetCarePlatform => 'Alifi est une plateforme complète de soins pour animaux qui connecte les propriétaires d\'animaux avec des vétérinaires, des magasins pour animaux et d\'autres services de soins pour animaux. Notre mission est de rendre les soins pour animaux accessibles, pratiques et fiables pour tous.';

  @override
  String get verifiedServices => 'Services vérifiés';

  @override
  String get allVeterinariansAndPetStoresOnOurPlatformAreVerified => 'Tous les vétérinaires et magasins pour animaux sur notre plateforme sont vérifiés pour assurer les soins de la plus haute qualité pour vos animaux bien-aimés.';

  @override
  String get secureAndPrivate => 'Sécurisé et privé';

  @override
  String get yourDataAndYourPetsInformationAreProtected => 'Vos données et les informations de vos animaux sont protégées par des mesures de sécurité conformes aux normes de l\'industrie.';

  @override
  String get contactAndSupport => 'Contact et support';

  @override
  String get emailSupport => 'Support par e-mail';

  @override
  String get phoneSupport => 'Support téléphonique';

  @override
  String get website => 'Site web';

  @override
  String get legal => 'Légal';

  @override
  String get readOurTermsAndConditions => 'Lire nos conditions générales';

  @override
  String get learnAboutOurPrivacyPractices => 'En savoir plus sur nos pratiques de confidentialité';

  @override
  String get developer => 'Développeur';

  @override
  String get developedBy => 'Développé par';

  @override
  String get alifiDevelopmentTeam => 'Équipe de développement Alifi';

  @override
  String get copyright => 'Copyright';

  @override
  String get copyrightText => '© 2024 Alifi. Tous droits réservés.';

  @override
  String get phoneSupportComingSoon => 'Support téléphonique bientôt disponible !';

  @override
  String get websiteComingSoon => 'Site web bientôt disponible !';

  @override
  String get termsOfServiceComingSoon => 'Conditions d\'utilisation bientôt disponibles !';

  @override
  String get privacyPolicyComingSoon => 'Politique de confidentialité bientôt disponible !';

  @override
  String get pressBackAgainToExit => 'Appuyez à nouveau pour quitter';

  @override
  String get lostPetDetails => 'Détails de l\'animal perdu';

  @override
  String get fundraising => 'Collecte de fonds';

  @override
  String get animalShelterExpansion => 'Expansion du refuge pour animaux';

  @override
  String get helpUsExpandOurShelter => 'Aidez-nous à agrandir notre refuge pour accueillir plus d\'animaux dans le besoin.';

  @override
  String get profile => 'Profil';

  @override
  String get wishlist => 'Liste de souhaits';

  @override
  String get adoptionCenter => 'Centre d\'adoption';

  @override
  String get ordersAndMessages => 'Commandes et messages';

  @override
  String get becomeAVet => 'Devenir vétérinaire';

  @override
  String get becomeAStore => 'Devenir magasin';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get storeDashboard => 'Tableau de bord';

  @override
  String get errorLoadingDashboard => 'Erreur lors du chargement du tableau de bord';

  @override
  String get noDashboardDataAvailable => 'Aucune donnée de tableau de bord disponible';

  @override
  String get totalSales => 'Ventes Totales';

  @override
  String get engagement => 'Engagement';

  @override
  String get totalOrders => 'Tot. Commandes';

  @override
  String get activeOrders => 'Comm. Actives';

  @override
  String get viewAllSellerTools => 'Voir tous les outils vendeur';

  @override
  String get vetDashboard => 'Tableau de Bord Vétérinaire';

  @override
  String get freeShipping => 'Livraison gratuite';

  @override
  String get viewStore => 'Voir le Magasin';

  @override
  String get buyNow => 'Acheter Maintenant';

  @override
  String get addToCart => 'Ajouter au Panier';

  @override
  String get addToWishlist => 'Ajouter aux favoris';

  @override
  String get removeFromWishlist => 'Retirer des Favoris';

  @override
  String get productDetails => 'Détails du Produit';

  @override
  String get specifications => 'Spécifications';

  @override
  String get reviews => 'Avis';

  @override
  String get relatedProducts => 'Produits Similaires';

  @override
  String get outOfStock => 'Rupture de Stock';

  @override
  String get inStock => 'En Stock';

  @override
  String get quantity => 'Quantité';

  @override
  String get selectQuantity => 'Sélectionner la Quantité';

  @override
  String get productImages => 'Images du Produit';

  @override
  String get shareProduct => 'Partager le Produit';

  @override
  String get reportProduct => 'Signaler le Produit';

  @override
  String get sellerDashboard => 'Tableau de Bord Vendeur';

  @override
  String get products => 'Produits';

  @override
  String get messages => 'Messages';

  @override
  String get orders => 'Commandes';

  @override
  String get pleaseLogIn => 'Veuillez vous connecter.';

  @override
  String get revenueAnalytics => 'Analyses des Revenus';

  @override
  String get todaysSales => 'Ventes d\'Aujourd\'hui';

  @override
  String get thisWeek => 'Cette Semaine';

  @override
  String get thisMonth => 'Ce Mois';

  @override
  String get keyMetrics => 'Métriques Clés';

  @override
  String get uniqueCustomers => 'Clients Uniques';

  @override
  String get recentActivity => 'Activité Récente';

  @override
  String get addProduct => 'Ajouter un Produit';

  @override
  String get manageProducts => 'Gérer les Produits';

  @override
  String get productAnalytics => 'Analyses des Produits';

  @override
  String get totalProducts => 'Total des Produits';

  @override
  String get activeProducts => 'Produits Actifs';

  @override
  String get soldProducts => 'Produits Vendus';

  @override
  String get lowStock => 'Stock Faible';

  @override
  String get noProductsFound => 'Aucun produit trouvé';

  @override
  String get createYourFirstProduct => 'Créez votre premier produit';

  @override
  String get productName => 'Nom du Produit';

  @override
  String get productDescription => 'Description du Produit';

  @override
  String get productPrice => 'Prix du Produit';

  @override
  String get productCategory => 'Catégorie du Produit';

  @override
  String get saveProduct => 'Enregistrer le Produit';

  @override
  String get updateProduct => 'Mettre à Jour le Produit';

  @override
  String get deleteProduct => 'Supprimer le Produit';

  @override
  String get areYouSureDeleteProduct => 'Êtes-vous sûr de vouloir supprimer ce produit ?';

  @override
  String get productSavedSuccessfully => 'Produit enregistré avec succès !';

  @override
  String get productUpdatedSuccessfully => 'Produit mis à jour avec succès !';

  @override
  String get productDeletedSuccessfully => 'Produit supprimé avec succès !';

  @override
  String errorSavingProduct(Object error) {
    return 'Erreur lors de l\'enregistrement du produit : $error';
  }

  @override
  String errorUpdatingProduct(Object error) {
    return 'Erreur lors de la mise à jour du produit : $error';
  }

  @override
  String errorDeletingProduct(Object error) {
    return 'Erreur lors de la suppression du produit : $error';
  }

  @override
  String get noMessagesFound => 'Aucun message trouvé';

  @override
  String get startConversation => 'Commencer une conversation';

  @override
  String get typeMessage => 'Tapez un message...';

  @override
  String get send => 'Envoyer';

  @override
  String get noOrdersFound => 'Aucune commande trouvée';

  @override
  String get orderHistory => 'Historique des Commandes';

  @override
  String get orderDetails => 'Détails de la Commande';

  @override
  String get orderStatus => 'Statut de la Commande';

  @override
  String get orderDate => 'Date de la Commande';

  @override
  String get orderTotal => 'Total de la Commande';

  @override
  String get customerInfo => 'Informations Client';

  @override
  String get shippingAddress => 'Adresse de Livraison';

  @override
  String paymentMethod(Object method) {
    return 'Méthode de paiement : $method';
  }

  @override
  String get orderItems => 'Articles de la Commande';

  @override
  String get pending => 'En Attente';

  @override
  String get confirmed => 'Confirmé';

  @override
  String get shipped => 'Expédié';

  @override
  String get delivered => 'Livré';

  @override
  String get cancelled => 'Annulé';

  @override
  String get processing => 'En Cours';

  @override
  String get readyForPickup => 'Prêt pour Retrait';

  @override
  String get updateOrderStatus => 'Mettre à Jour le Statut';

  @override
  String get markAsShipped => 'Marquer comme Expédié';

  @override
  String get markAsDelivered => 'Marquer comme Livré';

  @override
  String get cancelOrder => 'Annuler la commande';

  @override
  String get orderUpdatedSuccessfully => 'Commande mise à jour avec succès !';

  @override
  String errorUpdatingOrder(Object error) {
    return 'Erreur lors de la mise à jour de la commande : $error';
  }

  @override
  String get custom => 'Personnalisé...';

  @override
  String get enterAmountInDZD => 'Entrez le montant en DZD';

  @override
  String get payVia => 'Payer via :';

  @override
  String get discussion => 'Discussion';

  @override
  String get online => 'En ligne';

  @override
  String get offline => 'Hors ligne';

  @override
  String get typing => 'écrit...';

  @override
  String get messageSent => 'Message envoyé';

  @override
  String get messageDelivered => 'Message livré';

  @override
  String get messageRead => 'Message lu';

  @override
  String get newMessage => 'Nouveau message';

  @override
  String get unreadMessages => 'Messages non lus';

  @override
  String get markAsRead => 'Marquer comme lu';

  @override
  String get deleteMessage => 'Supprimer le message';

  @override
  String get blockUser => 'Bloquer l\'utilisateur';

  @override
  String get reportUser => 'Signaler l\'utilisateur';

  @override
  String get clearChat => 'Effacer le chat';

  @override
  String get chatCleared => 'Chat effacé';

  @override
  String get userBlocked => 'Utilisateur bloqué';

  @override
  String get userReported => 'Utilisateur signalé';

  @override
  String errorSendingMessage(Object error) {
    return 'Erreur lors de l\'envoi du message : $error';
  }

  @override
  String errorLoadingMessages(Object error) {
    return 'Erreur lors du chargement des messages : $error';
  }

  @override
  String get appointmentInProgress => 'Rendez-vous en Cours';

  @override
  String get live => 'EN DIRECT';

  @override
  String get endNow => 'Terminer Maintenant';

  @override
  String get elapsedTime => 'Temps Écoulé';

  @override
  String get remaining => 'Restant';

  @override
  String get minutes => 'Minutes';

  @override
  String get start => 'Commencer';

  @override
  String get delay => 'Retarder';

  @override
  String get appointmentStarting => 'Début du Rendez-vous';

  @override
  String get time => 'Heure';

  @override
  String get duration => 'Durée';

  @override
  String get startAppointment => 'Commencer RDV';

  @override
  String appointmentStarted(Object petName) {
    return 'Rendez-vous commencé pour $petName';
  }

  @override
  String errorStartingAppointment(Object error) {
    return 'Erreur lors du démarrage du RDV: $error';
  }

  @override
  String get appointmentRevenue => 'Revenus du RDV';

  @override
  String howMuchEarned(Object petName) {
    return 'Combien avez-vous gagné du rendez-vous de $petName ?';
  }

  @override
  String get revenueAmount => 'Montant des Revenus';

  @override
  String get enterAmount => 'Entrez le montant (ex: 150)';

  @override
  String revenueAddedSuccessfully(Object amount) {
    return 'Revenus de $amount ajoutés avec succès !';
  }

  @override
  String get pleaseEnterValidAmount => 'Veuillez entrer un montant valide';

  @override
  String errorAddingRevenue(Object error) {
    return 'Erreur lors de l\'ajout des revenus : $error';
  }

  @override
  String get noAppointmentsFound => 'Aucun rendez-vous trouvé';

  @override
  String get yourScheduleIsClear => 'Votre planning est libre';

  @override
  String get upcomingAppointments => 'Rendez-vous à venir';

  @override
  String get completedAppointments => 'Rendez-vous terminés';

  @override
  String get cancelledAppointments => 'Rendez-vous annulés';

  @override
  String get searchPatients => 'Rechercher des patients...';

  @override
  String get activePatients => 'Patients Actifs';

  @override
  String get newThisMonth => 'Nouveaux ce Mois';

  @override
  String get myPatients => 'Mes Patients';

  @override
  String get noPatientsFound => 'Aucun patient trouvé';

  @override
  String get avgAppointmentDuration => 'Durée Moyenne des Rendez-vous';

  @override
  String get patientSatisfaction => 'Satisfaction des Patients';

  @override
  String get appointmentStatus => 'Statut Rendez-vous';

  @override
  String get appointmentCompleted => 'Rendez-vous terminé';

  @override
  String get newPatientRegistered => 'Nouveau patient enregistré';

  @override
  String get vaccinationGiven => 'Vaccination administrée';

  @override
  String get surgeryScheduled => 'Chirurgie programmée';

  @override
  String get accessDenied => 'Accès Refusé';

  @override
  String get thisPageIsOnlyAvailableForVeterinaryAccounts => 'Cette page n\'est disponible que pour les comptes vétérinaires.';

  @override
  String get overview => 'Aperçu';

  @override
  String get patients => 'Patients';

  @override
  String get analytics => 'Analyses';

  @override
  String get todaysAppoint => 'Rdv Aujourd\'hui';

  @override
  String get totalPatients => 'Total Patients';

  @override
  String get revenueToday => 'Revenus Aujourd\'hui';

  @override
  String get nextAppoint => 'Prochain Rdv';

  @override
  String get quickActions => 'Actions Rapides';

  @override
  String get scheduleAppointment => 'Programmer un RDV';

  @override
  String get addPatient => 'Ajouter Patient';

  @override
  String get viewRecords => 'Voir Dossiers';

  @override
  String get emergencyContact => 'Contact Urgence';

  @override
  String get affiliateDisclosureText => 'Ce produit est disponible grâce à notre partenariat d\'affiliation avec AliExpress. Lorsque vous effectuez un achat via ces liens, vous soutenez notre application sans coût supplémentaire pour vous. Merci de nous aider à maintenir cette application !';

  @override
  String get customerReviews => 'Avis Clients';

  @override
  String get noReviewsYet => 'Aucun avis pour le moment';

  @override
  String get beTheFirstToReviewThisProduct => 'Soyez le premier à évaluer ce produit';

  @override
  String errorLoadingReviews(Object error) {
    return 'Erreur lors du chargement des avis : $error';
  }

  @override
  String get noRelatedProductsFound => 'Aucun produit connexe trouvé';

  @override
  String get iDontHaveACreditCard => '(je n\'ai pas de carte de crédit)';

  @override
  String get howDoesItWork => 'Comment ça marche';

  @override
  String get howItWorksText => 'Vous entrez votre adresse et votre ville, puis vous vous assurez d\'envoyer MONEY_AMOUNT à cette adresse CCP 000000000000000000000000000000 puis vous envoyez la preuve de paiement à cet email payment@alifi.app, nous nous assurerons de faire expédier votre produit dès que possible';

  @override
  String get enterYourAddress => 'Entrez votre adresse';

  @override
  String get selectYourCity => 'Sélectionnez votre ville';

  @override
  String get done => 'Terminé';

  @override
  String get ordered => 'Commandé';

  @override
  String get searchProducts => 'Rechercher des produits...';

  @override
  String get searchStores => 'Rechercher des magasins...';

  @override
  String get searchVets => 'Rechercher des vétérinaires...';

  @override
  String get userProfile => 'Profil Utilisateur';

  @override
  String get storeProfile => 'Profil Magasin';

  @override
  String get vetProfile => 'Profil Vétérinaire';

  @override
  String get personalInfo => 'Informations Personnelles';

  @override
  String get contactInfo => 'Informations de Contact';

  @override
  String get accountSettings => 'Paramètres du Compte';

  @override
  String get saveChanges => 'Enregistrer les Modifications';

  @override
  String get thisActionCannotBeUndone => 'Cette action ne peut pas être annulée';

  @override
  String get accountDeleted => 'Compte supprimé';

  @override
  String errorDeletingAccount(Object error) {
    return 'Erreur lors de la suppression du compte : $error';
  }

  @override
  String get passwordChanged => 'Mot de passe changé avec succès';

  @override
  String errorChangingPassword(Object error) {
    return 'Erreur lors du changement de mot de passe : $error';
  }

  @override
  String get profileUpdated => 'Profil mis à jour avec succès';

  @override
  String errorUpdatingProfile(Object error) {
    return 'Erreur lors de la mise à jour du profil : $error';
  }

  @override
  String get currentPassword => 'Mot de Passe Actuel';

  @override
  String get newPassword => 'Nouveau Mot de Passe';

  @override
  String get confirmPassword => 'Confirmer le Mot de Passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordTooShort => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get invalidEmail => 'Adresse e-mail invalide';

  @override
  String get emailAlreadyInUse => 'E-mail déjà utilisé';

  @override
  String get weakPassword => 'Le mot de passe est trop faible';

  @override
  String get userNotFound => 'Utilisateur non trouvé';

  @override
  String get wrongPassword => 'Mot de passe incorrect';

  @override
  String get tooManyRequests => 'Trop de demandes. Veuillez réessayer plus tard';

  @override
  String get operationNotAllowed => 'Opération non autorisée';

  @override
  String get networkError => 'Erreur réseau. Veuillez vérifier votre connexion';

  @override
  String get unknownError => 'Une erreur inconnue s\'est produite';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get loading => 'Chargement...';

  @override
  String get success => 'Succès';

  @override
  String get warning => 'Avertissement';

  @override
  String get info => 'Info';

  @override
  String get searching => 'Recherche...';

  @override
  String get searchPeoplePetsVets => 'Rechercher des personnes, animaux, vétérinaires...';

  @override
  String get recommendedVetsAndStores => 'Vétérinaires et Magasins Recommandés';

  @override
  String get recentSearches => 'Recherches Récentes';

  @override
  String get noRecentSearches => 'Aucune recherche récente';

  @override
  String get trySearchingWithDifferentKeywords => 'Essayez de rechercher avec des mots-clés différents';

  @override
  String errorSearchingUsers(Object error) {
    return 'Erreur lors de la recherche d\'utilisateurs : $error';
  }

  @override
  String get myMessages => 'Mes Messages';

  @override
  String get myOrders => 'Mes Commandes';

  @override
  String get startDiscussion => 'Commencer une Discussion';

  @override
  String sendMessageToStore(Object storeName) {
    return 'Envoyer un message à $storeName';
  }

  @override
  String failedToSendMessage(Object error) {
    return 'Échec de l\'envoi du message : $error';
  }

  @override
  String get pleaseSignInToFollowUsers => 'Veuillez vous connecter pour abonner les utilisateurs';

  @override
  String errorUpdatingFollowStatus(Object error) {
    return 'Erreur lors de la mise à jour du statut de suivi : $error';
  }

  @override
  String get followers => 'Abonnés';

  @override
  String get following => 'Abonné';

  @override
  String get follow => 'Aboner';

  @override
  String get unfollow => 'Désabonner';

  @override
  String get viewInMap => 'Voir sur la map';

  @override
  String get message => 'Message';

  @override
  String get call => 'Appeler';

  @override
  String get address => 'Adresse';

  @override
  String get phone => 'Téléphone';

  @override
  String get bio => 'Bio';

  @override
  String get posts => 'Publications';

  @override
  String get photos => 'Photos';

  @override
  String get videos => 'Vidéos';

  @override
  String get friends => 'Amis';

  @override
  String get mutualFriends => 'Amis communs';

  @override
  String get shareProfile => 'Partager le profil';

  @override
  String get copyProfileLink => 'Copier le lien du profil';

  @override
  String get profileLinkCopied => 'Lien du profil copié dans le presse-papiers';

  @override
  String get errorCopyingProfileLink => 'Erreur lors de la copie du lien du profil';

  @override
  String get noPostsYet => 'Aucune publication pour le moment';

  @override
  String get noPhotosYet => 'Aucune photo pour le moment';

  @override
  String get noVideosYet => 'Aucune vidéo pour le moment';

  @override
  String get noFriendsYet => 'Aucun ami pour le moment';

  @override
  String get noMutualFriends => 'Aucun ami commun';

  @override
  String get loadingProfile => 'Chargement du profil...';

  @override
  String errorLoadingProfile(Object error) {
    return 'Erreur lors du chargement du profil : $error';
  }

  @override
  String get profileNotFound => 'Profil non trouvé';

  @override
  String get accountSuspended => 'Compte suspendu';

  @override
  String get accountPrivate => 'Ce compte est privé';

  @override
  String get followToSeeContent => 'Suivez pour voir le contenu';

  @override
  String get requestToFollow => 'Demande de suivi';

  @override
  String get requestSent => 'Demande envoyée';

  @override
  String get cancelRequest => 'Annuler la demande';

  @override
  String get acceptRequest => 'Accepter la demande';

  @override
  String get declineRequest => 'Refuser la demande';

  @override
  String get removeFollower => 'Retirer l\'abonné';

  @override
  String get muteUser => 'Muet l\'utilisateur';

  @override
  String get unmuteUser => 'Réactiver l\'utilisateur';

  @override
  String get userMuted => 'Utilisateur muet';

  @override
  String get userUnmuted => 'Utilisateur réactivé';

  @override
  String errorMutingUser(Object error) {
    return 'Erreur lors de la mise en sourdine de l\'utilisateur : $error';
  }

  @override
  String errorUnmutingUser(Object error) {
    return 'Erreur lors de la réactivation de l\'utilisateur : $error';
  }

  @override
  String get you => 'Vous';

  @override
  String get yourRecentProfileVisitsWillAppearHere => 'Vos visites de profil récentes apparaîtront ici';

  @override
  String get noProductsYet => 'Aucun produit pour le moment';

  @override
  String get noPetsYet => 'Aucun animal pour le moment';

  @override
  String get rating => 'Note';

  @override
  String get sendAMessage => 'Envoyer un message';

  @override
  String get reportAccount => 'Signaler le compte';

  @override
  String get pleaseSignInToSendMessages => 'Veuillez vous connecter pour envoyer des messages';

  @override
  String get helpUsUnderstandWhatsHappening => 'Aidez-nous à comprendre ce qui se passe';

  @override
  String get unknownUser => 'Utilisateur inconnu';

  @override
  String get whyAreYouReportingThisAccount => 'Pourquoi signalez-vous ce compte ?';

  @override
  String get submitReport => 'Soumettre le rapport';

  @override
  String get spamOrUnwantedContent => 'Spam ou contenu indésirable';

  @override
  String get inappropriateBehavior => 'Comportement inapproprié';

  @override
  String get fakeOrMisleadingInformation => 'Informations fausses ou trompeuses';

  @override
  String get harassmentOrBullying => 'Harcèlement ou intimidation';

  @override
  String get scamOrFraud => 'Arnaque ou fraude';

  @override
  String get hateSpeechOrSymbols => 'Discours de haine ou symboles';

  @override
  String get violenceOrDangerousContent => 'Violence ou contenu dangereux';

  @override
  String get intellectualPropertyViolation => 'Violation de propriété intellectuelle';

  @override
  String reportSubmittedFor(Object user) {
    return 'Signalement soumis pour $user';
  }

  @override
  String get marketplace => 'Boutique';

  @override
  String get searchItemsProducts => 'Rechercher des articles, produits...';

  @override
  String get food => 'Nourriture';

  @override
  String get toys => 'Jouets';

  @override
  String get health => 'Santé';

  @override
  String get beds => 'Lits';

  @override
  String get hygiene => 'Hygiène';

  @override
  String get mostOrders => 'Plus de Commandes';

  @override
  String get priceLowToHigh => 'Prix : Croissant';

  @override
  String get priceHighToLow => 'Prix : Décroissant';

  @override
  String get newestFirst => 'Plus Récent en Premier';

  @override
  String get sortBy => 'Trier par';

  @override
  String get allCategories => 'Toutes les Catégories';

  @override
  String get filterByCategory => 'Filtrer par Catégorie';

  @override
  String get newListings => 'Nouvelles annonces';

  @override
  String get recommended => 'Recommandé';

  @override
  String get popularProducts => 'Produits Populaires';

  @override
  String noProductsFoundFor(Object query) {
    return 'Aucun produit trouvé pour \"$query\"';
  }

  @override
  String get noRecommendedProductsAvailable => 'Aucun produit recommandé disponible';

  @override
  String get noPopularProductsAvailable => 'Aucun produit populaire disponible';

  @override
  String get viewAllVetTools => 'Voir tous les outils vétérinaires';

  @override
  String weveRaised(Object amount) {
    return 'Nous avons collecté $amount DZD !';
  }

  @override
  String get goal => 'Objectif';

  @override
  String get contribute => 'Contribuer';

  @override
  String get hiAskMeAboutAnyPetAdvice => 'Salut ! Demande-moi des conseils sur les animaux,\net je ferai de mon mieux pour t\'aider,\net ton petit compagnon !';

  @override
  String get tapToChat => 'Appuyez pour discuter...';

  @override
  String get sorryIEncounteredAnError => 'Désolé, j\'ai rencontré une erreur. Veuillez réessayer.';

  @override
  String get youMayBeInterested => 'Annonces intéressantes';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get errorLoadingProducts => 'Erreur lors du chargement des produits';

  @override
  String get noProductsAvailable => 'Aucun produit disponible';

  @override
  String get loadingCombinedProducts => 'Chargement des produits combinés...';

  @override
  String loadedAliExpressProducts(Object count) {
    return 'Chargé $count produits AliExpress';
  }

  @override
  String errorLoadingAliExpressProducts(Object error) {
    return 'Erreur lors du chargement des produits AliExpress : $error';
  }

  @override
  String loadedStoreProducts(Object count) {
    return 'Chargé $count produits du magasin';
  }

  @override
  String errorLoadingStoreProducts(Object error) {
    return 'Erreur lors du chargement des produits du magasin : $error';
  }

  @override
  String get noProductsFoundFromEitherSource => 'Aucun produit trouvé de l\'une ou l\'autre source';

  @override
  String get creatingMockDataForTesting => 'Création de données fictives pour les tests...';

  @override
  String totalCombinedProducts(Object count) {
    return 'Total des produits combinés : $count';
  }

  @override
  String errorInGetCombinedProducts(Object error) {
    return 'Erreur dans _getCombinedProducts : $error';
  }

  @override
  String get petToySet => 'Ensemble de jouets pour animaux';

  @override
  String get interactiveToysForPets => 'Jouets interactifs pour animaux';

  @override
  String get petFoodBowl => 'Bol de nourriture pour animaux';

  @override
  String get stainlessSteelFoodBowl => 'Bol de nourriture en acier inoxydable';

  @override
  String get days => 'jours';

  @override
  String get day => 'jour';

  @override
  String get hour => 'heure';

  @override
  String get hours => 'heures';

  @override
  String get minute => 'minute';

  @override
  String get justNow => 'À l\'instant';

  @override
  String get ago => 'il y a';

  @override
  String get totalAppointments => 'Total Rendez-vous';

  @override
  String get newPatients => 'Nouveaux Patients';

  @override
  String get emergencyCases => 'Cas d\'Urgence';

  @override
  String get noAppointmentsYet => 'Aucun rendez-vous encore';

  @override
  String get completed => 'Terminé';

  @override
  String get complete => 'Terminer';

  @override
  String howMuchDidYouEarnFromAppointment(Object petName) {
    return 'Combien avez-vous gagné du rendez-vous de $petName ?';
  }

  @override
  String get pleaseEnterAValidAmount => 'Veuillez entrer un montant valide';

  @override
  String revenueOfAddedSuccessfully(Object amount) {
    return 'Revenus de $amount ajoutés avec succès !';
  }

  @override
  String get markComplete => 'Marquer Terminé';

  @override
  String appointmentStartedFor(Object petName) {
    return 'Rendez-vous commencé pour $petName';
  }

  @override
  String errorCompletingAppointment(Object error) {
    return 'Erreur lors de la finalisation du RDV: $error';
  }

  @override
  String get salesAnalytics => 'Analyses des Ventes';

  @override
  String get youHaveNoProductsYet => 'Vous n\'avez pas encore de produits.';

  @override
  String get contributeWith => 'Contribuer avec :';

  @override
  String get shippingFeeApplies => 'Frais de livraison applicables';

  @override
  String deliveryInDays(Object days) {
    return 'Livraison en $days jours';
  }

  @override
  String get storeNotFound => 'Magasin non trouvé';

  @override
  String get buyAsAGift => 'Acheter en Cadeau';

  @override
  String get affiliateDisclosure => 'Divulgation d\'Affiliation';

  @override
  String get youMayBeInterestedToo => 'Vous pourriez aussi être intéressé par';

  @override
  String get contactStore => 'Contacter le Magasin';

  @override
  String get buyItForMe => 'Achetez-le pour moi';

  @override
  String get vetInformation => 'Informations Vétérinaires';

  @override
  String get petId => 'ID d\'Animal';

  @override
  String get editPets => 'Modifier les Animaux';

  @override
  String get editExistingPet => 'Modifier l\'animal existant';

  @override
  String get whatsYourPetsName => 'Quel est le nom de votre animal ?';

  @override
  String get petsName => 'Nom de l\'animal';

  @override
  String get whatBreedIsYourPet => 'Quelle est la race de votre animal ?';

  @override
  String get petsBreed => 'Race de l\'animal';

  @override
  String get selectPetType => 'Sélectionner le type d\'animal';

  @override
  String get dog => 'Chien';

  @override
  String get cat => 'Chat';

  @override
  String get selectGender => 'Sélectionner le Sexe';

  @override
  String get male => 'Mâle';

  @override
  String get female => 'Femelle';

  @override
  String get selectBirthday => 'Sélectionner l\'Anniversaire';

  @override
  String get selectWeight => 'Sélectionner le Poids';

  @override
  String get selectPhoto => 'Sélectionner la Photo';

  @override
  String get takePhoto => 'Prendre une Photo';

  @override
  String get chooseFromGallery => 'Choisir dans la Galerie';

  @override
  String get selectColor => 'Sélectionner la Couleur';

  @override
  String get kg => 'kg';

  @override
  String get lbs => 'lbs';

  @override
  String get monthsOld => 'mois';

  @override
  String get month => 'mois';

  @override
  String get months => 'mois';

  @override
  String get year => 'an';

  @override
  String get years => 'ans';

  @override
  String get pleaseFillInAllFields => 'Veuillez remplir tous les champs';

  @override
  String get startingSaveProcess => 'Début du processus de sauvegarde...';

  @override
  String get uploadingPhoto => 'Téléchargement de la photo...';

  @override
  String get savingToDatabase => 'Sauvegarde dans la base de données...';

  @override
  String errorAddingPet(Object error) {
    return 'Erreur lors de l\'ajout de l\'animal : $error';
  }

  @override
  String get vaccines => 'Vaccins';

  @override
  String get illness => 'Maladie';

  @override
  String get coreVaccines => 'Vaccins Essentiels';

  @override
  String get nonCoreVaccines => 'Vaccins Non-Essentiels';

  @override
  String get addVaccine => 'Ajouter un Vaccin';

  @override
  String get logAnIllness => 'Enregistrer une Maladie';

  @override
  String get noLoggedVaccines => 'Aucun vaccin enregistré pour cet animal';

  @override
  String get noLoggedIllnesses => 'Aucune maladie enregistrée pour cet animal';

  @override
  String get noLoggedChronicIllnesses => 'Aucune maladie chronique enregistrée pour cet animal';

  @override
  String get vaccineAdded => 'Vaccin ajouté !';

  @override
  String failedToAddVaccine(Object error) {
    return 'Échec de l\'ajout du vaccin : $error';
  }

  @override
  String get illnessAdded => 'Maladie ajoutée !';

  @override
  String failedToAddIllness(Object error) {
    return 'Échec de l\'ajout de la maladie : $error';
  }

  @override
  String get vaccineUpdated => 'Vaccin mis à jour !';

  @override
  String failedToUpdateVaccine(Object error) {
    return 'Échec de la mise à jour du vaccin : $error';
  }

  @override
  String get illnessUpdated => 'Maladie mise à jour !';

  @override
  String failedToUpdateIllness(Object error) {
    return 'Échec de la mise à jour de la maladie : $error';
  }

  @override
  String get vaccineDeleted => 'Vaccin supprimé !';

  @override
  String failedToDeleteVaccine(Object error) {
    return 'Échec de la suppression du vaccin : $error';
  }

  @override
  String get illnessDeleted => 'Maladie supprimée !';

  @override
  String failedToDeleteIllness(Object error) {
    return 'Échec de la suppression de la maladie : $error';
  }

  @override
  String get selectVaccineType => 'Sélectionner le Type de Vaccin';

  @override
  String get selectIllnessType => 'Sélectionner le Type de Maladie';

  @override
  String get addNotes => 'Ajouter des Notes';

  @override
  String get notes => 'Notes';

  @override
  String get edit => 'Modifier';

  @override
  String get chronicIllnesses => 'Maladies Chroniques';

  @override
  String get illnesses => 'Maladies';

  @override
  String get selectPetForPetId => 'Sélectionnez l\'animal pour lequel vous voulez demander l\'ID';

  @override
  String get pleaseSelectPetFirst => 'Veuillez d\'abord sélectionner un animal';

  @override
  String get petIdRequestSubmitted => 'Demande d\'ID d\'animal soumise avec succès !';

  @override
  String get yourPetIdIsBeingProcessed => 'Votre ID d\'animal est en cours de traitement et de fabrication, veuillez patienter';

  @override
  String get petIdManagement => 'Gestion des ID d\'Animaux';

  @override
  String get digitalPetIds => 'ID d\'Animaux Numériques';

  @override
  String get physicalPetIds => 'ID d\'Animaux Physiques';

  @override
  String get ready => 'Prêt';

  @override
  String get editPhysicalPetId => 'Modifier l\'ID Physique d\'Animal';

  @override
  String get customer => 'Client';

  @override
  String get status => 'Statut';

  @override
  String get processingStatus => 'En Cours';

  @override
  String get update => 'Mettre à Jour';

  @override
  String get petIdStatusUpdated => 'Statut de l\'ID d\'animal mis à jour avec succès';

  @override
  String errorUpdatingPetId(Object error) {
    return 'Erreur lors de la mise à jour de l\'ID d\'animal : $error';
  }

  @override
  String get physicalPetIdRequestSubmitted => 'Demande d\'ID physique d\'animal soumise avec succès ! Vous serez contacté pour le paiement.';

  @override
  String get requestPhysicalPetId => 'Demander un ID physique d\'animal';

  @override
  String get fullName => 'Nom Complet';

  @override
  String get phoneNumber => 'Numéro de Téléphone';

  @override
  String get zipCode => 'Code Postal';

  @override
  String get submitRequest => 'Soumettre la demande';

  @override
  String get pleaseFillAllFields => 'Veuillez remplir tous les champs';

  @override
  String errorCheckingPetIdStatus(Object error) {
    return 'Erreur lors de la vérification du statut de l\'ID d\'animal : $error';
  }

  @override
  String get age => 'Âge';

  @override
  String get weight => 'Poids';

  @override
  String get breed => 'Race';

  @override
  String get gender => 'Sexe';

  @override
  String get color => 'Couleur';

  @override
  String get species => 'Espèce';

  @override
  String get name => 'Nom';

  @override
  String resultsFound(Object count) {
    return '$count résultats trouvés';
  }

  @override
  String get whatTypeOfPetDoYouHave => 'Quel type d\'animal avez-vous ?';

  @override
  String get next => 'Suivant';

  @override
  String get petsNearMe => 'Animaux près de moi';

  @override
  String get basedOnYourCurrentLocation => 'Basé sur votre localisation actuelle';

  @override
  String get noAdoptionListingsInYourArea => 'Aucune annonce d\'adoption dans votre région';

  @override
  String get noAdoptionListingsYet => 'Aucune annonce d\'adoption pour le moment';

  @override
  String get beTheFirstToAddPetForAdoption => 'Soyez le premier à ajouter un animal à l\'adoption !';

  @override
  String get addListing => 'Ajouter une annonce';

  @override
  String get searchPets => 'Rechercher des animaux...';

  @override
  String get gettingYourLocation => 'Obtention de votre emplacement...';

  @override
  String get locationPermissionDenied => 'Permission de localisation refusée';

  @override
  String get locationPermissionPermanentlyDenied => 'Permission de localisation refusée définitivement';

  @override
  String get unableToGetLocation => 'Impossible d\'obtenir la localisation';

  @override
  String filtersApplied(Object count) {
    return 'Filtres appliqués : $count actif';
  }

  @override
  String get pleaseLoginToManageListings => 'Veuillez vous connecter pour gérer vos annonces';

  @override
  String get errorLoadingListings => 'Erreur lors du chargement des annonces';

  @override
  String get noPetsNearMe => 'Aucun animal près de moi';

  @override
  String get posting => 'Publication...';

  @override
  String get postForAdoption => 'Publier pour l\'adoption';

  @override
  String get listingTitle => 'Titre de l\'annonce';

  @override
  String get enterTitleForListing => 'Entrez un titre pour votre annonce';

  @override
  String get describePetAndAdopter => 'Décrivez votre animal et ce que vous recherchez chez un adoptant';

  @override
  String get location => 'Emplacement';

  @override
  String get enterLocationForAdoption => 'Entrez la localisation pour l\'adoption';

  @override
  String get petInformation => 'Informations sur l\'animal';

  @override
  String get listingDetails => 'Détails de l\'annonce';

  @override
  String get adoptionFee => 'Frais d\'adoption (DZD)';

  @override
  String get freeAdoption => '0 pour adoption gratuite';

  @override
  String get pleaseEnterTitle => 'Veuillez entrer un titre pour l\'annonce';

  @override
  String get pleaseEnterDescription => 'Veuillez entrer une description';

  @override
  String get pleaseEnterLocation => 'Veuillez entrer un emplacement';

  @override
  String petPostedForAdoptionSuccessfully(Object petName) {
    return '$petName a été publié pour l\'adoption avec succès !';
  }

  @override
  String failedToPostAdoptionListing(Object error) {
    return 'Échec de la publication de l\'annonce d\'adoption : $error';
  }

  @override
  String get offerForAdoption => 'Offrir à l\'adoption';

  @override
  String get deletePet => 'Supprimer l\'animal';

  @override
  String areYouSureDeletePet(Object petName) {
    return 'Êtes-vous sûr de vouloir supprimer $petName ?';
  }

  @override
  String petDeletedSuccessfully(Object petName) {
    return '$petName a été supprimé avec succès';
  }

  @override
  String failedToDeletePet(Object error) {
    return 'Échec de la suppression de l\'animal : $error';
  }

  @override
  String get myListings => 'Mes annonces';

  @override
  String get noListingsFound => 'Aucune annonce trouvée';

  @override
  String get editListing => 'Modifier l\'annonce';

  @override
  String get deleteListing => 'Supprimer l\'annonce';

  @override
  String get listingDeletedSuccessfully => 'Annonce supprimée avec succès';

  @override
  String failedToDeleteListing(Object error) {
    return 'Échec de la suppression de l\'annonce : $error';
  }

  @override
  String get areYouSureDeleteListing => 'Êtes-vous sûr de vouloir supprimer cette annonce ?';

  @override
  String get contactInformation => 'Informations de contact';

  @override
  String get postedBy => 'Publié par';

  @override
  String get contactOwner => 'Contacter le propriétaire';

  @override
  String adoptionFeeValue(Object fee) {
    return 'Frais d\'adoption : $fee DZD';
  }

  @override
  String get free => 'Gratuit';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get requirements => 'Exigences';

  @override
  String get noRequirements => 'Aucune exigence spécifique';

  @override
  String get contactNumber => 'Numéro de contact';

  @override
  String get noContactNumber => 'Aucun numéro de contact fourni';

  @override
  String get lastUpdated => 'Dernière mise à jour';

  @override
  String get createdOn => 'Créé le';

  @override
  String get adoptionListingDetails => 'Détails de l\'annonce d\'adoption';

  @override
  String get petDetails => 'Détails de l\'animal';

  @override
  String get petType => 'Type d\'animal';

  @override
  String get petAge => 'Âge';

  @override
  String get petGender => 'Sexe';

  @override
  String get petColor => 'Couleur';

  @override
  String get petWeight => 'Poids';

  @override
  String get petBreed => 'Race';

  @override
  String get petLocation => 'Localisation';

  @override
  String get petImages => 'Images';

  @override
  String get noImages => 'Aucune image disponible';

  @override
  String get viewAllImages => 'Voir toutes les images';

  @override
  String get adoptionProcess => 'Processus d\'adoption';

  @override
  String get adoptionSteps => 'Étapes d\'adoption';

  @override
  String get step1 => 'Étape 1';

  @override
  String get step2 => 'Étape 2';

  @override
  String get step3 => 'Étape 3';

  @override
  String get step4 => 'Étape 4';

  @override
  String get contactOwnerStep => 'Contacter le propriétaire';

  @override
  String get meetPetStep => 'Rencontrer l\'animal';

  @override
  String get completeAdoptionStep => 'Finaliser l\'adoption';

  @override
  String get followUpStep => 'Suivi et soins';

  @override
  String get contactOwnerDescription => 'Contactez le propriétaire de l\'animal pour exprimer votre intérêt et poser des questions sur l\'animal.';

  @override
  String get meetPetDescription => 'Organisez une rencontre en personne avec l\'animal pour vous assurer qu\'il convient à votre famille.';

  @override
  String get completeAdoptionDescription => 'Si tout se passe bien, finalisez le processus d\'adoption avec le propriétaire.';

  @override
  String get followUpDescription => 'Fournissez des soins continus et suivez avec le propriétaire si nécessaire.';

  @override
  String get adoptionTips => 'Conseils d\'adoption';

  @override
  String get adoptionTipsDescription => 'Voici quelques conseils pour vous aider dans le processus d\'adoption :';

  @override
  String get tip1 => 'Posez beaucoup de questions sur l\'historique, la santé et le comportement de l\'animal';

  @override
  String get tip2 => 'Rencontrez l\'animal en personne avant de prendre une décision';

  @override
  String get tip3 => 'Considérez votre mode de vie et votre situation de logement';

  @override
  String get tip4 => 'Soyez patient et ne vous précipitez pas dans la décision';

  @override
  String get tip5 => 'Préparez votre maison pour le nouvel animal';

  @override
  String get tip6 => 'Ayez un plan pour les soins continus et les dépenses';

  @override
  String get adoptionSuccess => 'Succès de l\'adoption';

  @override
  String get adoptionSuccessDescription => 'Félicitations pour avoir trouvé votre nouveau compagnon ! N\'oubliez pas :';

  @override
  String get successTip1 => 'Donnez à votre nouvel animal le temps de s\'adapter à son nouveau foyer';

  @override
  String get successTip2 => 'Planifiez une visite vétérinaire dans la première semaine';

  @override
  String get successTip3 => 'Mettez à jour les informations de puce si applicable';

  @override
  String get successTip4 => 'Restez en contact avec l\'ancien propriétaire si nécessaire';

  @override
  String get successTip5 => 'Fournissez beaucoup d\'amour et de patience pendant la transition';

  @override
  String get adoptionResources => 'Ressources d\'adoption';

  @override
  String get adoptionResourcesDescription => 'Voici quelques ressources utiles pour les nouveaux parents d\'animaux :';

  @override
  String get resource1 => 'Guides de soins et conseils pour animaux';

  @override
  String get resource2 => 'Recommandations de vétérinaires locaux';

  @override
  String get resource3 => 'Ressources de formation pour animaux';

  @override
  String get resource4 => 'Informations sur les soins d\'urgence';

  @override
  String get resource5 => 'Ressources de logement adapté aux animaux';

  @override
  String get adoptionSupport => 'Soutien à l\'adoption';

  @override
  String get adoptionSupportDescription => 'Besoin d\'aide pour votre adoption ? Nous sommes là pour vous soutenir :';

  @override
  String get support1 => 'Contactez notre équipe de soutien à l\'adoption';

  @override
  String get support2 => 'Rejoignez nos forums communautaires';

  @override
  String get support3 => 'Accédez aux ressources éducatives';

  @override
  String get support4 => 'Obtenez des recommandations vétérinaires';

  @override
  String get support5 => 'Trouvez des services de soins pour animaux';

  @override
  String get adoptionFaq => 'FAQ sur l\'adoption';

  @override
  String get adoptionFaqDescription => 'Questions courantes sur l\'adoption d\'animaux :';

  @override
  String get faq1 => 'Que dois-je demander au propriétaire de l\'animal ?';

  @override
  String get faq2 => 'Comment savoir si un animal me convient ?';

  @override
  String get faq3 => 'Quels documents ai-je besoin pour l\'adoption ?';

  @override
  String get faq4 => 'Combien coûte les soins d\'un animal ?';

  @override
  String get faq5 => 'Et si l\'adoption ne fonctionne pas ?';

  @override
  String get adoptionGuidelines => 'Directives d\'adoption';

  @override
  String get adoptionGuidelinesDescription => 'Veuillez suivre ces directives pour une adoption réussie :';

  @override
  String get guideline1 => 'Soyez honnête sur votre expérience et votre situation de logement';

  @override
  String get guideline2 => 'Posez des questions détaillées sur les besoins de l\'animal';

  @override
  String get guideline3 => 'Considérez l\'engagement à long terme';

  @override
  String get guideline4 => 'Ayez un plan de secours pour les urgences';

  @override
  String get guideline5 => 'Soyez respectueux du temps et de la décision du propriétaire';

  @override
  String get adoptionSafety => 'Sécurité de l\'adoption';

  @override
  String get adoptionSafetyDescription => 'Restez en sécurité pendant le processus d\'adoption :';

  @override
  String get safety1 => 'Rencontrez dans un lieu public pour la première rencontre';

  @override
  String get safety2 => 'Amenez un ami ou un membre de la famille';

  @override
  String get safety3 => 'Faites confiance à votre instinct';

  @override
  String get safety4 => 'Ne vous sentez pas pressé de prendre une décision rapide';

  @override
  String get safety5 => 'Signalez tout comportement suspect';

  @override
  String get adoptionPreparation => 'Préparation à l\'adoption';

  @override
  String get adoptionPreparationDescription => 'Préparez-vous pour votre nouvel animal :';

  @override
  String get preparation1 => 'Sécurisez votre maison pour l\'animal';

  @override
  String get preparation2 => 'Rassemblez les fournitures nécessaires';

  @override
  String get preparation3 => 'Recherchez les exigences de soins pour animaux';

  @override
  String get preparation4 => 'Planifiez les dépenses continues';

  @override
  String get preparation5 => 'Organisez les soins pour animaux quand vous êtes absent';

  @override
  String get adoptionTimeline => 'Calendrier d\'adoption';

  @override
  String get adoptionTimelineDescription => 'Calendrier typique du processus d\'adoption :';

  @override
  String get timeline1 => 'Contact initial (1-2 jours)';

  @override
  String get timeline2 => 'Rencontre et salutations (3-7 jours)';

  @override
  String get timeline3 => 'Visite à domicile (optionnel, 1-2 semaines)';

  @override
  String get timeline4 => 'Finalisation de l\'adoption (1-4 semaines)';

  @override
  String get timeline5 => 'Soins de suivi (continu)';

  @override
  String get adoptionCosts => 'Coûts d\'adoption';

  @override
  String get adoptionCostsDescription => 'Considérez ces coûts lors de l\'adoption :';

  @override
  String get cost1 => 'Frais d\'adoption (le cas échéant)';

  @override
  String get cost2 => 'Visite vétérinaire initiale et vaccinations';

  @override
  String get cost3 => 'Fournitures et équipements pour animaux';

  @override
  String get cost4 => 'Dépenses continues de nourriture et de soins';

  @override
  String get cost5 => 'Fonds de soins vétérinaires d\'urgence';

  @override
  String get adoptionBenefits => 'Avantages de l\'adoption';

  @override
  String get adoptionBenefitsDescription => 'Avantages de l\'adoption d\'un animal :';

  @override
  String get benefit1 => 'Sauvez une vie et donnez un foyer à un animal dans le besoin';

  @override
  String get benefit2 => 'Souvent plus abordable que d\'acheter chez un éleveur';

  @override
  String get benefit3 => 'De nombreux animaux adoptés sont déjà dressés';

  @override
  String get benefit4 => 'Soutenez les organisations de protection des animaux';

  @override
  String get benefit5 => 'Vivez la joie de la compagnie d\'un animal';

  @override
  String get adoptionChallenges => 'Défis de l\'adoption';

  @override
  String get adoptionChallengesDescription => 'Soyez préparé à ces défis :';

  @override
  String get challenge1 => 'Période d\'adaptation pour l\'animal';

  @override
  String get challenge2 => 'Historique de santé ou de comportement inconnu';

  @override
  String get challenge3 => 'Besoins de formation potentiels';

  @override
  String get challenge4 => 'Engagement continu de temps et d\'argent';

  @override
  String get challenge5 => 'Attachement émotionnel et responsabilité';

  @override
  String get adoptionSuccessStories => 'Histoires de succès d\'adoption';

  @override
  String get adoptionSuccessStoriesDescription => 'Lisez des histoires d\'adoption inspirantes :';

  @override
  String get story1 => 'Comment Max a trouvé sa maison pour toujours';

  @override
  String get story2 => 'Le voyage de guérison de Luna';

  @override
  String get story3 => 'La première expérience d\'adoption d\'une famille';

  @override
  String get story4 => 'Succès de l\'adoption d\'un animal âgé';

  @override
  String get story5 => 'Adoption d\'un animal avec des besoins spéciaux';

  @override
  String get adoptionCommunity => 'Communauté d\'adoption';

  @override
  String get adoptionCommunityDescription => 'Connectez-vous avec d\'autres parents d\'animaux :';

  @override
  String get community1 => 'Rejoignez des groupes d\'animaux locaux';

  @override
  String get community2 => 'Partagez votre histoire d\'adoption';

  @override
  String get community3 => 'Obtenez des conseils de propriétaires expérimentés';

  @override
  String get community4 => 'Participez à des événements pour animaux';

  @override
  String get community5 => 'Faites du bénévolat dans des refuges pour animaux';

  @override
  String get adoptionEducation => 'Éducation à l\'adoption';

  @override
  String get adoptionEducationDescription => 'En savoir plus sur l\'adoption d\'animaux :';

  @override
  String get education1 => 'Comprendre le comportement des animaux';

  @override
  String get education2 => 'Santé et nutrition des animaux';

  @override
  String get education3 => 'Formation et socialisation';

  @override
  String get education4 => 'Soins d\'urgence pour animaux';

  @override
  String get education5 => 'Loi et réglementations sur les animaux';

  @override
  String get adoptionAdvocacy => 'Plaidoyer pour l\'adoption';

  @override
  String get adoptionAdvocacyDescription => 'Aidez à promouvoir l\'adoption d\'animaux :';

  @override
  String get advocacy1 => 'Partagez des histoires d\'adoption sur les réseaux sociaux';

  @override
  String get advocacy2 => 'Faites du bénévolat dans des refuges locaux';

  @override
  String get advocacy3 => 'Donnez aux organisations de protection des animaux';

  @override
  String get advocacy4 => 'Éduquez les autres sur les avantages de l\'adoption';

  @override
  String get advocacy5 => 'Soutenez les programmes de stérilisation';

  @override
  String get adoptionMyths => 'Mythes sur l\'adoption';

  @override
  String get adoptionMythsDescription => 'Idées fausses courantes sur l\'adoption d\'animaux :';

  @override
  String get myth1 => 'Les animaux adoptés ont des problèmes de comportement';

  @override
  String get myth2 => 'Vous ne pouvez pas trouver d\'animaux de race pure à adopter';

  @override
  String get myth3 => 'Les animaux adoptés sont malsains';

  @override
  String get myth4 => 'L\'adoption est trop compliquée';

  @override
  String get myth5 => 'Les animaux adoptés ne s\'attachent pas aux nouveaux propriétaires';

  @override
  String get adoptionFacts => 'Faits sur l\'adoption';

  @override
  String get adoptionFactsDescription => 'Faits sur l\'adoption d\'animaux :';

  @override
  String get fact1 => 'Des millions d\'animaux attendent des foyers';

  @override
  String get fact2 => 'Les animaux adoptés sont souvent déjà dressés';

  @override
  String get fact3 => 'Les frais d\'adoption aident à soutenir les soins aux animaux';

  @override
  String get fact4 => 'De nombreux animaux adoptés sont en bonne santé et bien élevés';

  @override
  String get fact5 => 'L\'adoption sauve des vies et réduit la surpopulation';

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

  @override
  String get socialMedia => 'Social Media';

  @override
  String get addSocialMedia => 'Add Social Media';

  @override
  String get tiktok => 'TikTok';

  @override
  String get facebook => 'Facebook';

  @override
  String get instagram => 'Instagram';

  @override
  String get enterTikTokUsername => 'Entrez le nom d\'utilisateur TikTok';

  @override
  String get enterFacebookUsername => 'Entrez le nom d\'utilisateur Facebook';

  @override
  String get enterInstagramUsername => 'Entrez le nom d\'utilisateur Instagram';

  @override
  String get socialMediaAdded => 'Compte de réseaux sociaux ajouté avec succès !';

  @override
  String get socialMediaUpdated => 'Compte de réseaux sociaux mis à jour avec succès !';

  @override
  String get socialMediaRemoved => 'Compte de réseaux sociaux supprimé avec succès !';

  @override
  String errorUpdatingSocialMedia(Object error) {
    return 'Erreur lors de la mise à jour des réseaux sociaux : $error';
  }

  @override
  String get removeSocialMedia => 'Supprimer les réseaux sociaux';

  @override
  String get areYouSureRemoveSocialMedia => 'Êtes-vous sûr de vouloir supprimer ce compte de réseaux sociaux ?';

  @override
  String get petOwners => 'Propriétaires d\'animaux';

  @override
  String get addPetOwner => 'Ajouter un propriétaire d\'animal';

  @override
  String searchForUsersToAddAsOwners(Object petName) {
    return 'Rechercher des utilisateurs à ajouter comme propriétaires de $petName';
  }

  @override
  String get petOwnershipRequests => 'Demandes de propriété d\'animaux';

  @override
  String pendingRequests(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count demande en attente$_temp0';
  }

  @override
  String moreRequests(Object count) {
    return '+ $count autres demandes';
  }

  @override
  String wantsToCoOwn(Object petName, Object userName) {
    return '$userName veut co-posséder $petName';
  }

  @override
  String get decline => 'Refuser';

  @override
  String get requestAccepted => 'Demande acceptée';

  @override
  String get requestDeclined => 'Demande refusée';

  @override
  String ownershipRequestSent(Object userName) {
    return 'Demande de propriété envoyée à $userName';
  }

  @override
  String get errorSendingRequest => 'Erreur lors de l\'envoi de la demande';

  @override
  String get petOwnershipRequest => 'Demande de propriété d\'animal';

  @override
  String get petOwnershipRequestAccepted => 'Demande de propriété d\'animal acceptée';

  @override
  String get petOwnershipRequestDeclined => 'Demande de propriété d\'animal refusée';

  @override
  String wantsToAddYouAsOwner(Object petName, Object userName) {
    return '$userName veut vous ajouter comme propriétaire de $petName';
  }

  @override
  String get checkMyPetsPageForRequests => 'Vérifiez votre page Mes Animaux pour les demandes';

  @override
  String get createPetProfile => 'Créer un profil d\'animal';

  @override
  String get petProfileNotFound => 'Profil d\'animal introuvable';

  @override
  String get errorCreatingPetProfile => 'Erreur lors de la création du profil de l\'animal';

  @override
  String get searchForPetProfiles => 'Rechercher des profils d\'animaux...';

  @override
  String get searchForPetProfilesTitle => 'Rechercher des profils d\'animaux';

  @override
  String get findAndFollowPublicPetAccounts => 'Trouvez et suivez des comptes d\'animaux publics\nde toute la communauté';

  @override
  String get noPetProfilesFound => 'Aucun profil d\'animal trouvé';

  @override
  String get writeCaptionForPhoto => 'Écrivez une légende pour cette photo...';

  @override
  String get addCaptionToPhoto => 'Ajouter une légende à cette photo';

  @override
  String get noCaption => 'Aucune légende';

  @override
  String get captionUpdatedSuccessfully => 'Légende mise à jour avec succès !';

  @override
  String failedToUpdateCaption(Object error) {
    return 'Échec de la mise à jour de la légende : $error';
  }

  @override
  String get maxCaptionLength => 'Maximum 200 caractères';

  @override
  String get searchingPetProfiles => 'Recherche de profils d\'animaux...';

  @override
  String noResultsFoundForPetProfiles(Object query) {
    return 'Aucun résultat trouvé pour \"$query\"';
  }

  @override
  String errorSearchingPetProfiles(Object error) {
    return 'Erreur lors de la recherche de profils d\'animaux : $error';
  }

  @override
  String get authDebugInfo => 'Informations de débogage d\'authentification';

  @override
  String get maximumPhotosAllowed => 'Maximum de 4 photos autorisées';

  @override
  String get photoAddedSuccessfully => 'Photo ajoutée avec succès !';

  @override
  String failedToAddPhoto(Object error) {
    return 'Échec de l\'ajout de la photo : $error';
  }

  @override
  String get reportAsLost => 'Signaler comme perdu';

  @override
  String get youMustBeLoggedInToReportLostPet => 'Vous devez être connecté pour signaler un animal perdu';

  @override
  String get pleaseSignInToReportMissingPet => 'Veuillez vous connecter pour signaler un animal manquant';

  @override
  String get selectPetToReportMissing => 'Sélectionnez un animal à signaler comme manquant';

  @override
  String get report => 'Signaler';

  @override
  String get lb => 'lb';

  @override
  String get petName => 'Nom de l\'animal';

  @override
  String get birthday => 'Anniversaire';

  @override
  String get borderColor => 'Couleur de bordure :';

  @override
  String get pickAColor => 'Choisir une couleur';

  @override
  String get glassDistortionEffectForTabBar => 'Effet de distorsion de verre pour la barre d\'onglets';

  @override
  String get enableCustomGlassDistortionEffect => 'Activer l\'effet de distorsion de verre personnalisé qui plie le contenu pour un aspect de verre réaliste';

  @override
  String get customGlassDistortionShaderDescription => 'Shader de distorsion de verre personnalisé qui plie et déforme subtilement le contenu à l\'intérieur de la barre de navigation pour simuler la réfraction de verre réaliste. Crée un aspect de verre authentique avec des distorsions d\'onde subtiles.';

  @override
  String get tapSaveLocationToFinish => 'Appuyez sur \"Enregistrer l\'emplacement\" pour terminer';

  @override
  String get orderPlacedSuccessfully => 'Commande passée avec succès !';

  @override
  String get selectAProductToOrder => 'Sélectionnez un produit à commander';

  @override
  String get order => 'Commande';

  @override
  String storeProducts(Object storeName) {
    return 'Produits de $storeName';
  }

  @override
  String iWouldLikeToOrder(Object price, Object productName) {
    return 'Je voudrais commander : $productName - $price';
  }

  @override
  String get product => 'Produit';

  @override
  String get trySearchingWithDifferentNameOrEmail => 'Essayez de rechercher avec un nom ou un email différent';

  @override
  String get startTypingToSearchForUsers => 'Commencez à taper pour rechercher des utilisateurs';

  @override
  String get sendRequest => 'Envoyer la demande';

  @override
  String ownershipRequestSentTo(Object userName) {
    return 'Demande de propriété envoyée à $userName';
  }

  @override
  String get viewAnExample => 'Voir un exemple';

  @override
  String get requestAPetId => 'Demander un ID d\'animal';

  @override
  String get shippingInformation => 'Informations d\'expédition';

  @override
  String get pleaseEnterYourFullName => 'Veuillez entrer votre nom complet';

  @override
  String get pleaseEnterYourPhoneNumber => 'Veuillez entrer votre numéro de téléphone';

  @override
  String get pleaseEnterYourAddress => 'Veuillez entrer votre adresse';

  @override
  String get pleaseEnterYourZipCode => 'Veuillez entrer votre code postal';

  @override
  String get errorLoadingPetIdImage => 'Erreur lors du chargement de l\'image de l\'ID d\'animal';

  @override
  String get tapImageToViewFullScreen => 'Appuyez sur l\'image pour la voir en plein écran';

  @override
  String get sharePetId => 'Partager l\'ID d\'animal';

  @override
  String get physicalPetIdRequestSubmittedSuccessfully => 'Demande d\'ID physique d\'animal soumise avec succès ! Vous serez contacté pour le paiement.';

  @override
  String errorRequestingPhysicalPetId(Object error) {
    return 'Erreur lors de la demande d\'ID physique d\'animal : $error';
  }

  @override
  String get welcomeToAlifi => 'Bienvenue chez ALIFI ! Ces Conditions d\'utilisation (\"Conditions\") régissent votre utilisation de l\'application mobile et du site web ALIFI (l\'\"Application\"), exploités par ALIFI LTD (\"nous\" ou \"notre\").';

  @override
  String get alifiLtdValuesYourPrivacy => 'ALIFI LTD (\"nous\" ou \"notre\") valorise votre vie privée. Cette Politique de confidentialité décrit comment nous collectons, utilisons, divulguons et protégeons vos informations personnelles lorsque vous utilisez l\'application mobile et le site web ALIFI (collectivement, l\'\"Application\").';

  @override
  String get petAdoptionsForRehomingAnimals => 'Adoptions d\'animaux pour reloger les animaux';

  @override
  String get missingPetAnnouncements => 'Annonces d\'animaux perdus';

  @override
  String get provideAccurateAndCompleteInformation => 'Fournir des informations précises et complètes';

  @override
  String get keepYourLoginCredentialsSecure => 'Garder vos identifiants de connexion sécurisés';

  @override
  String get notifyUsImmediatelyOfUnauthorizedAccess => 'Nous notifier immédiatement de tout accès non autorisé ou activité suspecte';

  @override
  String get youAreLufi => 'Vous êtes Lufi, un assistant de soins pour animaux professionnel et conseiller vétérinaire. Votre mission principale est de fournir des conseils précis basés sur des preuves concernant la santé, le comportement, la nutrition, l\'entraînement et les soins généraux des animaux.';

  @override
  String get thisProfileWillBePublicAndVisible => 'Ce profil sera public et visible par les autres utilisateurs';

  @override
  String get createProfile => 'Créer un profil';

  @override
  String get unknownProduct => 'Produit inconnu';

  @override
  String get nullValue => 'null';

  @override
  String get letsGetYouStarted => 'Commençons !';

  @override
  String get signUpAsVetOrStore => 's\'inscrire en tant que vétérinaire ou magasin';

  @override
  String get signUpAsVet => 'S\'inscrire en tant que vétérinaire';

  @override
  String get signUpAsStore => 'S\'inscrire en tant que magasin';

  @override
  String get failedToStartApp => 'Échec du démarrage de l\'application';

  @override
  String get deleteVaccine => 'Supprimer le vaccin';

  @override
  String get deleteVaccineConfirmation => 'Êtes-vous sûr de vouloir supprimer ce vaccin ?';

  @override
  String get undo => 'Annuler';

  @override
  String get deleteIllness => 'Supprimer la maladie';

  @override
  String get deleteIllnessConfirmation => 'Êtes-vous sûr de vouloir supprimer cette maladie ?';

  @override
  String get storeOwner => 'Propriétaire de magasin';

  @override
  String get addPetForAdoption => 'Ajouter un animal à adopter';

  @override
  String get back => 'Retour';

  @override
  String get saveListing => 'Enregistrer l\'annonce';

  @override
  String get continueText => 'Continuer';

  @override
  String get basicInformation => 'Informations de base';

  @override
  String get tellUsAboutPetForAdoption => 'Parlez-nous de l\'animal que vous voulez mettre à l\'adoption';

  @override
  String get enterPetName => 'Entrez le nom de l\'animal';

  @override
  String get pleaseEnterName => 'Veuillez entrer un nom';

  @override
  String get helpPotentialAdopters => 'Aidez les adoptants potentiels à mieux comprendre l\'animal';

  @override
  String get enterBreed => 'Entrez la race';

  @override
  String get unit => 'Unité';

  @override
  String get petPhoto => 'Photo de l\'animal';

  @override
  String get clearPhotoHelpsAdopters => 'Une photo claire aide les adoptants potentiels à se connecter avec l\'animal';

  @override
  String get tapToAddPhoto => 'Appuyez pour ajouter une photo';

  @override
  String get petDocumentation => 'Documentation de l\'animal';

  @override
  String get helpAdoptersUnderstandBackground => 'Aidez les adoptants potentiels à comprendre l\'historique de l\'animal';

  @override
  String get vaccinated => 'Vacciné';

  @override
  String get microchipped => 'Pucé';

  @override
  String get houseTrained => 'Éduqué à la maison';

  @override
  String get goodWithKids => 'Bon avec les enfants';

  @override
  String get goodWithDogs => 'Bon avec les chiens';

  @override
  String get goodWithCats => 'Bon avec les chats';

  @override
  String get yourPhoneNumber => 'Votre numéro de téléphone';

  @override
  String get pleaseEnterContactNumber => 'Veuillez entrer un numéro de contact';

  @override
  String get enterLocationManually => 'Entrer l\'emplacement manuellement';

  @override
  String get manualLocation => 'Emplacement manuel';

  @override
  String get locationPermissionNotGranted => 'Permission de localisation non accordée';

  @override
  String get dr => 'Dr.';

  @override
  String get neuteredSpayed => 'Stérilisé/Stérilisée';

  @override
  String get healthIssuesOptional => 'Problèmes de santé (Optionnel)';

  @override
  String get healthIssuesPlaceholder => 'Toute condition de santé ou besoin spécial...';

  @override
  String get additionalRequirementsOptional => 'Exigences supplémentaires (Optionnel)';

  @override
  String get requirementsPlaceholder => 'Toute exigence spécifique pour les adoptants potentiels...';

  @override
  String get howCanAdoptersReachYou => 'Comment les adoptants potentiels peuvent-ils vous joindre ?';

  @override
  String get autoDetectedLocation => 'Emplacement détecté automatiquement';

  @override
  String get enterCityStateOrAddress => 'Entrez votre ville, état ou adresse';

  @override
  String get editPet => 'Modifier l\'animal';

  @override
  String get pleaseEnterPetName => 'Veuillez entrer un nom d\'animal';

  @override
  String get addPhotoOfYourPet => 'Ajoutez une photo de votre animal';

  @override
  String get chooseColorForPetProfile => 'Choisissez une couleur pour le profil de votre animal';

  @override
  String get found => 'TROUVÉ';

  @override
  String get markAsFound => 'Marquer comme trouvé ?';

  @override
  String get markAsFoundConfirmation => 'Êtes-vous sûr de vouloir marquer cet animal comme trouvé ?';

  @override
  String get trySearchingWithDifferentName => 'Essayez de rechercher avec un nom ou un email différent';

  @override
  String get startTypingToSearch => 'Commencez à taper pour rechercher des utilisateurs';

  @override
  String get placeOrder => 'Passer la commande';

  @override
  String get confirmOrder => 'Confirmer la commande';

  @override
  String get shipOrder => 'Expédier la commande';

  @override
  String get deliverOrder => 'Livrer la commande';

  @override
  String get ship => 'Expédier';

  @override
  String get deliver => 'Livrer';

  @override
  String areYouSureYouWantToOrder(Object price, Object productName, Object quantity) {
    return 'Êtes-vous sûr de vouloir commander $quantity x \"$productName\" pour $price ?';
  }

  @override
  String confirmThatYouWillFulfill(Object productName) {
    return 'Confirmez que vous allez honorer la commande pour \"$productName\" ?';
  }

  @override
  String markOrderAsShipped(Object productName) {
    return 'Marquer la commande pour \"$productName\" comme expédiée ?';
  }

  @override
  String markOrderAsDelivered(Object productName) {
    return 'Marquer la commande pour \"$productName\" comme livrée ?';
  }

  @override
  String areYouSureYouWantToCancel(Object productName) {
    return 'Êtes-vous sûr de vouloir annuler la commande pour \"$productName\" ?';
  }

  @override
  String get enterPetNameRequired => 'Entrez le nom de votre animal (Requis)';

  @override
  String get describePetFeatures => 'Décrivez votre animal - taille, couleur, caractéristiques distinctives... (Requis)';

  @override
  String get addContactNumber => 'Ajouter un numéro de contact';

  @override
  String get enterContactNumber => 'Entrez le numéro de contact';

  @override
  String get add => 'Ajouter';

  @override
  String get remove => 'Supprimer';

  @override
  String get rewardOptional => 'Récompense (Optionnel)';

  @override
  String get enterRewardAmount => 'Entrez le montant de la récompense';

  @override
  String get missingPetReportSubmitted => 'Rapport d\'animal perdu soumis';

  @override
  String get hopeYouFindPetSoon => 'Nous espérons que vous retrouverez votre animal bientôt ! La communauté sera notifiée.';

  @override
  String get couldNotGetLocation => 'Impossible d\'obtenir l\'emplacement actuel. Veuillez réessayer.';

  @override
  String get failedToReportLostPet => 'Échec du signalement de l\'animal perdu. Veuillez réessayer.';

  @override
  String get noLostPetReportFound => 'Aucun rapport d\'animal perdu trouvé pour cet animal.';

  @override
  String greatNewsMarkAsFound(Object petName) {
    return 'Bonne nouvelle ! Êtes-vous sûr de vouloir marquer $petName comme trouvé ? Cela mettra à jour le rapport d\'animal perdu.';
  }

  @override
  String petMarkedAsFound(Object petName) {
    return '$petName a été marqué comme trouvé !';
  }

  @override
  String failedToMarkAsFound(Object error) {
    return 'Échec du marquage comme trouvé : $error';
  }

  @override
  String get myPetsPatients => 'Mes Animaux (Patients)';

  @override
  String get selectProductToOrder => 'Sélectionnez un produit à commander';

  @override
  String get checkout => 'Paiement';

  @override
  String get deliveryAddress => 'Adresse de livraison';

  @override
  String get manageAddresses => 'Gérer les adresses';

  @override
  String get addAddress => 'Ajouter une adresse';

  @override
  String get youDontHaveAnyAddressesToShipTo => 'Vous n\'avez aucune adresse pour expédier';

  @override
  String get couponCode => 'Code de réduction';

  @override
  String get enterCouponCode => 'Entrez le code de réduction';

  @override
  String get apply => 'Appliquer';

  @override
  String get couponFunctionalityComingSoon => 'Fonctionnalité de réduction bientôt disponible !';

  @override
  String get orderSummary => 'Résumé de la commande';

  @override
  String subtotal(Object quantity) {
    return 'Sous-total (${quantity}x)';
  }

  @override
  String get shipping => 'Expédition';

  @override
  String get tax => 'Taxe';

  @override
  String get appFee => 'Frais d\'application';

  @override
  String get total => 'Total';

  @override
  String get addAddressToContinue => 'Ajoutez une adresse pour continuer';

  @override
  String get completePayment => 'Finaliser le paiement';

  @override
  String get choosePaymentMethod => 'Choisir la méthode de paiement';

  @override
  String get cibEpayment => 'Paiement électronique CIB';

  @override
  String get paySecurelyWithYourCibCard => 'Payez en toute sécurité avec votre carte CIB';

  @override
  String get edahabia => 'EDAHABIA';

  @override
  String get payWithYourEdahabiaCard => 'Payez avec votre carte EDAHABIA';

  @override
  String get poweredBy => 'Propulsé par';

  @override
  String get paymentOnDelivery => 'Paiement à la livraison';

  @override
  String get payWhenYourOrderArrives => 'Payez quand votre commande arrive';

  @override
  String get totalAmount => 'Montant total';

  @override
  String get selectPaymentMethod => 'Sélectionner la méthode de paiement';

  @override
  String get completeSecurePayment => 'Finaliser le paiement sécurisé';

  @override
  String get processingPayment => 'Traitement du paiement...';

  @override
  String get pleaseSelectAPaymentMethod => 'Veuillez sélectionner une méthode de paiement.';

  @override
  String paymentComingSoon(Object methodName) {
    return 'Paiement $methodName bientôt disponible !';
  }

  @override
  String errorCreatingPayment(Object error) {
    return 'Erreur lors de la création du paiement : $error';
  }

  @override
  String get paymentWasCancelled => 'Le paiement a été annulé';

  @override
  String get processingPaymentTitle => 'Traitement du paiement';

  @override
  String get pleaseWaitWhileWeVerifyYourPayment => 'Veuillez patienter pendant que nous vérifions votre paiement';

  @override
  String get verifyingPaymentStatus => 'Vérification du statut du paiement...';

  @override
  String get verifyingPayment => 'Vérification du paiement';

  @override
  String get checkingPaymentStatusManually => 'Vérification manuelle du statut du paiement';

  @override
  String get paymentVerificationTimeout => 'Délai d\'attente de vérification du paiement dépassé. Veuillez vérifier manuellement le statut de votre paiement.';

  @override
  String get paymentFailed => 'Échec du paiement';

  @override
  String errorProcessingOrder(Object error) {
    return 'Erreur lors du traitement de la commande : $error';
  }

  @override
  String paymentForProductPlusAppFee(Object productName) {
    return 'Paiement pour $productName + Frais d\'application';
  }

  @override
  String get paymentMethodCashOnDelivery => 'Méthode de paiement : Espèces à la livraison | Statut : Paiement en attente';

  @override
  String helloIJustPlacedAnOrder(Object orderId, Object productName) {
    return 'Bonjour ! Je viens de passer une commande pour $productName. Paiement à la livraison. Numéro de commande : $orderId';
  }

  @override
  String get paymentSuccessful => 'Paiement réussi !';

  @override
  String amount(Object amount) {
    return 'Montant : $amount';
  }

  @override
  String orderId(Object orderId) {
    return 'Numéro de commande : $orderId';
  }

  @override
  String get paymentProcessedSuccessfully => 'Votre paiement a été traité avec succès. Vous recevrez un email de confirmation sous peu.';

  @override
  String get continue => 'Continuer';

  @override
  String get paymentFailedTitle => 'Échec du paiement';

  @override
  String get paymentCouldNotBeProcessed => 'Votre paiement n\'a pas pu être traité. Veuillez vérifier vos détails de paiement et réessayer.';

  @override
  String get goBack => 'Retour';

  @override
  String get orderConfirmed => 'Commande confirmée !';

  @override
  String yourOrderOfHasBeenConfirmed(Object amount) {
    return 'Votre commande de $amount a été confirmée.';
  }

  @override
  String get yourOrderHasBeenConfirmed => 'Votre commande a été confirmée ! Vous paierez quand le produit sera livré à votre adresse.';

  @override
  String get backToHome => 'Retour à l\'accueil';
}
