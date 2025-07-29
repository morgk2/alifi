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
  String get aiPetAssistant => 'AI pet assistant';

  @override
  String get typeYourMessage => 'Type your message...';

  @override
  String get alifi => 'alifi';

  @override
  String get goodAfternoonUser => 'Good afternoon, user!';

  @override
  String get loadingNearbyPets => 'Loading nearby pets...';

  @override
  String get lostPetsNearby => 'Lost pets nearby';

  @override
  String get recentLostPets => 'Recent lost pets';

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
  String get error => 'Error';

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
  String get vet => 'vet';

  @override
  String get store => 'store';

  @override
  String get vetClinic => 'vet clinic';

  @override
  String get petStore => 'Pet Store';

  @override
  String get myPets => 'My Pets';

  @override
  String get addPet => 'Add Pet';

  @override
  String get editPet => 'Edit Pet';

  @override
  String get petName => 'Pet Name';

  @override
  String get petType => 'Pet Type';

  @override
  String get petBreed => 'Pet Breed';

  @override
  String get petAge => 'Pet Age';

  @override
  String get petWeight => 'Pet Weight';

  @override
  String get petColor => 'Pet Color';

  @override
  String get petGender => 'Pet Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get deletePet => 'Delete Pet';

  @override
  String get deletePetConfirmation => 'Are you sure you want to delete this pet?';

  @override
  String get petDeletedSuccessfully => 'Pet deleted successfully';

  @override
  String get petSavedSuccessfully => 'Pet saved successfully';

  @override
  String errorSavingPet(Object error) {
    return 'Error saving pet: $error';
  }

  @override
  String errorDeletingPet(Object error) {
    return 'Error deleting pet: $error';
  }

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get noImageSelected => 'No image selected';

  @override
  String get loading => 'Loading...';

  @override
  String get noPetsFound => 'No pets found';

  @override
  String get addYourFirstPet => 'Add your first pet';

  @override
  String get petDetails => 'Pet Details';

  @override
  String get petPhotos => 'Pet Photos';

  @override
  String get petMedicalHistory => 'Medical History';

  @override
  String get petVaccinations => 'Vaccinations';

  @override
  String get petMedications => 'Medications';

  @override
  String get petAllergies => 'Allergies';

  @override
  String get petBehavior => 'Behavior';

  @override
  String get petDiet => 'Diet';

  @override
  String get petExercise => 'Exercise';

  @override
  String get petGrooming => 'Grooming';

  @override
  String get petTraining => 'Training';

  @override
  String get petInsurance => 'Insurance';

  @override
  String get petMicrochip => 'Microchip';

  @override
  String get petLicense => 'License';

  @override
  String get petRegistration => 'Registration';

  @override
  String get petEmergencyContact => 'Emergency Contact';

  @override
  String get petVet => 'Veterinarian';

  @override
  String get petGroomer => 'Groomer';

  @override
  String get petTrainer => 'Trainer';

  @override
  String get petSitter => 'Pet Sitter';

  @override
  String get petWalker => 'Pet Walker';

  @override
  String get petBoarding => 'Boarding';

  @override
  String get petDaycare => 'Daycare';

  @override
  String get petAdoption => 'Adoption';

  @override
  String get petFoster => 'Foster';

  @override
  String get petRescue => 'Rescue';

  @override
  String get petShelter => 'Shelter';

  @override
  String get petBreeder => 'Breeder';

  @override
  String get petClinic => 'Clinic';

  @override
  String get petHospital => 'Hospital';

  @override
  String get petPharmacy => 'Pharmacy';

  @override
  String get petFood => 'Food';

  @override
  String get petToys => 'Toys';

  @override
  String get petBeds => 'Beds';

  @override
  String get petCrates => 'Crates';

  @override
  String get petCarriers => 'Carriers';

  @override
  String get petCollars => 'Collars';

  @override
  String get petLeashes => 'Leashes';

  @override
  String get petHarnesses => 'Harnesses';

  @override
  String get petTags => 'Tags';

  @override
  String get petClothing => 'Clothing';

  @override
  String get petShoes => 'Shoes';

  @override
  String get petAccessories => 'Accessories';

  @override
  String get petSupplies => 'Supplies';

  @override
  String get petEquipment => 'Equipment';

  @override
  String get petTools => 'Tools';

  @override
  String get petMedicine => 'Medicine';

  @override
  String get petVitamins => 'Vitamins';

  @override
  String get petSupplements => 'Supplements';

  @override
  String get petTreats => 'Treats';

  @override
  String get petSnacks => 'Snacks';

  @override
  String get petWater => 'Water';

  @override
  String get petBowl => 'Bowl';

  @override
  String get petFeeder => 'Feeder';

  @override
  String get petFountain => 'Fountain';

  @override
  String get petLitter => 'Litter';

  @override
  String get petLitterBox => 'Litter Box';

  @override
  String get petScratchingPost => 'Scratching Post';

  @override
  String get petTree => 'Cat Tree';

  @override
  String get petCage => 'Cage';

  @override
  String get petAquarium => 'Aquarium';

  @override
  String get petTerrarium => 'Terrarium';

  @override
  String get petHutch => 'Hutch';

  @override
  String get petCoop => 'Coop';

  @override
  String get petStable => 'Stable';

  @override
  String get petBarn => 'Barn';

  @override
  String get petKennel => 'Kennel';

  @override
  String get petRun => 'Run';

  @override
  String get petFence => 'Fence';

  @override
  String get petGate => 'Gate';

  @override
  String get petDoor => 'Pet Door';

  @override
  String get petRamp => 'Ramp';

  @override
  String get petStairs => 'Stairs';

  @override
  String get petElevator => 'Elevator';

  @override
  String get petEscalator => 'Escalator';

  @override
  String get petSlide => 'Slide';

  @override
  String get petSwing => 'Swing';

  @override
  String get petSeesaw => 'Seesaw';

  @override
  String get petMerryGoRound => 'Merry-go-round';

  @override
  String get petFerrisWheel => 'Ferris Wheel';

  @override
  String get petRollerCoaster => 'Roller Coaster';

  @override
  String get petCarousel => 'Carousel';

  @override
  String get petBumperCars => 'Bumper Cars';

  @override
  String get petGoKarts => 'Go-karts';

  @override
  String get petMiniGolf => 'Mini Golf';

  @override
  String get petBowling => 'Bowling';

  @override
  String get petArcade => 'Arcade';

  @override
  String get petCinema => 'Cinema';

  @override
  String get petTheater => 'Theater';

  @override
  String get petConcert => 'Concert';

  @override
  String get petFestival => 'Festival';

  @override
  String get petCarnival => 'Carnival';

  @override
  String get petCircus => 'Circus';

  @override
  String get petZoo => 'Zoo';

  @override
  String get petMuseum => 'Museum';

  @override
  String get petLibrary => 'Library';

  @override
  String get petSchool => 'School';

  @override
  String get petUniversity => 'University';

  @override
  String get petCollege => 'College';

  @override
  String get petAcademy => 'Academy';

  @override
  String get petInstitute => 'Institute';

  @override
  String get petCenter => 'Center';

  @override
  String get petFoundation => 'Foundation';

  @override
  String get petAssociation => 'Association';

  @override
  String get petSociety => 'Society';

  @override
  String get petClub => 'Club';

  @override
  String get petGroup => 'Group';

  @override
  String get petTeam => 'Team';

  @override
  String get petSquad => 'Squad';

  @override
  String get petGang => 'Gang';

  @override
  String get petPack => 'Pack';

  @override
  String get petHerd => 'Herd';

  @override
  String get petFlock => 'Flock';

  @override
  String get petSwarm => 'Swarm';

  @override
  String get petColony => 'Colony';

  @override
  String get petNest => 'Nest';

  @override
  String get petDen => 'Den';

  @override
  String get petLair => 'Lair';

  @override
  String get petCave => 'Cave';

  @override
  String get petBurrow => 'Burrow';

  @override
  String get petHole => 'Hole';

  @override
  String get petTunnel => 'Tunnel';

  @override
  String get petMaze => 'Maze';

  @override
  String get petLabyrinth => 'Labyrinth';

  @override
  String get petPuzzle => 'Puzzle';

  @override
  String get petGame => 'Game';

  @override
  String get petPlay => 'Play';

  @override
  String get petFun => 'Fun';

  @override
  String get petHappy => 'Happy';

  @override
  String get petSad => 'Sad';

  @override
  String get petAngry => 'Angry';

  @override
  String get petScared => 'Scared';

  @override
  String get petExcited => 'Excited';

  @override
  String get petCalm => 'Calm';

  @override
  String get petSleepy => 'Sleepy';

  @override
  String get petHungry => 'Hungry';

  @override
  String get petThirsty => 'Thirsty';

  @override
  String get petTired => 'Tired';

  @override
  String get petEnergetic => 'Energetic';

  @override
  String get petLazy => 'Lazy';

  @override
  String get petActive => 'Active';

  @override
  String get petQuiet => 'Quiet';

  @override
  String get petLoud => 'Loud';

  @override
  String get petNoisy => 'Noisy';

  @override
  String get petSilent => 'Silent';

  @override
  String get petTalkative => 'Talkative';

  @override
  String get petShy => 'Shy';

  @override
  String get petFriendly => 'Friendly';

  @override
  String get petAggressive => 'Aggressive';

  @override
  String get petGentle => 'Gentle';

  @override
  String get petRough => 'Rough';

  @override
  String get petSoft => 'Soft';

  @override
  String get petHard => 'Hard';

  @override
  String get petSmooth => 'Smooth';

  @override
  String get petWarm => 'Warm';

  @override
  String get petCold => 'Cold';

  @override
  String get petHot => 'Hot';

  @override
  String get petCool => 'Cool';

  @override
  String get petWet => 'Wet';

  @override
  String get petDry => 'Dry';

  @override
  String get petClean => 'Clean';

  @override
  String get petDirty => 'Dirty';

  @override
  String get petFresh => 'Fresh';

  @override
  String get petStale => 'Stale';

  @override
  String get petNew => 'New';

  @override
  String get petOld => 'Old';

  @override
  String get petYoung => 'Young';

  @override
  String get petBaby => 'Baby';

  @override
  String get petPuppy => 'Puppy';

  @override
  String get petKitten => 'Kitten';

  @override
  String get petCub => 'Cub';

  @override
  String get petChick => 'Chick';

  @override
  String get petFoal => 'Foal';

  @override
  String get petCalf => 'Calf';

  @override
  String get petLamb => 'Lamb';

  @override
  String get petKid => 'Kid';

  @override
  String get petPiglet => 'Piglet';

  @override
  String get petDuckling => 'Duckling';

  @override
  String get petGosling => 'Gosling';

  @override
  String get petCygnets => 'Cygnets';

  @override
  String get petTadpole => 'Tadpole';

  @override
  String get petFry => 'Fry';

  @override
  String get petFingerling => 'Fingerling';

  @override
  String get petSmolt => 'Smolt';

  @override
  String get petParr => 'Parr';

  @override
  String get petAlevin => 'Alevin';

  @override
  String get petSpawn => 'Spawn';

  @override
  String get petRoe => 'Roe';

  @override
  String get petCaviar => 'Caviar';

  @override
  String get petEgg => 'Egg';

  @override
  String get petLarva => 'Larva';

  @override
  String get petPupa => 'Pupa';

  @override
  String get petCaterpillar => 'Caterpillar';

  @override
  String get petChrysalis => 'Chrysalis';

  @override
  String get petCocoon => 'Cocoon';

  @override
  String get petMaggot => 'Maggot';

  @override
  String get petGrub => 'Grub';

  @override
  String get petWorm => 'Worm';

  @override
  String get petSlug => 'Slug';

  @override
  String get petSnail => 'Snail';

  @override
  String get petClam => 'Clam';

  @override
  String get petOyster => 'Oyster';

  @override
  String get petMussel => 'Mussel';

  @override
  String get petScallop => 'Scallop';

  @override
  String get petAbalone => 'Abalone';

  @override
  String get petConch => 'Conch';

  @override
  String get petWhelk => 'Whelk';

  @override
  String get petPeriwinkle => 'Periwinkle';

  @override
  String get petLimpets => 'Limpets';

  @override
  String get petBarnacles => 'Barnacles';

  @override
  String get petCrabs => 'Crabs';

  @override
  String get petLobsters => 'Lobsters';

  @override
  String get petShrimp => 'Shrimp';

  @override
  String get petPrawns => 'Prawns';

  @override
  String get petCrayfish => 'Crayfish';

  @override
  String get petKrill => 'Krill';

  @override
  String get petCopepods => 'Copepods';

  @override
  String get petAmphipods => 'Amphipods';

  @override
  String get petIsopods => 'Isopods';

  @override
  String get petOstracods => 'Ostracods';

  @override
  String get petBranchiopods => 'Branchiopods';

  @override
  String get petRemipedes => 'Remipedes';

  @override
  String get petCephalocarids => 'Cephalocarids';

  @override
  String get petMalacostracans => 'Malacostracans';

  @override
  String get petMaxillopods => 'Maxillopods';

  @override
  String get petThecostracans => 'Thecostracans';

  @override
  String get petTantulocarids => 'Tantulocarids';

  @override
  String get petMystacocarids => 'Mystacocarids';

  @override
  String get petBranchiurans => 'Branchiurans';

  @override
  String get petPentastomids => 'Pentastomids';

  @override
  String get petTardigrades => 'Tardigrades';

  @override
  String get petRotifers => 'Rotifers';

  @override
  String get petGastrotrichs => 'Gastrotrichs';

  @override
  String get petKinorhynchs => 'Kinorhynchs';

  @override
  String get petLoriciferans => 'Loriciferans';

  @override
  String get petPriapulids => 'Priapulids';

  @override
  String get petNematodes => 'Nematodes';

  @override
  String get petNematomorphs => 'Nematomorphs';

  @override
  String get petAcanthocephalans => 'Acanthocephalans';

  @override
  String get petEntoprocts => 'Entoprocts';

  @override
  String get petCycliophorans => 'Cycliophorans';

  @override
  String get petMicrognathozoans => 'Micrognathozoans';

  @override
  String get petGnathostomulids => 'Gnathostomulids';

  @override
  String get petPlatyhelminthes => 'Platyhelminthes';

  @override
  String get petCestodes => 'Cestodes';

  @override
  String get petTrematodes => 'Trematodes';

  @override
  String get petMonogeneans => 'Monogeneans';

  @override
  String get petTurbellarians => 'Turbellarians';

  @override
  String get petCatenulids => 'Catenulids';

  @override
  String get petRhabditophorans => 'Rhabditophorans';

  @override
  String get petNeodermata => 'Neodermata';

  @override
  String get petAspidogastrea => 'Aspidogastrea';

  @override
  String get petDigenea => 'Digenea';

  @override
  String get petMonopisthocotylea => 'Monopisthocotylea';

  @override
  String get petPolyopisthocotylea => 'Polyopisthocotylea';

  @override
  String get petGyrocotylidea => 'Gyrocotylidea';

  @override
  String get petAmphilinidea => 'Amphilinidea';

  @override
  String get petCaryophyllidea => 'Caryophyllidea';

  @override
  String get petDiphyllobothriidea => 'Diphyllobothriidea';

  @override
  String get petHaplobothriidea => 'Haplobothriidea';

  @override
  String get petBothriocephalidea => 'Bothriocephalidea';

  @override
  String get petLitobothriidea => 'Litobothriidea';

  @override
  String get petLecanicephalidea => 'Lecanicephalidea';

  @override
  String get petRhinebothriidea => 'Rhinebothriidea';

  @override
  String get petTetraphyllidea => 'Tetraphyllidea';

  @override
  String get petOnchoproteocephalidea => 'Onchoproteocephalidea';

  @override
  String get petProteocephalidea => 'Proteocephalidea';

  @override
  String get petTrypanorhyncha => 'Trypanorhyncha';

  @override
  String get petDiphyllidea => 'Diphyllidea';

  @override
  String get petSpathebothriidea => 'Spathebothriidea';
}
