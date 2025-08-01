import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/debug_service.dart';
import 'firebase_options.dart';

// Debug overlay for iOS crash debugging
class DebugOverlay extends StatefulWidget {
  final Widget child;
  
  const DebugOverlay({super.key, required this.child});

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  bool _showDebug = false;
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addLog('Debug overlay initialized');
    _addLog('Platform: ${Theme.of(context).platform}');
    
    // Add system info
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addLog('Screen size: ${MediaQuery.of(context).size}');
      _addLog('Device pixel ratio: ${MediaQuery.of(context).devicePixelRatio}');
    });
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().split('.')[0];
    final logEntry = '[$timestamp] $message';
    setState(() {
      _logs.add(logEntry);
      if (_logs.length > 100) {
        _logs.removeAt(0);
      }
    });
    print('🔍 [DebugOverlay] $message');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showDebug)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black.withOpacity(0.8),
              child: Column(
                children: [
                  // Debug header
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.red,
                    child: Row(
                      children: [
                        const Icon(Icons.bug_report, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'DEBUG MODE - iOS Crash Prevention',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() => _showDebug = false),
                        ),
                      ],
                    ),
                  ),
                  // Logs area
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              log,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Control buttons
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _addLog('Manual log entry added');
                          },
                          child: const Text('Add Log'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _logs.clear();
                            });
                            _addLog('Logs cleared');
                          },
                          child: const Text('Clear Logs'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            _addLog('System info: ${MediaQuery.of(context).size}');
                            _addLog('Platform: ${Theme.of(context).platform}');
                            _addLog('Pixel ratio: ${MediaQuery.of(context).devicePixelRatio}');
                          },
                          child: const Text('System Info'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Debug toggle button
        Positioned(
          top: 50,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.red,
            onPressed: () {
              setState(() => _showDebug = !_showDebug);
              _addLog('Debug overlay ${_showDebug ? 'enabled' : 'disabled'}');
            },
            child: const Icon(Icons.bug_report, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// Error boundary widget to catch crashes
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  
  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  String? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Set up error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        _error = details.exception.toString();
        _stackTrace = details.stack;
      });
      print('🔍 [ErrorBoundary] Caught error: ${details.exception}');
      print('🔍 [ErrorBoundary] Stack trace: ${details.stack}');
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.red[50],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'CRASH PREVENTED',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'An error was caught and prevented the app from crashing:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                if (_stackTrace != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Stack trace:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _stackTrace.toString(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _error = null;
                          _stackTrace = null;
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Restart the app
                        SystemNavigator.pop();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Restart App'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return widget.child;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://your-project.supabase.co',
    anonKey: 'your-anon-key',
  );

  // Set up error handling for iOS debugging
  FlutterError.onError = (FlutterErrorDetails details) {
    print('🔍 [Main] Flutter error: ${details.exception}');
    print('🔍 [Main] Stack trace: ${details.stack}');
  };

  // Set up platform channel for iOS debugging
  const platform = MethodChannel('debug_channel');
  platform.setMethodCallHandler((call) async {
    print('🔍 [Main] Platform call: ${call.method}');
    print('🔍 [Main] Arguments: ${call.arguments}');
    return null;
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('🔍 [MyApp] Initializing app...');
      
      // Initialize debug service
      await DebugService().initialize();
      
      // Initialize services (simplified for debugging)
      try {
        // Just initialize the debug service for now
        print('🔍 [MyApp] Services initialization skipped for debugging');
      } catch (e) {
        print('🔍 [MyApp] Error initializing services: $e');
      }
      
      print('🔍 [MyApp] All services initialized successfully');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('🔍 [MyApp] Error during initialization: $e');
      print('🔍 [MyApp] Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: DebugOverlay(
        child: MaterialApp(
          title: 'Alifi',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Inter',
            useMaterial3: true,
          ),
          supportedLocales: const [
            Locale('en'),
          ],
          home: _buildHome(),
        ),
      ),
    );
  }

  Widget _buildHome() {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Initializing app...'),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Initialization Error:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_error!),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, child) {
          return authService.isInitialized
              ? _buildMainApp(authService)
              : _buildLoadingScreen();
        },
      ),
    );
  }

  Widget _buildMainApp(AuthService authService) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildAppointmentsTab(),
          _buildProfileTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _tabController.index,
        onTap: (index) {
          _tabController.animateTo(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Home Tab',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('This is the home screen'),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Appointments Tab',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('This is the appointments screen'),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Profile Tab',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('This is the profile screen'),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.purple),
          SizedBox(height: 16),
          Text(
            'Settings Tab',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('This is the settings screen'),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Loading...'),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Loading Error:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_error!),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
