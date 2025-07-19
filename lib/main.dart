import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'widgets/spinning_loader.dart';
import 'services/database_service.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

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

      // Configure Firestore for web
      if (kIsWeb) {
        FirebaseFirestore.instance.enablePersistence().catchError((e) {
          print('Error enabling Firestore persistence: $e');
        });
        print('Firestore web persistence configured');
      }
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
      create: (_) => AuthService()..init(),
        ),
        Provider(
          create: (_) => DatabaseService(),
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    
    print('AuthWrapper: isInitialized=${authService.isInitialized}, isLoadingUser=${authService.isLoadingUser}, isAuthenticated=${authService.isAuthenticated}');
    print('AuthWrapper: currentUser=${authService.currentUser?.email ?? 'null'}, isGuestMode=${authService.isGuestMode}');

    // Show splash screen while initializing or loading user
    if (!authService.isInitialized || authService.isLoadingUser) {
      print('AuthWrapper: Showing splash screen');
      return const SplashScreen();
    }

    // If authenticated, show main app
    if (authService.isAuthenticated) {
      print('AuthWrapper: User is authenticated, showing main app');
      return const PageContainer();
    }

    // If not authenticated, show login page
    print('AuthWrapper: User is not authenticated, showing login page');
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
    print('LoginPage: Google Sign-In button pressed');
    final authService = context.read<AuthService>();
    print('LoginPage: Calling authService.signInWithGoogle()');
    final user = await authService.signInWithGoogle();
    print('LoginPage: signInWithGoogle() returned: ${user?.email ?? 'null'}');
    if (user != null && mounted) {
      print('LoginPage: User signed in successfully, navigating to home');
      _navigateToHome(context);
    } else {
      print('LoginPage: Sign-in failed or user is null');
    }
  }

  void _debugAuthState(BuildContext context) async {
    final authService = context.read<AuthService>();
    print('Debug Auth State:');
    print('isInitialized: ${authService.isInitialized}');
    print('isLoadingUser: ${authService.isLoadingUser}');
    print('isAuthenticated: ${authService.isAuthenticated}');
    print('currentUser: ${authService.currentUser?.email ?? 'null'}');
    print('isGuestMode: ${authService.isGuestMode}');
    
    // Check Firebase auth state directly
    try {
      final firebaseAuth = FirebaseAuth.instance;
      final firebaseUser = firebaseAuth.currentUser;
      print('Firebase Auth State:');
      print('Current Firebase user: ${firebaseUser?.email ?? 'null'}');
      print('Firebase user ID: ${firebaseUser?.uid ?? 'null'}');
      print('Firebase user display name: ${firebaseUser?.displayName ?? 'null'}');
      
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
    final logoWidth = size.width * 0.6; // 60% of screen width for login page

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
          child: Column(
            children: [
                  const SizedBox(height: 40),
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
                    // Debug button for testing
                    if (kDebugMode)
                      _SocialButton(
                        text: 'Debug: Check Auth State',
                        icon: AppIcons.googleIcon,
                        color: Colors.orange,
                        textColor: Colors.white,
                        onPressed: () => _debugAuthState(context),
                      ),
                    if (kDebugMode) const SizedBox(height: 12),
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
                  const SizedBox(height: 40),
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
      textDirection: TextDirection.ltr,
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
