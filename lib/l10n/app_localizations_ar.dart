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
  String get lostPetsNearby => 'الحيوانات المفقودة القريبة';

  @override
  String get recentLostPets => 'الحيوانات المفقودة حديثاً';

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
  String get addYourBusiness => 'أضف عملك التجاري';

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
  String get french => 'Français';

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
  String error(Object error) {
    return 'خطأ: $error';
  }

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
  String get store => 'المتجر';

  @override
  String get vetClinic => 'عيادة بيطرية';

  @override
  String get petStore => 'متجر الحيوانات الأليفة';

  @override
  String get myPets => 'حيواناتي الأليفة';

  @override
  String get testNotificationsDescription => 'اختبر الإشعارات للتحقق من أنها تعمل على جهازك.';

  @override
  String get disableNotificationsTitle => 'تعطيل الإشعارات؟';

  @override
  String get disableNotificationsDescription => 'لن تتلقى إشعارات دفع بعد الآن. يمكنك إعادة تفعيلها في أي وقت.';

  @override
  String get appSettings => 'إعدادات التطبيق';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get manageYourNotifications => 'إدارة إشعاراتك';

  @override
  String get currency => 'العملة';

  @override
  String get account => 'الحساب';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get updateYourInformation => 'تحديث معلوماتك';

  @override
  String get privacyAndSecurity => 'الخصوصية والأمان';

  @override
  String get manageYourPrivacySettings => 'إدارة إعدادات الخصوصية';

  @override
  String get support => 'الدعم';

  @override
  String get helpCenter => 'مركز المساعدة';

  @override
  String get getHelpAndSupport => 'الحصول على المساعدة والدعم';

  @override
  String get reportABug => 'الإبلاغ عن خلل';

  @override
  String get helpUsImproveTheApp => 'ساعدنا على تحسين التطبيق';

  @override
  String get rateTheApp => 'قيّم التطبيق';

  @override
  String get shareYourFeedback => 'شاركنا ملاحظاتك';

  @override
  String get appVersionAndInfo => 'إصدار التطبيق والمعلومات';

  @override
  String get adminTools => 'أدوات الإدارة';

  @override
  String get addAliexpressProduct => 'إضافة منتج AliExpress';

  @override
  String get addNewProductsToTheStore => 'إضافة منتجات جديدة إلى المتجر';

  @override
  String get bulkImportProducts => 'استيراد المنتجات بالجملة';

  @override
  String get importMultipleProductsAtOnce => 'استيراد عدة منتجات دفعة واحدة';

  @override
  String get userManagement => 'إدارة المستخدمين';

  @override
  String get manageUserAccounts => 'إدارة حسابات المستخدمين';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get currentLocale => 'اللغة الحالية';

  @override
  String get localizedTextTest => 'اختبار النص المحلي';

  @override
  String get addTestAppointment => 'إضافة موعد تجريبي';

  @override
  String get createAppointmentForTesting => 'إنشاء موعد خلال ساعة ونصف للاختبار';

  @override
  String get noSubscription => 'لا يوجد اشتراك';

  @override
  String get selectCurrency => 'اختر العملة';

  @override
  String get usd => 'دولار أمريكي';

  @override
  String get dzd => 'دينار جزائري';

  @override
  String get pleaseLoginToViewNotifications => 'يرجى تسجيل الدخول لعرض الإشعارات';

  @override
  String get markAllAsRead => 'وضع علامة قراءة للكل';

  @override
  String get errorLoadingNotifications => 'خطأ في تحميل الإشعارات';

  @override
  String errorWithMessage(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noNotificationsYet => 'لا توجد إشعارات بعد';

  @override
  String get notificationsEmptyHint => 'ستظهر الإشعارات هنا عندما تتلقى رسائل أو طلبات أو متابعات';

  @override
  String get sendTestNotificationTooltip => 'إرسال إشعار تجريبي';

  @override
  String get unableToOpenChatUserNotFound => 'تعذر فتح الدردشة - المستخدم غير موجود';

  @override
  String errorOpeningChat(Object error) {
    return 'خطأ في فتح المحادثة: $error';
  }

  @override
  String get unableToOpenChatSenderMissing => 'تعذر فتح الدردشة - معلومات المرسل مفقودة';

  @override
  String get unableToOpenOrderMissing => 'تعذر فتح الطلب - معلومات الطلب مفقودة';

  @override
  String get unableToOpenProfileUserNotFound => 'تعذر فتح الملف الشخصي - المستخدم غير موجود';

  @override
  String errorOpeningProfile(Object error) {
    return 'خطأ في فتح الملف الشخصي: $error';
  }

  @override
  String get unableToOpenProfileUserMissing => 'تعذر فتح الملف الشخصي - معلومات المستخدم مفقودة';

  @override
  String get appointmentNotificationNavigationTbd => 'إشعار موعد - سيتم تنفيذ التنقل لاحقًا';

  @override
  String get notificationDeleted => 'تم حذف الإشعار';

  @override
  String errorDeletingNotification(Object error) {
    return 'خطأ في حذف الإشعار: $error';
  }

  @override
  String get allNotificationsMarkedAsRead => 'تم وضع علامة قراءة على جميع الإشعارات';

  @override
  String errorMarkingNotificationsAsRead(Object error) {
    return 'خطأ أثناء وضع علامة القراءة على الإشعارات: $error';
  }

  @override
  String testAppointmentCreated(Object id, Object time) {
    return 'تم إنشاء موعد تجريبي! المعرف: $id\nالوقت: $time';
  }

  @override
  String errorCreatingTestAppointment(Object error) {
    return 'خطأ في إنشاء الموعد التجريبي: $error';
  }

  @override
  String get noUserLoggedIn => 'لا يوجد مستخدم مسجل دخول';

  @override
  String get todaysVetAppointment => 'موعد الطبيب البيطري اليوم';

  @override
  String get soon => 'قريبًا';

  @override
  String get past => 'سابق';

  @override
  String get today => 'اليوم';

  @override
  String get pet => 'الحيوان الأليف';

  @override
  String get veterinarian => 'طبيب بيطري';

  @override
  String get notesLabel => 'ملاحظات:';

  @override
  String get unableToContactVet => 'تعذر الاتصال بالطبيب البيطري في الوقت الحالي';

  @override
  String get contactVet => 'اتصل بالطبيب البيطري';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String hoursMinutesUntilAppointment(Object hours, Object minutes) {
    return '$hoursس $minutesد حتى الموعد';
  }

  @override
  String minutesUntilAppointment(Object minutes) {
    return '$minutesد حتى الموعد';
  }

  @override
  String get appointmentStartingNow => 'الموعد يبدأ الآن!';

  @override
  String errorLoadingPets(Object error) {
    return 'خطأ في تحميل الحيوانات الأليفة: $error';
  }

  @override
  String errorLoadingTimeSlots(Object error) {
    return 'خطأ في تحميل الأوقات المتاحة: $error';
  }

  @override
  String get pleaseFillRequiredFields => 'يرجى ملء جميع الحقول المطلوبة';

  @override
  String get appointmentRequestSent => 'تم إرسال طلب الموعد بنجاح!';

  @override
  String errorBookingAppointment(Object error) {
    return 'خطأ في حجز الموعد: $error';
  }

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get selectADate => 'اختر تاريخًا';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get noAvailableTimeSlotsForThisDate => 'لا توجد أوقات متاحة لهذا التاريخ';

  @override
  String get selectPet => 'اختر الحيوان الأليف';

  @override
  String get noPetsFoundPleaseAdd => 'لم يتم العثور على حيوانات أليفة. يرجى إضافة حيوان أليف أولاً.';

  @override
  String get appointmentType => 'نوع الموعد';

  @override
  String get reasonOptional => 'السبب (اختياري)';

  @override
  String get describeAppointmentReason => 'صف سبب الموعد...';

  @override
  String get bookAppointment => 'احجز موعدًا';

  @override
  String get noPetsFound => 'لم يتم العثور على حيوانات أليفة';

  @override
  String get needToAddPetBeforeBooking => 'تحتاج إلى إضافة حيوان أليف قبل حجز موعد.';

  @override
  String get addPetCta => 'أضف حيوانًا أليفًا';

  @override
  String drName(Object name) {
    return 'د. $name';
  }

  @override
  String get searchForHelp => 'البحث عن المساعدة...';

  @override
  String get all => 'الكل';

  @override
  String get appointments => 'المواعيد';

  @override
  String get pets => 'الحيوانات الأليفة';

  @override
  String get noResultsFound => 'لم يتم العثور على نتائج';

  @override
  String get tryAdjustingSearchOrCategoryFilter => 'حاول تعديل البحث أو مرشح الفئة';

  @override
  String get stillNeedHelp => 'هل ما زلت بحاجة للمساعدة؟';

  @override
  String get contactSupportTeamForPersonalizedAssistance => 'تواصل مع فريق الدعم للحصول على مساعدة مخصصة';

  @override
  String get emailSupportComingSoon => 'دعم البريد الإلكتروني قريباً!';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get liveChatComingSoon => 'الدردشة المباشرة قريباً!';

  @override
  String get liveChat => 'الدردشة المباشرة';

  @override
  String get howToBookAppointment => 'كيف أحجز موعداً مع طبيب بيطري؟';

  @override
  String get bookAppointmentInstructions => 'لحجز موعد، اذهب إلى قسم \"البحث عن طبيب بيطري\"، ابحث عن الأطباء البيطريين في منطقتك، اختر واحداً، واضغط \"حجز موعد\". يمكنك اختيار التاريخ والوقت المفضل لديك.';

  @override
  String get howToAddPets => 'كيف أضيف حيواناتي الأليفة إلى التطبيق؟';

  @override
  String get addPetsInstructions => 'اذهب إلى \"حيواناتي الأليفة\" في التنقل السفلي، اضغط على زر \"+\"، واملأ معلومات حيوانك الأليف بما في ذلك الاسم والنوع والسلالة والعمر.';

  @override
  String get howToReportLostPet => 'كيف أبلغ عن حيوان أليف مفقود؟';

  @override
  String get reportLostPetInstructions => 'انتقل إلى قسم \"الحيوانات الأليفة المفقودة\"، اضغط \"الإبلاغ عن حيوان أليف مفقود\"، املأ التفاصيل بما في ذلك الصور والموقع ومعلومات الاتصال.';

  @override
  String get lostPets => 'الحيوانات الأليفة المفقودة';

  @override
  String get howToOrderPetSupplies => 'كيف أطلب مستلزمات الحيوانات الأليفة؟';

  @override
  String get orderPetSuppliesInstructions => 'اذهب إلى قسم \"المتجر\"، تصفح المنتجات، أضف العناصر إلى السلة، وتابع للدفع بطريقة الدفع الخاصة بك.';

  @override
  String get howToContactCustomerSupport => 'كيف أتواصل مع دعم العملاء؟';

  @override
  String get contactCustomerSupportInstructions => 'يمكنك التواصل معنا من خلال ميزة \"الإبلاغ عن خطأ\" في الإعدادات، أو راسلنا على support@alifi.com.';

  @override
  String get howToChangeAccountSettings => 'كيف أغير إعدادات حسابي؟';

  @override
  String get changeAccountSettingsInstructions => 'اذهب إلى الإعدادات، اضغط على الإعداد الذي تريد تغييره، واتبع التعليمات لتحديث معلوماتك.';

  @override
  String get howToFindVeterinariansNearMe => 'كيف أجد أطباء بيطريين بالقرب مني؟';

  @override
  String get findVeterinariansInstructions => 'استخدم ميزة \"البحث عن طبيب بيطري\" واسمح بالوصول إلى الموقع لرؤية الأطباء البيطريين في منطقتك، أو ابحث بالمدينة/الرمز البريدي.';

  @override
  String get howToCancelAppointment => 'كيف ألغي موعداً؟';

  @override
  String get cancelAppointmentInstructions => 'اذهب إلى \"مواعيدي\"، ابحث عن الموعد الذي تريد إلغاءه، اضغط عليه، واختر \"إلغاء الموعد\".';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get stayUpdatedWithImportantNotifications => 'ابق محدثاً بالإشعارات المهمة:';

  @override
  String get newMessages => 'رسائل جديدة';

  @override
  String get getNotifiedWhenSomeoneSendsMessage => 'احصل على إشعار عندما يرسل لك شخص ما رسالة';

  @override
  String get trackOrdersAndDeliveryStatus => 'تتبع طلباتك وحالة التوصيل';

  @override
  String get petCareReminders => 'تذكيرات رعاية الحيوانات الأليفة';

  @override
  String get neverMissImportantPetCareAppointments => 'لا تفوت أبداً مواعيد رعاية الحيوانات الأليفة المهمة';

  @override
  String get youCanChangeThisLaterInDeviceSettings => 'يمكنك تغيير هذا لاحقاً في إعدادات جهازك';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get enable => 'تفعيل';

  @override
  String get toReceiveNotificationsPleaseEnableInDeviceSettings => 'لتلقي الإشعارات، يرجى تفعيلها في إعدادات جهازك.';

  @override
  String errorSearchingLocation(Object error) {
    return 'خطأ في البحث عن الموقع: $error';
  }

  @override
  String errorGettingPlaceDetails(Object error) {
    return 'خطأ في الحصول على تفاصيل المكان: $error';
  }

  @override
  String errorSelectingLocation(Object error) {
    return 'خطأ في اختيار الموقع: $error';
  }

  @override
  String errorReverseGeocoding(Object error) {
    return 'خطأ في الترميز الجغرافي العكسي: $error';
  }

  @override
  String get searchLocation => 'البحث عن الموقع...';

  @override
  String get confirmLocation => 'تأكيد الموقع';

  @override
  String get giftToAFriend => 'هدية لصديق';

  @override
  String get searchByNameOrEmail => 'البحث بالاسم أو البريد الإلكتروني';

  @override
  String get searchForUsersToGift => 'البحث عن المستخدمين لإعطاء هدية.';

  @override
  String get noUsersFound => 'لم يتم العثور على مستخدمين.';

  @override
  String get noName => 'لا يوجد اسم';

  @override
  String get noEmail => 'لا يوجد بريد إلكتروني';

  @override
  String get gift => 'هدية';

  @override
  String get anonymous => 'مجهول';

  @override
  String get confirmYourGift => 'تأكيد هديتك';

  @override
  String areYouSureYouWantToGiftThisProductTo(Object userName) {
    return 'هل أنت متأكد من أنك تريد إعطاء هذه المنتج كهدية لـ $userName؟';
  }

  @override
  String get youHaveAGift => 'لديك هدية!';

  @override
  String get hasGiftedYou => 'أعطاك هدية:';

  @override
  String get refuse => 'رفض';

  @override
  String get accept => 'قبول';

  @override
  String get searchUsers => 'البحث عن المستخدمين...';

  @override
  String get typeToSearchForUsers => 'اكتب للبحث عن المستخدمين';

  @override
  String get select => 'اختر';

  @override
  String get checkUp => 'فحص';

  @override
  String get vaccination => 'تطعيم';

  @override
  String get surgery => 'جراحة';

  @override
  String get consultation => 'استشارة';

  @override
  String get emergency => 'طوارئ';

  @override
  String get followUp => 'متابعة';

  @override
  String get addPet => 'إضافة حيوان أليف';

  @override
  String get bird => 'طائر';

  @override
  String get rabbit => 'أرنب';

  @override
  String get hamster => 'هامستر';

  @override
  String get fish => 'سمك';

  @override
  String get testNotificationSent => 'تم إرسال الإشعار التجريبي!';

  @override
  String errorSendingTestNotification(Object error) {
    return 'خطأ في إرسال الإشعار التجريبي: $error';
  }

  @override
  String get notificationPreferencesSavedSuccessfully => 'تم حفظ تفضيلات الإشعارات بنجاح!';

  @override
  String errorSavingPreferences(Object error) {
    return 'خطأ في حفظ التفضيلات: $error';
  }

  @override
  String get notificationsEnabledSuccessfully => 'تم تفعيل الإشعارات بنجاح!';

  @override
  String errorRequestingPermission(Object error) {
    return 'خطأ في طلب الإذن: $error';
  }

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get pushNotifications => 'إشعارات الدفع';

  @override
  String get notificationsEnabled => 'مفعل';

  @override
  String get notificationsDisabled => 'معطل';

  @override
  String get generalSettings => 'الإعدادات العامة';

  @override
  String get sound => 'الصوت';

  @override
  String get playSoundForNotifications => 'تشغيل الصوت للإشعارات';

  @override
  String get vibration => 'الاهتزاز';

  @override
  String get vibrateDeviceForNotifications => 'اهتزاز الجهاز للإشعارات';

  @override
  String get emailNotifications => 'إشعارات البريد الإلكتروني';

  @override
  String get receiveNotificationsViaEmail => 'تلقي الإشعارات عبر البريد الإلكتروني';

  @override
  String get quietHours => 'الساعات الهادئة';

  @override
  String get enableQuietHours => 'تمكين الساعات الهادئة';

  @override
  String get muteNotificationsDuringSpecifiedHours => 'كتم الإشعارات خلال الساعات المحددة';

  @override
  String get startTime => 'وقت البدء';

  @override
  String get endTime => 'وقت الانتهاء';

  @override
  String get notificationTypes => 'أنواع الإشعارات';

  @override
  String get chatMessages => 'رسائل الدردشة';

  @override
  String get newMessagesFromOtherUsers => 'رسائل جديدة من المستخدمين الآخرين';

  @override
  String get orderUpdates => 'تحديثات الطلبات';

  @override
  String get orderStatusChangesAndUpdates => 'تغييرات وتحديثات حالة الطلب';

  @override
  String get appointmentRequestsAndReminders => 'طلبات المواعيد والتذكيرات';

  @override
  String get socialActivity => 'النشاط الاجتماعي';

  @override
  String get newFollowersAndSocialInteractions => 'متابعون جدد وتفاعلات اجتماعية';

  @override
  String get testNotifications => 'اختبار الإشعارات';

  @override
  String get sendTestNotification => 'إرسال إشعار تجريبي';

  @override
  String get savePreferences => 'حفظ التفضيلات';

  @override
  String get disable => 'تعطيل';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get user => 'المستخدم';

  @override
  String get noLostPetsReportedNearby => 'لا توجد حيوانات مفقودة تم الإبلاغ عنها قريباً';

  @override
  String get weWillNotifyYouWhenPetsAreReported => 'سنخطرك عندما يتم الإبلاغ عن حيوانات في منطقتك';

  @override
  String get noRecentLostPetsReported => 'لا توجد حيوانات مفقودة حديثاً تم الإبلاغ عنها';

  @override
  String get enableLocationToSeePetsInYourArea => 'تفعيل الموقع لرؤية الحيوانات في منطقتك';

  @override
  String get navigate => 'التنقل';

  @override
  String get open => 'مفتوح';

  @override
  String get closed => 'مغلق';

  @override
  String get openNow => 'مفتوح الآن';

  @override
  String get visitClinicProfile => 'زيارة ملف العيادة';

  @override
  String get visitStoreProfile => 'زيارة ملف المتجر';

  @override
  String get alifiFavorite => 'مفضل Alifi';

  @override
  String get alifiAffiliated => 'شريك Alifi';

  @override
  String get pleaseEnableLocationServicesOrEnterManually => 'يرجى تفعيل خدمات الموقع أو إدخال موقعك يدوياً.';

  @override
  String get locationPermissionRequiredForFeature => 'إذن الموقع مطلوب لهذه الميزة. يرجى تفعيله في إعدادات التطبيق.';

  @override
  String get unknown => 'غير معروف';

  @override
  String get addYourFirstPet => 'أضف حيوانك الأليف الأول';

  @override
  String get healthInformation => 'معلومات الصحة';

  @override
  String get snake => 'ثعبان';

  @override
  String get lizard => 'سحلية';

  @override
  String get guineaPig => 'خنزير غينيا';

  @override
  String get ferret => 'ابن مقرض';

  @override
  String get turtle => 'سلحفاة';

  @override
  String get parrot => 'ببغاء';

  @override
  String get mouse => 'فأر';

  @override
  String get rat => 'جرذ';

  @override
  String get hedgehog => 'قنفذ';

  @override
  String get chinchilla => 'شنشيلا';

  @override
  String get gerbil => 'جربوع';

  @override
  String get duck => 'بطة';

  @override
  String get monkey => 'قرد';

  @override
  String get selected => 'مُختار';

  @override
  String get notSelected => 'غير مُختار';

  @override
  String get appNotResponding => 'التطبيق لا يستجيب';

  @override
  String get loginIssues => 'مشاكل تسجيل الدخول';

  @override
  String get paymentProblems => 'مشاكل الدفع';

  @override
  String get accountAccess => 'الوصول للحساب';

  @override
  String get missingFeatures => 'ميزات مفقودة';

  @override
  String get petListingIssues => 'مشاكل قائمة الحيوانات الأليفة';

  @override
  String get mapNotWorking => 'الخريطة لا تعمل';

  @override
  String get inappropriateContent => 'محتوى غير مناسب';

  @override
  String get technicalProblems => 'مشاكل تقنية';

  @override
  String get other => 'آخر';

  @override
  String get selectProblemType => 'اختر نوع المشكلة';

  @override
  String get submit => 'إرسال';

  @override
  String get display => 'العرض';

  @override
  String get interface => 'الواجهة';

  @override
  String get useBlurEffectForTabBar => 'استخدام تأثير الضبابية لشريط التبويب';

  @override
  String get enableGlassLikeBlurEffectOnNavigationBar => 'تفعيل تأثير الضبابية الزجاجي على شريط التنقل';

  @override
  String get whenDisabledTabBarWillHaveSolidWhiteBackground => 'عند التعطيل، سيكون لشريط التبويب خلفية بيضاء صلبة بدلاً من تأثير الضبابية الزجاجي.';

  @override
  String get customizeAppAppearanceAndInterface => 'تخصيص مظهر التطبيق والواجهة';

  @override
  String get save => 'حفظ';

  @override
  String get tapToChangePhoto => 'انقر لتغيير الصورة';

  @override
  String get coverPhotoOptional => 'صورة الغلاف (اختياري)';

  @override
  String get changeCover => 'تغيير الغلاف';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get enterUsername => 'أدخل اسم المستخدم';

  @override
  String get usernameCannotBeEmpty => 'اسم المستخدم لا يمكن أن يكون فارغاً';

  @override
  String get invalidUsername => 'اسم مستخدم غير صحيح (3-20 حرف، أحرف، أرقام، _)';

  @override
  String get displayName => 'اسم العرض';

  @override
  String get enterDisplayName => 'أدخل اسم العرض';

  @override
  String get displayNameCannotBeEmpty => 'اسم العرض لا يمكن أن يكون فارغاً';

  @override
  String get professionalInfo => 'المعلومات المهنية';

  @override
  String get enterYourQualificationsExperience => 'أدخل مؤهلاتك وخبراتك، إلخ.';

  @override
  String get accountType => 'نوع الحساب';

  @override
  String get requestToBeAVet => 'طلب أن تكون طبيب بيطري';

  @override
  String get joinOurVeterinaryNetwork => 'انضم إلى شبكتنا البيطرية';

  @override
  String get requestToBeAStore => 'طلب أن تكون متجر';

  @override
  String get sellPetProductsAndServices => 'بيع منتجات وخدمات الحيوانات الأليفة';

  @override
  String get linkedAccounts => 'الحسابات المرتبطة';

  @override
  String get linked => 'مرتبط';

  @override
  String get link => 'ربط';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get areYouSureYouWantToDeleteYourAccount => 'هل أنت متأكد من أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get delete => 'حذف';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح!';

  @override
  String failedToUpdateProfile(Object error) {
    return 'فشل في تحديث الملف الشخصي: $error';
  }

  @override
  String errorSelectingCover(Object error) {
    return 'خطأ في اختيار الغلاف: $error';
  }

  @override
  String get savingChanges => 'حفظ التغييرات...';

  @override
  String get locationSharing => 'مشاركة الموقع';

  @override
  String get allowAppToAccessYourLocation => 'السماح للتطبيق بالوصول إلى موقعك للخدمات القريبة';

  @override
  String get dataAnalytics => 'تحليلات البيانات';

  @override
  String get helpUsImproveBySharingAnonymousUsageData => 'ساعدنا في التحسين من خلال مشاركة بيانات الاستخدام المجهولة';

  @override
  String get profileVisibility => 'رؤية الملف الشخصي';

  @override
  String get controlWhoCanSeeYourProfileInformation => 'تحكم في من يمكنه رؤية معلومات ملفك الشخصي';

  @override
  String get dataAndPrivacy => 'البيانات والخصوصية';

  @override
  String get manageYourDataAndPrivacySettings => 'إدارة بياناتك وإعدادات الخصوصية.';

  @override
  String get receiveNotificationsAboutAppointmentsAndUpdates => 'استقبال إشعارات حول المواعيد والتحديثات';

  @override
  String get receiveImportantUpdatesViaEmail => 'استقبال التحديثات المهمة عبر البريد الإلكتروني';

  @override
  String get notificationPreferences => 'تفضيلات الإشعارات';

  @override
  String get customizeWhatNotificationsYouReceive => 'تخصيص الإشعارات التي تستقبلها.';

  @override
  String get security => 'الأمان';

  @override
  String get biometricAuthentication => 'المصادقة البيومترية';

  @override
  String get useFingerprintOrFaceIdToUnlockTheApp => 'استخدام البصمة أو معرف الوجه لفتح التطبيق';

  @override
  String get twoFactorAuthentication => 'المصادقة الثنائية';

  @override
  String get addAnExtraLayerOfSecurityToYourAccount => 'إضافة طبقة أمان إضافية لحسابك';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get updateYourAccountPassword => 'تحديث كلمة مرور حسابك';

  @override
  String get activeSessions => 'الجلسات النشطة';

  @override
  String get manageDevicesLoggedIntoYourAccount => 'إدارة الأجهزة المسجلة في حسابك.';

  @override
  String get dataAndStorage => 'البيانات والتخزين';

  @override
  String get storageUsage => 'استخدام التخزين';

  @override
  String get manageAppDataAndCache => 'إدارة بيانات التطبيق والتخزين المؤقت.';

  @override
  String get exportData => 'تصدير البيانات';

  @override
  String get downloadACopyOfYourData => 'تحميل نسخة من بياناتك.';

  @override
  String get permanentlyDeleteYourAccountAndData => 'حذف حسابك وبياناتك نهائياً';

  @override
  String get chooseWhoCanSeeYourProfileInformation => 'اختر من يمكنه رؤية معلومات ملفك الشخصي.';

  @override
  String get enterYourNewPassword => 'أدخل كلمة المرور الجديدة.';

  @override
  String get thisActionCannotBeUndoneAllYourDataWillBePermanentlyDeleted => 'لا يمكن التراجع عن هذا الإجراء. سيتم حذف جميع بياناتك نهائياً.';

  @override
  String get export => 'تصدير';

  @override
  String get yourPetsFavouriteApp => 'التطبيق المفضل لحيوانك الأليف';

  @override
  String get version => 'الإصدار 1.0.0';

  @override
  String get aboutAlifi => 'حول أليفي';

  @override
  String get alifiIsAComprehensivePetCarePlatform => 'أليفي هو منصة شاملة لرعاية الحيوانات الأليفة تربط أصحاب الحيوانات الأليفة بالأطباء البيطريين ومتاجر الحيوانات الأليفة وخدمات رعاية الحيوانات الأليفة الأخرى. مهمتنا هي جعل رعاية الحيوانات الأليفة سهلة المنال ومريحة وموثوقة للجميع.';

  @override
  String get verifiedServices => 'الخدمات الموثقة';

  @override
  String get allVeterinariansAndPetStoresOnOurPlatformAreVerified => 'جميع الأطباء البيطريين ومتاجر الحيوانات الأليفة في منصتنا موثقون لضمان أعلى جودة رعاية لحيواناتك الأليفة المحبوبة.';

  @override
  String get secureAndPrivate => 'آمن وخاص';

  @override
  String get yourDataAndYourPetsInformationAreProtected => 'بياناتك ومعلومات حيواناتك الأليفة محمية بإجراءات أمان معيارية في الصناعة.';

  @override
  String get contactAndSupport => 'الاتصال والدعم';

  @override
  String get emailSupport => 'دعم البريد الإلكتروني';

  @override
  String get phoneSupport => 'دعم الهاتف';

  @override
  String get website => 'الموقع الإلكتروني';

  @override
  String get legal => 'القانونية';

  @override
  String get readOurTermsAndConditions => 'اقرأ شروطنا وأحكامنا';

  @override
  String get learnAboutOurPrivacyPractices => 'تعرف على ممارسات الخصوصية لدينا';

  @override
  String get developer => 'المطور';

  @override
  String get developedBy => 'تم التطوير بواسطة';

  @override
  String get alifiDevelopmentTeam => 'فريق تطوير أليفي';

  @override
  String get copyright => 'حقوق النشر';

  @override
  String get copyrightText => '© 2024 أليفي. جميع الحقوق محفوظة.';

  @override
  String get phoneSupportComingSoon => 'دعم الهاتف قريباً!';

  @override
  String get websiteComingSoon => 'الموقع الإلكتروني قريباً!';

  @override
  String get termsOfServiceComingSoon => 'شروط الخدمة قريباً!';

  @override
  String get privacyPolicyComingSoon => 'سياسة الخصوصية قريباً!';

  @override
  String get pressBackAgainToExit => 'اضغط مرة أخرى للخروج';

  @override
  String get lostPetDetails => 'تفاصيل الحيوان المفقود';

  @override
  String get fundraising => 'جمع التبرعات';

  @override
  String get animalShelterExpansion => 'توسيع ملجأ الحيوانات';

  @override
  String get helpUsExpandOurShelter => 'ساعدنا في توسيع ملجأنا لاستيعاب المزيد من الحيوانات المحتاجة.';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get wishlist => 'قائمة الرغبات';

  @override
  String get adoptionCenter => 'مركز التبني';

  @override
  String get ordersAndMessages => 'الطلبات والرسائل';

  @override
  String get becomeAVet => 'كن طبيباً بيطرياً';

  @override
  String get becomeAStore => 'كن متجراً';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get storeDashboard => 'لوحة تحكم المتجر';

  @override
  String get errorLoadingDashboard => 'خطأ في تحميل لوحة التحكم';

  @override
  String get noDashboardDataAvailable => 'لا توجد بيانات متاحة للوحة التحكم';

  @override
  String get totalSales => 'إجمالي المبيعات';

  @override
  String get engagement => 'التفاعل';

  @override
  String get totalOrders => 'إجمالي الطلبات';

  @override
  String get activeOrders => 'الطلبات النشطة';

  @override
  String get viewAllSellerTools => 'عرض جميع أدوات البائع';

  @override
  String get vetDashboard => 'لوحة تحكم الطبيب البيطري';

  @override
  String get freeShipping => 'شحن مجاني';

  @override
  String get viewStore => 'عرض المتجر';

  @override
  String get buyNow => 'اشتر الآن';

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String get addToWishlist => 'أضف إلى قائمة الرغبات';

  @override
  String get removeFromWishlist => 'إزالة من المفضلة';

  @override
  String get productDetails => 'تفاصيل المنتج';

  @override
  String get specifications => 'المواصفات';

  @override
  String get reviews => 'المراجعات';

  @override
  String get relatedProducts => 'المنتجات ذات الصلة';

  @override
  String get outOfStock => 'نفذت الكمية';

  @override
  String get inStock => 'متوفر';

  @override
  String get quantity => 'الكمية';

  @override
  String get selectQuantity => 'اختر الكمية';

  @override
  String get productImages => 'صور المنتج';

  @override
  String get shareProduct => 'مشاركة المنتج';

  @override
  String get reportProduct => 'الإبلاغ عن المنتج';

  @override
  String get sellerDashboard => 'لوحة تحكم البائع';

  @override
  String get products => 'المنتجات';

  @override
  String get messages => 'الرسائل';

  @override
  String get orders => 'طلبات';

  @override
  String get pleaseLogIn => 'يرجى تسجيل الدخول.';

  @override
  String get revenueAnalytics => 'تحليلات الإيرادات';

  @override
  String get todaysSales => 'مبيعات اليوم';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get keyMetrics => 'المقاييس الرئيسية';

  @override
  String get uniqueCustomers => 'العملاء الفريدون';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get manageProducts => 'إدارة المنتجات';

  @override
  String get productAnalytics => 'تحليلات المنتجات';

  @override
  String get totalProducts => 'إجمالي المنتجات';

  @override
  String get activeProducts => 'المنتجات النشطة';

  @override
  String get soldProducts => 'المنتجات المباعة';

  @override
  String get lowStock => 'المخزون منخفض';

  @override
  String get noProductsFound => 'لم يتم العثور على منتجات';

  @override
  String get createYourFirstProduct => 'أنشئ منتجك الأول';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get productDescription => 'وصف المنتج';

  @override
  String get productPrice => 'سعر المنتج';

  @override
  String get productCategory => 'فئة المنتج';

  @override
  String get saveProduct => 'حفظ المنتج';

  @override
  String get updateProduct => 'تحديث المنتج';

  @override
  String get deleteProduct => 'حذف المنتج';

  @override
  String get areYouSureDeleteProduct => 'هل أنت متأكد من حذف هذا المنتج؟';

  @override
  String get productSavedSuccessfully => 'تم حفظ المنتج بنجاح!';

  @override
  String get productUpdatedSuccessfully => 'تم تحديث المنتج بنجاح!';

  @override
  String get productDeletedSuccessfully => 'تم حذف المنتج بنجاح!';

  @override
  String errorSavingProduct(Object error) {
    return 'خطأ في حفظ المنتج: $error';
  }

  @override
  String errorUpdatingProduct(Object error) {
    return 'خطأ في تحديث المنتج: $error';
  }

  @override
  String errorDeletingProduct(Object error) {
    return 'خطأ في حذف المنتج: $error';
  }

  @override
  String get noMessagesFound => 'لم يتم العثور على رسائل';

  @override
  String get startConversation => 'ابدأ محادثة';

  @override
  String get typeMessage => 'اكتب رسالة...';

  @override
  String get send => 'إرسال';

  @override
  String get noOrdersFound => 'لم يتم العثور على طلبات';

  @override
  String get orderHistory => 'تاريخ الطلبات';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get orderStatus => 'حالة الطلب';

  @override
  String get orderDate => 'تاريخ الطلب';

  @override
  String get orderTotal => 'إجمالي الطلب';

  @override
  String get customerInfo => 'معلومات العميل';

  @override
  String get shippingAddress => 'عنوان الشحن';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get orderItems => 'عناصر الطلب';

  @override
  String get pending => 'في الانتظار';

  @override
  String get confirmed => 'مؤكد';

  @override
  String get shipped => 'تم الشحن';

  @override
  String get delivered => 'تم التوصيل';

  @override
  String get cancelled => 'ملغي';

  @override
  String get processing => 'قيد المعالجة';

  @override
  String get readyForPickup => 'جاهز للاستلام';

  @override
  String get updateOrderStatus => 'تحديث حالة الطلب';

  @override
  String get markAsShipped => 'تحديد كشح';

  @override
  String get markAsDelivered => 'تحديد كمسلم';

  @override
  String get cancelOrder => 'إلغاء الطلب';

  @override
  String get orderUpdatedSuccessfully => 'تم تحديث الطلب بنجاح!';

  @override
  String errorUpdatingOrder(Object error) {
    return 'خطأ في تحديث الطلب: $error';
  }

  @override
  String get custom => 'مخصص...';

  @override
  String get enterAmountInDZD => 'أدخل المبلغ بالدينار الجزائري';

  @override
  String get payVia => 'ادفع عبر :';

  @override
  String get discussion => 'مناقشة';

  @override
  String get online => 'متصل';

  @override
  String get offline => 'غير متصل';

  @override
  String get typing => 'يكتب...';

  @override
  String get messageSent => 'تم إرسال الرسالة';

  @override
  String get messageDelivered => 'تم تسليم الرسالة';

  @override
  String get messageRead => 'تم قراءة الرسالة';

  @override
  String get newMessage => 'رسالة جديدة';

  @override
  String get unreadMessages => 'رسائل غير مقروءة';

  @override
  String get markAsRead => 'تحديد كمقروء';

  @override
  String get deleteMessage => 'حذف الرسالة';

  @override
  String get blockUser => 'حظر المستخدم';

  @override
  String get reportUser => 'الإبلاغ عن المستخدم';

  @override
  String get clearChat => 'مسح المحادثة';

  @override
  String get chatCleared => 'تم مسح المحادثة';

  @override
  String get userBlocked => 'تم حظر المستخدم';

  @override
  String get userReported => 'تم الإبلاغ عن المستخدم';

  @override
  String errorSendingMessage(Object error) {
    return 'خطأ في إرسال الرسالة: $error';
  }

  @override
  String errorLoadingMessages(Object error) {
    return 'خطأ في تحميل الرسائل: $error';
  }

  @override
  String get appointmentInProgress => 'الموعد قيد التنفيذ';

  @override
  String get live => 'مباشر';

  @override
  String get endNow => 'إنهاء الآن';

  @override
  String get elapsedTime => 'الوقت المنقضي';

  @override
  String get remaining => 'المتبقي';

  @override
  String get minutes => 'دقائق';

  @override
  String get start => 'ابدأ';

  @override
  String get delay => 'تأخير';

  @override
  String get appointmentStarting => 'بدء الموعد';

  @override
  String get time => 'الوقت';

  @override
  String get duration => 'المدة';

  @override
  String get startAppointment => 'بدء الموعد';

  @override
  String appointmentStarted(Object petName) {
    return 'تم بدء الموعد لـ $petName';
  }

  @override
  String errorStartingAppointment(Object error) {
    return 'خطأ في بدء الموعد: $error';
  }

  @override
  String get appointmentRevenue => 'إيرادات الموعد';

  @override
  String howMuchEarned(Object petName) {
    return 'كم ربحت من موعد $petName؟';
  }

  @override
  String get revenueAmount => 'مبلغ الإيرادات';

  @override
  String get enterAmount => 'أدخل المبلغ (مثال: 150)';

  @override
  String revenueAddedSuccessfully(Object amount) {
    return 'تم إضافة الإيرادات بنجاح!';
  }

  @override
  String get pleaseEnterValidAmount => 'يرجى إدخال مبلغ صحيح';

  @override
  String errorAddingRevenue(Object error) {
    return 'خطأ في إضافة الإيرادات: $error';
  }

  @override
  String get noAppointmentsFound => 'لم يتم العثور على مواعيد';

  @override
  String get yourScheduleIsClear => 'جدولك فارغ';

  @override
  String get upcomingAppointments => 'المواعيد القادمة';

  @override
  String get completedAppointments => 'المواعيد المكتملة';

  @override
  String get cancelledAppointments => 'المواعيد الملغاة';

  @override
  String get searchPatients => 'البحث عن المرضى...';

  @override
  String get activePatients => 'المرضى النشطون';

  @override
  String get newThisMonth => 'جديد هذا الشهر';

  @override
  String get myPatients => 'مرضاي';

  @override
  String get noPatientsFound => 'لم يتم العثور على مرضى';

  @override
  String get avgAppointmentDuration => 'متوسط مدة الموعد';

  @override
  String get patientSatisfaction => 'رضا المريض';

  @override
  String get appointmentStatus => 'حالة الموعد';

  @override
  String get appointmentCompleted => 'تم إكمال الموعد';

  @override
  String get newPatientRegistered => 'تم تسجيل مريض جديد';

  @override
  String get vaccinationGiven => 'تم إعطاء التطعيم';

  @override
  String get surgeryScheduled => 'تم جدولة الجراحة';

  @override
  String get accessDenied => 'تم رفض الوصول';

  @override
  String get thisPageIsOnlyAvailableForVeterinaryAccounts => 'هذه الصفحة متاحة فقط لحسابات الأطباء البيطريين.';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get patients => 'المرضى';

  @override
  String get analytics => 'التحليلات';

  @override
  String get todaysAppoint => 'مواعيد اليوم';

  @override
  String get totalPatients => 'إجمالي المرضى';

  @override
  String get revenueToday => 'الإيرادات اليوم';

  @override
  String get nextAppoint => 'الموعد التالي';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get scheduleAppointment => 'جدولة موعد';

  @override
  String get addPatient => 'إضافة مريض';

  @override
  String get viewRecords => 'عرض السجلات';

  @override
  String get emergencyContact => 'جهة اتصال الطوارئ';

  @override
  String get affiliateDisclosureText => 'هذا المنتج متاح من خلال شراكتنا مع AliExpress. عند الشراء من خلال هذه الروابط، تساعد في دعم تطبيقنا دون أي تكلفة إضافية عليك. شكراً لمساعدتك في الحفاظ على هذا التطبيق!';

  @override
  String get customerReviews => 'تقييمات العملاء';

  @override
  String get noReviewsYet => 'لا توجد تقييمات بعد';

  @override
  String get beTheFirstToReviewThisProduct => 'كن أول من يقيم هذا المنتج';

  @override
  String errorLoadingReviews(Object error) {
    return 'خطأ في تحميل التقييمات: $error';
  }

  @override
  String get noRelatedProductsFound => 'لم يتم العثور على منتجات ذات صلة';

  @override
  String get iDontHaveACreditCard => '(ليس لدي بطاقة ائتمان)';

  @override
  String get howDoesItWork => 'كيف يعمل';

  @override
  String get howItWorksText => 'أدخل عنوانك ومدينتك ثم تأكد من إرسال المبلغ إلى عنوان CCP هذا 000000000000000000000000000000 ثم أرسل إثبات الدفع إلى هذا البريد الإلكتروني payment@alifi.app، سنتأكد من شحن منتجك في أقرب وقت ممكن';

  @override
  String get enterYourAddress => 'أدخل عنوانك';

  @override
  String get selectYourCity => 'اختر مدينتك';

  @override
  String get done => 'تم';

  @override
  String get ordered => 'تم الطلب';

  @override
  String get searchProducts => 'البحث عن المنتجات...';

  @override
  String get searchStores => 'البحث عن المتاجر...';

  @override
  String get searchVets => 'البحث عن الأطباء البيطريين...';

  @override
  String get userProfile => 'ملف المستخدم الشخصي';

  @override
  String get storeProfile => 'ملف المتجر الشخصي';

  @override
  String get vetProfile => 'ملف الطبيب البيطري الشخصي';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get contactInfo => 'معلومات الاتصال';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get thisActionCannotBeUndone => 'لا يمكن التراجع عن هذا الإجراء';

  @override
  String get accountDeleted => 'تم حذف الحساب';

  @override
  String errorDeletingAccount(Object error) {
    return 'خطأ في حذف الحساب: $error';
  }

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور بنجاح';

  @override
  String errorChangingPassword(Object error) {
    return 'خطأ في تغيير كلمة المرور: $error';
  }

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String errorUpdatingProfile(Object error) {
    return 'خطأ في تحديث الملف الشخصي: $error';
  }

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get passwordTooShort => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get invalidEmail => 'عنوان البريد الإلكتروني غير صحيح';

  @override
  String get emailAlreadyInUse => 'البريد الإلكتروني مستخدم بالفعل';

  @override
  String get weakPassword => 'كلمة المرور ضعيفة جداً';

  @override
  String get userNotFound => 'المستخدم غير موجود';

  @override
  String get wrongPassword => 'كلمة المرور خاطئة';

  @override
  String get tooManyRequests => 'طلبات كثيرة جداً. يرجى المحاولة لاحقاً';

  @override
  String get operationNotAllowed => 'العملية غير مسموح بها';

  @override
  String get networkError => 'خطأ في الشبكة. يرجى التحقق من اتصالك';

  @override
  String get unknownError => 'حدث خطأ غير معروف';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get success => 'نجح';

  @override
  String get warning => 'تحذير';

  @override
  String get info => 'معلومات';

  @override
  String get searching => 'جاري البحث...';

  @override
  String get searchPeoplePetsVets => 'البحث عن الأشخاص والحيوانات الأليفة والأطباء البيطريين...';

  @override
  String get recommendedVetsAndStores => 'الأطباء البيطريون والمتاجر الموصى بها';

  @override
  String get recentSearches => 'عمليات البحث الحديثة';

  @override
  String get noRecentSearches => 'لا توجد عمليات بحث حديثة';

  @override
  String get trySearchingWithDifferentKeywords => 'جرب البحث بكلمات مفتاحية مختلفة';

  @override
  String errorSearchingUsers(Object error) {
    return 'خطأ في البحث عن المستخدمين: $error';
  }

  @override
  String get myMessages => 'رسائلي';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get startDiscussion => 'ابدأ مناقشة';

  @override
  String sendMessageToStore(Object storeName) {
    return 'أرسل رسالة إلى $storeName';
  }

  @override
  String failedToSendMessage(Object error) {
    return 'فشل في إرسال الرسالة: $error';
  }

  @override
  String get pleaseSignInToFollowUsers => 'يرجى تسجيل الدخول لمتابعة المستخدمين';

  @override
  String errorUpdatingFollowStatus(Object error) {
    return 'خطأ في تحديث حالة المتابعة: $error';
  }

  @override
  String get followers => 'المتابعون';

  @override
  String get following => 'يتبع';

  @override
  String get follow => 'متابعة';

  @override
  String get unfollow => 'إلغاء المتابعة';

  @override
  String get viewInMap => 'عرض في الخريطة';

  @override
  String get message => 'رسالة';

  @override
  String get call => 'اتصال';

  @override
  String get address => 'العنوان';

  @override
  String get phone => 'الهاتف';

  @override
  String get bio => 'السيرة الذاتية';

  @override
  String get posts => 'المنشورات';

  @override
  String get photos => 'الصور';

  @override
  String get videos => 'الفيديوهات';

  @override
  String get friends => 'الأصدقاء';

  @override
  String get mutualFriends => 'الأصدقاء المشتركون';

  @override
  String get shareProfile => 'مشاركة الملف الشخصي';

  @override
  String get copyProfileLink => 'نسخ رابط الملف الشخصي';

  @override
  String get profileLinkCopied => 'تم نسخ رابط الملف الشخصي إلى الحافظة';

  @override
  String get errorCopyingProfileLink => 'خطأ في نسخ رابط الملف الشخصي';

  @override
  String get noPostsYet => 'لا توجد منشورات بعد';

  @override
  String get noPhotosYet => 'لا توجد صور بعد';

  @override
  String get noVideosYet => 'لا توجد فيديوهات بعد';

  @override
  String get noFriendsYet => 'لا توجد أصدقاء بعد';

  @override
  String get noMutualFriends => 'لا توجد أصدقاء مشتركون';

  @override
  String get loadingProfile => 'جاري تحميل الملف الشخصي...';

  @override
  String errorLoadingProfile(Object error) {
    return 'خطأ في تحميل الملف الشخصي: $error';
  }

  @override
  String get profileNotFound => 'الملف الشخصي غير موجود';

  @override
  String get accountSuspended => 'تم تعليق الحساب';

  @override
  String get accountPrivate => 'هذا الحساب خاص';

  @override
  String get followToSeeContent => 'تابع لرؤية المحتوى';

  @override
  String get requestToFollow => 'طلب متابعة';

  @override
  String get requestSent => 'تم إرسال الطلب';

  @override
  String get cancelRequest => 'إلغاء الطلب';

  @override
  String get acceptRequest => 'قبول الطلب';

  @override
  String get declineRequest => 'رفض الطلب';

  @override
  String get removeFollower => 'إزالة المتابع';

  @override
  String get muteUser => 'كتم المستخدم';

  @override
  String get unmuteUser => 'إلغاء كتم المستخدم';

  @override
  String get userMuted => 'تم كتم المستخدم';

  @override
  String get userUnmuted => 'تم إلغاء كتم المستخدم';

  @override
  String errorMutingUser(Object error) {
    return 'خطأ في كتم المستخدم: $error';
  }

  @override
  String errorUnmutingUser(Object error) {
    return 'خطأ في إلغاء كتم المستخدم: $error';
  }

  @override
  String get you => 'أنت';

  @override
  String get yourRecentProfileVisitsWillAppearHere => 'ستظهر زيارات ملفك الشخصي الحديثة هنا';

  @override
  String get noProductsYet => 'لا توجد منتجات بعد';

  @override
  String get noPetsYet => 'لا توجد حيوانات أليفة بعد';

  @override
  String get rating => 'التقييم';

  @override
  String get sendAMessage => 'إرسال رسالة';

  @override
  String get reportAccount => 'الإبلاغ عن الحساب';

  @override
  String get pleaseSignInToSendMessages => 'يرجى تسجيل الدخول لإرسال الرسائل';

  @override
  String get helpUsUnderstandWhatsHappening => 'ساعدنا في فهم ما يحدث';

  @override
  String get unknownUser => 'مستخدم غير معروف';

  @override
  String get whyAreYouReportingThisAccount => 'لماذا تبلغ عن هذا الحساب؟';

  @override
  String get submitReport => 'إرسال البلاغ';

  @override
  String get spamOrUnwantedContent => 'محتوى مزعج أو غير مرغوب فيه';

  @override
  String get inappropriateBehavior => 'سلوك غير لائق';

  @override
  String get fakeOrMisleadingInformation => 'معلومات مزيفة أو مضللة';

  @override
  String get harassmentOrBullying => 'مضايقة أو تنمر';

  @override
  String get scamOrFraud => 'احتيال أو نصب';

  @override
  String get hateSpeechOrSymbols => 'خطاب كراهية أو رموز';

  @override
  String get violenceOrDangerousContent => 'عنف أو محتوى خطير';

  @override
  String get intellectualPropertyViolation => 'انتهاك الملكية الفكرية';

  @override
  String reportSubmittedFor(Object user) {
    return 'تم إرسال البلاغ عن $user';
  }

  @override
  String get marketplace => 'السوق';

  @override
  String get searchItemsProducts => 'البحث عن العناصر والمنتجات...';

  @override
  String get food => 'الطعام';

  @override
  String get toys => 'الألعاب';

  @override
  String get health => 'الصحة';

  @override
  String get beds => 'الأسرّة';

  @override
  String get hygiene => 'النظافة';

  @override
  String get mostOrders => 'أكثر الطلبات';

  @override
  String get priceLowToHigh => 'السعر: من الأقل إلى الأعلى';

  @override
  String get priceHighToLow => 'السعر: من الأعلى إلى الأقل';

  @override
  String get newestFirst => 'الأحدث أولاً';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get allCategories => 'جميع الفئات';

  @override
  String get filterByCategory => 'تصفية حسب الفئة';

  @override
  String get newListings => 'القوائم الجديدة';

  @override
  String get recommended => 'موصى به';

  @override
  String get popularProducts => 'المنتجات الشائعة';

  @override
  String noProductsFoundFor(Object query) {
    return 'لم يتم العثور على منتجات لـ \"$query\"';
  }

  @override
  String get noRecommendedProductsAvailable => 'لا توجد منتجات موصى بها متاحة';

  @override
  String get noPopularProductsAvailable => 'لا توجد منتجات شائعة متاحة';

  @override
  String get viewAllVetTools => 'عرض جميع أدوات الطبيب البيطري';

  @override
  String weveRaised(Object amount) {
    return 'لقد جمعنا $amount دينار جزائري!';
  }

  @override
  String get goal => 'الهدف';

  @override
  String get contribute => 'تبرع';

  @override
  String get hiAskMeAboutAnyPetAdvice => 'مرحباً! اسألني عن أي نصيحة للحيوانات الأليفة،\nوسأبذل قصارى جهدي لمساعدتك\nوصغيرك!';

  @override
  String get tapToChat => 'اضغط للدردشة...';

  @override
  String get sorryIEncounteredAnError => 'عذراً، واجهت خطأ. يرجى المحاولة مرة أخرى.';

  @override
  String get youMayBeInterested => 'قد يهمك';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get errorLoadingProducts => 'خطأ في تحميل المنتجات';

  @override
  String get noProductsAvailable => 'لا توجد منتجات متاحة';

  @override
  String get loadingCombinedProducts => 'جاري تحميل المنتجات المجمعة...';

  @override
  String loadedAliExpressProducts(Object count) {
    return 'تم تحميل $count منتج من علي إكسبرس';
  }

  @override
  String errorLoadingAliExpressProducts(Object error) {
    return 'خطأ في تحميل منتجات علي إكسبرس: $error';
  }

  @override
  String loadedStoreProducts(Object count) {
    return 'تم تحميل $count منتج من المتجر';
  }

  @override
  String errorLoadingStoreProducts(Object error) {
    return 'خطأ في تحميل منتجات المتجر: $error';
  }

  @override
  String get noProductsFoundFromEitherSource => 'لم يتم العثور على منتجات من أي مصدر';

  @override
  String get creatingMockDataForTesting => 'إنشاء بيانات وهمية للاختبار...';

  @override
  String totalCombinedProducts(Object count) {
    return 'إجمالي المنتجات المجمعة: $count';
  }

  @override
  String errorInGetCombinedProducts(Object error) {
    return 'خطأ في _getCombinedProducts: $error';
  }

  @override
  String get petToySet => 'مجموعة ألعاب الحيوانات الأليفة';

  @override
  String get interactiveToysForPets => 'ألعاب تفاعلية للحيوانات الأليفة';

  @override
  String get petFoodBowl => 'وعاء طعام الحيوانات الأليفة';

  @override
  String get stainlessSteelFoodBowl => 'وعاء طعام من الفولاذ المقاوم للصدأ';

  @override
  String get days => 'أيام';

  @override
  String get day => 'يوم';

  @override
  String get hour => 'ساعة';

  @override
  String get hours => 'ساعات';

  @override
  String get minute => 'دقيقة';

  @override
  String get justNow => 'الآن';

  @override
  String get ago => 'منذ';

  @override
  String get totalAppointments => 'إجمالي المواعيد';

  @override
  String get newPatients => 'مرضى جدد';

  @override
  String get emergencyCases => 'حالات الطوارئ';

  @override
  String get noAppointmentsYet => 'لا توجد مواعيد بعد';

  @override
  String get completed => 'مكتمل';

  @override
  String get complete => 'إكمال';

  @override
  String howMuchDidYouEarnFromAppointment(Object petName) {
    return 'كم ربحت من موعد $petName؟';
  }

  @override
  String get pleaseEnterAValidAmount => 'يرجى إدخال مبلغ صحيح';

  @override
  String revenueOfAddedSuccessfully(Object amount) {
    return 'تم إضافة إيرادات $amount بنجاح!';
  }

  @override
  String get markComplete => 'تحديد كمكتمل';

  @override
  String appointmentStartedFor(Object petName) {
    return 'تم بدء الموعد لـ $petName';
  }

  @override
  String errorCompletingAppointment(Object error) {
    return 'خطأ في إكمال الموعد: $error';
  }

  @override
  String get salesAnalytics => 'تحليلات المبيعات';

  @override
  String get youHaveNoProductsYet => 'ليس لديك منتجات بعد.';

  @override
  String get contributeWith => 'تبرع بـ :';

  @override
  String get shippingFeeApplies => 'تطبق رسوم الشحن';

  @override
  String deliveryInDays(Object days) {
    return 'التوصيل خلال $days أيام';
  }

  @override
  String get storeNotFound => 'لم يتم العثور على المتجر';

  @override
  String get buyAsAGift => 'اشتر كهدية';

  @override
  String get affiliateDisclosure => 'إفصاح الشراكة';

  @override
  String get youMayBeInterestedToo => 'قد تكون مهتماً أيضاً بـ';

  @override
  String get contactStore => 'تواصل مع المتجر';

  @override
  String get buyItForMe => 'اشتره لي';

  @override
  String get vetInformation => 'معلومات الطبيب البيطري';

  @override
  String get petId => 'هوية الحيوان الأليف';

  @override
  String get editPets => 'تعديل الحيوانات الأليفة';

  @override
  String get editExistingPet => 'تعديل الحيوان الأليف الموجود';

  @override
  String get whatsYourPetsName => 'ما اسم حيوانك الأليف؟';

  @override
  String get petsName => 'اسم الحيوان الأليف';

  @override
  String get whatBreedIsYourPet => 'ما سلالة حيوانك الأليف؟';

  @override
  String get petsBreed => 'سلالة الحيوان الأليف';

  @override
  String get selectPetType => 'اختر نوع الحيوان الأليف';

  @override
  String get dog => 'كلب';

  @override
  String get cat => 'قط';

  @override
  String get selectGender => 'اختر الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get selectBirthday => 'اختر تاريخ الميلاد';

  @override
  String get selectWeight => 'اختر الوزن';

  @override
  String get selectPhoto => 'اختر الصورة';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختر من المعرض';

  @override
  String get selectColor => 'اختر اللون';

  @override
  String get kg => 'كجم';

  @override
  String get lbs => 'رطل';

  @override
  String get monthsOld => 'أشهر';

  @override
  String get month => 'شهر';

  @override
  String get months => 'أشهر';

  @override
  String get year => 'سنة';

  @override
  String get years => 'سنوات';

  @override
  String get pleaseFillInAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get startingSaveProcess => 'بدء عملية الحفظ...';

  @override
  String get uploadingPhoto => 'رفع الصورة...';

  @override
  String get savingToDatabase => 'الحفظ في قاعدة البيانات...';

  @override
  String errorAddingPet(Object error) {
    return 'خطأ في إضافة الحيوان الأليف: $error';
  }

  @override
  String get vaccines => 'اللقاحات';

  @override
  String get illness => 'المرض';

  @override
  String get coreVaccines => 'اللقاحات الأساسية';

  @override
  String get nonCoreVaccines => 'اللقاحات غير الأساسية';

  @override
  String get addVaccine => 'إضافة لقاح';

  @override
  String get logAnIllness => 'تسجيل مرض';

  @override
  String get noLoggedVaccines => 'لا توجد لقاحات مسجلة لهذا الحيوان الأليف';

  @override
  String get noLoggedIllnesses => 'لا توجد أمراض مسجلة لهذا الحيوان الأليف';

  @override
  String get noLoggedChronicIllnesses => 'لا توجد أمراض مزمنة مسجلة لهذا الحيوان الأليف';

  @override
  String get vaccineAdded => 'تم إضافة اللقاح!';

  @override
  String failedToAddVaccine(Object error) {
    return 'فشل في إضافة اللقاح: $error';
  }

  @override
  String get illnessAdded => 'تم إضافة المرض!';

  @override
  String failedToAddIllness(Object error) {
    return 'فشل في إضافة المرض: $error';
  }

  @override
  String get vaccineUpdated => 'تم تحديث اللقاح!';

  @override
  String failedToUpdateVaccine(Object error) {
    return 'فشل في تحديث اللقاح: $error';
  }

  @override
  String get illnessUpdated => 'تم تحديث المرض!';

  @override
  String failedToUpdateIllness(Object error) {
    return 'فشل في تحديث المرض: $error';
  }

  @override
  String get vaccineDeleted => 'تم حذف اللقاح!';

  @override
  String failedToDeleteVaccine(Object error) {
    return 'فشل في حذف اللقاح: $error';
  }

  @override
  String get illnessDeleted => 'تم حذف المرض!';

  @override
  String failedToDeleteIllness(Object error) {
    return 'فشل في حذف المرض: $error';
  }

  @override
  String get selectVaccineType => 'اختر نوع اللقاح';

  @override
  String get selectIllnessType => 'اختر نوع المرض';

  @override
  String get addNotes => 'إضافة ملاحظات';

  @override
  String get notes => 'ملاحظات';

  @override
  String get edit => 'تعديل';

  @override
  String get chronicIllnesses => 'الأمراض المزمنة';

  @override
  String get illnesses => 'الأمراض';

  @override
  String get selectPetForPetId => 'اختر الحيوان الأليف الذي تريد طلب هويته';

  @override
  String get pleaseSelectPetFirst => 'يرجى اختيار حيوان أليف أولاً';

  @override
  String get petIdRequestSubmitted => 'تم تقديم طلب هوية الحيوان الأليف بنجاح!';

  @override
  String get yourPetIdIsBeingProcessed => 'هوية حيوانك الأليف قيد المعالجة والتصنيع، يرجى التحلي بالصبر';

  @override
  String get petIdManagement => 'إدارة هويات الحيوانات الأليفة';

  @override
  String get digitalPetIds => 'هويات الحيوانات الأليفة الرقمية';

  @override
  String get physicalPetIds => 'هويات الحيوانات الأليفة المادية';

  @override
  String get ready => 'جاهز';

  @override
  String get editPhysicalPetId => 'تعديل هوية الحيوان الأليف المادية';

  @override
  String get customer => 'العميل';

  @override
  String get status => 'الحالة';

  @override
  String get processingStatus => 'قيد المعالجة';

  @override
  String get update => 'تحديث';

  @override
  String get petIdStatusUpdated => 'تم تحديث حالة هوية الحيوان الأليف بنجاح';

  @override
  String errorUpdatingPetId(Object error) {
    return 'خطأ في تحديث هوية الحيوان الأليف: $error';
  }

  @override
  String get physicalPetIdRequestSubmitted => 'تم تقديم طلب هوية الحيوان الأليف المادية بنجاح! سيتم الاتصال بك للدفع.';

  @override
  String get requestPhysicalPetId => 'طلب هوية حيوان أليف مادية';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get zipCode => 'الرمز البريدي';

  @override
  String get submitRequest => 'تقديم الطلب';

  @override
  String get pleaseFillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String errorCheckingPetIdStatus(Object error) {
    return 'خطأ في التحقق من حالة هوية الحيوان الأليف: $error';
  }

  @override
  String get age => 'العمر';

  @override
  String get weight => 'الوزن';

  @override
  String get breed => 'السلالة';

  @override
  String get gender => 'الجنس';

  @override
  String get color => 'اللون';

  @override
  String get species => 'النوع';

  @override
  String get name => 'الاسم';

  @override
  String resultsFound(Object count) {
    return 'تم العثور على $count نتيجة';
  }
}
