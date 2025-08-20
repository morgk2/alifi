import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:ui';
import 'dart:async';
import '../models/fundraising.dart';
import '../models/lost_pet.dart';
import '../models/user.dart';
import '../models/appointment.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';

import '../widgets/placeholder_image.dart';
import '../widgets/fundraising_card.dart';
import '../widgets/combined_recommendations_widget.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'leaderboard_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:latlong2/latlong.dart' show Distance, LengthUnit;
import 'package:flutter/animation.dart';
import '../widgets/ai_assistant_card.dart';
import '../widgets/seller_dashboard_card.dart';
import '../widgets/vet_dashboard_card.dart';
import '../widgets/optimized_image.dart';
import '../widgets/today_appointment_widget.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/gift_notification_controller.dart';
import '../widgets/notification_badge.dart';
import '../services/device_performance.dart';
import '../widgets/skeleton_loader.dart';
import 'wishlist_page.dart';
import 'adoption_center_page.dart';
import 'vet_signup_page.dart';
import 'store_signup_page.dart';
import 'user_orders_page.dart';
import '../widgets/services_section.dart';
import '../utils/age_formatter.dart';
import '../utils/app_fonts.dart';


class HomePage extends StatefulWidget {
  final VoidCallback onNavigateToMap;
  final ValueChanged<double>? onSideMenuProgressChanged;

  const HomePage({
    super.key,
    required this.onNavigateToMap,
    this.onSideMenuProgressChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Add side menu state
  bool _isSideMenuOpen = false;
  // Add animation controller for side menu
  late AnimationController _sideMenuController;
  late Animation<double> _sideMenuAnimation;
  // Add drag progress tracking for progressive side menu
  double _dragProgress = 0.0;
  bool _isDragging = false;
  bool _isAnimating = false;
  // Consolidated scroll controller for better performance
  final ScrollController _scrollController = ScrollController();
  final DatabaseService _databaseService = DatabaseService();
  GiftNotificationController? _giftNotificationController;
  
  // Single animation controller for refresh
  late AnimationController _refreshController;
  
  // Replace setState variables with ValueNotifier for better performance
  // Static header only; remove dynamic header notifiers
  final ValueNotifier<int> _currentPetPageNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _currentStorePageNotifier = ValueNotifier<int>(0);
  final ValueNotifier<List<LostPet>> _lostPetsNotifier = ValueNotifier<List<LostPet>>([]);
  final ValueNotifier<latlong.LatLng?> _userLocationNotifier = ValueNotifier<latlong.LatLng?>(null);
  final ValueNotifier<bool> _isLoadingLocationNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isLoadingPetsNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hasAttemptedLoadNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isRefreshingNotifier = ValueNotifier<bool>(false);

  // Back button exit functionality
  DateTime? _lastBackPressTime;

  Future<bool> _onWillPop() async {
    // If side menu is open, close it instead of exiting
    if (_isSideMenuOpen) {
      _closeSideMenu();
      return false;
    }
    
    final now = DateTime.now();
    if (_lastBackPressTime == null || 
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.pressBackAgainToExit ?? 'Press back again to exit'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.black87,
        ),
      );
      return false;
    }
    return true;
  }

  // Precache frequently used asset images for better performance
  void _precacheAssets() {
    if (!mounted) return;
    
    final List<String> assetPaths = [
      'assets/images/notification_icon.png',
      'assets/images/menu.svg',
      'assets/images/header_title.png',
      'assets/images/alifiarabic.png',
      'assets/images/logo_cropped.png',
      'assets/images/ai_pet.png',
      'assets/images/ai_lufi.png',
      'assets/images/loading.png',
      'assets/images/back_icon.png',
      'assets/images/leaderboard.png',
      // Service images for better performance
      'assets/images/adoptionservice.png',
      'assets/images/storeservice.png',
      'assets/images/vetservice.png',
      'assets/images/trainerservice.png',
      'assets/images/groomerservice.png',
    ];
    
    for (final path in assetPaths) {
      try {
        precacheImage(AssetImage(path), context);
      } catch (e) {
        if (kDebugMode) print('Failed to precache $path: $e');
      }
    }
  }

  // Removed unused methods and variables for better performance

  // Removed unused method _reportFound

  void _toggleSideMenu() {
    if (_isSideMenuOpen) {
      _closeSideMenu();
    } else {
      _openSideMenu();
    }
  }

