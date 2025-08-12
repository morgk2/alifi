import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'icons.dart';
import 'dialogs/terms_of_service_dialog.dart';
import 'dialogs/privacy_policy_dialog.dart';
import 'dialogs/report_problem_dialog.dart';
import 'pages/page_container.dart';
import 'pages/vet_signup_page.dart';
import 'pages/store_signup_page.dart';
import 'pages/location_setup_page.dart';
import 'pages/admin_users_page.dart';
import 'services/auth_service.dart';
import 'services/device_performance.dart';
import 'services/storage_service.dart';
import 'services/navigation_service.dart';
import 'utils/navigation_bar_detector.dart';
import 'config/supabase_config.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'widgets/spinning_loader.dart';
import 'services/database_service.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:google_sign_in/google_sign_in.dart';
import 'services/places_service.dart';
import 'services/push_notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'utils/locale_notifier.dart';
import 'dart:ui' as ui;
import 'l10n/app_localizations.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dialogs/notification_permission_dialog.dart';
import 'services/appointment_reminder_service.dart';
import 'services/notification_service.dart';
import 'services/currency_service.dart';
import 'services/permission_service.dart';
import 'dialogs/permission_request_dialog.dart';
import 'services/map_focus_service.dart';
import 'services/display_settings_service.dart';
import 'services/user_preferences_service.dart';
import 'services/chargily_pay_service.dart';
import 'widgets/keyboard_dismissible_text_field.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

Future<void> main() async {
  try {
    print('Starting app initialization...');
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize WebView for Android and iOS (skip for web)
    if (!kIsWeb) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        WebViewPlatform.instance = AndroidWebViewPlatform();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        WebViewPlatform.instance = WebKitWebViewPlatform();
      }
    }
    
    // Initialize device performance detection
    await DevicePerformance().initialize();
    print('Device performance detection initialized');
    
    // Initialize Supabase
    await Supabase.initialize(
      url: SupabaseConfig.projectUrl,
      anonKey: SupabaseConfig.anonKey,
    );
    print('Supabase initialized successfully');

    // Test Supabase storage connection (with timeout)
    try {
      final storageService = StorageService(Supabase.instance.client);
      final isConnected = await storageService.testConnection().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('Supabase connection test timed out');
          return false;
        },
      );
      print('Supabase storage connection test: ${isConnected ? 'SUCCESS' : 'FAILED'}');
    } catch (e) {
      print('Error testing Supabase connection: $e');
    }
    
    // Optimize for smoother rendering
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    
    print('Flutter binding initialized');
    
    // Initialize Firebase
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');

      // Configure Firestore for web
      if (kIsWeb) {
        FirebaseFirestore.instance.enablePersistence().catchError((e) {
          print('Error enabling Firestore persistence: $e');
        });
        print('Firestore web persistence configured');
      }

      // Run vet users migration (non-blocking)
      DatabaseService().migrateVetUsers().catchError((e) {
        print('Error in vet users migration: $e');
      });
      print('Vet users migration started');

      // Update all user follower/following counts (non-blocking)
      DatabaseService().updateAllUserCounts().catchError((e) {
        print('Error in user counts migration: $e');
      });
      print('User counts migration started');

      // Initialize push notifications with delay and error handling
      Future.delayed(const Duration(seconds: 2), () async {
        try {
          await PushNotificationService().initialize();
          print('Push notifications initialized');
          
          // Check if notifications are enabled and show permission dialog if needed
          final notificationService = PushNotificationService();
          final notificationsEnabled = await notificationService.areNotificationsEnabled();
          
          if (!notificationsEnabled) {
            // Show permission dialog after a short delay
            Future.delayed(const Duration(seconds: 3), () {
              _showNotificationPermissionDialog();
            });
          }

          // Initialize Chargily Pay service
          try {
            await ChargilyPayService().initialize();
            print('Chargily Pay service initialized');
          } catch (e) {
            print('Error initializing Chargily Pay service: $e');
          }

          // Initialize appointment reminder service
          final appointmentReminderService = AppointmentReminderService();
          appointmentReminderService.initialize();
          print('Appointment reminder service initialized');
        } catch (e) {
          print('Error initializing push notifications: $e');
          // Don't crash the app if push notifications fail
        }
      });
    } catch (e) {
      print('Error initializing Firebase: $e');
      // Continue anyway as the app should work in guest mode
    }

    // Configure Firestore
    if (kIsWeb) {
      try {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        print('Firestore web settings configured');
      } catch (e) {
        print('Error configuring Firestore settings: $e');
      }
    }

    // Initialize Places Service cache (with timeout)
    try {
      await PlacesService.initialize().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('Places Service initialization timed out');
        },
      );
      print('Places Service cache initialized');
    } catch (e) {
      print('Error initializing Places Service: $e');
    }

    // Initialize Navigation Bar Detector
    try {
      await NavigationBarDetector.initialize();
      print('Navigation Bar Detector initialized');
    } catch (e) {
      print('Error initializing Navigation Bar Detector: $e');
    }

    // Initialize user preferences service
    final userPreferencesService = UserPreferencesService();
    await userPreferencesService.initialize();
    
    // Get the saved language preference or use default
    final savedLocale = userPreferencesService.language;
    
    runApp(LocaleNotifierProvider(
      initialLocale: savedLocale,
      preferencesService: userPreferencesService,
      child: MainApp(userPreferencesService: userPreferencesService),
    ));
    
    // Check and request permissions after app is initialized (mobile only)
    if (!kIsWeb) {
      Future.delayed(const Duration(seconds: 2), () {
        _checkAndRequestPermissions();
      });
    }
    
    print('App started successfully');
  } catch (e, stackTrace) {
    print('Fatal error during app initialization: $e');
    print('Stack trace: $stackTrace');
    // Show an error UI instead of crashing
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Failed to start the app',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Error: $e',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

// Global function to show notification permission dialog
void _showNotificationPermissionDialog() {
  // This will be called from the main function
  // The dialog will be shown when the app is ready
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Use a simpler approach - the dialog will be shown from the MainApp widget
    _shouldShowNotificationDialog = true;
  });
}

