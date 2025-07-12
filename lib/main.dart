import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'icons.dart';
import 'dialogs/terms_of_service_dialog.dart';
import 'dialogs/privacy_policy_dialog.dart';
import 'dialogs/report_problem_dialog.dart';
import 'pages/page_container.dart';
import 'services/auth_service.dart';
import 'services/device_performance.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  try {
    print('Starting app initialization...');
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize device performance detection
    await DevicePerformance().initialize();
    print('Device performance detection initialized');
    
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

    runApp(const MainApp());
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService()..init(),
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'Inter',
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
        builder: (context, child) {
          // Add performance optimizations
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // Show splash screen while initializing
    if (!authService.isInitialized) {
      return const SplashScreen();
    }

    // If authenticated, show main app
    if (authService.isAuthenticated) {
      return const PageContainer();
    }

    // If not authenticated, show login page
    return const LoginPage();
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
        child: Hero(
          tag: 'logo',
          child: Image.asset(
            'assets/images/alifi_logo.png',
            width: logoWidth,
            fit: BoxFit.contain,
          ),
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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.6; // 60% of screen width for login page

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(),
              Hero(
                tag: 'logo',
                flightShuttleBuilder: (
                  BuildContext flightContext,
                  Animation<double> animation,
                  HeroFlightDirection flightDirection,
                  BuildContext fromHeroContext,
                  BuildContext toHeroContext,
                ) {
                  return Image.asset(
                    'assets/images/alifi_logo.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                  );
                },
                child: Image.asset(
                  'assets/images/alifi_logo.png',
                  width: logoWidth,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 80),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _SocialButton(
                      text: 'Continue with Facebook',
                      icon: AppIcons.facebookIcon,
                      color: const Color(0xFF1877F2),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12),
                    _SocialButton(
                      text: 'Continue with Google',
                      icon: AppIcons.googleIcon,
                      color: Colors.white,
                      textColor: Colors.black87,
                      borderColor: Colors.grey[300],
                      onPressed: () => _handleGoogleSignIn(context),
                    ),
                    const SizedBox(height: 12),
                    _SocialButton(
                      text: 'Continue with Apple',
                      icon: AppIcons.appleIcon,
                      iconSize: 20,
                      color: Colors.black,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 16),
                    _SocialButton(
                      text: 'Continue as Guest',
                      color: Colors.white,
                      textColor: Colors.black87,
                      borderColor: Colors.grey[300],
                      onPressed: () => _navigateToHome(context),
                    ),
                    const SizedBox(height: 32),
                    TextButton(
                      onPressed: () => _showReportProblemDialog(context),
                      child: const Text(
                        'Report a problem',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      children: [
                        const TextSpan(
                            text: 'By clicking continue, you agree to our '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: Colors.blue[700],
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _showTermsDialog(context),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Colors.blue[700],
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _showPrivacyDialog(context),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
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
