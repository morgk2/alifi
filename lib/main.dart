import 'package:flutter/material.dart';
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
import 'services/auth_service.dart';
import 'services/device_performance.dart';
import 'services/storage_service.dart';
import 'config/supabase_config.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'widgets/spinning_loader.dart';
import 'services/database_service.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:google_sign_in/google_sign_in.dart';
import 'services/places_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'utils/locale_notifier.dart';
import 'dart:ui' as ui;
import 'l10n/app_localizations.dart';
import 'package:dotted_border/dotted_border.dart';

Future<void> main() async {
  try {
    print('Starting app initialization...');
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize device performance detection
    await DevicePerformance().initialize();
    print('Device performance detection initialized');
    
    // Initialize Supabase
    await Supabase.initialize(
      url: SupabaseConfig.projectUrl,
      anonKey: SupabaseConfig.anonKey,
    );
    print('Supabase initialized successfully');

    // Test Supabase storage connection
    final storageService = StorageService(Supabase.instance.client);
    final isConnected = await storageService.testConnection();
    print('Supabase storage connection test: ${isConnected ? 'SUCCESS' : 'FAILED'}');
    
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

      // Run vet users migration
      await DatabaseService().migrateVetUsers();
      print('Vet users migration completed');

      // Update all user follower/following counts
      await DatabaseService().updateAllUserCounts();
      print('User counts migration completed');
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

    // Initialize Places Service cache
    await PlacesService.initialize();
    print('Places Service cache initialized');

    runApp(LocaleNotifierProvider(
      initialLocale: const Locale('en'),
      child: const MainApp(),
    ));
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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
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
      ],
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'InterDisplay',
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
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
    
    Widget mainContent;
    // Show splash screen while initializing or loading user
    if (!authService.isInitialized || authService.isLoadingUser) {
      mainContent = const SplashScreen();
    }
    // If authenticated, show main app
    else if (authService.isAuthenticated) {
      mainContent = const PageContainer();
    }
    // If not authenticated, show login page
    else {
      mainContent = const LoginPage();
    }

    return mainContent;
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
            Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/images/alifi_logo.png',
                width: logoWidth,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            const SpinningLoader(
              size: 32,
              color: Colors.orange,
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const PageContainer()),
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

  Future<void> _handleAppleSignIn(BuildContext context) async {
    final authService = context.read<AuthService>();
    final user = await authService.signInWithApple();
    if (user != null && mounted) {
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
                  child: Image.asset(
                    'assets/images/logo_cropped.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
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
                            text: 'Continue with Apple',
                            icon: AppIcons.appleIcon,
                            iconSize: 20,
                            color: Colors.white,
                            textColor: Colors.black87,
                            borderColor: Colors.grey[300],
                            onPressed: () => _handleAppleSignIn(context),
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
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => const VetSignUpPage(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.ease;
                                        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ),
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
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => const StoreSignUpPage(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.ease;
                                        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ),
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
                        child: TextField(
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

// Update VetSignUpPage to collect user input and pass it to the summary page
class VetSignUpPage extends StatefulWidget {
  const VetSignUpPage({super.key});

  @override
  State<VetSignUpPage> createState() => _VetSignUpPageState();
}

class _VetSignUpPageState extends State<VetSignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController clinicLocationController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isValid = false;

  void _validate() {
    setState(() {
      isValid =
        firstNameController.text.trim().isNotEmpty &&
        lastNameController.text.trim().isNotEmpty &&
        clinicNameController.text.trim().isNotEmpty &&
        clinicLocationController.text.trim().isNotEmpty &&
        cityController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    firstNameController.addListener(_validate);
    lastNameController.addListener(_validate);
    clinicNameController.addListener(_validate);
    clinicLocationController.addListener(_validate);
    cityController.addListener(_validate);
    phoneController.addListener(_validate);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    clinicNameController.dispose();
    clinicLocationController.dispose();
    cityController.dispose();
    phoneController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.35;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Image.asset(
                    'assets/images/vet_3d.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sign up as a vet',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4092FF),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'to sign up as a vet in alifi, you need to provide us with these information. all information must be accurate',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _RoundedTextField(hint: 'First name', controller: firstNameController),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoundedTextField(hint: 'Last name', controller: lastNameController),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _RoundedTextField(hint: 'Your clinic name', controller: clinicNameController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _RoundedTextField(hint: 'Your clinic location', controller: clinicLocationController),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoundedTextField(hint: 'City', controller: cityController),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _RoundedTextField(hint: 'Phone number', controller: phoneController, isPhone: true),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isValid ? () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => VetSignUpSummaryPage(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            clinicName: clinicNameController.text,
                            clinicLocation: clinicLocationController.text,
                            city: cityController.text,
                            phone: phoneController.text,
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4092FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text.rich(
                  TextSpan(
                    text: 'By continuing, you agree to our ',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final bool isPhone;
  const _RoundedTextField({required this.hint, this.controller, this.isPhone = false});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.number : TextInputType.text,
      inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF4092FF)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
}

class StoreSignUpPage extends StatefulWidget {
  const StoreSignUpPage({super.key});

  @override
  State<StoreSignUpPage> createState() => _StoreSignUpPageState();
}

class _StoreSignUpPageState extends State<StoreSignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController storeLocationController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isValid = false;

  void _validate() {
    setState(() {
      isValid =
        firstNameController.text.trim().isNotEmpty &&
        lastNameController.text.trim().isNotEmpty &&
        storeNameController.text.trim().isNotEmpty &&
        storeLocationController.text.trim().isNotEmpty &&
        cityController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    firstNameController.addListener(_validate);
    lastNameController.addListener(_validate);
    storeNameController.addListener(_validate);
    storeLocationController.addListener(_validate);
    cityController.addListener(_validate);
    phoneController.addListener(_validate);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    storeNameController.dispose();
    storeLocationController.dispose();
    cityController.dispose();
    phoneController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.35;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Image.asset(
                    'assets/images/store_3d.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sign up as a store',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28a745),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'to sign up as a store in alifi, you need to provide us with these information. all information must be accurate',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _RoundedTextField(hint: 'First name', controller: firstNameController),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoundedTextField(hint: 'Last name', controller: lastNameController),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _RoundedTextField(hint: 'Your store name', controller: storeNameController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _RoundedTextField(hint: 'Your store location', controller: storeLocationController),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoundedTextField(hint: 'City', controller: cityController),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _RoundedTextField(hint: 'Phone number', controller: phoneController, isPhone: true),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isValid ? () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => StoreSignUpSummaryPage(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            storeName: storeNameController.text,
                            storeLocation: storeLocationController.text,
                            city: cityController.text,
                            phone: phoneController.text,
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28a745),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text.rich(
                  TextSpan(
                    text: 'By continuing, you agree to our ',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// In VetSignUpSummaryPage, link the continue button to VetSubscriptionPage with right-slide
class VetSignUpSummaryPage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String clinicName;
  final String clinicLocation;
  final String city;
  final String phone;
  const VetSignUpSummaryPage({super.key, required this.firstName, required this.lastName, required this.clinicName, required this.clinicLocation, required this.city, required this.phone});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.28;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'assets/images/vet_3d2.png',
                width: logoWidth,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Finishing things up!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4092FF),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: DottedBorder(
                color: const Color(0xFFBFD8F9),
                strokeWidth: 1.5,
                dashPattern: [6, 3],
                borderType: BorderType.RRect,
                radius: const Radius.circular(16),
                padding: EdgeInsets.zero,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$firstName, $lastName', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(clinicName, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text('${clinicLocation.isNotEmpty ? clinicLocation + ', ' : ''}$city', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: Image.asset(
                          'assets/images/logo_cropped.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => VetSubscriptionPage(
                        firstName: firstName,
                        lastName: lastName,
                        clinicName: clinicName,
                        clinicLocation: clinicLocation,
                        city: city,
                        phone: phone,
                      ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4092FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoreSignUpSummaryPage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String storeName;
  final String storeLocation;
  final String city;
  final String phone;
  const StoreSignUpSummaryPage({super.key, required this.firstName, required this.lastName, required this.storeName, required this.storeLocation, required this.city, required this.phone});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.28;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'assets/images/store_3d2.png',
                width: logoWidth,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Finishing things up!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF28a745),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: DottedBorder(
                color: const Color(0xFFa3d8b8),
                strokeWidth: 1.5,
                dashPattern: [6, 3],
                borderType: BorderType.RRect,
                radius: const Radius.circular(16),
                padding: EdgeInsets.zero,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$firstName, $lastName', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(storeName, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text('${storeLocation.isNotEmpty ? storeLocation + ', ' : ''}$city', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: Image.asset(
                          'assets/images/logo_cropped.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => StoreSubscriptionPage(
                        firstName: firstName,
                        lastName: lastName,
                        storeName: storeName,
                        storeLocation: storeLocation,
                        city: city,
                        phone: phone,
                      ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF28a745),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VetSubscriptionPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String clinicName;
  final String clinicLocation;
  final String city;
  final String phone;
  const VetSubscriptionPage({super.key, required this.firstName, required this.lastName, required this.clinicName, required this.clinicLocation, required this.city, required this.phone});

  @override
  State<VetSubscriptionPage> createState() => _VetSubscriptionPageState();
}

class _VetSubscriptionPageState extends State<VetSubscriptionPage> {
  int selected = 0;

  final List<Map<String, dynamic>> offers = [
    {
      'title': 'alifi verified',
      'price': '900 DZD',
      'features': [
        'Adds your clinic to our the map',
        'Special marking for your clinic in the map',
        'Get patients to book appointments with you through the app',
        'Manage your schedule and appointments through the app',
      ],
    },
    {
      'title': 'alifi affiliated',
      'price': '1200 DZD',
      'features': [
        'Adds your clinic to our the map',
        'Even more special marking for your clinic in the map',
        'Get patients to book appointments with you through the app',
        'Manage your schedule and appointments through the app',
        'Have a verification badge on your profile and on the map',
        'Appear first on the search (when there\'s no favorite near)',
      ],
    },
    {
      'title': 'alifi favorite',
      'price': '2000 DZD',
      'features': [
        'Adds your clinic to our the map',
        'Get the most special marking for your clinic in the map',
        'Get patients to book appointments with you through the app',
        'Manage your schedule and appointments through the app',
        'Have a verification badge on your profile and on the map',
        'Appear on the homescreen when close',
        'Appear first on the search',
        'Get to post on homescreen',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.28;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Image.asset(
                  'assets/images/vet_3d2.png',
                  width: logoWidth,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Finishing things up!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4092FF),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose your offer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4092FF),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(3, (i) {
                    final isSelected = selected == i;
                    final isFavorite = i == 2;
                    final cardWidth = MediaQuery.of(context).size.width / 3.4;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The card itself
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: EdgeInsets.only(right: i < 2 ? 12 : 0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selected = i;
                                  });
                                },
                                child: AnimatedScale(
                                  scale: isSelected ? 1.08 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: AnimatedOpacity(
                                    opacity: isSelected ? 1.0 : 0.7,
                                    duration: const Duration(milliseconds: 300),
                                    child: Container(
                                      width: cardWidth,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 22),
                                      decoration: BoxDecoration(
                                        color: isFavorite ? const Color(0xFFFFF7E0) : Colors.white,
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF4092FF) : Colors.grey.shade300,
                                          width: 2.5,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: isFavorite
                                            ? [
                                                BoxShadow(
                                                  color: Colors.amber.withOpacity(0.13),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                offers[i]['title'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: isFavorite
                                                      ? const Color(0xFFFFB300)
                                                      : Colors.black87,
                                                ),
                                              ),
                                              if (isSelected)
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8.0),
                                                  child: Icon(Icons.check_circle, color: Color(0xFF4092FF), size: 22),
                                                ),
                                            ],
                                          ),
                                          // Add space for the stamp for all cards, so all cards have same height
                                          const SizedBox(height: 54),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Stamp badge at the bottom center of the favorite card, animated with the card's scale
                            if (isFavorite)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 12, // Move the stamp up, closer to the card
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selected = 2;
                                    });
                                  },
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 1.0, end: isSelected ? 1.08 : 1.0),
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: Image.asset(
                                          'assets/images/stamp.png',
                                          width: 72,
                                          height: 72,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monthly price', style: TextStyle(color: Colors.grey, fontSize: 17)),
                    Text(offers[selected]['price'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: ListView.separated(
                      key: ValueKey(selected),
                      itemCount: offers[selected]['features'].length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE0E0E0)),
                      itemBuilder: (context, idx) {
                        final feature = offers[selected]['features'][idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  feature,
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ),
                              if (feature.contains('info'))
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Icon(Icons.info_outline, color: Colors.grey, size: 18),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => VetCheckoutPage(
                            selectedOffer: offers[selected],
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            clinicName: widget.clinicName,
                            clinicLocation: widget.clinicLocation,
                            city: widget.city,
                            phone: widget.phone,
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4092FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoreSubscriptionPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String storeName;
  final String storeLocation;
  final String city;
  final String phone;
  const StoreSubscriptionPage({super.key, required this.firstName, required this.lastName, required this.storeName, required this.storeLocation, required this.city, required this.phone});

  @override
  State<StoreSubscriptionPage> createState() => _StoreSubscriptionPageState();
}

class _StoreSubscriptionPageState extends State<StoreSubscriptionPage> {
  int selected = 0;

  final List<Map<String, dynamic>> offers = [
    {
      'title': 'alifi verified',
      'price': '900 DZD',
      'features': [
        'Adds your store to our the map',
        'Special marking for your store in the map',
        'Get customers to find your store through the app',
      ],
    },
    {
      'title': 'alifi affiliated',
      'price': '1200 DZD',
      'features': [
        'Adds your store to our the map',
        'Even more special marking for your store in the map',
        'Get customers to find your store through the app',
        'Have a verification badge on your profile and on the map',
        'Appear first on the search (when there\'s no favorite near)',
      ],
    },
    {
      'title': 'alifi favorite',
      'price': '2000 DZD',
      'features': [
        'Adds your store to our the map',
        'Get the most special marking for your store in the map',
        'Get customers to find your store through the app',
        'Have a verification badge on your profile and on the map',
        'Appear on the homescreen when close',
        'Appear first on the search',
        'Get to post on homescreen',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.28;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Image.asset(
                  'assets/images/store_3d2.png',
                  width: logoWidth,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Finishing things up!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF28a745),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose your offer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF28a745),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(3, (i) {
                    final isSelected = selected == i;
                    final isFavorite = i == 2;
                    final cardWidth = MediaQuery.of(context).size.width / 3.4;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The card itself
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: EdgeInsets.only(right: i < 2 ? 12 : 0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selected = i;
                                  });
                                },
                                child: AnimatedScale(
                                  scale: isSelected ? 1.08 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: AnimatedOpacity(
                                    opacity: isSelected ? 1.0 : 0.7,
                                    duration: const Duration(milliseconds: 300),
                                    child: Container(
                                      width: cardWidth,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 22),
                                      decoration: BoxDecoration(
                                        color: isFavorite ? const Color(0xFFFFF7E0) : Colors.white,
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF28a745) : Colors.grey.shade300,
                                          width: 2.5,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: isFavorite
                                            ? [
                                                BoxShadow(
                                                  color: Colors.amber.withOpacity(0.13),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                offers[i]['title'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: isFavorite
                                                      ? const Color(0xFFFFB300)
                                                      : Colors.black87,
                                                ),
                                              ),
                                              if (isSelected)
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8.0),
                                                  child: Icon(Icons.check_circle, color: Color(0xFF28a745), size: 22),
                                                ),
                                            ],
                                          ),
                                          // Add space for the stamp for all cards, so all cards have same height
                                          const SizedBox(height: 54),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Stamp badge at the bottom center of the favorite card, animated with the card's scale
                            if (isFavorite)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 12, // Move the stamp up, closer to the card
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selected = 2;
                                    });
                                  },
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 1.0, end: isSelected ? 1.08 : 1.0),
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: Image.asset(
                                          'assets/images/stamp.png',
                                          width: 72,
                                          height: 72,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monthly price', style: TextStyle(color: Colors.grey, fontSize: 17)),
                    Text(offers[selected]['price'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: ListView.separated(
                      key: ValueKey(selected),
                      itemCount: offers[selected]['features'].length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE0E0E0)),
                      itemBuilder: (context, idx) {
                        final feature = offers[selected]['features'][idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  feature,
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ),
                              if (feature.contains('info'))
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Icon(Icons.info_outline, color: Colors.grey, size: 18),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => StoreCheckoutPage(
                            selectedOffer: offers[selected],
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            storeName: widget.storeName,
                            storeLocation: widget.storeLocation,
                            city: widget.city,
                            phone: widget.phone,
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28a745),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VetCheckoutPage extends StatefulWidget {
  final Map<String, dynamic> selectedOffer;
  final String firstName;
  final String lastName;
  final String clinicName;
  final String clinicLocation;
  final String city;
  final String phone;
  const VetCheckoutPage({super.key, required this.selectedOffer, required this.firstName, required this.lastName, required this.clinicName, required this.clinicLocation, required this.city, required this.phone});

  @override
  State<VetCheckoutPage> createState() => _VetCheckoutPageState();
}

class _VetCheckoutPageState extends State<VetCheckoutPage> {
  int _selectedPaymentIndex = -1;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'PayPal', 'icon': 'assets/images/paypal_logo.png'},
    {'name': 'CIB_SB', 'icon': 'assets/images/cib_logo.png', 'icon2': 'assets/images/sb_logo.png'},
    {'name': 'Visa/Mastercard', 'icon': 'assets/images/visa_mastercard.png'},
    {'name': 'Stripe', 'icon': 'assets/images/stripe_logo.png'},
    {'name': 'CCP', 'icon': null},
  ];

  void _checkout() {
    if (_selectedPaymentIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return;
    }

    final method = _paymentMethods[_selectedPaymentIndex];
    if (method['name'] == 'CCP') {
      FirebaseFirestore.instance.collection('vet_requests').add({
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'clinicName': widget.clinicName,
        'clinicLocation': widget.clinicLocation,
        'city': widget.city,
        'phone': widget.phone,
        'subscription': widget.selectedOffer['title'],
        'price': widget.selectedOffer['price'],
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const VetCCPConfirmationPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checked out with ${method['name']} (demo only)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.selectedOffer['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: widget.selectedOffer['title'] == 'alifi favorite' ? const Color(0xFFFFB300) : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.selectedOffer['price'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4092FF)),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(widget.selectedOffer['features'].length, (idx) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF4092FF), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.selectedOffer['features'][idx],
                              style: const TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Choose a payment method:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: _paymentMethods.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.8,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, idx) {
                  final method = _paymentMethods[idx];
                  final isSelected = _selectedPaymentIndex == idx;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _selectedPaymentIndex = idx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEAF3FF) : Colors.white,
                        borderRadius: BorderRadius.circular(30), // pill shape
                        border: Border.all(
                          color: isSelected ? const Color(0xFF4092FF) : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: () {
                          if (method['name'] == 'CCP') {
                            return const Text(
                              'CCP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4092FF),
                              ),
                            );
                          } else if (method['name'] == 'CIB_SB') {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (method['icon'] != null)
                                  Image.asset(method['icon']!, height: 20),
                                Container(
                                  height: 18,
                                  width: 1,
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  color: Colors.grey[300],
                                ),
                                if (method['icon2'] != null)
                                  Image.asset(method['icon2']!, height: 20),
                              ],
                            );
                          } else if (method['name'] == 'PayPal') {
                            return Image.asset(
                              method['icon']!,
                              height: 30, // larger logo for PayPal
                            );
                          } else if (method['icon'] != null) {
                            return Image.asset(
                              method['icon']!,
                              height: method['name'] == 'Visa/Mastercard' ? 20 : 24,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }(),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(widget.selectedOffer['price'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _checkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4092FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Checkout', style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Add VetCCPConfirmationPage
class VetCCPConfirmationPage extends StatelessWidget {
  const VetCCPConfirmationPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('CCP Request', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_in_talk, color: Color(0xFF4092FF), size: 64),
              const SizedBox(height: 32),
              const Text(
                'Thank you for choosing CCP!\nAn agent will call you later for confirmation.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your request has been submitted and is pending approval.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4092FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                ),
                child: const Text('Back to Home', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoreCheckoutPage extends StatefulWidget {
  final Map<String, dynamic> selectedOffer;
  final String firstName;
  final String lastName;
  final String storeName;
  final String storeLocation;
  final String city;
  final String phone;
  const StoreCheckoutPage({super.key, required this.selectedOffer, required this.firstName, required this.lastName, required this.storeName, required this.storeLocation, required this.city, required this.phone});

  @override
  State<StoreCheckoutPage> createState() => _StoreCheckoutPageState();
}

class _StoreCheckoutPageState extends State<StoreCheckoutPage> {
  int _selectedPaymentIndex = -1;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'PayPal', 'icon': 'assets/images/paypal_logo.png'},
    {'name': 'CIB_SB', 'icon': 'assets/images/cib_logo.png', 'icon2': 'assets/images/sb_logo.png'},
    {'name': 'Visa/Mastercard', 'icon': 'assets/images/visa_mastercard.png'},
    {'name': 'Stripe', 'icon': 'assets/images/stripe_logo.png'},
    {'name': 'CCP', 'icon': null},
  ];

  void _checkout() {
    if (_selectedPaymentIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return;
    }

    final method = _paymentMethods[_selectedPaymentIndex];
    if (method['name'] == 'CCP') {
      FirebaseFirestore.instance.collection('store_requests').add({
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'storeName': widget.storeName,
        'storeLocation': widget.storeLocation,
        'city': widget.city,
        'phone': widget.phone,
        'subscription': widget.selectedOffer['title'],
        'price': widget.selectedOffer['price'],
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const StoreCCPConfirmationPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checked out with ${method['name']} (demo only)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.selectedOffer['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: widget.selectedOffer['title'] == 'alifi favorite' ? const Color(0xFFFFB300) : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.selectedOffer['price'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF28a745)),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(widget.selectedOffer['features'].length, (idx) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF28a745), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.selectedOffer['features'][idx],
                              style: const TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Choose a payment method:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: _paymentMethods.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.8,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, idx) {
                  final method = _paymentMethods[idx];
                  final isSelected = _selectedPaymentIndex == idx;
                  return InkWell(
                    borderRadius: BorderRadius.circular(30), // pill shape
                    onTap: () => setState(() => _selectedPaymentIndex = idx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE2F5E8) : Colors.white,
                        borderRadius: BorderRadius.circular(30), // pill shape
                        border: Border.all(
                          color: isSelected ? const Color(0xFF28a745) : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: () {
                          if (method['name'] == 'CCP') {
                            return const Text(
                              'CCP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF28a745),
                              ),
                            );
                          } else if (method['name'] == 'CIB_SB') {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (method['icon'] != null)
                                  Image.asset(method['icon']!, height: 20),
                                Container(
                                  height: 18,
                                  width: 1,
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  color: Colors.grey[300],
                                ),
                                if (method['icon2'] != null)
                                  Image.asset(method['icon2']!, height: 20),
                              ],
                            );
                          } else if (method['name'] == 'PayPal') {
                            return Image.asset(
                              method['icon']!,
                              height: 30, // larger logo for PayPal
                            );
                          } else if (method['icon'] != null) {
                            return Image.asset(
                              method['icon']!,
                              height: method['name'] == 'Visa/Mastercard' ? 20 : 24,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }(),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(widget.selectedOffer['price'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _checkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28a745),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Checkout', style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoreCCPConfirmationPage extends StatelessWidget {
  const StoreCCPConfirmationPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('CCP Request', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_in_talk, color: Color(0xFF28a745), size: 64),
              const SizedBox(height: 32),
              const Text(
                'Thank you for choosing CCP!\nAn agent will call you later for confirmation.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your request has been submitted and is pending approval.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF28a745),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                ),
                child: const Text('Back to Home', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