// Global flag to show notification dialog
bool _shouldShowNotificationDialog = false;

// Global flag to show permission dialog
bool _shouldShowPermissionDialog = false;

void _checkAndRequestPermissions() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _shouldShowPermissionDialog = true;
  });
}

class MainApp extends StatefulWidget {
  final UserPreferencesService userPreferencesService;
  
  const MainApp({super.key, required this.userPreferencesService});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    // Check if we should show the notification permission dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_shouldShowNotificationDialog) {
        _shouldShowNotificationDialog = false;
        _showNotificationDialog();
      }
    });
    
    // Check and request permissions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_shouldShowPermissionDialog) {
        _shouldShowPermissionDialog = false;
        _checkAndShowPermissionDialog();
      }
    });
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const NotificationPermissionDialog(),
    );
  }

  void _checkAndShowPermissionDialog() async {
    // Skip permission dialog on web
    if (kIsWeb) {
      print('Skipping permission dialog on web platform');
      return;
    }
    
    try {
      final permissionService = PermissionService();
      final status = await permissionService.getPermissionStatus();
      
      final needsLocation = !status['location']!;
      final needsNotification = !status['notification']!;
      
      if (needsLocation || needsNotification) {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => PermissionRequestDialog(
              needsLocation: needsLocation,
              needsNotification: needsNotification,
              onComplete: () {
                print('Permission request completed');
              },
            ),
          );
        }
      }
    } catch (e) {
      print('Error checking permissions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeNotifierState = LocaleNotifier.of(context);
    final locale = localeNotifierState?.localeNotifier.locale ?? const Locale('en');
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService()..init(),
        ),
        Provider(
          create: (_) => DatabaseService(),
        ),
        Provider(
          create: (_) => StorageService(Supabase.instance.client),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationService(),
        ),
        ChangeNotifierProvider(
          create: (_) => CurrencyService(),
        ),
        ChangeNotifierProvider(
          create: (_) => MapFocusService(),
        ),
        ChangeNotifierProvider.value(
          value: widget.userPreferencesService,
        ),
        ChangeNotifierProxyProvider<UserPreferencesService, DisplaySettingsService>(
          create: (_) => DisplaySettingsService(),
          update: (_, preferencesService, displaySettingsService) {
            displaySettingsService?.setPreferencesService(preferencesService);
            return displaySettingsService ?? DisplaySettingsService();
          },
        ),
      ],
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        theme: ThemeData(
          fontFamily: 'InterDisplay',
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
              TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
            },
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
            ),
          ),
          iconButtonTheme: IconButtonThemeData(
            style: IconButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
            ),
          ),
        ),
        home: const AuthWrapper(),
        locale: locale,
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
          Locale('fr'),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          // Only wrap with RepaintBoundary and ScrollConfiguration, no floating button
          return RepaintBoundary(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                physics: const ClampingScrollPhysics(),
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: child!,
            ),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showDebugButton = false;

  @override
  void initState() {
    super.initState();
    _checkDebugMode();
  }

  void _checkDebugMode() {
    assert(() {
      setState(() => _showDebugButton = true);
      return true;
    }());
  }

  Future<void> _showAuthDebugInfo() async {
    final googleSignIn = GoogleSignIn();
    final firebaseAuth = FirebaseAuth.instance;

    try {
      // Check current sign-in state
      final isSignedIn = await googleSignIn.isSignedIn();
      final currentGoogleUser = await googleSignIn.signInSilently();
      final firebaseUser = firebaseAuth.currentUser;

      String debugInfo = '''
Google Sign-In Status:
- Is Signed In: $isSignedIn
- Current Google User: ${currentGoogleUser?.email ?? 'null'}
- Google ID Token: ${currentGoogleUser != null ? 'Present' : 'null'}

Firebase Status:
- Current User: ${firebaseUser?.email ?? 'null'}
- User ID: ${firebaseUser?.uid ?? 'null'}
- Is Email Verified: ${firebaseUser?.emailVerified ?? 'null'}
- Provider Data: ${firebaseUser?.providerData.map((p) => p.providerId).join(', ') ?? 'null'}
''';

      // Show debug info
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Auth Debug Info'),
          content: SingleChildScrollView(
            child: SelectableText(debugInfo),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Sign out of everything
                await googleSignIn.signOut();
                await firebaseAuth.signOut();
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signed out of all services')),
                );
              },
              child: const Text('Force Sign Out'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to get debug info: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final notificationService = context.read<NotificationService>();
    
    // Initialize notification listeners when user is authenticated
    if (authService.isAuthenticated && authService.currentUser != null) {
      final user = authService.currentUser!;
      notificationService.initializeListeners(user.id, user.accountType);
    }
    
    Widget mainContent;
    // Show splash screen while initializing or loading user
    if (!authService.isInitialized || authService.isLoadingUser) {
      mainContent = const SplashScreen();
    }
    // If authenticated, check if vet/store needs location setup
    else if (authService.isAuthenticated) {
      if (authService.needsLocationSetup()) {
        mainContent = const LocationSetupRedirect();
      } else {
        mainContent = PageContainer(key: pageContainerKey);
      }
    }
    // If not authenticated, show login page
    else {
      mainContent = const LoginPage();
    }

    return mainContent;
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.7; // 70% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/images/alifi_logo.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _fadeAnimation,
              child: const CupertinoActivityIndicator(
                radius: 16,
                color: CupertinoColors.systemOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  
  late Animation<double> _fadeAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    // Start the animation after Hero animation completes
    Future.delayed(const Duration(milliseconds: 800), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToHome(BuildContext context) {
    NavigationService.pushReplacement(
      context,
      const PageContainer(),
    );
  }

  void _showReportProblemDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (context) => const ReportProblemDialog(),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TermsOfServiceDialog(),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PrivacyPolicyDialog(),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authService = context.read<AuthService>();
    final user = await authService.signInWithGoogle();
    if (user != null && mounted) {
      _navigateToHome(context);
    }
  }

  Future<void> _handleGuestSignIn(BuildContext context) async {
    final authService = context.read<AuthService>();
    await authService.signInAsGuest();
    if (mounted) {
      _navigateToHome(context);
    }
  }

  Future<void> _handleFacebookSignIn(BuildContext context) async {
    final authService = context.read<AuthService>();
    final user = await authService.signInWithFacebook();
    if (user != null && mounted) {
      _navigateToHome(context);
    }
  }

  void _debugAuthState(BuildContext context) async {
    final authService = context.read<AuthService>();
    
    // Check Firebase auth state directly
    try {
      final firebaseAuth = FirebaseAuth.instance;
      final firebaseUser = firebaseAuth.currentUser;
      
      // Show a dialog with the debug info
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Debug Info'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AuthService initialized: ${authService.isInitialized}'),
                Text('AuthService loading: ${authService.isLoadingUser}'),
                Text('AuthService authenticated: ${authService.isAuthenticated}'),
                Text('AuthService user: ${authService.currentUser?.email ?? 'null'}'),
                Text('Firebase user: ${firebaseUser?.email ?? 'null'}'),
                Text('Guest mode: ${authService.isGuestMode}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error checking Firebase auth state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.5; // 50% of screen width for login page
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 48),
                Center(
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/logo_cropped.png',
                        width: logoWidth,
                        fit: BoxFit.contain,
                      ),
                      // Hidden admin button over the logo
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            // Show admin users page
                            NavigationService.push(
                              context,
                              const AdminUsersPage(),
                            );
                          },
                          child: Container(
                            color: Colors.transparent,
                            width: logoWidth,
                            height: logoWidth * 0.3, // Approximate logo height
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Let's get you started!",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _SocialButton(
                            text: 'Continue with Google',
                            icon: AppIcons.googleIcon,
                            color: Colors.white,
                            textColor: Colors.black87,
                            borderColor: Colors.grey[300],
                            onPressed: () => _handleGoogleSignIn(context),
                          ),
                          const SizedBox(height: 16),
                          _SocialButton(
                            text: 'Continue with Facebook',
                            icon: AppIcons.facebookIcon,
                            color: Colors.white,
                            textColor: Colors.black87,
                            borderColor: Colors.grey[300],
                            onPressed: () => _handleFacebookSignIn(context),
                          ),
                          const SizedBox(height: 16),
                          _SocialButton(
                            text: localizations.continueAsGuest,
                            icon: AppIcons.appleIcon,
                            iconSize: 20,
                            color: Colors.white,
                            textColor: Colors.black87,
                            borderColor: Colors.grey[300],
                            onPressed: () => _handleGuestSignIn(context),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'sign up as a vet or a store',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  NavigationService.push(
                                    context,
                                    const VetSignUpPage(),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF2196F3)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text(
                                  'Sign up as a vet',
                                  style: TextStyle(
                                    color: Color(0xFF2196F3),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              OutlinedButton(
                                onPressed: () {
                                  NavigationService.push(
                                    context,
                                    const StoreSignUpPage(),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF4CAF50)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text(
                                  'Sign up as a store',
                                  style: TextStyle(
                                    color: Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final String? icon;
  final double iconSize;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.text,
    this.icon,
    this.iconSize = 24,
    required this.color,
    this.textColor = Colors.white,
    this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: borderColor != null ? 0 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
          splashFactory: NoSplash.splashFactory,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              SvgPicture.string(
                icon!,
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(
                  textColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GeminiChatBox extends StatefulWidget {
  const GeminiChatBox({super.key});

  @override
  State<GeminiChatBox> createState() => _GeminiChatBoxState();
}

class _GeminiChatBoxState extends State<GeminiChatBox> {
  static final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  bool _loading = false;
  static const String _apiKey = 'AIzaSyB32jJtKaieqAx2OLUs0TkXnBJD2zhuilc';

  Future<String> _fetchGeminiReply(String userMessage) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text": "You are a virtual pet dog named Lufi. You are a friendly, helpful pet assistant that detects and responds in the same language the user uses. For example, if they write in French, respond in French. If they write in English, respond in English, etc. Focus on giving clear, practical, and supportive pet care advice while maintaining a warm and approachable tone in the user's preferred language. You may occasionally use gentle pet-like expressions, but prioritize being informative and helpful over being playful."
            },
            {"text": userMessage}
          ]
        }
      ]
    });
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final parts = data['candidates'][0]['content']['parts'];
        if (parts != null && parts.isNotEmpty && parts[0]['text'] != null) {
          return parts[0]['text'];
        }
      }
      return 'No response from Gemini.';
    } else {
      return 'Error: ${response.statusCode}\n${response.body}';
    }
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': userMessage});
      _controller.clear();
      _loading = true;
    });
    _listKey.currentState?.insertItem(_messages.length - 1);
    final reply = await _fetchGeminiReply(userMessage);
    setState(() {
      _messages.add({'role': 'ai', 'text': reply});
      _loading = false;
    });
    _listKey.currentState?.insertItem(_messages.length - 1);
  }

  Widget _buildMessage(BuildContext context, int index, Animation<double> animation) {
    final msg = _messages[index];
    final isUser = msg['role'] == 'user';
    final text = msg['text'] ?? '';
    final isOneLine = _isOneLine(text, context);
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1.0,
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/images/ai_lufi.png'),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.deepPurple[100] : Colors.grey[200],
                    borderRadius: isOneLine
                        ? BorderRadius.circular(32)
                        : BorderRadius.circular(20),
                  ),
                  child: isUser
                      ? Text(
                          text,
                          style: const TextStyle(fontSize: 16),
                        )
                      : _buildFormattedAiMessage(text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to format AI message with bold/large titles for **Title** lines
  Widget _buildFormattedAiMessage(String text) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: lines.map((line) {
        final boldTitle = RegExp(r'^\*\*(.+)\*\*$');
        final match = boldTitle.firstMatch(line.trim());
        if (match != null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              match.group(1)!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Text(
              line,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage('assets/images/ai_lufi.png'),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(32),
              ),
              child: _AnimatedTypingDots(),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to determine if the text is one line in the current context
  bool _isOneLine(String text, BuildContext context) {
    final span = TextSpan(text: text, style: const TextStyle(fontSize: 16));
    final tp = TextPainter(
      text: span,
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
    );
    tp.layout(maxWidth: MediaQuery.of(context).size.width * 0.7);
    return !tp.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Stack(
      children: [
        // Transparent layer to detect taps outside the sheet
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            color: Colors.transparent,
          ),
        ),
        DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 6,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const Text(
                  'AI pet assistant',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Expanded(
                  child: AnimatedList(
                    key: _listKey,
                controller: scrollController,
                    initialItemCount: _messages.length,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    itemBuilder: (context, index, animation) => _buildMessage(context, index, animation),
              ),
            ),
            if (_loading)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: _buildTypingIndicator(),
              ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 8,
                  right: 8,
                  bottom: mq.viewInsets.bottom + mq.padding.bottom + 16, // Add safe space for nav bar
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(32), // pill shape
                        ),
                        child: KeyboardDismissibleTextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Type your message...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                          enabled: !_loading,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_upward_rounded),
                        color: Colors.white,
                        onPressed: _loading ? null : _sendMessage,
                        iconSize: 24,
                        splashRadius: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
          ),
        ),
      ],
    );
  }
}

