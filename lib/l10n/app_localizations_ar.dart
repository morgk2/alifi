// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get continueWithFacebook => 'المتابعة مع فيسبوك';

  @override
  String get continueWithGoogle => 'المتابعة مع جوجل';

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
  String get loadingNearbyPets => 'جاري تحميل الحيوانات القريبة...';

  @override
  String get lostPetsNearby => 'حيوانات مفقودة بالقرب';

  @override
  String get recentLostPets => 'الحيوانات المفقودة مؤخراً';

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
  String get petMarkedAsFoundSuccessfully => 'تم تمييز الحيوان كأنه تم العثور عليه بنجاح!';

  @override
  String errorMarkingPetAsFound(Object error) {
    return 'خطأ في تحديد الحيوان الأليف كموجود: $error';
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
  String get enterCustomAmount => 'أدخل المبلغ المخصص';

  @override
  String get locationServicesDisabled => 'خدمات الموقع معطلة';

  @override
  String get pleaseEnableLocationServices => 'يرجى تفعيل خدمات الموقع';

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
  String get addedPetStoreToMap => 'تمت إضافة متجر الحيوانات إلى الخريطة';

  @override
  String errorAddingBusiness(Object error) {
    return 'خطأ في إضافة العمل: $error';
  }

  @override
  String get migrateLocations => 'ترحيل المواقع';

  @override
  String get migrateLocationsDescription => 'سيتم ترحيل جميع مواقع الحيوانات الموجودة إلى التنسيق الجديد. لا يمكن التراجع عن هذه العملية.';

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
  String authServiceInitialized(Object status) {
    return 'خدمة المصادقة مهيأة: $status';
  }

  @override
  String authServiceLoading(Object status) {
    return 'خدمة المصادقة تحمل: $status';
  }

  @override
  String authServiceAuthenticated(Object status) {
    return 'خدمة المصادقة مصادق عليها: $status';
  }

  @override
  String authServiceUser(Object email) {
    return 'مستخدم خدمة المصادقة: $email';
  }

  @override
  String firebaseUser(Object email) {
    return 'مستخدم Firebase: $email';
  }

  @override
  String guestMode(Object status) {
    return 'وضع الضيف: $status';
  }

  @override
  String get forceSignOut => 'إجبار تسجيل الخروج';

  @override
  String get signedOutOfAllServices => 'تم تسجيل الخروج من جميع الخدمات';

  @override
  String failedToGetDebugInfo(Object error) {
    return 'فشل في الحصول على معلومات التصحيح: $error';
  }

  @override
  String error(Object error, Object message) {
    return 'خطأ: $message';
  }

  @override
  String lastSeen(Object location, Object time) {
    return 'آخر رؤية: $location';
  }

  @override
  String physicalPetIdFor(Object petName) {
    return 'هوية الحيوان المادية لـ $petName';
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
  String get vetsNearMe => 'الأطباء البيطريون القريبون';

  @override
  String get recommendedVets => 'الأطباء البيطريون الموصى بهم';

  @override
  String get topVets => 'أفضل الأطباء البيطريون';

  @override
  String get store => 'المتجر';

  @override
  String get vetClinic => 'عيادة بيطرية';

  @override
  String get petStore => 'متجر الحيوانات';

  @override
  String get services => 'الخدمات';

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
    return 'خطأ في فتح الدردشة: $error';
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
    return 'تم إنشاء موعد اختبار! المعرف: $id\nالوقت: $time';
  }

  @override
  String errorCreatingTestAppointment(Object error) {
    return 'خطأ في إنشاء موعد الاختبار: $error';
  }

  @override
  String get noUserLoggedIn => 'لا يوجد مستخدم مسجل الدخول';

  @override
  String get todaysVetAppointment => 'موعد الطبيب البيطري اليوم';

  @override
  String get soon => 'قريبًا';

  @override
  String get past => 'سابق';

  @override
  String get today => 'اليوم';

  @override
  String get pet => 'الحيوان';

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
    return 'خطأ في تحميل الحيوانات: $error';
  }

  @override
  String errorLoadingTimeSlots(Object error) {
    return 'خطأ في تحميل الأوقات المتاحة: $error';
  }

  @override
  String get pleaseFillRequiredFields => 'يرجى ملء جميع الحقول المطلوبة (الصورة، الاسم، والوصف)';

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
  String get selectPet => 'اختر الحيوان';

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
  String get pets => 'الحيوانات';

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
  String get reportLostPetInstructions => 'انتقل إلى قسم \"الحيوانات المفقودة\"، اضغط \"الإبلاغ عن حيوان أليف مفقود\"، املأ التفاصيل بما في ذلك الصور والموقع ومعلومات الاتصال.';

  @override
  String get lostPets => 'الحيوانات المفقودة';

  @override
  String get howToOrderPetSupplies => 'كيف أطلب مستلزمات الحيوانات؟';

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
  String get petCareReminders => 'تذكيرات رعاية الحيوانات';

  @override
  String get neverMissImportantPetCareAppointments => 'لا تفوت أبداً مواعيد رعاية الحيوانات المهمة';

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
  String get noUsersFound => 'لم يتم العثور على مستخدمين';

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
  String get select => 'اختيار';

  @override
  String get checkUp => 'فحص عام';

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
  String get addPet => 'إضافة حيوان';

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
  String get user => 'مستخدم';

  @override
  String get noLostPetsReportedNearby => 'لا توجد حيوانات أليفة مفقودة مبلغ عنها في المنطقة';

  @override
  String get weWillNotifyYouWhenPetsAreReported => 'سنقوم بإشعارك عندما يتم الإبلاغ عن حيوانات أليفة في منطقتك';

  @override
  String get noRecentLostPetsReported => 'لا توجد حيوانات أليفة مفقودة مبلغ عنها مؤخراً';

  @override
  String get enableLocationToSeePetsInYourArea => 'فعّل الموقع لرؤية الحيوانات في منطقتك';

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
  String get ferret => 'فيريت';

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
  String get chinchilla => 'شنشيلة';

  @override
  String get gerbil => 'جرذ صحراوي';

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
  String get petListingIssues => 'مشاكل قائمة الحيوانات';

  @override
  String get mapNotWorking => 'الخريطة لا تعمل';

  @override
  String get inappropriateContent => 'محتوى غير مناسب';

  @override
  String get technicalProblems => 'مشاكل تقنية';

  @override
  String get other => 'أخرى';

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
  String get useLiquidGlassEffectForTabBar => 'استخدام تأثير الزجاج السائل لشريط التبويب';

  @override
  String get enableLiquidGlassEffectOnNavigationBar => 'تفعيل تأثير الزجاج السائل على شريط التنقل';

  @override
  String get whenDisabledLiquidGlassTabBarWillNotDistortBackground => 'عند التعطيل، لن يقوم شريط التبويب بتشويه محتوى الخلفية. يعمل بشكل منفصل عن تأثير الضبابية.';

  @override
  String get useSolidColorForTabBar => 'استخدام لون صلب لشريط التبويب';

  @override
  String get enableSolidColorOnNavigationBar => 'تفعيل خلفية لون صلب على شريط التنقل';

  @override
  String get whenDisabledSolidColorTabBarWillHaveEffect => 'عند التعطيل، سيستخدم شريط التبويب أحد التأثيرات البصرية الأخرى. يمكن تفعيل تأثير واحد فقط في كل مرة.';

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
  String get sellPetProductsAndServices => 'بيع منتجات وخدمات الحيوانات';

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
  String get alifiIsAComprehensivePetCarePlatform => 'أليفي هو منصة شاملة لرعاية الحيوانات تربط أصحاب الحيوانات بالأطباء البيطريين ومتاجر الحيوانات وخدمات رعاية الحيوانات الأخرى. مهمتنا هي جعل رعاية الحيوانات سهلة المنال ومريحة وموثوقة للجميع.';

  @override
  String get verifiedServices => 'الخدمات الموثقة';

  @override
  String get allVeterinariansAndPetStoresOnOurPlatformAreVerified => 'جميع الأطباء البيطريين ومتاجر الحيوانات في منصتنا موثقون لضمان أعلى جودة رعاية لحيواناتك الأليفة المحبوبة.';

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
  String get addToWishlist => 'أضف إلى المفضلة';

  @override
  String get removeFromWishlist => 'إزالة من المفضلة';

  @override
  String get productDetails => 'تفاصيل المنتج';

  @override
  String get specifications => 'المواصفات';

  @override
  String get reviews => 'التقييمات';

  @override
  String get relatedProducts => 'المنتجات ذات الصلة';

  @override
  String get outOfStock => 'نفذت الكمية';

  @override
  String get inStock => 'متوفر';

  @override
  String quantity(Object qty) {
    return 'الكمية: $qty';
  }

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
  String get orders => 'الطلبات';

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
  String paymentMethod(Object method) {
    return 'طريقة الدفع: $method';
  }

  @override
  String get orderItems => 'عناصر الطلب';

  @override
  String get pending => 'في الانتظار';

  @override
  String get confirmed => 'مؤكد';

  @override
  String get shipped => 'تم الشحن';

  @override
  String get delivered => 'تم التسليم';

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
  String get payVia => 'ادفع عبر';

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
  String unreadMessages(Object count) {
    return '$count رسائل غير مقروءة';
  }

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
  String get chatCleared => 'تم مسح المحادثة بنجاح';

  @override
  String get userBlocked => 'تم حظر المستخدم بنجاح';

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
  String get enterAmount => 'أدخل المبلغ (مثل 150)';

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
  String get affiliateDisclosureText => 'هذا المنتج متاح من خلال شراكتنا التابعة مع علي إكسبرس. عند الشراء من خلال هذه الروابط، تساعد في دعم تطبيقنا دون أي تكلفة إضافية عليك. شكراً لمساعدتك في الحفاظ على هذا التطبيق!';

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
  String get accountDeleted => 'تم حذف الحساب بنجاح';

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
  String get searchPeoplePetsVets => 'البحث عن الأشخاص والحيوانات والأطباء البيطريين...';

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
  String get startDiscussion => 'Start a discussion';

  @override
  String sendMessageToStore(Object storeName) {
    return 'Send a message to $storeName';
  }

  @override
  String failedToSendMessage(Object error) {
    return 'فشل في إرسال الرسالة: $error';
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
  String get message => 'رسالة';

  @override
  String get call => 'اتصال';

  @override
  String get address => 'العنوان';

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
  String get you => 'أنت';

  @override
  String get yourRecentProfileVisitsWillAppearHere => 'ستظهر زيارات ملفك الشخصي الحديثة هنا';

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
  String get unknownUser => 'مستخدم غير معروف';

  @override
  String get whyAreYouReportingThisAccount => 'Why are you reporting this account?';

  @override
  String get submitReport => 'إرسال التقرير';

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
  String get youMayBeInterested => 'قد يهمك';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get errorLoadingProducts => 'Error loading products';

  @override
  String get noProductsAvailable => 'لا توجد منتجات متاحة';

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
  String get justNow => 'الآن';

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
  String get youMayBeInterestedToo => 'قد تكون مهتماً أيضاً بـ';

  @override
  String get contactStore => 'تواصل مع المتجر';

  @override
  String get buyItForMe => 'اشتره لي';

  @override
  String get vetInformation => 'معلومات الطبيب البيطري';

  @override
  String get petId => 'هوية الحيوان';

  @override
  String get editPets => 'تعديل الحيوانات';

  @override
  String get editExistingPet => 'تعديل الحيوان الموجود';

  @override
  String get whatsYourPetsName => 'ما اسم حيوانك الأليف؟';

  @override
  String get petsName => 'اسم الحيوان';

  @override
  String get whatBreedIsYourPet => 'ما سلالة حيوانك الأليف؟';

  @override
  String get petsBreed => 'سلالة الحيوان';

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
    return 'خطأ في إضافة الحيوان: $error';
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
  String get noLoggedVaccines => 'لا توجد لقاحات مسجلة لهذا الحيوان';

  @override
  String get noLoggedIllnesses => 'لا توجد أمراض مسجلة لهذا الحيوان';

  @override
  String get noLoggedChronicIllnesses => 'لا توجد أمراض مزمنة مسجلة لهذا الحيوان';

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
  String get selectPetForPetId => 'اختر الحيوان الذي تريد طلب هويته';

  @override
  String get pleaseSelectPetFirst => 'يرجى اختيار حيوان أليف أولاً';

  @override
  String get petIdRequestSubmitted => 'تم تقديم طلب هوية الحيوان بنجاح!';

  @override
  String get yourPetIdIsBeingProcessed => 'هوية حيوانك الأليف قيد المعالجة والتصنيع، يرجى التحلي بالصبر';

  @override
  String get petIdManagement => 'إدارة هويات الحيوانات';

  @override
  String get digitalPetIds => 'هويات الحيوانات الرقمية';

  @override
  String get physicalPetIds => 'هويات الحيوانات المادية';

  @override
  String get ready => 'جاهز';

  @override
  String get editPhysicalPetId => 'تعديل هوية الحيوان المادية';

  @override
  String get customer => 'العميل';

  @override
  String get status => 'الحالة';

  @override
  String get processingStatus => 'قيد المعالجة';

  @override
  String get update => 'تحديث';

  @override
  String get petIdStatusUpdated => 'تم تحديث حالة هوية الحيوان بنجاح';

  @override
  String errorUpdatingPetId(Object error) {
    return 'خطأ في تحديث هوية الحيوان: $error';
  }

  @override
  String get physicalPetIdRequestSubmitted => 'تم تقديم طلب هوية الحيوان المادية بنجاح! سيتم الاتصال بك للدفع.';

  @override
  String get requestPhysicalPetId => 'طلب هوية حيوان أليف مادية';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get zipCode => 'الرمز البريدي';

  @override
  String get submitRequest => 'إرسال الطلب';

  @override
  String get pleaseFillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String errorCheckingPetIdStatus(Object error) {
    return 'خطأ في التحقق من حالة هوية الحيوان: $error';
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

  @override
  String get whatTypeOfPetDoYouHave => 'ما نوع الحيوان الذي لديك؟';

  @override
  String get next => 'التالي';

  @override
  String get petsNearMe => 'الحيوانات القريبة مني';

  @override
  String get basedOnYourCurrentLocation => 'بناءً على موقعك الحالي';

  @override
  String get noAdoptionListingsInYourArea => 'لا توجد قوائم تبني في منطقتك';

  @override
  String get noAdoptionListingsYet => 'لا توجد قوائم تبني بعد';

  @override
  String get beTheFirstToAddPetForAdoption => 'كن أول من يضيف حيوان أليف للتبني!';

  @override
  String get addListing => 'إضافة قائمة';

  @override
  String get searchPets => 'البحث عن الحيوانات...';

  @override
  String get gettingYourLocation => 'جاري الحصول على موقعك...';

  @override
  String get locationPermissionDenied => 'تم رفض إذن الموقع';

  @override
  String get locationPermissionPermanentlyDenied => 'تم رفض إذن الموقع نهائياً';

  @override
  String get unableToGetLocation => 'غير قادر على الحصول على الموقع';

  @override
  String filtersApplied(Object count) {
    return 'تم تطبيق المرشحات: $count نشط';
  }

  @override
  String get pleaseLoginToManageListings => 'يرجى تسجيل الدخول لإدارة قوائمك';

  @override
  String get errorLoadingListings => 'خطأ في تحميل القوائم';

  @override
  String get noPetsNearMe => 'لا توجد حيوانات أليفة قريبة مني';

  @override
  String get posting => 'جاري النشر...';

  @override
  String get postForAdoption => 'نشر للتبني';

  @override
  String get listingTitle => 'عنوان القائمة';

  @override
  String get enterTitleForListing => 'أدخل عنواناً لقائمتك';

  @override
  String get describePetAndAdopter => 'صف حيوانك الأليف وما تبحث عنه في المتبني';

  @override
  String get location => 'الموقع';

  @override
  String get enterLocationForAdoption => 'أدخل موقع التبني';

  @override
  String get petInformation => 'معلومات الحيوان';

  @override
  String get listingDetails => 'تفاصيل القائمة';

  @override
  String get adoptionFee => 'رسوم التبني (دينار جزائري)';

  @override
  String get freeAdoption => '0 للتبني المجاني';

  @override
  String get pleaseEnterTitle => 'يرجى إدخال عنوان للقائمة';

  @override
  String get pleaseEnterDescription => 'يرجى إدخال وصف';

  @override
  String get pleaseEnterLocation => 'يرجى إدخال موقع';

  @override
  String petPostedForAdoptionSuccessfully(Object petName) {
    return 'تم نشر $petName للتبني بنجاح!';
  }

  @override
  String failedToPostAdoptionListing(Object error) {
    return 'فشل في نشر قائمة التبني: $error';
  }

  @override
  String get offerForAdoption => 'عرض للتبني';

  @override
  String get deletePet => 'حذف الحيوان الأليف';

  @override
  String areYouSureDeletePet(Object petName) {
    return 'هل أنت متأكد من حذف $petName؟';
  }

  @override
  String petDeletedSuccessfully(Object petName) {
    return 'تم حذف $petName بنجاح';
  }

  @override
  String failedToDeletePet(Object error) {
    return 'فشل في حذف الحيوان الأليف: $error';
  }

  @override
  String get myListings => 'قوائمي';

  @override
  String get noListingsFound => 'لم يتم العثور على قوائم';

  @override
  String get editListing => 'تعديل الإعلان';

  @override
  String get deleteListing => 'حذف القائمة';

  @override
  String get listingDeletedSuccessfully => 'تم حذف القائمة بنجاح';

  @override
  String failedToDeleteListing(Object error) {
    return 'فشل في حذف القائمة: $error';
  }

  @override
  String get areYouSureDeleteListing => 'هل أنت متأكد من حذف هذه القائمة؟';

  @override
  String get contactInformation => 'معلومات الاتصال';

  @override
  String get postedBy => 'نشر بواسطة';

  @override
  String get contactOwner => 'اتصال بالمالك';

  @override
  String adoptionFeeValue(Object fee) {
    return 'رسوم التبني: $fee دينار جزائري';
  }

  @override
  String get free => 'مجاني';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get requirements => 'المتطلبات';

  @override
  String get noRequirements => 'لا توجد متطلبات محددة';

  @override
  String get contactNumber => 'رقم الاتصال';

  @override
  String get noContactNumber => 'لا يوجد رقم اتصال';

  @override
  String get lastUpdated => 'آخر تحديث';

  @override
  String get createdOn => 'تم الإنشاء في';

  @override
  String get adoptionListingDetails => 'تفاصيل قائمة التبني';

  @override
  String get petDetails => 'تفاصيل الحيوان';

  @override
  String get petType => 'نوع الحيوان';

  @override
  String get petAge => 'العمر';

  @override
  String get petGender => 'الجنس';

  @override
  String get petColor => 'اللون';

  @override
  String get petWeight => 'الوزن';

  @override
  String get petBreed => 'السلالة';

  @override
  String get petLocation => 'الموقع';

  @override
  String get petImages => 'الصور';

  @override
  String get noImages => 'لا توجد صور متاحة';

  @override
  String get viewAllImages => 'عرض جميع الصور';

  @override
  String get adoptionProcess => 'عملية التبني';

  @override
  String get adoptionSteps => 'خطوات التبني';

  @override
  String get step1 => 'الخطوة 1';

  @override
  String get step2 => 'الخطوة 2';

  @override
  String get step3 => 'الخطوة 3';

  @override
  String get step4 => 'الخطوة 4';

  @override
  String get contactOwnerStep => 'اتصال بالمالك';

  @override
  String get meetPetStep => 'مقابلة الحيوان';

  @override
  String get completeAdoptionStep => 'إكمال التبني';

  @override
  String get followUpStep => 'المتابعة والرعاية';

  @override
  String get contactOwnerDescription => 'تواصل مع مالك الحيوان لإبداء اهتمامك وطرح أسئلة حول الحيوان.';

  @override
  String get meetPetDescription => 'رتب لمقابلة الحيوان شخصياً للتأكد من أنه مناسب لعائلتك.';

  @override
  String get completeAdoptionDescription => 'إذا سار كل شيء على ما يرام، أكمل عملية التبني مع المالك.';

  @override
  String get followUpDescription => 'قدم رعاية مستمرة وتابع مع المالك إذا لزم الأمر.';

  @override
  String get adoptionTips => 'نصائح التبني';

  @override
  String get adoptionTipsDescription => 'إليك بعض النصائح لمساعدتك في عملية التبني:';

  @override
  String get tip1 => 'اطرح الكثير من الأسئلة حول تاريخ الحيوان وصحته وسلوكه';

  @override
  String get tip2 => 'قابل الحيوان شخصياً قبل اتخاذ القرار';

  @override
  String get tip3 => 'فكر في نمط حياتك ووضعك المعيشي';

  @override
  String get tip4 => 'كن صبوراً ولا تستعجل في اتخاذ القرار';

  @override
  String get tip5 => 'جهز منزلك للحيوان الأليف الجديد';

  @override
  String get tip6 => 'لديك خطة للرعاية المستمرة والمصروفات';

  @override
  String get adoptionSuccess => 'نجاح التبني';

  @override
  String get adoptionSuccessDescription => 'تهانينا على العثور على رفيقك الجديد! تذكر:';

  @override
  String get successTip1 => 'امنح حيوانك الأليف الجديد وقتاً للتكيف مع منزله الجديد';

  @override
  String get successTip2 => 'حدد موعد فحص بيطري في الأسبوع الأول';

  @override
  String get successTip3 => 'حدث معلومات الشريحة الإلكترونية إذا كانت متاحة';

  @override
  String get successTip4 => 'حافظ على التواصل مع المالك السابق إذا لزم الأمر';

  @override
  String get successTip5 => 'قدم الكثير من الحب والصبر أثناء الانتقال';

  @override
  String get adoptionResources => 'موارد التبني';

  @override
  String get adoptionResourcesDescription => 'إليك بعض الموارد المفيدة لأولياء الأمور الجدد:';

  @override
  String get resource1 => 'أدلة رعاية الحيوانات ونصائح';

  @override
  String get resource2 => 'توصيات الأطباء البيطريين المحليين';

  @override
  String get resource3 => 'موارد تدريب الحيوانات';

  @override
  String get resource4 => 'معلومات رعاية الحيوانات في الطوارئ';

  @override
  String get resource5 => 'موارد السكن الصديق للحيوانات الأليفة';

  @override
  String get adoptionSupport => 'دعم التبني';

  @override
  String get adoptionSupportDescription => 'تحتاج مساعدة في تبني؟ نحن هنا لدعمك:';

  @override
  String get support1 => 'تواصل مع فريق دعم التبني';

  @override
  String get support2 => 'انضم إلى منتديات مجتمعنا';

  @override
  String get support3 => 'الوصول إلى الموارد التعليمية';

  @override
  String get support4 => 'احصل على توصيات الأطباء البيطريين';

  @override
  String get support5 => 'اعثر على خدمات رعاية الحيوانات';

  @override
  String get adoptionFaq => 'الأسئلة الشائعة حول التبني';

  @override
  String get adoptionFaqDescription => 'الأسئلة الشائعة حول تبني الحيوانات:';

  @override
  String get faq1 => 'ماذا يجب أن أسأل مالك الحيوان؟';

  @override
  String get faq2 => 'كيف أعرف إذا كان الحيوان مناسب لي؟';

  @override
  String get faq3 => 'ما المستندات التي أحتاجها للتبني؟';

  @override
  String get faq4 => 'كم تكلفة رعاية الحيوان؟';

  @override
  String get faq5 => 'ماذا لو لم ينجح التبني؟';

  @override
  String get adoptionGuidelines => 'إرشادات التبني';

  @override
  String get adoptionGuidelinesDescription => 'يرجى اتباع هذه الإرشادات لتبني ناجح:';

  @override
  String get guideline1 => 'كن صادقاً بشأن خبرتك والوضع المعيشي';

  @override
  String get guideline2 => 'اطرح أسئلة مفصلة حول احتياجات الحيوان';

  @override
  String get guideline3 => 'فكر في الالتزام طويل المدى';

  @override
  String get guideline4 => 'لديك خطة احتياطية للطوارئ';

  @override
  String get guideline5 => 'كن محترماً لوقت المالك وقراره';

  @override
  String get adoptionSafety => 'سلامة التبني';

  @override
  String get adoptionSafetyDescription => 'ابق آمناً أثناء عملية التبني:';

  @override
  String get safety1 => 'قابل في مكان عام للمقابلة الأولى';

  @override
  String get safety2 => 'أحضر صديقاً أو أحد أفراد العائلة';

  @override
  String get safety3 => 'ثق بحدسك';

  @override
  String get safety4 => 'لا تشعر بالضغط لاتخاذ قرار سريع';

  @override
  String get safety5 => 'أبلغ عن أي سلوك مشبوه';

  @override
  String get adoptionPreparation => 'تحضير التبني';

  @override
  String get adoptionPreparationDescription => 'جهز لحيوانك الأليف الجديد:';

  @override
  String get preparation1 => 'أمّن منزلك للحيوان الأليف';

  @override
  String get preparation2 => 'اجمع الإمدادات اللازمة';

  @override
  String get preparation3 => 'ابحث عن متطلبات رعاية الحيوان';

  @override
  String get preparation4 => 'خطط للمصروفات المستمرة';

  @override
  String get preparation5 => 'رتب لرعاية الحيوان عندما تكون بعيداً';

  @override
  String get adoptionTimeline => 'الجدول الزمني للتبني';

  @override
  String get adoptionTimelineDescription => 'الجدول الزمني النموذجي لعملية التبني:';

  @override
  String get timeline1 => 'التواصل الأولي (1-2 يوم)';

  @override
  String get timeline2 => 'اللقاء والتعارف (3-7 أيام)';

  @override
  String get timeline3 => 'زيارة المنزل (اختياري، 1-2 أسبوع)';

  @override
  String get timeline4 => 'إكمال التبني (1-4 أسابيع)';

  @override
  String get timeline5 => 'رعاية المتابعة (مستمر)';

  @override
  String get adoptionCosts => 'تكاليف التبني';

  @override
  String get adoptionCostsDescription => 'فكر في هذه التكاليف عند التبني:';

  @override
  String get cost1 => 'رسوم التبني (إن وجدت)';

  @override
  String get cost2 => 'الزيارة البيطرية الأولية والتطعيمات';

  @override
  String get cost3 => 'إمدادات الحيوان والمعدات';

  @override
  String get cost4 => 'مصروفات الطعام والرعاية المستمرة';

  @override
  String get cost5 => 'صندوق الرعاية البيطرية في الطوارئ';

  @override
  String get adoptionBenefits => 'فوائد التبني';

  @override
  String get adoptionBenefitsDescription => 'فوائد تبني حيوان أليف:';

  @override
  String get benefit1 => 'أنقذ حياة وأعطِ منزلاً لحيوان أليف محتاج';

  @override
  String get benefit2 => 'غالباً ما يكون أكثر تكلفة من الشراء من مربي';

  @override
  String get benefit3 => 'العديد من الحيوانات المتبناة مدربة بالفعل';

  @override
  String get benefit4 => 'ادعم منظمات رعاية الحيوان';

  @override
  String get benefit5 => 'اختبر فرحة رفقة الحيوان';

  @override
  String get adoptionChallenges => 'تحديات التبني';

  @override
  String get adoptionChallengesDescription => 'كن مستعداً لهذه التحديات:';

  @override
  String get challenge1 => 'فترة التكيف للحيوان الأليف';

  @override
  String get challenge2 => 'تاريخ صحي أو سلوكي غير معروف';

  @override
  String get challenge3 => 'احتياجات تدريب محتملة';

  @override
  String get challenge4 => 'التزام مستمر بالوقت والمال';

  @override
  String get challenge5 => 'التعلق العاطفي والمسؤولية';

  @override
  String get adoptionSuccessStories => 'قصص نجاح التبني';

  @override
  String get adoptionSuccessStoriesDescription => 'اقرأ قصص التبني الملهمة:';

  @override
  String get story1 => 'كيف وجد ماكس منزله الدائم';

  @override
  String get story2 => 'رحلة لونا للشفاء';

  @override
  String get story3 => 'تجربة التبني الأولى لعائلة';

  @override
  String get story4 => 'نجاح تبني حيوان أليف مسن';

  @override
  String get story5 => 'تبني حيوان أليف ذو احتياجات خاصة';

  @override
  String get adoptionCommunity => 'مجتمع التبني';

  @override
  String get adoptionCommunityDescription => 'تواصل مع آباء الحيوانات الآخرين:';

  @override
  String get community1 => 'انضم إلى مجموعات الحيوانات المحلية';

  @override
  String get community2 => 'شارك قصة تبني';

  @override
  String get community3 => 'احصل على نصيحة من المالكين ذوي الخبرة';

  @override
  String get community4 => 'شارك في أحداث الحيوانات';

  @override
  String get community5 => 'تطوع في ملاجئ الحيوانات';

  @override
  String get adoptionEducation => 'تعليم التبني';

  @override
  String get adoptionEducationDescription => 'تعلم المزيد عن تبني الحيوانات:';

  @override
  String get education1 => 'فهم سلوك الحيوان';

  @override
  String get education2 => 'صحة الحيوان والتغذية';

  @override
  String get education3 => 'التدريب والتنشئة الاجتماعية';

  @override
  String get education4 => 'رعاية الحيوان في الطوارئ';

  @override
  String get education5 => 'قانون الحيوان واللوائح';

  @override
  String get adoptionAdvocacy => 'الدفاع عن التبني';

  @override
  String get adoptionAdvocacyDescription => 'ساعد في تعزيز تبني الحيوانات:';

  @override
  String get advocacy1 => 'شارك قصص التبني على وسائل التواصل الاجتماعي';

  @override
  String get advocacy2 => 'تطوع في الملاجئ المحلية';

  @override
  String get advocacy3 => 'تبرع لمنظمات رعاية الحيوان';

  @override
  String get advocacy4 => 'علم الآخرين عن فوائد التبني';

  @override
  String get advocacy5 => 'ادعم برامج التعقيم';

  @override
  String get adoptionMyths => 'أساطير التبني';

  @override
  String get adoptionMythsDescription => 'المفاهيم الخاطئة الشائعة حول تبني الحيوانات:';

  @override
  String get myth1 => 'الحيوانات المتبناة لديها مشاكل سلوكية';

  @override
  String get myth2 => 'لا يمكنك العثور على حيوانات أليفة أصيلة للتبني';

  @override
  String get myth3 => 'الحيوانات المتبناة غير صحية';

  @override
  String get myth4 => 'التبني معقد جداً';

  @override
  String get myth5 => 'الحيوانات المتبناة لا ترتبط بالمالكين الجدد';

  @override
  String get adoptionFacts => 'حقائق التبني';

  @override
  String get adoptionFactsDescription => 'حقائق حول تبني الحيوانات:';

  @override
  String get fact1 => 'ملايين الحيوانات تنتظر منازل';

  @override
  String get fact2 => 'الحيوانات المتبناة غالباً ما تكون مدربة بالفعل';

  @override
  String get fact3 => 'رسوم التبني تساعد في دعم رعاية الحيوان';

  @override
  String get fact4 => 'العديد من الحيوانات المتبناة صحية ومطيعة';

  @override
  String get fact5 => 'التبني ينقذ الأرواح ويقلل من الاكتظاظ السكاني';

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
  String get tiktok => 'تيك توك';

  @override
  String get facebook => 'فيسبوك';

  @override
  String get instagram => 'إنستغرام';

  @override
  String get enterTikTokUsername => 'أدخل اسم مستخدم تيك توك';

  @override
  String get enterFacebookUsername => 'أدخل اسم مستخدم فيسبوك';

  @override
  String get enterInstagramUsername => 'أدخل اسم مستخدم إنستغرام';

  @override
  String get socialMediaAdded => 'تم إضافة حساب وسائل التواصل الاجتماعي بنجاح!';

  @override
  String get socialMediaUpdated => 'تم تحديث حساب وسائل التواصل الاجتماعي بنجاح!';

  @override
  String get socialMediaRemoved => 'تم إزالة حساب وسائل التواصل الاجتماعي بنجاح!';

  @override
  String errorUpdatingSocialMedia(Object error) {
    return 'خطأ في تحديث وسائل التواصل الاجتماعي: $error';
  }

  @override
  String get removeSocialMedia => 'إزالة وسائل التواصل الاجتماعي';

  @override
  String get areYouSureRemoveSocialMedia => 'هل أنت متأكد من إزالة حساب وسائل التواصل الاجتماعي هذا؟';

  @override
  String get petOwners => 'مالكو الحيوانات الأليفة';

  @override
  String get addPetOwner => 'إضافة مالك للحيوان الأليف';

  @override
  String searchForUsersToAddAsOwners(Object petName) {
    return 'البحث عن مستخدمين لإضافتهم كملاك لـ $petName';
  }

  @override
  String get petOwnershipRequests => 'طلبات ملكية الحيوانات الأليفة';

  @override
  String pendingRequests(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ات',
      one: '',
    );
    return '$count طلب معلق$_temp0';
  }

  @override
  String moreRequests(Object count) {
    return '+ $count طلبات أخرى';
  }

  @override
  String wantsToCoOwn(Object petName, Object userName) {
    return '$userName يريد المشاركة في ملكية $petName';
  }

  @override
  String get decline => 'رفض';

  @override
  String get requestAccepted => 'تم قبول الطلب';

  @override
  String get requestDeclined => 'تم رفض الطلب';

  @override
  String ownershipRequestSent(Object userName) {
    return 'تم إرسال طلب الملكية إلى $userName';
  }

  @override
  String get errorSendingRequest => 'خطأ في إرسال الطلب';

  @override
  String get petOwnershipRequest => 'طلب ملكية الحيوان';

  @override
  String get petOwnershipRequestAccepted => 'تم قبول طلب ملكية الحيوان الأليف';

  @override
  String get petOwnershipRequestDeclined => 'تم رفض طلب ملكية الحيوان الأليف';

  @override
  String wantsToAddYouAsOwner(Object petName, Object userName) {
    return '$userName يريد إضافتك كمالك لـ $petName';
  }

  @override
  String get checkMyPetsPageForRequests => 'تحقق من صفحة حيواناتي الأليفة للطلبات';

  @override
  String get createPetProfile => 'إنشاء ملف الحيوان الأليف';

  @override
  String get petProfileNotFound => 'لم يتم العثور على ملف الحيوان الأليف';

  @override
  String get errorCreatingPetProfile => 'خطأ في إنشاء ملف الحيوان الأليف';

  @override
  String get searchForPetProfiles => 'البحث عن ملفات الحيوانات الأليفة...';

  @override
  String get searchForPetProfilesTitle => 'البحث عن ملفات الحيوانات الأليفة';

  @override
  String get findAndFollowPublicPetAccounts => 'ابحث واتبع حسابات الحيوانات الأليفة العامة\nمن جميع أنحاء المجتمع';

  @override
  String get noPetProfilesFound => 'لم يتم العثور على ملفات الحيوانات الأليفة';

  @override
  String get writeCaptionForPhoto => 'اكتب تعليقاً على هذه الصورة...';

  @override
  String get addCaptionToPhoto => 'أضف تعليقاً على هذه الصورة';

  @override
  String get noCaption => 'لا يوجد تعليق';

  @override
  String get captionUpdatedSuccessfully => 'تم تحديث التعليق بنجاح!';

  @override
  String failedToUpdateCaption(Object error) {
    return 'فشل في تحديث التعليق: $error';
  }

  @override
  String get maxCaptionLength => 'الحد الأقصى 200 حرف';

  @override
  String get searchingPetProfiles => 'البحث في ملفات الحيوانات الأليفة...';

  @override
  String noResultsFoundForPetProfiles(Object query) {
    return 'لم يتم العثور على نتائج لـ \"$query\"';
  }

  @override
  String errorSearchingPetProfiles(Object error) {
    return 'خطأ في البحث عن ملفات الحيوانات الأليفة: $error';
  }

  @override
  String get authDebugInfo => 'معلومات تصحيح المصادقة';

  @override
  String get maximumPhotosAllowed => 'الحد الأقصى 4 صور مسموح';

  @override
  String get photoAddedSuccessfully => 'تم إضافة الصورة بنجاح!';

  @override
  String failedToAddPhoto(Object error) {
    return 'فشل في إضافة الصورة: $error';
  }

  @override
  String get reportAsLost => 'الإبلاغ كأنه مفقود';

  @override
  String get youMustBeLoggedInToReportLostPet => 'يجب أن تكون مسجل الدخول للإبلاغ عن حيوان أليف مفقود';

  @override
  String get pleaseSignInToReportMissingPet => 'يرجى تسجيل الدخول للإبلاغ عن حيوان مفقود';

  @override
  String get selectPetToReportMissing => 'اختر حيوان أليف للإبلاغ عن فقدانه';

  @override
  String get report => 'بلاغ';

  @override
  String get lb => 'رطل';

  @override
  String get petName => 'اسم الحيوان الأليف';

  @override
  String get birthday => 'تاريخ الميلاد';

  @override
  String get borderColor => 'لون الحدود:';

  @override
  String get pickAColor => 'اختر لوناً';

  @override
  String get glassDistortionEffectForTabBar => 'تأثير تشويه الزجاج لشريط التبويب';

  @override
  String get enableCustomGlassDistortionEffect => 'تفعيل تأثير تشويه الزجاج المخصص الذي ينحني المحتوى للمظهر الواقعي للزجاج';

  @override
  String get customGlassDistortionShaderDescription => 'مظلل تشويه الزجاج المخصص الذي ينحني ويشوه المحتوى داخل شريط التنقل لمحاكاة انكسار الزجاج الواقعي. ينشئ مظهراً زجاجياً أصيلاً مع تشوهات موجية خفيفة.';

  @override
  String get tapSaveLocationToFinish => 'انقر على \"حفظ الموقع\" للإنهاء';

  @override
  String get orderPlacedSuccessfully => 'تم تقديم الطلب بنجاح!';

  @override
  String get selectAProductToOrder => 'اختر منتجاً للطلب';

  @override
  String get order => 'الطلب';

  @override
  String storeProducts(Object storeName) {
    return 'منتجات $storeName';
  }

  @override
  String iWouldLikeToOrder(Object price, Object productName) {
    return 'أود طلب: $productName - $price';
  }

  @override
  String get product => 'المنتج';

  @override
  String get trySearchingWithDifferentNameOrEmail => 'جرب البحث باسم أو بريد إلكتروني مختلف';

  @override
  String get startTypingToSearchForUsers => 'ابدأ الكتابة للبحث عن المستخدمين';

  @override
  String get sendRequest => 'إرسال الطلب';

  @override
  String ownershipRequestSentTo(Object userName) {
    return 'تم إرسال طلب الملكية إلى $userName';
  }

  @override
  String get viewAnExample => 'عرض مثال';

  @override
  String get requestAPetId => 'طلب هوية حيوان أليف';

  @override
  String get shippingInformation => 'معلومات الشحن';

  @override
  String get pleaseEnterYourFullName => 'يرجى إدخال اسمك الكامل';

  @override
  String get pleaseEnterYourPhoneNumber => 'يرجى إدخال رقم هاتفك';

  @override
  String get pleaseEnterYourAddress => 'يرجى إدخال عنوانك';

  @override
  String get pleaseEnterYourZipCode => 'يرجى إدخال الرمز البريدي';

  @override
  String get errorLoadingPetIdImage => 'خطأ في تحميل صورة هوية الحيوان الأليف';

  @override
  String get tapImageToViewFullScreen => 'انقر على الصورة لعرضها بالشاشة الكاملة';

  @override
  String get sharePetId => 'مشاركة هوية الحيوان الأليف';

  @override
  String get physicalPetIdRequestSubmittedSuccessfully => 'تم تقديم طلب هوية الحيوان الأليف المادية بنجاح! سيتم الاتصال بك للدفع.';

  @override
  String errorRequestingPhysicalPetId(Object error) {
    return 'خطأ في طلب هوية الحيوان الأليف المادية: $error';
  }

  @override
  String get welcomeToAlifi => 'مرحباً بك في أليفي! تحكم شروط الخدمة هذه (\"الشروط\") استخدامك لتطبيق أليفي المحمول والموقع الإلكتروني (\"التطبيق\")، الذي تشغله أليفي المحدودة (\"نحن\" أو \"لنا\").';

  @override
  String get alifiLtdValuesYourPrivacy => 'تعتز أليفي المحدودة (\"نحن\" أو \"لنا\") بخصوصيتك. تصف سياسة الخصوصية هذه كيفية جمع واستخدام وكشف وحماية معلوماتك الشخصية عند استخدام تطبيق أليفي المحمول والموقع الإلكتروني (يُشار إليهما معاً باسم \"التطبيق\").';

  @override
  String get petAdoptionsForRehomingAnimals => 'تبني الحيوانات الأليفة لإعادة توطين الحيوانات';

  @override
  String get missingPetAnnouncements => 'إعلانات الحيوانات المفقودة';

  @override
  String get provideAccurateAndCompleteInformation => 'تقديم معلومات دقيقة وكاملة';

  @override
  String get keepYourLoginCredentialsSecure => 'الحفاظ على بيانات اعتماد تسجيل الدخول آمنة';

  @override
  String get notifyUsImmediatelyOfUnauthorizedAccess => 'إخطارنا فوراً بأي وصول غير مصرح أو نشاط مشبوه';

  @override
  String get youAreLufi => 'أنت لوفي، مساعد رعاية الحيوانات المحترف والمستشار البيطري. مهمتك الأساسية هي تقديم إرشادات دقيقة قائمة على الأدلة حول صحة الحيوانات وسلوكها وتغذيتها وتدريبها والرعاية العامة.';

  @override
  String get thisProfileWillBePublicAndVisible => 'سيكون هذا الملف الشخصي عاماً ومرئياً للمستخدمين الآخرين';

  @override
  String get createProfile => 'إنشاء ملف شخصي';

  @override
  String get unknownProduct => 'منتج غير معروف';

  @override
  String get nullValue => 'فارغ';

  @override
  String get letsGetYouStarted => 'دعنا نبدأ!';

  @override
  String get signUpAsVetOrStore => 'سجل كطبيب بيطري أو متجر';

  @override
  String get signUpAsVet => 'سجل كطبيب بيطري';

  @override
  String get signUpAsStore => 'سجل كمتجر';

  @override
  String get failedToStartApp => 'فشل في بدء التطبيق';

  @override
  String get deleteVaccine => 'حذف اللقاح';

  @override
  String get deleteVaccineConfirmation => 'هل أنت متأكد من أنك تريد حذف هذا اللقاح؟';

  @override
  String get undo => 'تراجع';

  @override
  String get deleteIllness => 'حذف المرض';

  @override
  String get deleteIllnessConfirmation => 'هل أنت متأكد من أنك تريد حذف هذا المرض؟';

  @override
  String get storeOwner => 'مالك المتجر';

  @override
  String get addPetForAdoption => 'إضافة حيوان للتبني';

  @override
  String get back => 'رجوع';

  @override
  String get saveListing => 'حفظ الإعلان';

  @override
  String get continueText => 'متابعة';

  @override
  String get basicInformation => 'المعلومات الأساسية';

  @override
  String get tellUsAboutPetForAdoption => 'أخبرنا عن الحيوان الذي تريد وضعه للتبني';

  @override
  String get enterPetName => 'أدخل اسم الحيوان';

  @override
  String get pleaseEnterName => 'يرجى إدخال اسم';

  @override
  String get helpPotentialAdopters => 'ساعد المتبنين المحتملين على فهم الحيوان بشكل أفضل';

  @override
  String get enterBreed => 'أدخل السلالة';

  @override
  String get unit => 'الوحدة';

  @override
  String get petPhoto => 'صورة الحيوان';

  @override
  String get clearPhotoHelpsAdopters => 'الصورة الواضحة تساعد المتبنين المحتملين على التواصل مع الحيوان';

  @override
  String get tapToAddPhoto => 'انقر لإضافة صورة';

  @override
  String get petDocumentation => 'وثائق الحيوان';

  @override
  String get helpAdoptersUnderstandBackground => 'ساعد المتبنين المحتملين على فهم خلفية الحيوان';

  @override
  String get vaccinated => 'مطعم';

  @override
  String get microchipped => 'مزود بشريحة إلكترونية';

  @override
  String get houseTrained => 'مدرب على المنزل';

  @override
  String get goodWithKids => 'جيد مع الأطفال';

  @override
  String get goodWithDogs => 'جيد مع الكلاب';

  @override
  String get goodWithCats => 'جيد مع القطط';

  @override
  String get yourPhoneNumber => 'رقم هاتفك';

  @override
  String get pleaseEnterContactNumber => 'يرجى إدخال رقم اتصال';

  @override
  String get enterLocationManually => 'أدخل الموقع يدوياً';

  @override
  String get manualLocation => 'الموقع اليدوي';

  @override
  String get locationPermissionNotGranted => 'لم يتم منح إذن الموقع';

  @override
  String get dr => 'د.';

  @override
  String get neuteredSpayed => 'مخصي/مستأصل';

  @override
  String get healthIssuesOptional => 'مشاكل صحية (اختياري)';

  @override
  String get healthIssuesPlaceholder => 'أي حالات صحية أو احتياجات خاصة...';

  @override
  String get additionalRequirementsOptional => 'متطلبات إضافية (اختياري)';

  @override
  String get requirementsPlaceholder => 'أي متطلبات محددة للمتبنين المحتملين...';

  @override
  String get howCanAdoptersReachYou => 'كيف يمكن للمتبنين المحتملين الوصول إليك؟';

  @override
  String get autoDetectedLocation => 'الموقع المكتشف تلقائياً';

  @override
  String get enterCityStateOrAddress => 'أدخل مدينتك أو ولايتك أو عنوانك';

  @override
  String get editPet => 'تعديل الحيوان';

  @override
  String get pleaseEnterPetName => 'يرجى إدخال اسم الحيوان';

  @override
  String get addPhotoOfYourPet => 'أضف صورة لحيوانك';

  @override
  String get chooseColorForPetProfile => 'اختر لوناً لملف الحيوان الشخصي';

  @override
  String get found => 'تم العثور عليه';

  @override
  String get markAsFound => 'تحديد كموجود';

  @override
  String get markAsFoundConfirmation => 'هل أنت متأكد من أنك تريد تحديد هذا الحيوان كموجود؟';

  @override
  String get trySearchingWithDifferentName => 'جرب البحث باسم أو بريد إلكتروني مختلف';

  @override
  String get startTypingToSearch => 'ابدأ الكتابة للبحث عن المستخدمين';

  @override
  String get placeOrder => 'تقديم الطلب';

  @override
  String get confirmOrder => 'تأكيد الطلب';

  @override
  String get shipOrder => 'شحن الطلب';

  @override
  String get deliverOrder => 'توصيل الطلب';

  @override
  String get ship => 'شحن';

  @override
  String get deliver => 'توصيل';

  @override
  String areYouSureYouWantToOrder(Object price, Object productName, Object quantity) {
    return 'هل أنت متأكد من أنك تريد طلب $quantity x \"$productName\" مقابل $price؟';
  }

  @override
  String confirmThatYouWillFulfill(Object productName) {
    return 'تأكيد أنك ستقوم بتنفيذ الطلب لـ \"$productName\"؟';
  }

  @override
  String markOrderAsShipped(Object productName) {
    return 'تحديد الطلب لـ \"$productName\" كشحون؟';
  }

  @override
  String markOrderAsDelivered(Object productName) {
    return 'تحديد الطلب لـ \"$productName\" كموصول؟';
  }

  @override
  String areYouSureYouWantToCancel(Object productName) {
    return 'هل أنت متأكد من أنك تريد إلغاء الطلب لـ \"$productName\"؟';
  }

  @override
  String get enterPetNameRequired => 'أدخل اسم حيوانك الأليف (مطلوب)';

  @override
  String get describePetFeatures => 'صف حيوانك الأليف - الحجم، اللون، الميزات المميزة... (مطلوب)';

  @override
  String get addContactNumber => 'إضافة رقم الاتصال';

  @override
  String get enterContactNumber => 'أدخل رقم الاتصال';

  @override
  String get add => 'إضافة';

  @override
  String get remove => 'إزالة';

  @override
  String get rewardOptional => 'المكافأة (اختياري)';

  @override
  String get enterRewardAmount => 'أدخل مبلغ المكافأة';

  @override
  String get missingPetReportSubmitted => 'تم إرسال تقرير الحيوان الأليف المفقود';

  @override
  String get hopeYouFindPetSoon => 'نأمل أن تجد حيوانك الأليف قريباً! سيتم إخطار المجتمع.';

  @override
  String get couldNotGetLocation => 'تعذر الحصول على الموقع الحالي. يرجى المحاولة مرة أخرى.';

  @override
  String get failedToReportLostPet => 'فشل في الإبلاغ عن الحيوان الأليف المفقود. يرجى المحاولة مرة أخرى.';

  @override
  String get noLostPetReportFound => 'لم يتم العثور على تقرير حيوان أليف مفقود لهذا الحيوان.';

  @override
  String greatNewsMarkAsFound(Object petName) {
    return 'أخبار رائعة! هل أنت متأكد من أنك تريد تحديد $petName كموجود؟ سيتم تحديث تقرير الحيوان الأليف المفقود.';
  }

  @override
  String get petMarkedAsFound => 'تم تحديد الحيوان الأليف كموجود بنجاح';

  @override
  String failedToMarkAsFound(Object error) {
    return 'فشل في التحديد كموجود: $error';
  }

  @override
  String get myPetsPatients => 'حيواناتي الأليفة (المرضى)';

  @override
  String get selectProductToOrder => 'اختر منتج للطلب';

  @override
  String get checkout => 'الدفع';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get manageAddresses => 'إدارة العناوين';

  @override
  String get addAddress => 'إضافة عنوان';

  @override
  String get youDontHaveAnyAddressesToShipTo => 'ليس لديك أي عناوين للشحن إليها';

  @override
  String get couponCode => 'رمز القسيمة';

  @override
  String get enterCouponCode => 'أدخل رمز القسيمة';

  @override
  String get apply => 'تطبيق';

  @override
  String get couponFunctionalityComingSoon => 'وظيفة القسيمة قريباً!';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String subtotal(Object quantity) {
    return 'المجموع الفرعي (${quantity}x)';
  }

  @override
  String get shipping => 'الشحن';

  @override
  String get tax => 'الضريبة';

  @override
  String get appFee => 'رسوم التطبيق';

  @override
  String get total => 'المجموع: ';

  @override
  String get addAddressToContinue => 'أضف عنوان للمتابعة';

  @override
  String get completePayment => 'إتمام الدفع';

  @override
  String get choosePaymentMethod => 'اختر طريقة الدفع';

  @override
  String get cibEpayment => 'الدفع الإلكتروني CIB';

  @override
  String get paySecurelyWithYourCibCard => 'ادفع بأمان ببطاقة CIB الخاصة بك';

  @override
  String get edahabia => 'الذهبية';

  @override
  String get payWithYourEdahabiaCard => 'ادفع ببطاقة الذهبية الخاصة بك';

  @override
  String get poweredBy => 'مدعوم من';

  @override
  String get paymentOnDelivery => 'الدفع عند التسليم';

  @override
  String get payWhenYourOrderArrives => 'ادفع عند وصول طلبك';

  @override
  String get totalAmount => 'المبلغ الإجمالي';

  @override
  String get selectPaymentMethod => 'اختر طريقة الدفع';

  @override
  String get completeSecurePayment => 'إتمام الدفع الآمن';

  @override
  String get processingPayment => 'معالجة الدفع...';

  @override
  String get pleaseSelectAPaymentMethod => 'يرجى اختيار طريقة دفع.';

  @override
  String paymentComingSoon(Object methodName) {
    return 'دفع $methodName قريباً!';
  }

  @override
  String errorCreatingPayment(Object error) {
    return 'خطأ في إنشاء الدفع: $error';
  }

  @override
  String get paymentWasCancelled => 'تم إلغاء الدفع';

  @override
  String get processingPaymentTitle => 'معالجة الدفع';

  @override
  String get pleaseWaitWhileWeVerifyYourPayment => 'يرجى الانتظار بينما نتحقق من دفعتك';

  @override
  String get verifyingPaymentStatus => 'التحقق من حالة الدفع...';

  @override
  String get verifyingPayment => 'التحقق من الدفع';

  @override
  String get checkingPaymentStatusManually => 'فحص حالة الدفع يدوياً';

  @override
  String get paymentVerificationTimeout => 'انتهت مهلة التحقق من الدفع. يرجى فحص حالة الدفع يدوياً.';

  @override
  String get paymentFailed => 'فشل الدفع';

  @override
  String errorProcessingOrder(Object error) {
    return 'خطأ في معالجة الطلب: $error';
  }

  @override
  String paymentForProductPlusAppFee(Object productName) {
    return 'الدفع لـ $productName + رسوم التطبيق';
  }

  @override
  String get paymentMethodCashOnDelivery => 'طريقة الدفع: الدفع عند التسليم | الحالة: في انتظار الدفع';

  @override
  String helloIJustPlacedAnOrder(Object orderId, Object productName) {
    return 'مرحباً! لقد قمت للتو بتقديم طلب لـ $productName. الدفع عند التسليم. رقم الطلب: $orderId';
  }

  @override
  String get orderConfirmed => 'تم تأكيد الطلب!';

  @override
  String yourOrderOfHasBeenConfirmed(Object amount) {
    return 'تم تأكيد طلبك بقيمة $amount.';
  }

  @override
  String get yourOrderHasBeenConfirmed => 'تم تأكيد طلبك! ستدفع عند تسليم المنتج إلى عنوانك.';

  @override
  String get backToHome => 'العودة إلى الصفحة الرئيسية';

  @override
  String get paymentSuccessful => 'تم الدفع بنجاح!';

  @override
  String amount(Object amount) {
    return 'المبلغ: $amount';
  }

  @override
  String orderId(Object id) {
    return 'رقم الطلب: $id';
  }

  @override
  String get paymentProcessedSuccessfully => 'تم معالجة دفعتك بنجاح. ستتلقى رسالة تأكيد بالبريد الإلكتروني قريباً.';

  @override
  String get continueButton => 'متابعة';

  @override
  String get paymentFailedTitle => 'فشل الدفع';

  @override
  String get paymentCouldNotBeProcessed => 'تعذر معالجة دفعتك. يرجى التحقق من تفاصيل الدفع والمحاولة مرة أخرى.';

  @override
  String get goBack => 'العودة';

  @override
  String get noOrdersYet => 'لا توجد طلبات بعد';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get viewOrder => 'عرض الطلب';

  @override
  String get orderCancelled => 'تم إلغاء الطلب بنجاح';

  @override
  String errorCancellingOrder(Object error) {
    return 'خطأ في إلغاء الطلب: $error';
  }

  @override
  String get noUnreadMessages => 'لا توجد رسائل غير مقروءة';

  @override
  String get pleaseLogInToViewOrders => 'يرجى تسجيل الدخول لعرض الطلبات';

  @override
  String errorLoadingOrders(Object error) {
    return 'خطأ في تحميل الطلبات: $error';
  }

  @override
  String get checkConsoleForErrorDetails => 'تحقق من وحدة التحكم للحصول على تفاصيل الخطأ';

  @override
  String get yourOrdersWillAppearHere => 'ستظهر طلباتك هنا';

  @override
  String get lastSeenLabel => 'آخر مرة شوهد';

  @override
  String errorMessage(Object error) {
    return 'خطأ: $error';
  }

  @override
  String petMarkedAsFoundWithName(Object petName) {
    return 'تم تحديد $petName كموجود!';
  }

  @override
  String storeWithName(Object storeName) {
    return 'المتجر: $storeName';
  }

  @override
  String get confirmDelivery => 'تأكيد التسليم';

  @override
  String get orderStatusPending => 'في الانتظار';

  @override
  String get orderStatusOrdered => 'تم الطلب';

  @override
  String get orderStatusConfirmed => 'مؤكد';

  @override
  String get orderStatusShipped => 'تم الشحن';

  @override
  String get orderStatusDelivered => 'تم التسليم';

  @override
  String get orderStatusConfirmedDelivered => 'تم تأكيد التسليم';

  @override
  String get orderStatusDisputedDelivery => 'تسليم متنازع عليه';

  @override
  String get orderStatusCancelled => 'ملغى';

  @override
  String get orderStatusRefunded => 'مسترد';

  @override
  String daysAgo(Object days) {
    return 'منذ $days يوم';
  }

  @override
  String hoursAgo(Object hours) {
    return 'منذ $hours ساعة';
  }

  @override
  String minutesAgo(Object minutes) {
    return 'منذ $minutes دقيقة';
  }

  @override
  String get unknownStore => 'متجر غير معروف';

  @override
  String get errorLoadingStoreInfo => 'خطأ في تحميل معلومات المتجر';

  @override
  String get noDiscussionsYet => 'لا توجد مناقشات بعد';

  @override
  String get conversationsWithSellersWillAppearHere => 'ستظهر محادثاتك مع البائعين هنا';

  @override
  String errorLoadingDiscussions(Object error) {
    return 'خطأ في تحميل المناقشات: $error';
  }

  @override
  String get pleaseLogInToViewDiscussions => 'يرجى تسجيل الدخول لعرض المناقشات';

  @override
  String get invalidConversationData => 'بيانات محادثة غير صالحة';

  @override
  String get orderProgress => 'تقدم الطلب';

  @override
  String stepOf(Object current, Object total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get typeAMessage => 'اكتب رسالة...';

  @override
  String get shareMedia => 'مشاركة الوسائط';

  @override
  String get camera => 'الكاميرا';

  @override
  String get takeAPhoto => 'التقاط صورة';

  @override
  String get photoLibrary => 'مكتبة الصور';

  @override
  String get chooseFromLibrary => 'اختيار من المكتبة';

  @override
  String get video => 'فيديو';

  @override
  String get recordOrChooseVideo => 'تسجيل أو اختيار فيديو';

  @override
  String errorSelectingMedia(Object error) {
    return 'خطأ في اختيار الوسائط: $error';
  }

  @override
  String uploading(Object current, Object total) {
    return 'جاري الرفع... ($current/$total)';
  }

  @override
  String mediaAttachments(Object count) {
    return 'مرفقات الوسائط ($count)';
  }

  @override
  String get failedToUploadMedia => 'فشل في رفع ملفات الوسائط';

  @override
  String get checkOutThisProduct => 'تحقق من هذا المنتج!';

  @override
  String get interestedInYourService => 'مهتم بخدمتك';

  @override
  String get aboutMyLostPet => 'عن حيواني الأليف المفقود';

  @override
  String get petRescueConfirmation => 'تأكيد إنقاذ الحيوان الأليف';

  @override
  String didPersonHelpReunite(Object personName) {
    return 'هل ساعدك $personName بنجاح في لم شملك بحيوانك الأليف المفقود في الاجتماع المجدول؟';
  }

  @override
  String get addToRescueCount => 'سيضيف هذا +1 إلى عدد الحيوانات الأليفة التي أنقذها ويساعد أصحاب الحيوانات الأليفة الآخرين.';

  @override
  String get no => 'لا';

  @override
  String get yesRescued => 'نعم، تم الإنقاذ!';

  @override
  String rescueRecorded(Object personName) {
    return '🎉 تم تسجيل الإنقاذ! $personName لديه الآن +1 حيوان أليف تم إنقاذه.';
  }

  @override
  String failedToRecordRescue(Object error) {
    return 'فشل في تسجيل الإنقاذ: $error';
  }

  @override
  String get markMeetingAsFinished => 'تحديد الاجتماع كمنتهي؟';

  @override
  String get markMeetingCompleted => 'سيحدد هذا الاجتماع المجدول كمكتمل ويسأل عما إذا كان حيوانك الأليف قد تم إنقاذه بنجاح.';

  @override
  String get onlyOncePerMeeting => 'يمكنك القيام بذلك مرة واحدة فقط لكل اجتماع.';

  @override
  String get markAsFinished => 'وضع علامة كمنتهي';

  @override
  String get meetingMarkedFinished => '✅ تم تحديد الاجتماع كمنتهي!';

  @override
  String failedToFinishMeeting(Object error) {
    return 'فشل في إنهاء الاجتماع: $error';
  }

  @override
  String get meetingProposalSent => 'تم إرسال اقتراح الاجتماع!';

  @override
  String get failedToProposeMeeting => 'فشل في اقتراح اللقاء';

  @override
  String get meetingConfirmed => 'تم تأكيد الاجتماع';

  @override
  String get failedToConfirmMeeting => 'فشل في تأكيد اللقاء';

  @override
  String get meetingRejected => 'تم رفض اللقاء';

  @override
  String get failedToRejectMeeting => 'فشل في رفض اللقاء';

  @override
  String get meetingDetailsUpdated => 'تم تحديث تفاصيل اللقاء!';

  @override
  String get failedToUpdateMeetingDetails => 'فشل في تحديث تفاصيل اللقاء';

  @override
  String get scheduleMeeting => 'جدولة اجتماع';

  @override
  String get sharingProduct => 'مشاركة منتج';

  @override
  String sharingService(Object serviceType) {
    return 'مشاركة خدمة $serviceType';
  }

  @override
  String get sharingOrderDetails => 'مشاركة تفاصيل الطلب';

  @override
  String lostPet(Object petName) {
    return 'حيوان أليف مفقود: $petName';
  }

  @override
  String get mixedBreed => 'سلالة مختلطة';

  @override
  String reward(Object amount) {
    return 'مكافأة: \$$amount';
  }

  @override
  String get lostPetInformation => 'معلومات الحيوان الأليف المفقود';

  @override
  String get orderConfirmation => 'تأكيد الطلب';

  @override
  String orderNumber(Object orderId) {
    return 'الطلب رقم #$orderId';
  }

  @override
  String get petIdentification => 'تحديد هوية الحيوان الأليف';

  @override
  String isThisMediaOfPet(Object mediaType) {
    return 'هل هذه $mediaType لحيوانك الأليف المفقود؟';
  }

  @override
  String get confirmedThisIsPet => 'مؤكد: هذا هو حيوانك الأليف';

  @override
  String get confirmedThisIsNotPet => 'مؤكد: هذا ليس حيوانك الأليف';

  @override
  String get failedToSaveIdentification => 'فشل في حفظ التحديد';

  @override
  String personConfirmedPet(Object personName) {
    return 'أكد $personName أن هذا هو حيوانه الأليف';
  }

  @override
  String personConfirmedNotPet(Object personName) {
    return 'أكد $personName أن هذا ليس حيوانه الأليف';
  }

  @override
  String get picture => 'صورة';

  @override
  String get photo => 'صورة';

  @override
  String get book => 'حجز';

  @override
  String get vetConsultation => 'استشارة طبيب بيطري';

  @override
  String get storeChat => 'محادثة المتجر';

  @override
  String get customerChat => 'محادثة العميل';

  @override
  String serviceProvider(Object serviceType) {
    return 'مقدم خدمة $serviceType';
  }

  @override
  String get attachProduct => 'إرفاق منتج';

  @override
  String get attachService => 'إرفاق خدمة';

  @override
  String get attachOrder => 'إرفاق طلب';

  @override
  String get attachLostPet => 'إرفاق حيوان أليف مفقود';

  @override
  String get attachPhoto => 'إرفاق صورة';

  @override
  String get attachVideo => 'إرفاق فيديو';

  @override
  String get gallery => 'المعرض';

  @override
  String get imageUploaded => 'تم رفع الصورة بنجاح';

  @override
  String errorUploadingImage(Object error) {
    return 'خطأ في رفع الصورة: $error';
  }

  @override
  String get videoUploaded => 'تم رفع الفيديو بنجاح';

  @override
  String errorUploadingVideo(Object error) {
    return 'خطأ في رفع الفيديو: $error';
  }

  @override
  String get yesterday => 'أمس';

  @override
  String get longTimeAgo => 'منذ وقت طويل';

  @override
  String get messageDeleted => 'تم حذف الرسالة';

  @override
  String get areYouSureDeleteMessage => 'هل أنت متأكد من حذف هذه الرسالة؟';

  @override
  String get yes => 'نعم';

  @override
  String get unblockUser => 'إلغاء حظر المستخدم';

  @override
  String get areYouSureBlockUser => 'هل أنت متأكد من حظر هذا المستخدم؟';

  @override
  String get areYouSureUnblockUser => 'هل أنت متأكد من إلغاء حظر هذا المستخدم؟';

  @override
  String get userUnblocked => 'تم إلغاء حظر المستخدم بنجاح';

  @override
  String errorBlockingUser(Object error) {
    return 'خطأ في حظر المستخدم: $error';
  }

  @override
  String errorUnblockingUser(Object error) {
    return 'خطأ في إلغاء حظر المستخدم: $error';
  }

  @override
  String get reportReason => 'سبب الإبلاغ';

  @override
  String get spam => 'رسائل مزعجة';

  @override
  String get harassment => 'تحرش';

  @override
  String get reportSubmitted => 'تم تقديم البلاغ بنجاح';

  @override
  String errorSubmittingReport(Object error) {
    return 'خطأ في تقديم البلاغ: $error';
  }

  @override
  String get areYouSureClearChat => 'هل أنت متأكد من مسح جميع الرسائل في هذه المحادثة؟';

  @override
  String errorClearingChat(Object error) {
    return 'خطأ في مسح المحادثة: $error';
  }

  @override
  String get meetingScheduled => 'تم جدولة الاجتماع بنجاح';

  @override
  String errorSchedulingMeeting(Object error) {
    return 'خطأ في جدولة الاجتماع: $error';
  }

  @override
  String get meetingDate => 'تاريخ الاجتماع';

  @override
  String get meetingTime => 'وقت اللقاء';

  @override
  String get meetingLocation => 'موقع الاجتماع';

  @override
  String get meetingNotes => 'ملاحظات الاجتماع';

  @override
  String get confirmMeeting => 'تأكيد الاجتماع';

  @override
  String get meetingCancelled => 'تم إلغاء الاجتماع';

  @override
  String errorConfirmingMeeting(Object error) {
    return 'خطأ في تأكيد الاجتماع: $error';
  }

  @override
  String errorCancellingMeeting(Object error) {
    return 'خطأ في إلغاء الاجتماع: $error';
  }

  @override
  String get coordinateMeeting => 'تنسيق لقاء لإعادة توحيدك مع حيوانك الأليف! 🐾';

  @override
  String get proposeNewMeeting => 'اقتراح لقاء جديد';

  @override
  String get meetingPlace => 'مكان اللقاء';

  @override
  String get enterMeetingLocation => 'أدخل موقع اللقاء...';

  @override
  String get selectDateAndTime => 'اختر التاريخ والوقت...';

  @override
  String get updateMeeting => 'تحديث اللقاء';

  @override
  String get proposeMeeting => 'اقتراح لقاء';

  @override
  String get waitingForConfirmation => 'في انتظار التأكيد...';

  @override
  String get waitingForResponse => 'في انتظار الرد...';

  @override
  String get noLocationSet => 'لم يتم تحديد الموقع';

  @override
  String get reject => 'رفض';

  @override
  String get editDetails => 'تعديل التفاصيل';
}
