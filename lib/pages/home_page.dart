import 'package:flutter/material.dart' hide ScrollDirection;
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:timeago/timeago.dart' as timeago;
import '../models/fundraising.dart';
import '../models/lost_pet.dart';
import '../models/store_item.dart';
import '../services/database_service.dart';
import '../icons.dart';
import '../widgets/placeholder_image.dart';
import '../widgets/scrollable_fade_container.dart';
import '../widgets/fundraising_card.dart';
import '../widgets/lost_pet_card.dart';
import '../widgets/product_card.dart';
import '../models/aliexpress_product.dart';
import 'notification_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'leaderboard_page.dart';
import 'marketplace_page.dart';
import '../main.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter/animation.dart';
import '../widgets/spinning_loader.dart';
import '../widgets/ai_assistant_card.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onNavigateToMap;
  final Function(bool) onAIAssistantExpanded;  // Add this callback

  const HomePage({
    super.key,
    required this.onNavigateToMap,
    required this.onAIAssistantExpanded,  // Add this parameter
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _isAIAssistantExpanded = false;
  final ScrollController _petsScrollController = ScrollController();
  final ScrollController _storeScrollController = ScrollController();
  final ScrollController _mainScrollController = ScrollController();
  final DatabaseService _databaseService = DatabaseService();
  
  // Add refresh controller
  late AnimationController _refreshController;
  
  // Replace setState variables with ValueNotifier for better performance
  final ValueNotifier<bool> _showHeaderNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isAtTopNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int> _currentPetPageNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _currentStorePageNotifier = ValueNotifier<int>(0);
  final ValueNotifier<List<LostPet>> _lostPetsNotifier = ValueNotifier<List<LostPet>>([]);
  final ValueNotifier<latlong.LatLng?> _userLocationNotifier = ValueNotifier<latlong.LatLng?>(null);
  final ValueNotifier<bool> _isLoadingLocationNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isRefreshingNotifier = ValueNotifier<bool>(false);

  // Use mock data for store items
  final List<StoreItem> _storeItems = StoreItem.mockItems;

  // Helper method to calculate distance between two points
  String _calculateDistance(latlong.LatLng? userLocation, latlong.LatLng petLocation) {
    if (userLocation == null) return '';
    
    final distance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      petLocation.latitude,
      petLocation.longitude,
    );
    
    if (distance < 1000) {
      return '${distance.round()}m away';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km away';
    }
  }

  // Helper method to check if pet is within range (10km)
  bool _isWithinRange(latlong.LatLng? userLocation, latlong.LatLng petLocation) {
    if (userLocation == null) return false;
    
    final distance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      petLocation.latitude,
      petLocation.longitude,
    );
    
    return distance <= 10000; // 10km in meters
  }

  @override
  void initState() {
    super.initState();
    _petsScrollController.addListener(_onPetScroll);
    _storeScrollController.addListener(_onStoreScroll);
    _mainScrollController.addListener(_onMainScroll);
    
    // Initialize refresh controller
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Slower rotation for smoother look
    );
    
    _initializeLocationAndLoadPets();
  }

  Position? _currentPosition;

  Future<void> _initializeLocationAndLoadPets() async {
    try {
      // Only check location permission if we don't have a position yet
      if (_currentPosition == null) {
        // Request location permission
        final status = await Permission.location.request();
        if (status != PermissionStatus.granted) {
          print('Location permission denied, loading recent lost pets instead');
    _loadRecentLostPets();
          _isLoadingLocationNotifier.value = false;
          return;
        }

        // Check if location services are enabled
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          print('Location services disabled, loading recent lost pets instead');
          _loadRecentLostPets();
          _isLoadingLocationNotifier.value = false;
          return;
        }
      }

      // Get current position with lower accuracy for faster response
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 2),
      ).catchError((error) async {
        // If timeout or error, use last known position
        return await Geolocator.getLastKnownPosition() ?? 
          // If no last known position, use current position or default
          _currentPosition ?? Position(
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
      });
      
      final userLocation = latlong.LatLng(position.latitude, position.longitude);
      _userLocationNotifier.value = userLocation;
      _currentPosition = position;
      print('User location obtained: ${position.latitude}, ${position.longitude}');
      
      // Load nearby lost pets
      _loadNearbyLostPets(userLocation);
      
    } catch (e) {
      print('Error getting location: $e, loading recent lost pets instead');
      _loadRecentLostPets();
    } finally {
      _isLoadingLocationNotifier.value = false;
    }
  }

  Future<void> _loadNearbyLostPets(latlong.LatLng userLocation) async {
    // Subscribe to nearby lost pets stream
    _databaseService.getNearbyLostPets(
      userLocation: userLocation,
      radiusInKm: 10, // 10km radius
    ).listen((pets) {
      if (mounted) {
        print('Loaded ${pets.length} nearby lost pets');
        _lostPetsNotifier.value = pets;
      }
    });
  }

  Future<void> _loadRecentLostPets() async {
    // Subscribe to recent lost pets stream as fallback
    _databaseService.getRecentLostPets().listen((pets) {
      if (mounted) {
        print('Loaded ${pets.length} recent lost pets (fallback)');
        _lostPetsNotifier.value = pets;
      }
    });
  }

  @override
  void dispose() {
    _petsScrollController.removeListener(_onPetScroll);
    _storeScrollController.removeListener(_onStoreScroll);
    _mainScrollController.removeListener(_onMainScroll);
    _petsScrollController.dispose();
    _storeScrollController.dispose();
    _mainScrollController.dispose();
    _refreshController.dispose();
    
    // Dispose ValueNotifiers
    _showHeaderNotifier.dispose();
    _isAtTopNotifier.dispose();
    _currentPetPageNotifier.dispose();
    _currentStorePageNotifier.dispose();
    _lostPetsNotifier.dispose();
    _userLocationNotifier.dispose();
    _isLoadingLocationNotifier.dispose();
    _isRefreshingNotifier.dispose();
    
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshingNotifier.value) {
      _refreshController.repeat();
      
      try {
        // Start both operations concurrently
        await Future.wait([
          _initializeLocationAndLoadPets(),
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

  void _onPetScroll() {
    if (!_petsScrollController.hasClients) return;
    
    final double offset = _petsScrollController.offset;
    final double itemWidth = MediaQuery.of(context).size.width * 0.85 + 16.0; // Width + horizontal margin
    final int page = (offset / itemWidth).round();
    
    if (page != _currentPetPageNotifier.value) {
      _currentPetPageNotifier.value = page;
    }

    // If the scroll is ending (user lifts finger), snap to the nearest item
    if (!_petsScrollController.position.isScrollingNotifier.value) {
      final double targetOffset = page * itemWidth;
      _petsScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onStoreScroll() {
    if (!_storeScrollController.hasClients) return;
    final double offset = _storeScrollController.offset;
    final double itemWidth = MediaQuery.of(context).size.width * 0.6;
    final int page = (offset / itemWidth).round();
    if (page != _currentStorePageNotifier.value) {
      _currentStorePageNotifier.value = page;
    }
  }

  void _onMainScroll() {
    if (!_mainScrollController.hasClients) return;
    
    // Show header when scrolling up, hide when scrolling down
    if (_mainScrollController.position.userScrollDirection == ScrollDirection.reverse && _mainScrollController.offset > 100) {
      if (_showHeaderNotifier.value) {
        _showHeaderNotifier.value = false;
      }
    } else if (_mainScrollController.position.userScrollDirection == ScrollDirection.forward && _mainScrollController.offset > 100) {
      if (!_showHeaderNotifier.value) {
        _showHeaderNotifier.value = true;
      }
    }

    // Check if we're at the top of the scroll
    final bool isAtTop = _mainScrollController.offset < 5;
    if (isAtTop != _isAtTopNotifier.value) {
      _isAtTopNotifier.value = isAtTop;
    }
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  void _toggleAIAssistant(bool expanded) {
    setState(() {
      _isAIAssistantExpanded = expanded;
    });
    widget.onAIAssistantExpanded(expanded);  // Notify parent about the state change
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                // Reset refresh state when starting new scroll
                if (_isRefreshingNotifier.value) {
                  _isRefreshingNotifier.value = false;
                  _refreshController.stop();
                }
              } else if (notification is ScrollUpdateNotification) {
                // Check for overscroll
                if (notification.metrics.pixels < -80 && !_isRefreshingNotifier.value) {
                  _isRefreshingNotifier.value = true;
                  _handleRefresh();
                }
              }
              return false;
            },
            child: CustomScrollView(
              controller: _mainScrollController,
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
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildGreeting(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildWhatsNewSlider(),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        _buildStoreSection(),
                        const SizedBox(height: 80),
                      ],
                    ),
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
                            const Text(
                              'Fundraising',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
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
                            title: 'Animal Shelter Expansion',
                            description: 'Help us expand our shelter to accommodate more animals in need.',
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
                            const Text(
                              'AI Pet Assistant',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // AI Pet Assistant Card
                        if (!_isAIAssistantExpanded)
                          AIPetAssistantCard(
                            isExpanded: _isAIAssistantExpanded,
                            onTap: () => _toggleAIAssistant(true),
                          ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isAIAssistantExpanded)
            Positioned.fill(
              child: AIPetAssistantCard(
                isExpanded: true,
                onTap: () => _toggleAIAssistant(false),
              ),
            ),
          // Collapsible header with ValueListenableBuilder
          ValueListenableBuilder<bool>(
            valueListenable: _showHeaderNotifier,
            builder: (context, showHeader, child) {
              return ValueListenableBuilder<bool>(
                valueListenable: _isAtTopNotifier,
                builder: (context, isAtTop, child) {
                  return AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
                    offset: Offset(0, (showHeader && !isAtTop) ? 0 : -1),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  height: 56 + MediaQuery.of(context).padding.top,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: MediaQuery.of(context).padding.top,
                    ),
                    child: SizedBox(
                      height: 56,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Center text
                          const Center(
                            child: Text(
                              'alifi',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                          // Left and right elements
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.menu),
                                    onPressed: () => _navigateToSettings(context),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const LeaderboardPage(),
                                        ),
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
                                  _buildHeaderButton(
                                    icon: AppIcons.bellIcon,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const NotificationPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const ProfilePage(),
                                        ),
                                      );
                                    },
                                    child: const CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.grey,
                                      child: Icon(Icons.person, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 56, // Fixed height for consistency
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center text
          const Center(
            child: Text(
              'alifi',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
          // Left and right elements
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => _navigateToSettings(context),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LeaderboardPage(),
                        ),
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
                  _buildHeaderButton(
                    icon: AppIcons.bellIcon,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const GeminiChatBox(),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: SvgPicture.string(
              icon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingLocationNotifier,
      builder: (context, isLoadingLocation, child) {
        return ValueListenableBuilder<latlong.LatLng?>(
          valueListenable: _userLocationNotifier,
          builder: (context, userLocation, child) {
            return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                const Text(
          'Good afternoon, user!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
                if (isLoadingLocation)
                  const Text(
                    "Loading nearby pets...",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  )
                else if (userLocation != null)
                  const Text(
                    "Lost pets nearby",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  )
                else
                  const Text(
                    "Recent lost pets",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
          ),
        ),
      ],
            );
          },
        );
      },
    );
  }

  Widget _buildWhatsNewSlider() {
    return ValueListenableBuilder<List<LostPet>>(
      valueListenable: _lostPetsNotifier,
      builder: (context, lostPets, child) {
        if (lostPets.isEmpty) {
          return ValueListenableBuilder<bool>(
            valueListenable: _isLoadingLocationNotifier,
            builder: (context, isLoadingLocation, child) {
              return ValueListenableBuilder<latlong.LatLng?>(
                valueListenable: _userLocationNotifier,
                builder: (context, userLocation, child) {
                  String message;
                  if (isLoadingLocation) {
                    message = 'Loading nearby pets...';
                  } else if (userLocation != null) {
                    message = 'No lost pets reported nearby (within 10km)';
                  } else {
                    message = 'No recent lost pets reported';
                  }
                  
                  return Center(
        child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            message,
                            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
                            textAlign: TextAlign.center,
                          ),
                          if (userLocation == null && !isLoadingLocation) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Enable location to see pets in your area',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
          ),
        ),
                  );
                },
              );
            },
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final containerWidth = constraints.maxWidth;
              final itemWidth = MediaQuery.of(context).size.width * 0.85;
                  final totalWidth = itemWidth * lostPets.length + 16.0 * (lostPets.length - 1);

              return ScrollableFadeContainer(
                scrollController: _petsScrollController,
                containerWidth: containerWidth,
                contentWidth: totalWidth,
                child: ListView.builder(
                  controller: _petsScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const PageScrollPhysics().applyTo(
                    const BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: (MediaQuery.of(context).size.width - itemWidth) / 2,
                  ),
                      itemCount: lostPets.length,
                  itemBuilder: (context, index) {
                        final lostPet = lostPets[index];
                    final width = MediaQuery.of(context).size.width * 0.85;
                        return ValueListenableBuilder<int>(
                          valueListenable: _currentPetPageNotifier,
                          builder: (context, currentPage, child) {
                    return AnimatedScale(
                              scale: currentPage == index ? 1.0 : 0.92,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        width: width,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(90),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                                child: Stack(
                                  children: [
                                    Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: lostPet.pet.imageUrls.isNotEmpty
                                                ? CachedNetworkImage(
                                                    imageUrl: lostPet.pet.imageUrls.first,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                                    placeholder: (context, url) => const PlaceholderImage(
                                          width: 100,
                                          height: 100,
                                          isCircular: true,
                                        ),
                                                    errorWidget: (context, url, error) => const PlaceholderImage(
                                                      width: 100,
                                                      height: 100,
                                                      isCircular: true,
                                                    ),
                                                    fadeInDuration: const Duration(milliseconds: 300),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      lostPet.pet.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Text(
                                          'Last seen: ',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Text(
                                          timeago.format(lostPet.lastSeenDate),
                                          style: TextStyle(
                                            color: Colors.orange[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                                ValueListenableBuilder<latlong.LatLng?>(
                                                  valueListenable: _userLocationNotifier,
                                                  builder: (context, userLocation, child) {
                                                    final distance = _calculateDistance(userLocation, lostPet.location);
                                                    return Row(
                                      children: [
                                        const Text(
                                          'Location: ',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Expanded(
                                          child: Text(
                                            lostPet.address,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        if (distance.isNotEmpty) ...[
                                                          const SizedBox(width: 8),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                            decoration: BoxDecoration(
                                                              color: Colors.red[100],
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            child: Text(
                                                              distance,
                                                              style: TextStyle(
                                                                color: Colors.red[700],
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                          ),
                                        ),
                                      ],
                                                      ],
                                                    );
                                                  },
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: widget.onNavigateToMap,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF59E0B),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        minimumSize: const Size(120, 36),
                                        elevation: 4,
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.map, size: 18),
                                          SizedBox(width: 4),
                                          Text('Open maps'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                                    ),
                                    // Range indicator
                                    ValueListenableBuilder<latlong.LatLng?>(
                                      valueListenable: _userLocationNotifier,
                                      builder: (context, userLocation, child) {
                                        if (_isWithinRange(userLocation, lostPet.location)) {
                                          return Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    );
                                        }
                                        return const SizedBox.shrink();
                  },
                                    ),
                                  ],
                                ),
                ),
                            );
                          },
                        );
                      },
                    ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
            ValueListenableBuilder<int>(
              valueListenable: _currentPetPageNotifier,
              builder: (context, currentPage, child) {
                return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
                    lostPets.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                        color: currentPage == index
                    ? const Color(0xFFF59E0B)
                    : Colors.grey[300],
              ),
            ),
          ),
                );
              },
        ),
      ],
        );
      },
    );
  }

  Widget _buildStoreSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 8),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                SvgPicture.string(
                  AppIcons.storeIcon,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'You may be Interested',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MarketplacePage(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'See all',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                Icon(Icons.arrow_forward, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 220,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final containerWidth = constraints.maxWidth;
                    final itemWidth = MediaQuery.of(context).size.width * 0.6;

                    return StreamBuilder<List<AliexpressProduct>>(
                      stream: _databaseService.getRecommendedListings(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print('Error loading recommended products: ${snapshot.error}');
                          return Center(
                            child: Text(
                              'Error loading products',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: SpinningLoader(
                              size: 40,
                              color: Colors.orange,
                            ),
                          );
                        }

                        final products = snapshot.data!;
                        if (products.isEmpty) {
                          return Center(
                            child: Text(
                              'No products available',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          );
                        }

                        final totalWidth = itemWidth * products.length +
                            16.0 * (products.length - 1);

                    return ScrollableFadeContainer(
                      scrollController: _storeScrollController,
                      containerWidth: containerWidth,
                      contentWidth: totalWidth,
                      child: ListView.builder(
                        controller: _storeScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: products.length,
                        itemBuilder: (context, index) {
                              final product = products[index];
                              print('Building recommended product card for: ${product.name}');
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: ProductCard(
                                  product: product,
                                  width: itemWidth,
                                  height: 220,
                                  showDetails: true,
                                ),
                              );
                            },
                          ),
                          );
                        },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<int>(
                valueListenable: _currentStorePageNotifier,
                builder: (context, currentPage, child) {
                  return StreamBuilder<List<AliexpressProduct>>(
                    stream: _databaseService.getRecommendedListings(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      
                      return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                          snapshot.data!.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                              color: currentPage == index
                          ? const Color(0xFFF59E0B)
                          : Colors.grey[300],
                    ),
                  ),
                ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              // Remove AI Assistant Card from here
            ],
          ),
        ],
      ),
    );
  }
}