// Animated typing dots widget
class _AnimatedTypingDots extends StatefulWidget {
  @override
  State<_AnimatedTypingDots> createState() => _AnimatedTypingDotsState();
}

class _AnimatedTypingDotsState extends State<_AnimatedTypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _dotAnimations = List.generate(3, (i) {
      // Each dot animates up and down in a wave, with a smooth loop
      return TweenSequence([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: -8).chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: -8, end: 0).chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.18, 0.64 + i * 0.18, curve: Curves.linear),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _dotAnimations[i].value),
                child: child,
              );
            },
            child: Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Language switcher widget for use in settings page
class LanguageSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localeNotifierState = LocaleNotifier.of(context);
    final currentLocale = localeNotifierState?.localeNotifier.locale ?? const Locale('en');
    
    return DropdownButton<Locale>(
      value: currentLocale,
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          localeNotifierState?.changeLocale(newLocale);
        }
      },
      items: const [
        DropdownMenuItem(
          value: Locale('en'),
          child: Text('English'),
        ),
        DropdownMenuItem(
          value: Locale('ar'),
          child: Text('العربية'),
        ),
        DropdownMenuItem(
          value: Locale('fr'),
          child: Text('Français'),
        ),
      ],
    );
  }
}

// Widget to redirect vet/store users to location setup if they don't have a business location
class LocationSetupRedirect extends StatelessWidget {
  const LocationSetupRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    return const LocationSetupPage();
  }
}