  void _openSideMenu() {
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
    });
    _sideMenuController.animateTo(1.0, duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic);
    
    // Safety timeout to prevent stuck state
    Timer(const Duration(milliseconds: 500), () {
      if (_isAnimating && !_sideMenuController.isAnimating && !_isDragging) {
        _forceResetSideMenu();
      }
    });
  }

  void _closeSideMenu() {
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
    });
    _sideMenuController.animateTo(0.0, duration: const Duration(milliseconds: 250), curve: Curves.easeInCubic);
    
    // Safety timeout to prevent stuck state
    Timer(const Duration(milliseconds: 500), () {
      if (_isAnimating && !_sideMenuController.isAnimating && !_isDragging) {
        _forceResetSideMenu();
      }
    });
  }
  
  void _resetAnimationState() {
    _isAnimating = false;
    _isDragging = false;
    _dragProgress = 0.0;
  }
  
  void _forceResetSideMenu() {
    if (kDebugMode) {
      print('Force resetting side menu state');
    }
    _sideMenuController.reset();
    setState(() {
      _isSideMenuOpen = false;
      _resetAnimationState();
    });
    widget.onSideMenuProgressChanged?.call(0.0);
  }
  


  @override
  void initState() {
    super.initState();
    final devicePerformance = DevicePerformance();
    final isLowEnd = devicePerformance.performanceTier == PerformanceTier.low;
    final animationDuration = isLowEnd ? const Duration(milliseconds: 200) : const Duration(milliseconds: 500);
    
    // Initialize side menu animation controller
    _sideMenuController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Initialize streams - create once to avoid recreating on rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      if (user != null) {
        _todayAppointmentsStream = DatabaseService().getUserTodayAppointments(user.id);
      }
      
      // Precache frequently used asset images
      _precacheAssets();
    });
    
    // Create the side menu animation with throttled progress reporting
    _sideMenuAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sideMenuController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ))
      ..addListener(() {
        // Throttle progress callbacks to avoid excessive parent rebuilds
        final progress = _sideMenuAnimation.value;
        if ((_lastReportedProgress - progress).abs() > 0.01) {
          _lastReportedProgress = progress;
          widget.onSideMenuProgressChanged?.call(progress);
        }
        
        // Update side menu state when animation completes
        if (progress == 0.0 && _isSideMenuOpen) {
          setState(() {
            _isSideMenuOpen = false;
            _isAnimating = false;
          });
        } else if (progress == 1.0 && !_isSideMenuOpen) {
          setState(() {
            _isSideMenuOpen = true;
            _isAnimating = false;
          });
        }
        
        // Safety check: if animation is stuck, reset state
        if (_isAnimating && !_sideMenuController.isAnimating && !_isDragging) {
          if (kDebugMode) {
            print('Animation stuck detected, resetting state');
          }
          setState(() {
            _resetAnimationState();
          });
        }
      });
    
    // Initialize page controller with viewportFraction for showing partial next/prev cards
    _petPageController = PageController(
      viewportFraction: 0.85,
      initialPage: 0,
    );
    
    // Listen to page changes and update the notifier
    _petPageController?.addListener(_onPetPageScroll);
    
    // Initialize single animation controller for refresh
    _refreshController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );
    
    // Add scroll controller listener for main scroll functionality
    _scrollController.addListener(_onScroll);
    
    // Check for appointments first, then load pets
    _checkAppointmentsBeforeLoadingPets();
    
    // Set up a timer to periodically check for appointments
    _appointmentCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkForAppointmentsInBackground(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authService = Provider.of<AuthService>(context);
    if (_giftNotificationController == null) {
      _giftNotificationController =
          GiftNotificationController(context, authService);
    }
    
    // Check for appointments in didChangeDependencies to ensure Provider is available
    _checkForAppointmentsInBackground();
  }
  
  // Check for appointments in the background and update the notifier
  Future<void> _checkForAppointmentsInBackground() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      if (user != null) {
        final appointments = await DatabaseService().getUserTodayAppointments(user.id).first;
        _todayAppointmentsNotifier.value = appointments;
        if (kDebugMode) print('🔍 [HomePage] Found ${appointments.length} appointments for today');
      }
    } catch (e) {
      if (kDebugMode) print('🔍 [HomePage] Error checking appointments in background: $e');
    }
  }

  Position? _currentPosition;
  
  // Store today's appointments
  final ValueNotifier<List<Appointment>> _todayAppointmentsNotifier = ValueNotifier<List<Appointment>>([]);
  
  // Stream for today's appointments - created once in initState
  Stream<List<Appointment>>? _todayAppointmentsStream;
  
  // Throttling for side menu progress callbacks
  double _lastReportedProgress = -1;

  // Initialize location and load pets regardless of appointments
  Future<void> _checkAppointmentsBeforeLoadingPets() async {
    try {
      // Initialize location and load pets
      _initializeLocationAndLoadPets();
    } catch (e) {
      print('🔍 [HomePage] Error initializing location: $e');
    }
  }
  
  // Optimized location initialization with better error handling and performance
  Future<void> _initializeLocationAndLoadPets() async {
    try {
      // On web, use recent pets as fallback since location might not work properly
      if (kIsWeb) {
        print('Running on web platform, showing empty lost pets state (location not available)');
        _lostPetsNotifier.value = [];
        _isLoadingLocationNotifier.value = false;
        return;
      }
      
      // Only check location permission if we don't have a position yet
      if (_currentPosition == null) {
        // Check permission status without requesting immediately
        final status = await Permission.location.status;
        if (status != PermissionStatus.granted) {
          // Only request if not explicitly denied before
          if (status != PermissionStatus.denied && status != PermissionStatus.permanentlyDenied) {
            final requestStatus = await Permission.location.request();
            if (requestStatus != PermissionStatus.granted) {
              print('Location permission denied, showing empty lost pets state');
              _lostPetsNotifier.value = [];
              _isLoadingLocationNotifier.value = false;
              return;
            }
          } else {
            print('Location permission previously denied, showing empty lost pets state');
            _lostPetsNotifier.value = [];
            _isLoadingLocationNotifier.value = false;
            return;
          }
        }

        // Check if location services are enabled
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          print('Location services disabled, showing empty lost pets state');
          _lostPetsNotifier.value = [];
          _isLoadingLocationNotifier.value = false;
          return;
        }
      }

      // Use a compute function to move location calculation off the UI thread
      // This prevents UI jank during location acquisition
      Position? position;
      
      // Try to get last known position first (fast)
      position = await Geolocator.getLastKnownPosition();
      
      // If no last known position, get current position with timeout
      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 2),
          );
        } catch (e) {
          // Use default position if both methods fail
          position = _currentPosition ?? Position(
            latitude: 36.7538,
            longitude: 3.0588,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        }
      }
      
      final userLocation = latlong.LatLng(position.latitude, position.longitude);
      _userLocationNotifier.value = userLocation;
      _currentPosition = position;
      
      // Load nearby lost pets
      _loadNearbyLostPets();
      
    } catch (e) {
      print('Error getting location: $e, showing empty lost pets state');
      _lostPetsNotifier.value = [];
    } finally {
      _isLoadingLocationNotifier.value = false;
    }
  }

  // Stream subscriptions for better memory management
  StreamSubscription? _nearbyPetsSubscription;
  StreamSubscription? _recentPetsSubscription;
  Timer? _appointmentCheckTimer;

  void _loadNearbyLostPets() async {
    
    // Cancel any existing subscription first
    _nearbyPetsSubscription?.cancel();
    _recentPetsSubscription?.cancel();
    
    // Set loading state
    _isLoadingPetsNotifier.value = true;
    _hasAttemptedLoadNotifier.value = true;
    
    // Check if user location is available
    final userLocation = _userLocationNotifier.value;
    if (userLocation == null) {
      print('User location not available, showing empty lost pets state');
      _lostPetsNotifier.value = [];
      _isLoadingPetsNotifier.value = false;
      return;
    }
    
    print('🗺️ [HomePage] Loading nearby lost pets for user location: ${userLocation.latitude.toStringAsFixed(6)}, ${userLocation.longitude.toStringAsFixed(6)}');
    print('📍 [HomePage] Search radius: 10km');
    
    // Subscribe to nearby lost pets stream with proper memory management
    _nearbyPetsSubscription = _databaseService.getNearbyLostPets(
      userLocation: userLocation,
      radiusInKm: 10, // 10km radius for nearby lost pets
    ).listen((pets) {
      if (mounted) {
        print('🎯 [HomePage] Received ${pets.length} nearby lost pets within 10km radius');
        _isLoadingPetsNotifier.value = false;
        if (pets.isEmpty) {
          print('⚠️ [HomePage] No pets found within 10km radius, showing empty state (no fallback)');
          // Don't fall back to recent pets - show empty state instead
          _lostPetsNotifier.value = [];
        } else {
          print('✅ [HomePage] Displaying ${pets.length} nearby lost pets');
          // Log each pet for debugging
          for (int i = 0; i < pets.length; i++) {
            final pet = pets[i];
            final distance = const Distance().as(
              LengthUnit.Kilometer,
              userLocation,
              pet.location,
            );
            print('   ${i + 1}. "${pet.pet.name}" - ${distance.toStringAsFixed(3)}km away');
          }
          _lostPetsNotifier.value = pets;
        }
      }
    }, onError: (error) {
      print('❌ [HomePage] Error loading nearby lost pets: $error');
      // Don't fall back to recent pets on error - show empty state
      _isLoadingPetsNotifier.value = false;
      _lostPetsNotifier.value = [];
    });
  }



  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      final days = difference.inDays;
      final dayText = days == 1 ? AppLocalizations.of(context)!.day : AppLocalizations.of(context)!.days;
      return '$days $dayText ${AppLocalizations.of(context)!.ago}';
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      final hourText = hours == 1 ? AppLocalizations.of(context)!.hour : AppLocalizations.of(context)!.hours;
      return '$hours $hourText ${AppLocalizations.of(context)!.ago}';
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      final minuteText = minutes == 1 ? AppLocalizations.of(context)!.minute : AppLocalizations.of(context)!.minutes;
      return '$minutes $minuteText ${AppLocalizations.of(context)!.ago}';
    } else {
      return AppLocalizations.of(context)!.justNow;
    }
  }

  @override
  void dispose() {
    // Dispose the page controller
    _petPageController?.removeListener(_onPetPageScroll);
    _petPageController?.dispose();
    _petPageController = null;
    
    // Dispose consolidated scroll controller
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    
    // Dispose animation controllers
    _refreshController.dispose();
    _sideMenuController.dispose();
    
    // Cancel all stream subscriptions and timers
    _nearbyPetsSubscription?.cancel();
    _recentPetsSubscription?.cancel();
    _appointmentCheckTimer?.cancel();
    
    // Dispose ValueNotifiers
    _currentPetPageNotifier.dispose();
    _currentStorePageNotifier.dispose();
    _lostPetsNotifier.dispose();
    _userLocationNotifier.dispose();
    _isLoadingLocationNotifier.dispose();
    _isLoadingPetsNotifier.dispose();
    _hasAttemptedLoadNotifier.dispose();
    _isRefreshingNotifier.dispose();
    _todayAppointmentsNotifier.dispose();
    _giftNotificationController?.dispose();
    
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshingNotifier.value && mounted) {
      _refreshController.repeat();
      
      try {
        // Start both operations concurrently
        await Future.wait([
          _checkAppointmentsBeforeLoadingPets(), // Check appointments first
          // Add artificial minimum delay to ensure smooth animation
          Future.delayed(const Duration(milliseconds: 500)),
        ]);
      } finally {
        if (mounted) {
          _refreshController.stop();
          _isRefreshingNotifier.value = false;
        }
      }
    }
  }

  // Completely new implementation for pet card carousel
  PageController? _petPageController;
  
  void _onPetPageScroll() {
    if (_petPageController == null || !mounted) return;
    
    // Get the current page as a double (includes fractional part during animation)
    final double currentPageDouble = _petPageController!.page ?? 0;
    
    // For indicator and other integer-based logic, round to nearest page
    final int currentPage = currentPageDouble.round();
    
    // Update the current page notifier if it changed
    if (currentPage != _currentPetPageNotifier.value) {
      _currentPetPageNotifier.value = currentPage;
    }
  }
  
  void _navigateToPetCard(int direction) {
    if (_petPageController == null || !mounted) return;
    
    final int currentPage = _currentPetPageNotifier.value;
    final int targetPage = currentPage + direction;
    
    // Check bounds
    if (targetPage < 0 || targetPage >= _lostPetsNotifier.value.length) return;
    
    // Animate to the target page with a spring-like effect
    _petPageController!.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
    );
    
    // Add haptic feedback for physical feel
    HapticFeedback.mediumImpact();
  }
  
  void _openLostPetInMap(LostPet lostPet) {
    // Navigate to map and show the lost pet detail dialog
    widget.onNavigateToMap();
    
    // Add a small delay to ensure the map is loaded before showing the dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        // This will trigger the same behavior as clicking a lost pet marker on the map
        // You can implement the specific dialog logic here or call a method from the map page
        _showLostPetDetailDialog(lostPet);
      }
    });
  }
  
  void _showLostPetDetailDialog(LostPet lostPet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Icon(
              Icons.pets,
              color: const Color(0xFFF59E0B),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.lostPetDetails,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lostPet.pet.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${lostPet.pet.breed} • ${AgeFormatter.formatAge(lostPet.pet.age)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    lostPet.address,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Lost ${_formatTimeAgo(lostPet.lastSeenDate)}',
              style: TextStyle(
                color: Colors.orange[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            // Display reward if available
            if (lostPet.reward != null && lostPet.reward! > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF4CAF50),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: const Color(0xFF4CAF50),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '\$${lostPet.reward!.toStringAsFixed(0)} Reward',
                      style: TextStyle(
                        color: const Color(0xFF4CAF50),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (lostPet.contactNumbers.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    lostPet.contactNumbers.first,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.close,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Open in external maps app
              _openInExternalMaps(lostPet);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44), // Increased height
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.openInMaps,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _openInExternalMaps(LostPet lostPet) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${lostPet.location.latitude},${lostPet.location.longitude}';
    try {
      await launchUrlString(url);
    } catch (e) {
      debugPrint('Error opening maps: $e');
    }
  }

  // Consolidated scroll handler for better performance
  void _onScroll() {
    if (!_scrollController.hasClients || !mounted) return;
    
    // Static header: no dynamic visibility logic
    final double offset = _scrollController.offset;
    
    // Static header: no dynamic visibility or opacity logic
    
    // Calculate store page for pagination dots
    final viewportWidth = MediaQuery.of(context).size.width;
    final itemWidth = viewportWidth * 0.6;
    final int page = (offset / itemWidth).round();
    if (page != _currentStorePageNotifier.value) {
      _currentStorePageNotifier.value = page;
    }
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Background color
            Container(
              color: Colors.white,
            ),
            // Side Menu (behind main content)
            AnimatedBuilder(
              animation: _sideMenuAnimation,
              child: RepaintBoundary(child: _buildSideMenu()),
              builder: (context, child) {
                final screenWidth = MediaQuery.of(context).size.width;
                // Use drag progress when dragging, otherwise use animation value
                final progress = _isDragging ? _dragProgress : _sideMenuAnimation.value;
                final dx = -screenWidth * 0.65 * (1 - progress);
                return Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Transform.translate(
                    offset: Offset(dx, 0),
                    child: child,
                  ),
                );
              },
            ),
            // Main content with animation and rounded corners
            AnimatedBuilder(
              animation: _sideMenuAnimation,
              child: RepaintBoundary(child: _buildMainContent()),
              builder: (context, child) {
                final screenWidth = MediaQuery.of(context).size.width;
                // Use drag progress when dragging, otherwise use animation value
                final progress = _isDragging ? _dragProgress : _sideMenuAnimation.value;
                final dx = screenWidth * 0.65 * progress;
                return Transform.translate(
                  offset: Offset(dx, 0),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32 * progress),
                        bottomLeft: Radius.circular(32 * progress),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: child,
                  ),
                );
              },
            ),

            // Overlay to close side menu when tapping outside
            if (_isSideMenuOpen || _isDragging)
              AnimatedBuilder(
                animation: _sideMenuAnimation,
                builder: (context, child) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  // Use drag progress when dragging, otherwise use animation value
                  final progress = _isDragging ? _dragProgress : _sideMenuAnimation.value;
                  return Positioned(
                    left: screenWidth * 0.65 * progress,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _closeSideMenu,
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Heavy main content extracted so AnimatedBuilder can reuse it without rebuilding on every tick
  Widget _buildMainContent() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Prevent gesture conflicts with scrolling
      excludeFromSemantics: true,
      onHorizontalDragStart: (details) {
        if (_isAnimating) return;
        
        // Only allow gesture from left edge when menu is closed, or anywhere when menu is open
        final startPosition = details.globalPosition.dx;
        
        if (!_isSideMenuOpen && startPosition > 80) {
          // If menu is closed, only allow gestures from left edge (first 80 pixels)
          return;
        }
        
        _isDragging = true;
        _dragProgress = _sideMenuController.value;
        
        if (kDebugMode) {
          print('Drag start: position=${startPosition}, _isSideMenuOpen=$_isSideMenuOpen, initial_dragProgress=$_dragProgress');
        }
      },
      onHorizontalDragUpdate: (details) {
        if (!_isDragging || _isAnimating) return;
        
        final screenWidth = MediaQuery.of(context).size.width;
        final dragDistance = details.delta.dx;
        final menuWidth = screenWidth * 0.65;
        final progressIncrement = dragDistance / menuWidth;
        
        // Update drag progress based on drag direction
        setState(() {
          _dragProgress = (_dragProgress + progressIncrement).clamp(0.0, 1.0);
        });
        
        // Directly update the animation controller value for smooth dragging
        _sideMenuController.value = _dragProgress;
        
        // Update parent navigation bar
        widget.onSideMenuProgressChanged?.call(_dragProgress);
        
        if (kDebugMode) {
          print('Drag update: dx=${details.delta.dx}, _dragProgress=$_dragProgress');
        }
      },
      onHorizontalDragEnd: (details) {
        if (!_isDragging) return;
        _isDragging = false;
        
        final velocity = details.primaryVelocity ?? 0.0;
        final threshold = 0.25; // 25% threshold for completion (more responsive)
        
        if (kDebugMode) {
          print('Drag end: _dragProgress=$_dragProgress, velocity=$velocity');
        }
        
        // Determine final state based on progress and velocity
        bool shouldOpen;
        
        if (velocity.abs() > 300) {
          // Medium velocity gesture - follow velocity direction
          shouldOpen = velocity > 0;
        } else if (velocity.abs() > 100) {
          // Low velocity - combine with progress
          shouldOpen = velocity > 0 && _dragProgress > 0.1;
        } else {
          // Very low velocity - use threshold only
          shouldOpen = _dragProgress > threshold;
        }
        
        if (shouldOpen) {
          if (kDebugMode) print('Completing open');
          _openSideMenu();
        } else {
          if (kDebugMode) print('Completing close');
          _closeSideMenu();
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                if (_isRefreshingNotifier.value) {
                  _isRefreshingNotifier.value = false;
                  _refreshController.stop();
                }
              } else if (notification is ScrollUpdateNotification) {
                if (notification.metrics.pixels < -80 && !_isRefreshingNotifier.value) {
                  _isRefreshingNotifier.value = true;
                  _handleRefresh();
                }
              }
              return false;
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Custom refresh indicator
                SliverToBoxAdapter(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isRefreshingNotifier,
                    builder: (context, isRefreshing, child) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: isRefreshing ? 80 : 0,
                        child: Center(
                          child: RotationTransition(
                            turns: _refreshController,
                            child: Image.asset(
                              'assets/images/loading.png',
                              width: 32,
                              height: 32,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildHeader(context),
                        const SizedBox(height: 24),
                        _buildGreeting(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildConditionalSection(),
                ),
                // Today's Vet Appointments Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ValueListenableBuilder<List<Appointment>>(
                      valueListenable: _todayAppointmentsNotifier,
                      builder: (context, appointments, _) {
                        if (appointments.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            TodayAppointmentWidget(
                              appointments: appointments,
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                // Recommendations Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        CombinedRecommendationsWidget(
                          scrollController: _scrollController,
                          limit: 10,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                // Services Section (when lost pets are available)
                SliverToBoxAdapter(
                  child: ValueListenableBuilder<List<LostPet>>(
                    valueListenable: _lostPetsNotifier,
                    builder: (context, lostPets, _) {
                      final isLoadingPets = _isLoadingPetsNotifier.value;
                      final hasAttemptedLoad = _hasAttemptedLoadNotifier.value;
                      
                      // Show services section only when lost pets are available (not at top)
                      if (lostPets.isNotEmpty || (isLoadingPets && !hasAttemptedLoad)) {
                        return const ServicesSection(showTitle: true);
                      }
                      
                      // Don't show services section when it's already at the top
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.volunteer_activism,
                                color: Color(0xFF4CAF50),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context)!.fundraising,
                              style: TextStyle(
                                fontFamily: context.titleFont,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FundraisingCard(
                          fundraising: Fundraising(
                            id: 'fund_001',
                            title: AppLocalizations.of(context)!.animalShelterExpansion,
                            description: AppLocalizations.of(context)!.helpUsExpandOurShelter,
                            currentAmount: 324223.21,
                            goalAmount: 635000.00,
                            creatorId: 'user_001',
                            createdAt: DateTime.now(),
                            endDate: DateTime.now().add(const Duration(days: 30)),
                            status: 'active',
                            supporterIds: ['user_001', 'user_002', 'user_003'],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // AI Pet Assistant section
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/ai_pet.png',
                              width: 31,
                              height: 31,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context)!.aiPetAssistant,
                              style: TextStyle(
                                fontFamily: context.titleFont,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const AIPetAssistantCard(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildSideMenu() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
      ),
      child: Column(
        children: [
          const SizedBox(height: 28),
          // App logo (centered)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Image.asset(
                'assets/images/logo_cropped.png',
                width: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Profile option (now inside a white container like the others)
          _buildMenuGroup([
            _buildMenuItem(
              title: AppLocalizations.of(context)!.profile,
              onTap: () {
                _closeSideMenu();
                NavigationService.push(context, const ProfilePage());
              },
            ),
          ]),
          const SizedBox(height: 12),
          // Wishlist and Adoption Center group
          _buildMenuGroup([
            _buildMenuItem(
              title: AppLocalizations.of(context)!.wishlist,
              onTap: () {
                _closeSideMenu();
                NavigationService.push(context, const WishlistPage());
              },
            ),
            _buildMenuItem(
              title: AppLocalizations.of(context)!.adoptionCenter,
              onTap: () {
                _closeSideMenu();
                NavigationService.push(context, const AdoptionCenterPage());
              },
            ),
          ]),
          const SizedBox(height: 12),
          // Orders & Messages group
          _buildMenuGroup([
            _buildMenuItem(
              title: AppLocalizations.of(context)!.ordersAndMessages,
              onTap: () {
                _closeSideMenu();
                NavigationService.push(context, const UserOrdersPage());
              },
            ),
          ]),
          const SizedBox(height: 12),
          // Become a Vet and Become a Store group
          _buildMenuGroup([
            _buildMenuItem(
              title: AppLocalizations.of(context)!.becomeAVet,
              onTap: () {
                _closeSideMenu();
                NavigationService.push(context, const VetSignUpPage());
              },
            ),
            _buildMenuItem(
              title: AppLocalizations.of(context)!.becomeAStore,
              onTap: () {
                _closeSideMenu();
                NavigationService.push(context, const StoreSignUpPage());
              },
            ),
          ]),
          const Spacer(),
          // Settings and Logout group
          _buildMenuGroup([
            _buildMenuItem(
              title: AppLocalizations.of(context)!.settings,
              onTap: () {
                _closeSideMenu();
                NavigationService.push(context, const SettingsPage());
              },
            ),
            _buildMenuItem(
              title: AppLocalizations.of(context)!.logOut,
              onTap: () async {
                _closeSideMenu();
                await Provider.of<AuthService>(context, listen: false).signOut();
              },
              textColor: Colors.red,
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
                        child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: context.localizedFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGroup(List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return Column(
            children: [
              item,
              if (index < items.length - 1)
                Container(
                  height: 1,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
            ],
          );
        }).toList(),
    ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    // Ensure minimum safe distance from status bar, but reduce padding slightly
    final safeTopPadding = statusBarHeight > 0 ? statusBarHeight + 2.0 : 10.0;
    
    return Container(
      padding: EdgeInsets.only(top: safeTopPadding),
      height: 64 + safeTopPadding, // Reduced height for tighter positioning
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center image - conditional based on language
          Center(
            child: Image.asset(
              Localizations.localeOf(context).languageCode == 'ar' 
                ? 'assets/images/alifiarabic.png'
                : 'assets/images/header_title.png',
              height: 48,
              fit: BoxFit.contain,
            ),
          ),
          // Left and right elements
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggleSideMenu,
                    child: Container(
                      width: 44, // Increased hitbox width
                      height: 44, // Increased hitbox height
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/images/menu.svg',
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      NavigationService.push(
                        context,
                        const LeaderboardPage(),
                      );
                    },
                    child: Image.asset(
                      'assets/images/leaderboard.png',
                    width: 28,
                    height: 28,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Consumer<AuthService>(
                    builder: (context, authService, child) {
                      return NotificationBadge(
                        onTap: () {
                          NavigationService.push(
                            context,
                            const NotificationsPage(),
                          );
                        },
                        child: Container(
                          width: 48, // Increased hitbox width
                          height: 48, // Increased hitbox height
                          margin: const EdgeInsets.only(left: 8),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Image.asset(
                              'assets/images/notification_icon.png',
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  Consumer<AuthService>(
                    builder: (context, authService, child) {
                      final user = authService.currentUser;
                      return GestureDetector(
                        onTap: () {
                          NavigationService.push(
                            context,
                            const ProfilePage(),
                          );
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[300],
                          child: user?.photoURL != null && user!.photoURL!.isNotEmpty
                              ? ClipOval(
                                  child: OptimizedImage(
                                    imageUrl: user.photoURL!,
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                    placeholder: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    errorWidget: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 16,
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Removed unused method _buildHeaderButton
  
  Widget _buildGreeting() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingLocationNotifier,
      builder: (context, isLoadingLocation, child) {
        return ValueListenableBuilder<latlong.LatLng?>(
          valueListenable: _userLocationNotifier,
          builder: (context, userLocation, child) {
            return Consumer<AuthService>(
              builder: (context, authService, child) {
                final user = authService.currentUser;
                final isStoreAccount = user?.accountType == 'store';
                final isVetAccount = user?.accountType == 'vet';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(user),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    if (!isStoreAccount && !isVetAccount) ...[
                      ValueListenableBuilder<List<LostPet>>(
                        valueListenable: _lostPetsNotifier,
                        builder: (context, lostPets, _) {
                          final isLoadingPets = _isLoadingPetsNotifier.value;
                          final hasAttemptedLoad = _hasAttemptedLoadNotifier.value;
                          
                          // Show services title if no lost pets are available
                          if (lostPets.isEmpty && !isLoadingPets && hasAttemptedLoad) {
                            return Text(
                              AppLocalizations.of(context)!.services,
                              style: TextStyle(
                                fontFamily: context.titleFont,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.2,
                              ),
                            );
                          }
                          
                          // Show lost pets title if we have pets or are still loading
                          if (userLocation != null) {
                            return Text(
                              AppLocalizations.of(context)!.lostPetsNearby,
                              style: TextStyle(
                                fontFamily: context.titleFont,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.2,
                              ),
                            );
                          } else {
                            return Text(
                              AppLocalizations.of(context)!.recentLostPets,
                              style: TextStyle(
                                fontFamily: context.titleFont,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.2,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }



  // Optimized pet card with reduced nesting and simplified rendering
  Widget _buildLostPetCard(LostPet lostPet, BuildContext context) {
    final devicePerformance = DevicePerformance();
    final isLowEndDevice = devicePerformance.performanceTier == PerformanceTier.low;
    
    // Use const where possible for better performance
    const double cardWidth = 300;
    
    // Optimize text styles for low-end devices
    final TextStyle nameStyle = TextStyle(
      fontSize: isLowEndDevice ? 16 : 18,
      fontWeight: FontWeight.bold,
    );
    
    final TextStyle infoStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: isLowEndDevice ? 12 : 14,
    );
    
    return RepaintBoundary(
      child: SizedBox(
        width: cardWidth,
        // Flatten widget tree by removing unnecessary Container
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: lostPet.pet.imageUrls.isNotEmpty
                        ? OptimizedImage(
                            imageUrl: lostPet.pet.imageUrls.first,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            isCircular: true,
                            placeholder: const PlaceholderImage(
                              width: 100,
                              height: 100,
                              isCircular: true,
                            ),
                            errorWidget: const PlaceholderImage(
                              width: 100,
                              height: 100,
                              isCircular: true,
                            ),
                          )
                        : const PlaceholderImage(
                            width: 100,
                            height: 100,
                            isCircular: true,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lostPet.pet.name,
                            style: nameStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${lostPet.pet.breed} • ${AgeFormatter.formatAge(lostPet.pet.age)}',
                            style: infoStyle,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.red, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child:                               Text(
                                lostPet.address,
                                style: infoStyle.copyWith(fontSize: isLowEndDevice ? 11 : 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lost ${_formatTimeAgo(lostPet.lastSeenDate)}',
                          style: TextStyle(
                            color: Colors.orange[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Open in Maps button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Builder(
                            builder: (context) {
                              final isRTL = Localizations.localeOf(context).languageCode == 'ar';
                              final l10n = AppLocalizations.of(context)!;
                              
                              return ElevatedButton(
                                onPressed: () => _openLostPetInMap(lostPet),
                                style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF59E0B),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: isRTL
                                  ? [
                                      Text(
                                        l10n.openInMaps,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.map,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ]
                                  : [
                                      const Icon(
                                        Icons.map,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l10n.openInMaps,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                            ),
                          );
                        },
                      ),
                    ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.lost,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting(User? user) {
    // Get the current hour to determine the appropriate greeting
    final hour = DateTime.now().hour;
    String timeGreeting;
    
    if (hour < 12) {
      timeGreeting = AppLocalizations.of(context)!.goodMorning;
    } else if (hour < 17) {
      timeGreeting = AppLocalizations.of(context)!.goodAfternoon;
    } else {
      timeGreeting = AppLocalizations.of(context)!.goodEvening;
    }
    
    // Get the user's first name from display name
    String firstName = AppLocalizations.of(context)!.user;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      final nameParts = user.displayName!.trim().split(' ');
      firstName = nameParts.first;
    }
    
    return '$timeGreeting, $firstName!';
  }

  Widget _buildLostPetsSkeleton() {
    return Column(
      children: [
        // Pet card carousel skeleton
        SizedBox(
          height: 240,
          child: PageView.builder(
            itemCount: 3, // Show 3 skeleton cards
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(200),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: _buildLostPetCardSkeleton(),
              );
            },
          ),
        ),
        // Navigation arrows (static)
        const SizedBox(height: 16),
        // Page indicators skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
          )),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildConditionalSection() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        final isStoreAccount = user?.accountType == 'store';
        final isVetAccount = user?.accountType == 'vet';

        if (isStoreAccount) {
          return const SellerDashboardCard();
        }

        if (isVetAccount) {
          return const VetDashboardCard();
        }

        // Check for today's appointments first - ABSOLUTE PRIORITY
        if (_todayAppointmentsStream != null) {
          return StreamBuilder<List<Appointment>>(
            stream: _todayAppointmentsStream!,
            builder: (context, appointmentSnapshot) {
              return ValueListenableBuilder<latlong.LatLng?>(
                valueListenable: _userLocationNotifier,
                builder: (context, userLocation, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: _isLoadingLocationNotifier,
                    builder: (context, isLoadingLocation, _) {
                      if (appointmentSnapshot.connectionState == ConnectionState.waiting) {
                        // Keep UI stable and continue showing lost pets while appointments load
                        return _buildLostPetsOrServices();
                      }

                      final todayAppointments = appointmentSnapshot.data ?? [];
                      
                      if (kDebugMode) {
                        print('🔍 [HomePage] Today\'s appointments count: ${todayAppointments.length}');
                        for (final appointment in todayAppointments) {
                          print('🔍 [HomePage] Appointment found: ${appointment.petName} at ${appointment.formattedTime} (${appointment.status.name})');
                        }
                        
                        // We'll show lost pets regardless of appointments
                        print('🔍 [HomePage] Showing lost pets sections regardless of appointments');
                      }

                      // Show lost pets sections with smart loading
                      return _buildLostPetsOrServices();
                    },
                  );
                },
              );
            },
          );
        }
        
        // Fallback to showing lost pets if stream isn't initialized yet
        return _buildLostPetsOrServices();
      },
    );
  }

  Widget _buildLostPetsOrServices() {
    return ValueListenableBuilder<List<LostPet>>(
      valueListenable: _lostPetsNotifier,
      builder: (context, lostPets, _) {
        final isLoadingPets = _isLoadingPetsNotifier.value;
        final hasAttemptedLoad = _hasAttemptedLoadNotifier.value;
        
        // Show lost pets if we have them or if we're still loading
        if (lostPets.isNotEmpty || (isLoadingPets && !hasAttemptedLoad)) {
          return _buildSmartLostPetsSection();
        }
        
        // Show services section if no lost pets are available (at top, no title needed)
        return const ServicesSection(showTitle: false);
      },
    );
  }

  Widget _buildSmartLostPetsSection() {
    return ValueListenableBuilder<List<LostPet>>(
      valueListenable: _lostPetsNotifier,
      builder: (context, lostPets, _) {
        // Read other notifiers directly to avoid nested rebuilds
        final isLoadingPets = _isLoadingPetsNotifier.value;
        final hasAttemptedLoad = _hasAttemptedLoadNotifier.value;
        
        // Show skeleton when loading pets (regardless of location loading status)
        if (isLoadingPets && lostPets.isEmpty) {
          return _buildLostPetsSkeleton();
        }
        
        // If no pets and not loading, this section won't be shown (services will be shown instead)
        if (lostPets.isEmpty && !isLoadingPets && hasAttemptedLoad) {
          return const SizedBox.shrink();
        }
        
        // Show pets when we have them
        if (lostPets.isNotEmpty) {
          return Column(
            children: [
              // Pet card carousel with navigation arrows
              SizedBox(
                height: 240,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _petPageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: lostPets.length,
                      pageSnapping: true,
                      key: const PageStorageKey('pet_carousel'),
                      itemBuilder: (context, index) {
                        final lostPet = lostPets[index];
                        return RepaintBoundary(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(200),
                              border: Border.all(color: Colors.grey[300]!, width: 0.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: _buildLostPetCard(lostPet, context),
                          ),
                        );
                      },
                    ),
                    // Navigation arrows - only show when there are items to navigate to
                    ValueListenableBuilder<int>(
                      valueListenable: _currentPetPageNotifier,
                      builder: (context, currentPage, child) {
                        return Stack(
                          children: [
                            // Left arrow - only show if not on first page
                            if (currentPage > 0)
                              Positioned(
                                left: 16,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () => _navigateToPetCard(-1),
                                    child: Icon(
                                      Icons.chevron_left,
                                      color: Colors.grey[700],
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            // Right arrow - only show if not on last page
                            if (currentPage < lostPets.length - 1)
                              Positioned(
                                right: 16,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () => _navigateToPetCard(1),
                                    child: Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey[700],
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Page indicators
              if (lostPets.length > 1) ...[
                const SizedBox(height: 16),
                ValueListenableBuilder<int>(
                  valueListenable: _currentPetPageNotifier,
                  builder: (context, currentPage, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(lostPets.length, (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == currentPage ? const Color(0xFFF59E0B) : Colors.grey[300],
                        ),
                      )),
                    );
                  },
                ),
              ],
              const SizedBox(height: 32),
            ],
          );
        }
                        
        // Default case - show nothing while initializing
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLostPetCardSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50), // Match the pill shape
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Pet Image skeleton (circular)
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: ShimmerLoader(
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.withOpacity(0.3), // Much lighter gray
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet name skeleton
                  ShimmerLoader(
                    child: Container(
                      width: 120,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3), // Much lighter gray
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Breed and age skeleton
                  ShimmerLoader(
                    child: Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3), // Much lighter gray
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Location skeleton
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey.withOpacity(0.3), size: 16),
                      const SizedBox(width: 4),
                      ShimmerLoader(
                        child: Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3), // Much lighter gray
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Time skeleton
                  ShimmerLoader(
                    child: Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3), // Much lighter gray
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Button skeleton
                  ShimmerLoader(
                    child: Container(
                      width: 100,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3), // Much lighter gray
                        borderRadius: BorderRadius.circular(20),
                      ),
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

