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
  String get aiPetAssistant => 'Assistant IA ';

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
  String get pleaseEnableLocationServices => 'Veuillez activer les services de localisation ou saisir votre emplacement manuellement.';

  @override
  String get enterManually => 'Saisir manuellement';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get locationPermissionRequired => 'Autorisation de localisation requise';

  @override
  String get locationPermissionRequiredDescription => 'La permission de localisation est requise pour utiliser cette fonctionnalité. Veuillez l\'activer dans les paramètres de votre appareil.';

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
  String get authServiceInitialized => 'Service d\'authentification initialisé';

  @override
  String get authServiceLoading => 'Service d\'authentification en cours de chargement';

  @override
  String get authServiceAuthenticated => 'Service d\'authentification authentifié';

  @override
  String get authServiceUser => 'Utilisateur du service d\'authentification';

  @override
  String get firebaseUser => 'Utilisateur Firebase';

  @override
  String get guestMode => 'Mode invité';

  @override
  String get forceSignOut => 'Forcer la déconnexion';

  @override
  String get signedOutOfAllServices => 'Déconnecté de tous les services';

  @override
  String failedToGetDebugInfo(Object error) {
    return 'Échec de l\'obtention des informations de débogage : $error';
  }

  @override
  String error(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get lastSeen => 'Dernière connexion';

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
  String get vet => 'Vétérinaire';

  @override
  String get store => 'Magasin';

  @override
  String get vetClinic => 'clinique vétérinaire';

  @override
  String get petStore => 'Animalerie';

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
  String get noSubscription => 'Pas d\'abonnement';

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
  String get pleaseFillRequiredFields => 'Veuillez remplir tous les champs obligatoires';

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
  String get noUsersFound => 'Aucun utilisateur trouvé.';

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
  String get checkUp => 'Contrôle';

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
  String get paymentMethod => 'Méthode de Paiement';

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
  String get cancelOrder => 'Annuler la Commande';

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
  String get following => 'Abonnements';

  @override
  String get follow => 'Aboner';

  @override
  String get unfollow => 'désabonner';

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
  String get submitReport => 'Soumettre le signalement';

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
  String get newListings => 'Nouvelles Annonces';

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
  String get selectPetType => 'Sélectionner le Type d\'Animal';

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
  String get requestPhysicalPetId => 'Demander un ID Physique d\'Animal';

  @override
  String get fullName => 'Nom Complet';

  @override
  String get phoneNumber => 'Numéro de Téléphone';

  @override
  String get zipCode => 'Code Postal';

  @override
  String get submitRequest => 'Soumettre la Demande';

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
}
