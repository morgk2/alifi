import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/places_service.dart';
import '../services/navigation_service.dart';
import '../widgets/verification_badge.dart';
import '../widgets/vet_card_skeleton.dart';
import '../l10n/app_localizations.dart';
import 'user_profile_page.dart';
import 'package:geolocator/geolocator.dart';
import '../services/geocoding_service.dart';
import 'package:latlong2/latlong.dart' show Distance, LengthUnit;
import 'map_page.dart';
import '../utils/app_fonts.dart';

class VetsPage extends StatefulWidget {
  const VetsPage({super.key});

  @override
  State<VetsPage> createState() => _VetsPageState();
}

class _VetsPageState extends State<VetsPage> with TickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  final PlacesService _placesService = PlacesService();
  
  List<User> _nearbyVets = [];
  List<User> _recommendedVets = [];
  List<User> _topVets = [];
  List<Map<String, dynamic>> _nearbyVetLocations = [];
  
  bool _isLoadingNearby = false;
  bool _isLoadingRecommended = false;
  bool _isLoadingTop = false;
  
  latlong.LatLng? _userLocation;
  String? _userLocationName;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    // Start the fade animation immediately so skeletons are visible
    _fadeController.forward();
    _initializeData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    // Set all loading states to true at the beginning
    setState(() {
      _isLoadingNearby = true;
      _isLoadingRecommended = true;
      _isLoadingTop = true;
    });
    
    // Ensure minimum loading time so skeletons are visible
    final loadingFuture = Future.wait([
      _getUserLocation(),
      _loadNearbyVets(),
      _loadRecommendedVets(),
      _loadTopVets(),
    ]);
    
    final minimumLoadingTime = Future.delayed(const Duration(milliseconds: 800));
    
    await Future.wait([loadingFuture, minimumLoadingTime]);
    // Fade animation is already started in initState, no need to call forward() again
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (mounted) {
        setState(() {
          _userLocation = latlong.LatLng(position.latitude, position.longitude);
        });
        
        // Get location name using reverse geocoding
        await _getLocationName();
      }
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  Future<void> _getLocationName() async {
    if (_userLocation == null) return;
    
    try {
      // Use the same geocoding service as the adoption center
      final address = await GeocodingService.getAddressFromCoordinates(
        _userLocation!.latitude,
        _userLocation!.longitude,
      );
      
      if (mounted) {
        setState(() {
          _userLocationName = address;
        });
      }
    } catch (e) {
      print('Error getting location name: $e');
      // Fallback to coordinates if geocoding fails
      if (mounted) {
        setState(() {
          _userLocationName = '${_userLocation!.latitude.toStringAsFixed(2)}, ${_userLocation!.longitude.toStringAsFixed(2)}';
        });
      }
    }
  }

  Future<void> _loadNearbyVets() async {
    // Only set loading state if not already loading
    if (!_isLoadingNearby) {
      setState(() => _isLoadingNearby = true);
    }
    
    try {
      if (_userLocation != null) {
        // Load vets from database with location
        final nearbyVets = await _databaseService.getVetsNearLocation(
          _userLocation!,
          radiusKm: 25.0, // Reduced radius for more accuracy
        );
        
        // Filter to only show Alifi vet accounts (affiliated, favorite, or verified)
        final alifiVets = nearbyVets.where((vet) {
          final subscriptionPlan = (vet.subscriptionPlan ?? '').toLowerCase();
          return subscriptionPlan.contains('alifi favorite') ||
                 subscriptionPlan.contains('alifi affiliated') ||
                 subscriptionPlan.contains('alifi verified') ||
                 vet.isVerified == true;
        }).toList();
        
        print('🔍 [Nearby Vets] Total nearby vets: ${nearbyVets.length}');
        print('🔍 [Nearby Vets] Alifi vets: ${alifiVets.length}');
        
        // Load vet locations from Places Service and filter by distance
        await PlacesService.initialize();
        final allVetLocations = await _placesService.getAllVetClinics();
        
        // Filter Places Service results by distance
        final distance = const Distance();
        final nearbyVetLocations = allVetLocations.where((location) {
          try {
            final locationData = location['geometry']?['location'] ?? location['location'];
            if (locationData == null) return false;
            
            final lat = (locationData['lat'] ?? locationData['latitude']) as double;
            final lng = (locationData['lng'] ?? locationData['longitude']) as double;
            final vetLocation = latlong.LatLng(lat, lng);
            
            final distanceInKm = distance.as(
              LengthUnit.Kilometer,
              _userLocation!,
              vetLocation,
            );
            return distanceInKm <= 25.0; // Same radius as database vets
          } catch (e) {
            print('Error calculating distance for vet location: $e');
            return false;
          }
        }).toList();
        
        if (mounted) {
          setState(() {
            _nearbyVets = alifiVets; // Use filtered Alifi vets
            _nearbyVetLocations = nearbyVetLocations;
            _isLoadingNearby = false;
          });
        }
      } else {
        // Fallback: load Alifi vets if no location
        final allVets = await _databaseService.getAllVets();
        final alifiVets = allVets.where((vet) {
          final subscriptionPlan = (vet.subscriptionPlan ?? '').toLowerCase();
          return subscriptionPlan.contains('alifi favorite') ||
                 subscriptionPlan.contains('alifi affiliated') ||
                 subscriptionPlan.contains('alifi verified') ||
                 vet.isVerified == true;
        }).toList();
        
        if (mounted) {
          setState(() {
            _nearbyVets = alifiVets;
            _nearbyVetLocations = [];
            _isLoadingNearby = false;
          });
        }
      }
    } catch (e) {
      print('Error loading nearby vets: $e');
      if (mounted) {
        setState(() => _isLoadingNearby = false);
      }
    }
  }

  Future<void> _loadRecommendedVets() async {
    // Only set loading state if not already loading
    if (!_isLoadingRecommended) {
      setState(() => _isLoadingRecommended = true);
    }
    
    try {
      // Get vets with alifi favorite or affiliated subscription
      final recommendedVets = await _databaseService.getVetsBySubscription([
        'alifi favorite',
        'alifi affiliated',
      ]);
      
      if (mounted) {
        setState(() {
          _recommendedVets = recommendedVets;
          _isLoadingRecommended = false;
        });
      }
    } catch (e) {
      print('Error loading recommended vets: $e');
      if (mounted) {
        setState(() => _isLoadingRecommended = false);
      }
    }
  }

  Future<void> _loadTopVets() async {
    // Only set loading state if not already loading
    if (!_isLoadingTop) {
      setState(() => _isLoadingTop = true);
    }
    
    try {
      // Get top vets by follower count (max 7 cards)
      final topVets = await _databaseService.getTopVetsByFollowers(limit: 7);
      
      if (mounted) {
        setState(() {
          _topVets = topVets;
          _isLoadingTop = false;
        });
      }
    } catch (e) {
      print('Error loading top vets: $e');
      if (mounted) {
        setState(() => _isLoadingTop = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          l10n.vet,
          style: TextStyle(fontFamily: context.titleFont,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black),
        leading: CupertinoNavigationBarBackButton(
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: _initializeData,
              builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent) {
                // Calculate the slide offset based on pull extent
                final slideOffset = (pulledExtent / refreshTriggerPullDistance) * 40; // Max slide of 40 pixels
                final clampedOffset = slideOffset.clamp(0.0, 40.0);
                
                return Transform.translate(
                  offset: Offset(0, -20 + clampedOffset),
                  child: CupertinoActivityIndicator(
                    radius: 12,
                    color: Colors.blue,
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Vets Service Icon Banner
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Image.asset(
                        'assets/images/vetservice.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade100,
                            child: Icon(
                              CupertinoIcons.heart_fill,
                              size: 60,
                              color: Colors.blue.shade400,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Vets Near Me Section
                  _buildSectionHeader(
                    'Vets Near Me',
                    CupertinoIcons.location_solid,
                    Colors.blue,
                    subtitle: _userLocationName ?? (_userLocation != null ? 'Loading location...' : 'Enable location to see nearby vets'),
                    showMapButton: true,
                  ),
                  const SizedBox(height: 16),
                  _buildNearbyVetsSection(),
                  
                  const SizedBox(height: 48),
                  
                  // Recommended Vets Section
                  _buildSectionHeader(
                    'Recommended Vets',
                    CupertinoIcons.star_fill,
                    Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendedVetsSection(),
                  
                  const SizedBox(height: 48),
                  
                  // Top Vets Section
                  _buildSectionHeader(
                    'Most Followed Vets',
                    CupertinoIcons.person_2_fill,
                    Colors.purple,
                  ),
                  const SizedBox(height: 16),
                  _buildTopVetsSection(),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, {String? subtitle, bool showMapButton = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (showMapButton) ...[
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade500, Colors.blue.shade600],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        NavigationService.push(
                          context,
                          const MapPage(),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.map_fill,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'View in Map',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 44.0), // Align with the title text
              child: Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNearbyVetsSection() {
    if (_isLoadingNearby) {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          itemCount: 3, // Show 3 skeleton cards
          itemBuilder: (context, index) {
            return const VetCardSkeleton();
          },
        ),
      );
    }

    if (_nearbyVets.isEmpty && _nearbyVetLocations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.location_slash,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No vets found nearby',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try enabling location services',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: _nearbyVets.length + (_nearbyVetLocations.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _nearbyVets.length) {
            return _buildVetCard(_nearbyVets[index]);
          } else {
            return _buildExternalVetsSummaryCard();
          }
        },
      ),
    );
  }

  Widget _buildRecommendedVetsSection() {
    if (_isLoadingRecommended) {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          itemCount: 3, // Show 3 skeleton cards
          itemBuilder: (context, index) {
            return const VetCardSkeleton();
          },
        ),
      );
    }

    if (_recommendedVets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.star,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No recommended vets yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: _recommendedVets.length,
        itemBuilder: (context, index) {
          return _buildVetCard(_recommendedVets[index]);
        },
      ),
    );
  }

  Widget _buildTopVetsSection() {
    if (_isLoadingTop) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: List.generate(5, (index) => const VetListCardSkeleton()),
        ),
      );
    }

    if (_topVets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.star_circle,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No top vets yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: _topVets.asMap().entries.map((entry) {
          final index = entry.key;
          final vet = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildTopVetListCard(vet, showRanking: true, rank: index + 1),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVetCard(User vet, {bool showRanking = false, int? rank}) {
    final l10n = AppLocalizations.of(context)!;
    final isAlifiFavorite = (vet.subscriptionPlan ?? '').toLowerCase() == 'alifi favorite';
    final isAlifiAffiliated = (vet.subscriptionPlan ?? '').toLowerCase() == 'alifi affiliated';
    
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            NavigationService.push(
              context,
              UserProfilePage(user: vet),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (showRanking && rank != null) ...[
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: rank <= 3 ? Colors.amber : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$rank',
                            style: TextStyle(
                              color: rank <= 3 ? Colors.white : Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Profile Picture
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                      ),
                      child: ClipOval(
                        child: vet.photoURL != null
                            ? Image.network(
                                vet.photoURL!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade100,
                                    child: Icon(
                                      CupertinoIcons.person_fill,
                                      color: Colors.grey.shade400,
                                      size: 24,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey.shade100,
                                child: Icon(
                                  CupertinoIcons.person_fill,
                                  color: Colors.grey.shade400,
                                  size: 24,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vet.businessName ?? vet.clinicName ?? vet.displayName ?? 'Unknown Vet',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(CupertinoIcons.star_fill, size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                vet.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              if (vet.isVerified) ...[
                                const SizedBox(width: 8),
                                const VerificationBadge(size: 12),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Location display with better fallbacks
                Row(
                  children: [
                    Icon(CupertinoIcons.location_solid, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _getVetLocationText(vet),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: CupertinoIcons.person_2_fill,
                        value: (vet.patients?.length ?? 0).toString(),
                        label: 'Patients',
                        color: Colors.blue,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: CupertinoIcons.heart_fill,
                        value: vet.followersCount.toString(),
                        label: 'Followers',
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Subscription badges
                if (isAlifiFavorite || isAlifiAffiliated) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isAlifiFavorite)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                l10n.alifiFavorite,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'InterDisplay',
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isAlifiAffiliated) ...[
                        if (isAlifiFavorite) const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                l10n.alifiAffiliated,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'InterDisplay',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopVetListCard(User vet, {bool showRanking = false, int? rank}) {
    final l10n = AppLocalizations.of(context)!;
    final isAlifiFavorite = (vet.subscriptionPlan ?? '').toLowerCase() == 'alifi favorite';
    final isAlifiAffiliated = (vet.subscriptionPlan ?? '').toLowerCase() == 'alifi affiliated';
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            NavigationService.push(
              context,
              UserProfilePage(user: vet),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Ranking badge
                if (showRanking && rank != null) ...[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: rank <= 3 ? Colors.amber : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          color: rank <= 3 ? Colors.white : Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                // Profile Picture
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                  ),
                  child: ClipOval(
                    child: vet.photoURL != null
                        ? Image.network(
                            vet.photoURL!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade100,
                                child: Icon(
                                  CupertinoIcons.person_fill,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade100,
                            child: Icon(
                              CupertinoIcons.person_fill,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Vet Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vet.businessName ?? vet.clinicName ?? vet.displayName ?? 'Unknown Vet',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(CupertinoIcons.star_fill, size: 12, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            vet.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(CupertinoIcons.person_2_fill, size: 12, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            '${vet.followersCount}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getVetLocationText(vet),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Subscription badges
                if (isAlifiFavorite || isAlifiAffiliated) ...[
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      if (isAlifiFavorite)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, color: Colors.white, size: 10),
                              const SizedBox(width: 2),
                              Text(
                                l10n.alifiFavorite,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'InterDisplay',
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isAlifiAffiliated) ...[
                        if (isAlifiFavorite) const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, color: Colors.white, size: 10),
                              const SizedBox(width: 2),
                              Text(
                                l10n.alifiAffiliated,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'InterDisplay',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExternalVetsSummaryCard() {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            NavigationService.push(
              context,
              const MapPage(),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and count
                Row(
                  children: [
                    // Map icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                        color: Colors.orange.shade50,
                      ),
                      child: Icon(
                        CupertinoIcons.map_fill,
                        color: Colors.orange.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_nearbyVetLocations.length} vets on the map!',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'These vets are not verified by Alifi',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  'View all nearby veterinary clinics on the interactive map to find the best option for your pet.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // View on map button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade500, Colors.orange.shade600],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.map_fill,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'View on Map',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getVetLocationText(User vet) {
    // Debug logging to see what data is available
    print('🔍 [Vet Location Debug] Vet ID: ${vet.id}');
    print('🔍 [Vet Location Debug] Vet Name: ${vet.businessName ?? vet.clinicName ?? vet.displayName}');
    print('🔍 [Vet Location Debug] Subscription: ${vet.subscriptionPlan}');
    print('🔍 [Vet Location Debug] Is Verified: ${vet.isVerified}');
    print('🔍 [Vet Location Debug] businessLocation: "${vet.businessLocation}"');
    print('🔍 [Vet Location Debug] clinicLocation: "${vet.clinicLocation}"');
    print('🔍 [Vet Location Debug] city: "${vet.city}"');
    print('🔍 [Vet Location Debug] storeLocation: "${vet.storeLocation}"');
    print('🔍 [Vet Location Debug] location coordinates: ${vet.location}');
    print('🔍 [Vet Location Debug] userLocation: $_userLocation');
    
    // Try to get location from various fields with better null checking
    String? location;
    
    // Check business location fields
    if (vet.businessLocation != null && vet.businessLocation!.trim().isNotEmpty) {
      location = vet.businessLocation!.trim();
    } else if (vet.clinicLocation != null && vet.clinicLocation!.trim().isNotEmpty) {
      location = vet.clinicLocation!.trim();
    } else if (vet.storeLocation != null && vet.storeLocation!.trim().isNotEmpty) {
      location = vet.storeLocation!.trim();
    } else if (vet.city != null && vet.city!.trim().isNotEmpty) {
      location = vet.city!.trim();
    }
    
    if (location != null && location.isNotEmpty) {
      print('🔍 [Vet Location Debug] Using location text: "$location"');
      return location;
    }
    
    // If no location text, try to show distance if we have user location and vet coordinates
    if (_userLocation != null && vet.location != null) {
      try {
        final distance = const Distance();
        final distanceInKm = distance.as(
          LengthUnit.Kilometer,
          _userLocation!,
          vet.location!,
        );
        
        String distanceText;
        if (distanceInKm < 1) {
          distanceText = '${(distanceInKm * 1000).round()}m away';
        } else {
          distanceText = '${distanceInKm.toStringAsFixed(1)}km away';
        }
        
        print('🔍 [Vet Location Debug] Using distance: "$distanceText"');
        return distanceText;
      } catch (e) {
        print('🔍 [Vet Location Debug] Error calculating distance: $e');
      }
    }
    
    // Try to get location from default address
    if (vet.defaultAddress != null) {
      final address = vet.defaultAddress!;
      if (address['city'] != null && address['city'].toString().trim().isNotEmpty) {
        final cityText = address['city'].toString().trim();
        print('🔍 [Vet Location Debug] Using default address city: "$cityText"');
        return cityText;
      }
      if (address['address'] != null && address['address'].toString().trim().isNotEmpty) {
        final addressText = address['address'].toString().trim();
        print('🔍 [Vet Location Debug] Using default address: "$addressText"');
        return addressText;
      }
    }
    
    // Final fallback
    print('🔍 [Vet Location Debug] No location data found, using fallback');
    return 'Location not specified';
  }
}
