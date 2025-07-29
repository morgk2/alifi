// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get continueWithFacebook => 'تسجيل الدخول عبر فيسبوك';

  @override
  String get continueWithGoogle => 'تسجيل الدخول عبر جوجل';

  @override
  String get continueWithApple => 'تسجيل الدخول عبر أبل';

  @override
  String get continueAsGuest => 'الدخول كضيف';

  @override
  String get reportAProblem => 'الإبلاغ عن مشكلة';

  @override
  String get byClickingContinueYouAgreeToOur => 'بالنقر على متابعة، أنت توافق على';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get and => 'و';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get aiPetAssistant => 'مساعد الحيوانات الأليفة الذكي';

  @override
  String get typeYourMessage => 'اكتب رسالتك...';

  @override
  String get alifi => 'أليفي';

  @override
  String get goodAfternoonUser => 'مساء الخير، مستخدم!';

  @override
  String get loadingNearbyPets => 'جاري تحميل الحيوانات الأليفة القريبة...';

  @override
  String get lostPetsNearby => 'الحيوانات الأليفة المفقودة القريبة';

  @override
  String get recentLostPets => 'الحيوانات الأليفة المفقودة حديثاً';

  @override
  String get lost => 'مفقود';

  @override
  String get yearsOld => 'سنوات';

  @override
  String get description => 'الوصف';

  @override
  String get price => 'السعر';

  @override
  String get affiliatePartnership => 'شراكة تابعة';

  @override
  String get affiliatePartnershipDescription => 'هذا المنتج متاح من خلال شراكتنا التابعة مع علي إكسبرس. عند الشراء من خلال هذه الروابط، تدعم تطبيقنا دون تكلفة إضافية عليك. هذا يساعدنا في الحفاظ على خدماتنا وتحسينها.';

  @override
  String get reportFound => 'الإبلاغ عن العثور';

  @override
  String get openInMaps => 'فتح في الخرائط';

  @override
  String get contact => 'اتصال';

  @override
  String get petMarkedAsFoundSuccessfully => 'تم تمييز الحيوان الأليف كأنه تم العثور عليه بنجاح!';

  @override
  String errorMarkingPetAsFound(Object error) {
    return 'خطأ في تمييز الحيوان الأليف كأنه تم العثور عليه: $error';
  }

  @override
  String get areYouSure => 'هل أنت متأكد؟';

  @override
  String get thisWillPostYourMissingPetReport => 'سيتم نشر تقرير حيوانك الأليف المفقود في المجتمع.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get search => 'بحث';

  @override
  String get close => 'إغلاق';

  @override
  String get ok => 'موافق';

  @override
  String get proceed => 'متابعة';

  @override
  String get enterCustomAmount => 'أدخل مبلغ مخصص';

  @override
  String get locationServicesDisabled => 'خدمات الموقع معطلة';

  @override
  String get pleaseEnableLocationServices => 'يرجى تفعيل خدمات الموقع أو إدخال موقعك يدوياً.';

  @override
  String get enterManually => 'إدخال يدوي';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get locationPermissionRequired => 'إذن الموقع مطلوب';

  @override
  String get locationPermissionRequiredDescription => 'إذن الموقع مطلوب لاستخدام هذه الميزة. يرجى تفعيله في إعدادات جهازك.';

  @override
  String get enterYourLocation => 'أدخل موقعك';

  @override
  String locationSetTo(Object address) {
    return 'تم تعيين الموقع إلى: $address';
  }

  @override
  String get reportMissingPet => 'الإبلاغ عن حيوان أليف مفقود';

  @override
  String get addYourBusiness => 'أضف عملك';

  @override
  String get pleaseLoginToReportMissingPet => 'يرجى تسجيل الدخول للإبلاغ عن حيوان مفقود';

  @override
  String get thisVetIsAlreadyInDatabase => 'هذا الطبيب البيطري موجود بالفعل في قاعدة البيانات';

  @override
  String get thisStoreIsAlreadyInDatabase => 'هذا المتجر موجود بالفعل في قاعدة البيانات';

  @override
  String get addedVetClinicToMap => 'تمت إضافة العيادة البيطرية إلى الخريطة';

  @override
  String get addedPetStoreToMap => 'تمت إضافة متجر الحيوانات الأليفة إلى الخريطة';

  @override
  String errorAddingBusiness(Object error) {
    return 'خطأ في إضافة العمل: $error';
  }

  @override
  String get migrateLocations => 'ترحيل المواقع';

  @override
  String get migrateLocationsDescription => 'سيتم ترحيل جميع مواقع الحيوانات الأليفة الموجودة إلى التنسيق الجديد. لا يمكن التراجع عن هذه العملية.';

  @override
  String get migrationComplete => 'اكتمل الترحيل';

  @override
  String get migrationCompleteDescription => 'تم ترحيل جميع المواقع بنجاح إلى التنسيق الجديد.';

  @override
  String get migrationFailed => 'فشل الترحيل';

  @override
  String errorDuringMigration(Object error) {
    return 'خطأ أثناء الترحيل: $error';
  }

  @override
  String get adminDashboard => 'لوحة تحكم المدير';

  @override
  String get comingSoon => 'قريباً!';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get help => 'المساعدة';

  @override
  String get about => 'حول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get debugInfo => 'معلومات التصحيح';

  @override
  String get authServiceInitialized => 'تم تهيئة خدمة المصادقة';

  @override
  String get authServiceLoading => 'جاري تحميل خدمة المصادقة';

  @override
  String get authServiceAuthenticated => 'تم المصادقة في خدمة المصادقة';

  @override
  String get authServiceUser => 'مستخدم خدمة المصادقة';

  @override
  String get firebaseUser => 'مستخدم Firebase';

  @override
  String get guestMode => 'وضع الضيف';

  @override
  String get forceSignOut => 'إجبار تسجيل الخروج';

  @override
  String get signedOutOfAllServices => 'تم تسجيل الخروج من جميع الخدمات';

  @override
  String failedToGetDebugInfo(Object error) {
    return 'فشل في الحصول على معلومات التصحيح: $error';
  }

  @override
  String get error => 'خطأ';

  @override
  String get lastSeen => 'آخر ظهور';

  @override
  String physicalPetIdFor(Object petName) {
    return 'هوية الحيوان الأليف المادية لـ $petName';
  }

  @override
  String get priceValue => '\$20.00';

  @override
  String get hiAskMeAboutPetAdvice => 'مرحباً! اسألني عن أي نصيحة للحيوانات الأليفة،\nوسأبذل قصارى جهدي لمساعدتك ومساعدة\nصغيرك!';

  @override
  String errorGettingLocation(Object error) {
    return 'خطأ في الحصول على الموقع: $error';
  }

  @override
  String errorFindingLocation(Object error) {
    return 'خطأ في العثور على الموقع: $error';
  }

  @override
  String get vet => 'طبيب بيطري';

  @override
  String get store => 'متجر';

  @override
  String get vetClinic => 'عيادة بيطرية';

  @override
  String get petStore => 'متجر الحيوانات الأليفة';

  @override
  String get myPets => 'حيواناتي الأليفة';

  @override
  String get addPet => 'إضافة حيوان أليف';

  @override
  String get editPet => 'تعديل الحيوان الأليف';

  @override
  String get petName => 'اسم الحيوان الأليف';

  @override
  String get petType => 'نوع الحيوان الأليف';

  @override
  String get petBreed => 'سلالة الحيوان الأليف';

  @override
  String get petAge => 'عمر الحيوان الأليف';

  @override
  String get petWeight => 'وزن الحيوان الأليف';

  @override
  String get petColor => 'لون الحيوان الأليف';

  @override
  String get petGender => 'جنس الحيوان الأليف';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get deletePet => 'حذف الحيوان الأليف';

  @override
  String get deletePetConfirmation => 'هل أنت متأكد من حذف هذا الحيوان الأليف؟';

  @override
  String get petDeletedSuccessfully => 'تم حذف الحيوان الأليف بنجاح';

  @override
  String get petSavedSuccessfully => 'تم حفظ الحيوان الأليف بنجاح';

  @override
  String errorSavingPet(Object error) {
    return 'خطأ في حفظ الحيوان الأليف: $error';
  }

  @override
  String errorDeletingPet(Object error) {
    return 'خطأ في حذف الحيوان الأليف: $error';
  }

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختيار من المعرض';

  @override
  String get noImageSelected => 'لم يتم اختيار صورة';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get noPetsFound => 'لم يتم العثور على حيوانات أليفة';

  @override
  String get addYourFirstPet => 'أضف حيوانك الأليف الأول';

  @override
  String get petDetails => 'تفاصيل الحيوان الأليف';

  @override
  String get petPhotos => 'صور الحيوان الأليف';

  @override
  String get petMedicalHistory => 'التاريخ الطبي';

  @override
  String get petVaccinations => 'التطعيمات';

  @override
  String get petMedications => 'الأدوية';

  @override
  String get petAllergies => 'الحساسية';

  @override
  String get petBehavior => 'السلوك';

  @override
  String get petDiet => 'النظام الغذائي';

  @override
  String get petExercise => 'التمارين';

  @override
  String get petGrooming => 'التنظيف';

  @override
  String get petTraining => 'التدريب';

  @override
  String get petInsurance => 'التأمين';

  @override
  String get petMicrochip => 'الرقاقة الإلكترونية';

  @override
  String get petLicense => 'الترخيص';

  @override
  String get petRegistration => 'التسجيل';

  @override
  String get petEmergencyContact => 'جهة الاتصال في الطوارئ';

  @override
  String get petVet => 'الطبيب البيطري';

  @override
  String get petGroomer => 'المصفف';

  @override
  String get petTrainer => 'المدرب';

  @override
  String get petSitter => 'جليس الحيوانات الأليفة';

  @override
  String get petWalker => 'ممشى الحيوانات الأليفة';

  @override
  String get petBoarding => 'الإقامة';

  @override
  String get petDaycare => 'الحضانة';

  @override
  String get petAdoption => 'التبني';

  @override
  String get petFoster => 'الرعاية المؤقتة';

  @override
  String get petRescue => 'الإنقاذ';

  @override
  String get petShelter => 'الملجأ';

  @override
  String get petBreeder => 'المربي';

  @override
  String get petClinic => 'العيادة';

  @override
  String get petHospital => 'المستشفى';

  @override
  String get petPharmacy => 'الصيدلية';

  @override
  String get petFood => 'الطعام';

  @override
  String get petToys => 'الألعاب';

  @override
  String get petBeds => 'الأسرّة';

  @override
  String get petCrates => 'الصناديق';

  @override
  String get petCarriers => 'الحاويات';

  @override
  String get petCollars => 'الأطواق';

  @override
  String get petLeashes => 'الأحزمة';

  @override
  String get petHarnesses => 'الشدادات';

  @override
  String get petTags => 'العلامات';

  @override
  String get petClothing => 'الملابس';

  @override
  String get petShoes => 'الأحذية';

  @override
  String get petAccessories => 'الملحقات';

  @override
  String get petSupplies => 'المستلزمات';

  @override
  String get petEquipment => 'المعدات';

  @override
  String get petTools => 'الأدوات';

  @override
  String get petMedicine => 'الدواء';

  @override
  String get petVitamins => 'الفيتامينات';

  @override
  String get petSupplements => 'المكملات';

  @override
  String get petTreats => 'المكافآت';

  @override
  String get petSnacks => 'الوجبات الخفيفة';

  @override
  String get petWater => 'الماء';

  @override
  String get petBowl => 'الوعاء';

  @override
  String get petFeeder => 'المغذي';

  @override
  String get petFountain => 'النافورة';

  @override
  String get petLitter => 'الفراش';

  @override
  String get petLitterBox => 'صندوق الفضلات';

  @override
  String get petScratchingPost => 'عمود الخدش';

  @override
  String get petTree => 'شجرة القطط';

  @override
  String get petCage => 'القفص';

  @override
  String get petAquarium => 'الحوض';

  @override
  String get petTerrarium => 'التراريوم';

  @override
  String get petHutch => 'الخيمة';

  @override
  String get petCoop => 'القن';

  @override
  String get petStable => 'الإسطبل';

  @override
  String get petBarn => 'الحظيرة';

  @override
  String get petKennel => 'الكنل';

  @override
  String get petRun => 'الملعب';

  @override
  String get petFence => 'السور';

  @override
  String get petGate => 'البوابة';

  @override
  String get petDoor => 'باب الحيوان الأليف';

  @override
  String get petRamp => 'المنحدر';

  @override
  String get petStairs => 'السلالم';

  @override
  String get petElevator => 'المصعد';

  @override
  String get petEscalator => 'السلم المتحرك';

  @override
  String get petSlide => 'الزلاقة';

  @override
  String get petSwing => 'الأرجوحة';

  @override
  String get petSeesaw => 'المرجوحة';

  @override
  String get petMerryGoRound => 'دولاب الهواء';

  @override
  String get petFerrisWheel => 'عجلة فيريس';

  @override
  String get petRollerCoaster => 'سكة الحديد المعلقة';

  @override
  String get petCarousel => 'المرجوحة الدوارة';

  @override
  String get petBumperCars => 'سيارات التصادم';

  @override
  String get petGoKarts => 'الدراجات النارية الصغيرة';

  @override
  String get petMiniGolf => 'الجولف المصغر';

  @override
  String get petBowling => 'البولينج';

  @override
  String get petArcade => 'ألعاب الفيديو';

  @override
  String get petCinema => 'السينما';

  @override
  String get petTheater => 'المسرح';

  @override
  String get petConcert => 'الحفل الموسيقي';

  @override
  String get petFestival => 'المهرجان';

  @override
  String get petCarnival => 'الكرنفال';

  @override
  String get petCircus => 'السيرك';

  @override
  String get petZoo => 'الحديقة الحيوانية';

  @override
  String get petMuseum => 'المتحف';

  @override
  String get petLibrary => 'المكتبة';

  @override
  String get petSchool => 'المدرسة';

  @override
  String get petUniversity => 'الجامعة';

  @override
  String get petCollege => 'الكلية';

  @override
  String get petAcademy => 'الأكاديمية';

  @override
  String get petInstitute => 'المعهد';

  @override
  String get petCenter => 'المركز';

  @override
  String get petFoundation => 'المؤسسة';

  @override
  String get petAssociation => 'الجمعية';

  @override
  String get petSociety => 'المجتمع';

  @override
  String get petClub => 'النادي';

  @override
  String get petGroup => 'المجموعة';

  @override
  String get petTeam => 'الفريق';

  @override
  String get petSquad => 'الفرقة';

  @override
  String get petGang => 'العصابة';

  @override
  String get petPack => 'القطيع';

  @override
  String get petHerd => 'القطيع';

  @override
  String get petFlock => 'السرب';

  @override
  String get petSwarm => 'السرب';

  @override
  String get petColony => 'المستعمرة';

  @override
  String get petNest => 'العش';

  @override
  String get petDen => 'الجحر';

  @override
  String get petLair => 'الوكر';

  @override
  String get petCave => 'الكهف';

  @override
  String get petBurrow => 'الجحر';

  @override
  String get petHole => 'الحفرة';

  @override
  String get petTunnel => 'النفق';

  @override
  String get petMaze => 'المتاهة';

  @override
  String get petLabyrinth => 'المتاهة';

  @override
  String get petPuzzle => 'اللغز';

  @override
  String get petGame => 'اللعبة';

  @override
  String get petPlay => 'اللعب';

  @override
  String get petFun => 'المرح';

  @override
  String get petHappy => 'سعيد';

  @override
  String get petSad => 'حزين';

  @override
  String get petAngry => 'غاضب';

  @override
  String get petScared => 'خائف';

  @override
  String get petExcited => 'متحمس';

  @override
  String get petCalm => 'هادئ';

  @override
  String get petSleepy => 'نعسان';

  @override
  String get petHungry => 'جائع';

  @override
  String get petThirsty => 'عطشان';

  @override
  String get petTired => 'متعب';

  @override
  String get petEnergetic => 'نشط';

  @override
  String get petLazy => 'كسول';

  @override
  String get petActive => 'نشط';

  @override
  String get petQuiet => 'هادئ';

  @override
  String get petLoud => 'صاخب';

  @override
  String get petNoisy => 'صاخب';

  @override
  String get petSilent => 'صامت';

  @override
  String get petTalkative => 'ثرثار';

  @override
  String get petShy => 'خجول';

  @override
  String get petFriendly => 'ودود';

  @override
  String get petAggressive => 'عدواني';

  @override
  String get petGentle => 'لطيف';

  @override
  String get petRough => 'خشن';

  @override
  String get petSoft => 'ناعم';

  @override
  String get petHard => 'قاسي';

  @override
  String get petSmooth => 'أملس';

  @override
  String get petWarm => 'دافئ';

  @override
  String get petCold => 'بارد';

  @override
  String get petHot => 'ساخن';

  @override
  String get petCool => 'بارد';

  @override
  String get petWet => 'رطب';

  @override
  String get petDry => 'جاف';

  @override
  String get petClean => 'نظيف';

  @override
  String get petDirty => 'قذر';

  @override
  String get petFresh => 'طازج';

  @override
  String get petStale => 'قديم';

  @override
  String get petNew => 'جديد';

  @override
  String get petOld => 'قديم';

  @override
  String get petYoung => 'شاب';

  @override
  String get petBaby => 'طفل';

  @override
  String get petPuppy => 'جرو';

  @override
  String get petKitten => 'هريرة';

  @override
  String get petCub => 'شبل';

  @override
  String get petChick => 'فرخ';

  @override
  String get petFoal => 'مهر';

  @override
  String get petCalf => 'عجل';

  @override
  String get petLamb => 'خروف';

  @override
  String get petKid => 'جدي';

  @override
  String get petPiglet => 'خنزير صغير';

  @override
  String get petDuckling => 'بطة صغيرة';

  @override
  String get petGosling => 'إوزة صغيرة';

  @override
  String get petCygnets => 'بجعات صغيرة';

  @override
  String get petTadpole => 'شرغوف';

  @override
  String get petFry => 'زريعة';

  @override
  String get petFingerling => 'إصبعية';

  @override
  String get petSmolt => 'سمولت';

  @override
  String get petParr => 'بار';

  @override
  String get petAlevin => 'ألفين';

  @override
  String get petSpawn => 'بيض';

  @override
  String get petRoe => 'بيض السمك';

  @override
  String get petCaviar => 'كافيار';

  @override
  String get petEgg => 'بيضة';

  @override
  String get petLarva => 'يرقة';

  @override
  String get petPupa => 'شرنقة';

  @override
  String get petCaterpillar => 'يرقة';

  @override
  String get petChrysalis => 'شرنقة';

  @override
  String get petCocoon => 'شرنقة';

  @override
  String get petMaggot => 'يرقة';

  @override
  String get petGrub => 'يرقة';

  @override
  String get petWorm => 'دودة';

  @override
  String get petSlug => 'بزاقة';

  @override
  String get petSnail => 'حلزون';

  @override
  String get petClam => 'محار';

  @override
  String get petOyster => 'محار';

  @override
  String get petMussel => 'بلح البحر';

  @override
  String get petScallop => 'إسكالوب';

  @override
  String get petAbalone => 'أذن البحر';

  @override
  String get petConch => 'صدفة';

  @override
  String get petWhelk => 'بوق البحر';

  @override
  String get petPeriwinkle => 'بريونكل';

  @override
  String get petLimpets => 'برنقيل';

  @override
  String get petBarnacles => 'برنقيل';

  @override
  String get petCrabs => 'سرطان البحر';

  @override
  String get petLobsters => 'كركند';

  @override
  String get petShrimp => 'روبيان';

  @override
  String get petPrawns => 'جمبري';

  @override
  String get petCrayfish => 'سرطان النهر';

  @override
  String get petKrill => 'كريل';

  @override
  String get petCopepods => 'قشريات';

  @override
  String get petAmphipods => 'براغيث الماء';

  @override
  String get petIsopods => 'حشرات متساوية الأرجل';

  @override
  String get petOstracods => 'صدفيات';

  @override
  String get petBranchiopods => 'قشريات فرعيات';

  @override
  String get petRemipedes => 'حشرات مجدافية';

  @override
  String get petCephalocarids => 'رؤوسية';

  @override
  String get petMalacostracans => 'قشريات لينة';

  @override
  String get petMaxillopods => 'فكيات';

  @override
  String get petThecostracans => 'قشريات محرقة';

  @override
  String get petTantulocarids => 'تانتولوكاريد';

  @override
  String get petMystacocarids => 'مستاكوكاريد';

  @override
  String get petBranchiurans => 'خيشوميات';

  @override
  String get petPentastomids => 'خماسية الفم';

  @override
  String get petTardigrades => 'بطيئات المشية';

  @override
  String get petRotifers => 'دوارات';

  @override
  String get petGastrotrichs => 'معويات الشعر';

  @override
  String get petKinorhynchs => 'حرشفيات الفم';

  @override
  String get petLoriciferans => 'حاملات الدرع';

  @override
  String get petPriapulids => 'قضيبيات';

  @override
  String get petNematodes => 'ديدان خيطية';

  @override
  String get petNematomorphs => 'ديدان شعرية';

  @override
  String get petAcanthocephalans => 'ديدان شوكية الرأس';

  @override
  String get petEntoprocts => 'داخليات الشرج';

  @override
  String get petCycliophorans => 'دائرية الفم';

  @override
  String get petMicrognathozoans => 'صغار الفك';

  @override
  String get petGnathostomulids => 'فكيات الفم';

  @override
  String get petPlatyhelminthes => 'ديدان مسطحة';

  @override
  String get petCestodes => 'ديدان شريطية';

  @override
  String get petTrematodes => 'ديدان ماصة';

  @override
  String get petMonogeneans => 'ديدان وحيدة الجيل';

  @override
  String get petTurbellarians => 'ديدان مهدبة';

  @override
  String get petCatenulids => 'ديدان سلسلية';

  @override
  String get petRhabditophorans => 'ديدان عصوية';

  @override
  String get petNeodermata => 'جلد جديد';

  @override
  String get petAspidogastrea => 'درعيات البطن';

  @override
  String get petDigenea => 'ثنائية الجيل';

  @override
  String get petMonopisthocotylea => 'وحيدة الممص';

  @override
  String get petPolyopisthocotylea => 'متعددة الممص';

  @override
  String get petGyrocotylidea => 'دائرية الأوراق';

  @override
  String get petAmphilinidea => 'مزدوجة الخط';

  @override
  String get petCaryophyllidea => 'قرنفلية';

  @override
  String get petDiphyllobothriidea => 'ثنائية الفص';

  @override
  String get petHaplobothriidea => 'بسيطة الفص';

  @override
  String get petBothriocephalidea => 'رؤوسية الفص';

  @override
  String get petLitobothriidea => 'حجرية الفص';

  @override
  String get petLecanicephalidea => 'رؤوسية الكأس';

  @override
  String get petRhinebothriidea => 'رؤوسية الأنف';

  @override
  String get petTetraphyllidea => 'رباعية الأوراق';

  @override
  String get petOnchoproteocephalidea => 'رؤوسية الخطاف';

  @override
  String get petProteocephalidea => 'رؤوسية البروتيوس';

  @override
  String get petTrypanorhyncha => 'مثقوبة الخطاف';

  @override
  String get petDiphyllidea => 'ثنائية الأوراق';

  @override
  String get petSpathebothriidea => 'غمدية الأوراق';
}
