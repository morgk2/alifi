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
  String get pleaseEnableLocationServices => 'Veuillez activer les services de localisation ou saisir votre emplacement manuellement.';

  @override
  String get enterManually => 'Saisir manuellement';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get locationPermissionRequired => 'Permission de localisation requise';

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
  String get logout => 'Déconnexion';

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
  String get error => 'Erreur';

  @override
  String get lastSeen => 'Dernière vue';

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
  String get store => 'magasin';

  @override
  String get vetClinic => 'clinique vétérinaire';

  @override
  String get petStore => 'Animalerie';

  @override
  String get myPets => 'Mes Animaux';

  @override
  String get addPet => 'Ajouter un Animal';

  @override
  String get editPet => 'Modifier l\'Animal';

  @override
  String get petName => 'Nom de l\'Animal';

  @override
  String get petType => 'Type d\'Animal';

  @override
  String get petBreed => 'Race de l\'Animal';

  @override
  String get petAge => 'Âge de l\'Animal';

  @override
  String get petWeight => 'Poids de l\'Animal';

  @override
  String get petColor => 'Couleur de l\'Animal';

  @override
  String get petGender => 'Sexe de l\'Animal';

  @override
  String get male => 'Mâle';

  @override
  String get female => 'Femelle';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get deletePet => 'Supprimer l\'Animal';

  @override
  String get deletePetConfirmation => 'Êtes-vous sûr de vouloir supprimer cet animal ?';

  @override
  String get petDeletedSuccessfully => 'Animal supprimé avec succès';

  @override
  String get petSavedSuccessfully => 'Animal enregistré avec succès';

  @override
  String errorSavingPet(Object error) {
    return 'Erreur lors de l\'enregistrement de l\'animal : $error';
  }

  @override
  String errorDeletingPet(Object error) {
    return 'Erreur lors de la suppression de l\'animal : $error';
  }

  @override
  String get camera => 'Caméra';

  @override
  String get gallery => 'Galerie';

  @override
  String get takePhoto => 'Prendre une Photo';

  @override
  String get chooseFromGallery => 'Choisir dans la Galerie';

  @override
  String get noImageSelected => 'Aucune image sélectionnée';

  @override
  String get loading => 'Chargement...';

  @override
  String get noPetsFound => 'Aucun animal trouvé';

  @override
  String get addYourFirstPet => 'Ajoutez votre premier animal';

  @override
  String get petDetails => 'Détails de l\'Animal';

  @override
  String get petPhotos => 'Photos de l\'Animal';

  @override
  String get petMedicalHistory => 'Historique Médical';

  @override
  String get petVaccinations => 'Vaccinations';

  @override
  String get petMedications => 'Médicaments';

  @override
  String get petAllergies => 'Allergies';

  @override
  String get petBehavior => 'Comportement';

  @override
  String get petDiet => 'Régime Alimentaire';

  @override
  String get petExercise => 'Exercice';

  @override
  String get petGrooming => 'Toilettage';

  @override
  String get petTraining => 'Entraînement';

  @override
  String get petInsurance => 'Assurance';

  @override
  String get petMicrochip => 'Puce Électronique';

  @override
  String get petLicense => 'Licence';

  @override
  String get petRegistration => 'Enregistrement';

  @override
  String get petEmergencyContact => 'Contact d\'Urgence';

  @override
  String get petVet => 'Vétérinaire';

  @override
  String get petGroomer => 'Toiletteur';

  @override
  String get petTrainer => 'Dresseur';

  @override
  String get petSitter => 'Garde d\'Animal';

  @override
  String get petWalker => 'Promeneur d\'Animal';

  @override
  String get petBoarding => 'Pension';

  @override
  String get petDaycare => 'Garderie';

  @override
  String get petAdoption => 'Adoption';

  @override
  String get petFoster => 'Famille d\'Accueil';

  @override
  String get petRescue => 'Sauvetage';

  @override
  String get petShelter => 'Refuge';

  @override
  String get petBreeder => 'Éleveur';

  @override
  String get petClinic => 'Clinique';

  @override
  String get petHospital => 'Hôpital';

  @override
  String get petPharmacy => 'Pharmacie';

  @override
  String get petFood => 'Nourriture';

  @override
  String get petToys => 'Jouets';

  @override
  String get petBeds => 'Lits';

  @override
  String get petCrates => 'Cages';

  @override
  String get petCarriers => 'Transporteurs';

  @override
  String get petCollars => 'Colliers';

  @override
  String get petLeashes => 'Laisse';

  @override
  String get petHarnesses => 'Harnais';

  @override
  String get petTags => 'Étiquettes';

  @override
  String get petClothing => 'Vêtements';

  @override
  String get petShoes => 'Chaussures';

  @override
  String get petAccessories => 'Accessoires';

  @override
  String get petSupplies => 'Fournitures';

  @override
  String get petEquipment => 'Équipement';

  @override
  String get petTools => 'Outils';

  @override
  String get petMedicine => 'Médecine';

  @override
  String get petVitamins => 'Vitamines';

  @override
  String get petSupplements => 'Compléments';

  @override
  String get petTreats => 'Friandises';

  @override
  String get petSnacks => 'Collations';

  @override
  String get petWater => 'Eau';

  @override
  String get petBowl => 'Bol';

  @override
  String get petFeeder => 'Distributeur';

  @override
  String get petFountain => 'Fontaine';

  @override
  String get petLitter => 'Litière';

  @override
  String get petLitterBox => 'Bac à Litière';

  @override
  String get petScratchingPost => 'Arbre à Chat';

  @override
  String get petTree => 'Arbre à Chat';

  @override
  String get petCage => 'Cage';

  @override
  String get petAquarium => 'Aquarium';

  @override
  String get petTerrarium => 'Terrarium';

  @override
  String get petHutch => 'Clapier';

  @override
  String get petCoop => 'Poulailler';

  @override
  String get petStable => 'Écurie';

  @override
  String get petBarn => 'Grange';

  @override
  String get petKennel => 'Chenil';

  @override
  String get petRun => 'Enclos';

  @override
  String get petFence => 'Clôture';

  @override
  String get petGate => 'Portail';

  @override
  String get petDoor => 'Porte pour Animal';

  @override
  String get petRamp => 'Rampe';

  @override
  String get petStairs => 'Escaliers';

  @override
  String get petElevator => 'Ascenseur';

  @override
  String get petEscalator => 'Escalier Mécanique';

  @override
  String get petSlide => 'Toboggan';

  @override
  String get petSwing => 'Balançoire';

  @override
  String get petSeesaw => 'Bascule';

  @override
  String get petMerryGoRound => 'Manège';

  @override
  String get petFerrisWheel => 'Grande Roue';

  @override
  String get petRollerCoaster => 'Montagnes Russes';

  @override
  String get petCarousel => 'Carrousel';

  @override
  String get petBumperCars => 'Autos Tamponneuses';

  @override
  String get petGoKarts => 'Karting';

  @override
  String get petMiniGolf => 'Mini Golf';

  @override
  String get petBowling => 'Bowling';

  @override
  String get petArcade => 'Salle de Jeux';

  @override
  String get petCinema => 'Cinéma';

  @override
  String get petTheater => 'Théâtre';

  @override
  String get petConcert => 'Concert';

  @override
  String get petFestival => 'Festival';

  @override
  String get petCarnival => 'Carnaval';

  @override
  String get petCircus => 'Cirque';

  @override
  String get petZoo => 'Zoo';

  @override
  String get petMuseum => 'Musée';

  @override
  String get petLibrary => 'Bibliothèque';

  @override
  String get petSchool => 'École';

  @override
  String get petUniversity => 'Université';

  @override
  String get petCollege => 'Collège';

  @override
  String get petAcademy => 'Académie';

  @override
  String get petInstitute => 'Institut';

  @override
  String get petCenter => 'Centre';

  @override
  String get petFoundation => 'Fondation';

  @override
  String get petAssociation => 'Association';

  @override
  String get petSociety => 'Société';

  @override
  String get petClub => 'Club';

  @override
  String get petGroup => 'Groupe';

  @override
  String get petTeam => 'Équipe';

  @override
  String get petSquad => 'Escouade';

  @override
  String get petGang => 'Gang';

  @override
  String get petPack => 'Meute';

  @override
  String get petHerd => 'Troupeau';

  @override
  String get petFlock => 'Troupeau';

  @override
  String get petSwarm => 'Essaim';

  @override
  String get petColony => 'Colonie';

  @override
  String get petNest => 'Nid';

  @override
  String get petDen => 'Tanière';

  @override
  String get petLair => 'Repaire';

  @override
  String get petCave => 'Grotte';

  @override
  String get petBurrow => 'Terrier';

  @override
  String get petHole => 'Trou';

  @override
  String get petTunnel => 'Tunnel';

  @override
  String get petMaze => 'Labyrinthe';

  @override
  String get petLabyrinth => 'Labyrinthe';

  @override
  String get petPuzzle => 'Puzzle';

  @override
  String get petGame => 'Jeu';

  @override
  String get petPlay => 'Jouer';

  @override
  String get petFun => 'Amusement';

  @override
  String get petHappy => 'Heureux';

  @override
  String get petSad => 'Triste';

  @override
  String get petAngry => 'En Colère';

  @override
  String get petScared => 'Effrayé';

  @override
  String get petExcited => 'Excité';

  @override
  String get petCalm => 'Calme';

  @override
  String get petSleepy => 'Somnolent';

  @override
  String get petHungry => 'Affamé';

  @override
  String get petThirsty => 'Assoiffé';

  @override
  String get petTired => 'Fatigué';

  @override
  String get petEnergetic => 'Énergique';

  @override
  String get petLazy => 'Paresseux';

  @override
  String get petActive => 'Actif';

  @override
  String get petQuiet => 'Silencieux';

  @override
  String get petLoud => 'Bruyant';

  @override
  String get petNoisy => 'Bruyant';

  @override
  String get petSilent => 'Silencieux';

  @override
  String get petTalkative => 'Bavard';

  @override
  String get petShy => 'Timide';

  @override
  String get petFriendly => 'Amical';

  @override
  String get petAggressive => 'Agressif';

  @override
  String get petGentle => 'Doux';

  @override
  String get petRough => 'Brutal';

  @override
  String get petSoft => 'Doux';

  @override
  String get petHard => 'Dur';

  @override
  String get petSmooth => 'Lisse';

  @override
  String get petWarm => 'Chaud';

  @override
  String get petCold => 'Froid';

  @override
  String get petHot => 'Chaud';

  @override
  String get petCool => 'Frais';

  @override
  String get petWet => 'Mouillé';

  @override
  String get petDry => 'Sec';

  @override
  String get petClean => 'Propre';

  @override
  String get petDirty => 'Sale';

  @override
  String get petFresh => 'Frais';

  @override
  String get petStale => 'Rassis';

  @override
  String get petNew => 'Nouveau';

  @override
  String get petOld => 'Vieux';

  @override
  String get petYoung => 'Jeune';

  @override
  String get petBaby => 'Bébé';

  @override
  String get petPuppy => 'Chiot';

  @override
  String get petKitten => 'Chaton';

  @override
  String get petCub => 'Petit';

  @override
  String get petChick => 'Poussin';

  @override
  String get petFoal => 'Poulain';

  @override
  String get petCalf => 'Veau';

  @override
  String get petLamb => 'Agneau';

  @override
  String get petKid => 'Chevreau';

  @override
  String get petPiglet => 'Porcelet';

  @override
  String get petDuckling => 'Caneton';

  @override
  String get petGosling => 'Oison';

  @override
  String get petCygnets => 'Cygneaux';

  @override
  String get petTadpole => 'Têtard';

  @override
  String get petFry => 'Alevin';

  @override
  String get petFingerling => 'Fingerling';

  @override
  String get petSmolt => 'Smolt';

  @override
  String get petParr => 'Parr';

  @override
  String get petAlevin => 'Alevin';

  @override
  String get petSpawn => 'Frai';

  @override
  String get petRoe => 'Œufs de Poisson';

  @override
  String get petCaviar => 'Caviar';

  @override
  String get petEgg => 'Œuf';

  @override
  String get petLarva => 'Larve';

  @override
  String get petPupa => 'Nymphe';

  @override
  String get petCaterpillar => 'Chenille';

  @override
  String get petChrysalis => 'Chrysalide';

  @override
  String get petCocoon => 'Cocon';

  @override
  String get petMaggot => 'Asticot';

  @override
  String get petGrub => 'Ver';

  @override
  String get petWorm => 'Ver';

  @override
  String get petSlug => 'Limace';

  @override
  String get petSnail => 'Escargot';

  @override
  String get petClam => 'Palourde';

  @override
  String get petOyster => 'Huître';

  @override
  String get petMussel => 'Moule';

  @override
  String get petScallop => 'Coquille Saint-Jacques';

  @override
  String get petAbalone => 'Ormeau';

  @override
  String get petConch => 'Conque';

  @override
  String get petWhelk => 'Buccin';

  @override
  String get petPeriwinkle => 'Bigorneau';

  @override
  String get petLimpets => 'Patelles';

  @override
  String get petBarnacles => 'Balanes';

  @override
  String get petCrabs => 'Crabes';

  @override
  String get petLobsters => 'Homards';

  @override
  String get petShrimp => 'Crevettes';

  @override
  String get petPrawns => 'Crevettes';

  @override
  String get petCrayfish => 'Écrevisse';

  @override
  String get petKrill => 'Krill';

  @override
  String get petCopepods => 'Copépodes';

  @override
  String get petAmphipods => 'Amphipodes';

  @override
  String get petIsopods => 'Isopodes';

  @override
  String get petOstracods => 'Ostracodes';

  @override
  String get petBranchiopods => 'Branchiopodes';

  @override
  String get petRemipedes => 'Rémipèdes';

  @override
  String get petCephalocarids => 'Céphalocarides';

  @override
  String get petMalacostracans => 'Malacostracés';

  @override
  String get petMaxillopods => 'Maxillopodes';

  @override
  String get petThecostracans => 'Thécostracés';

  @override
  String get petTantulocarids => 'Tantulocarides';

  @override
  String get petMystacocarids => 'Mystacocarides';

  @override
  String get petBranchiurans => 'Branchioures';

  @override
  String get petPentastomids => 'Pentastomides';

  @override
  String get petTardigrades => 'Tardigrades';

  @override
  String get petRotifers => 'Rotifères';

  @override
  String get petGastrotrichs => 'Gastrotriches';

  @override
  String get petKinorhynchs => 'Kinorhynques';

  @override
  String get petLoriciferans => 'Loricifères';

  @override
  String get petPriapulids => 'Priapuliens';

  @override
  String get petNematodes => 'Nématodes';

  @override
  String get petNematomorphs => 'Nématomorphes';

  @override
  String get petAcanthocephalans => 'Acanthocéphales';

  @override
  String get petEntoprocts => 'Entoproctes';

  @override
  String get petCycliophorans => 'Cycliophores';

  @override
  String get petMicrognathozoans => 'Micrognathozoaires';

  @override
  String get petGnathostomulids => 'Gnathostomulides';

  @override
  String get petPlatyhelminthes => 'Plathelminthes';

  @override
  String get petCestodes => 'Cestodes';

  @override
  String get petTrematodes => 'Trématodes';

  @override
  String get petMonogeneans => 'Monogènes';

  @override
  String get petTurbellarians => 'Turbellariés';

  @override
  String get petCatenulids => 'Caténulides';

  @override
  String get petRhabditophorans => 'Rhabditophores';

  @override
  String get petNeodermata => 'Néodermates';

  @override
  String get petAspidogastrea => 'Aspidogastrées';

  @override
  String get petDigenea => 'Digènes';

  @override
  String get petMonopisthocotylea => 'Monopisthocotylées';

  @override
  String get petPolyopisthocotylea => 'Polyopisthocotylées';

  @override
  String get petGyrocotylidea => 'Gyrocotylidés';

  @override
  String get petAmphilinidea => 'Amphilinidés';

  @override
  String get petCaryophyllidea => 'Caryophyllidés';

  @override
  String get petDiphyllobothriidea => 'Diphyllobothriidés';

  @override
  String get petHaplobothriidea => 'Haplobothriidés';

  @override
  String get petBothriocephalidea => 'Bothriocéphalidés';

  @override
  String get petLitobothriidea => 'Litobothriidés';

  @override
  String get petLecanicephalidea => 'Lécanicéphalidés';

  @override
  String get petRhinebothriidea => 'Rhinébothriidés';

  @override
  String get petTetraphyllidea => 'Tétraphyllidés';

  @override
  String get petOnchoproteocephalidea => 'Onchoprotéocéphalidés';

  @override
  String get petProteocephalidea => 'Protéocéphalidés';

  @override
  String get petTrypanorhyncha => 'Trypanorhynques';

  @override
  String get petDiphyllidea => 'Diphyllidés';

  @override
  String get petSpathebothriidea => 'Spathebothriidés';
}
