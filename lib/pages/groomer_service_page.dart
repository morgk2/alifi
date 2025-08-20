import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../l10n/app_localizations.dart';
import '../utils/app_fonts.dart';
import '../services/navigation_service.dart';
import '../services/geocoding_service.dart';
import '../models/service_ad.dart';
import '../services/service_ad_service.dart';
import '../widgets/service_ad_card.dart';
import '../widgets/groomer_skeleton_loader.dart';
import '../widgets/user_ads_dialog.dart';
import 'post_service_ad_page.dart';

class GroomerServicePage extends StatefulWidget {
  const GroomerServicePage({super.key});

  @override
  State<GroomerServicePage> createState() => _GroomerServicePageState();
}

class _GroomerServicePageState extends State<GroomerServicePage> {
  List<ServiceAd> _groomingAds = [];
  bool _isLoading = true;
  bool _isLoadingLocation = false;
  String? _error;
  final GlobalKey _dropdownKey = GlobalKey();
  
  // Location variables
  latlong.LatLng? _userLocation;
  String? _userLocationName;

  @override
  void initState() {
    super.initState();
    // Ensure loading state is properly set from the start
    setState(() {
      _isLoading = true;
    });
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getUserLocation();
    await _loadGroomingAds();
  }

  Future<void> _getUserLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (mounted) {
        setState(() {
          _userLocation = latlong.LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
        
        // Get location name using reverse geocoding
        await _getLocationName();
      }
    } catch (e) {
      print('Error getting user location: $e');
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _getLocationName() async {
    if (_userLocation == null) return;
    
    try {
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

  Future<void> _loadGroomingAds() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      List<ServiceAd> ads;
      
      if (_userLocation != null) {
        // Load nearby grooming ads sorted by distance
        ads = await ServiceAdService.getNearbyServiceAds(
          serviceType: ServiceAdType.grooming,
          userLatitude: _userLocation!.latitude,
          userLongitude: _userLocation!.longitude,
          radiusKm: 50.0,
          limit: 20,
        );
      } else {
        // Fallback to all grooming ads
        ads = await ServiceAdService.getServiceAdsByType(ServiceAdType.grooming);
      }
      
      if (mounted) {
        setState(() {
          _groomingAds = ads;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshAds() async {
    await _loadGroomingAds();
  }

  void _showPostAdDropdown() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Post Grooming Ad',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: AppFonts.getTitleFontFamily(context),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Post Ad Action
                _buildActionSheetButton(
                  icon: CupertinoIcons.add_circled,
                  title: 'Post an Ad',
                  color: Colors.orange,
                  onPressed: () {
                    Navigator.pop(context);
                    _postGroomingAd();
                  },
                ),
                
                // Cancel button
                Container(
                  margin: const EdgeInsets.all(20),
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.getLocalizedFontFamily(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _postGroomingAd() async {
    final result = await NavigationService.push(
      context,
      PostServiceAdPage(serviceType: ServiceAdType.grooming),
    );
    
    // Refresh ads if a new ad was posted
    if (result != null) {
      _refreshAds();
    }
  }

  void _showUserAdsDialog() {
    showDialog(
      context: context,
      builder: (context) => UserAdsDialog(
        serviceType: ServiceAdType.grooming,
      ),
    ).then((_) {
      // Refresh ads when dialog is closed in case any were edited/deleted
      _refreshAds();
    });
  }

  Widget _buildActionSheetButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      width: double.infinity,
      child: CupertinoButton(
        onPressed: onPressed,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? Colors.red : Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.getLocalizedFontFamily(context),
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          l10n.groomers,
          style: TextStyle(
                                  fontFamily: AppFonts.getTitleFontFamily(context),
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/images/back_icon.png',
              width: 24,
              height: 24,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          // Settings Button
          GestureDetector(
            onTap: _showUserAdsDialog,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.settings,
                color: Colors.grey[700],
                size: 20,
              ),
            ),
          ),
          
          // Plus Button
          GestureDetector(
            key: _dropdownKey,
            onTap: _showPostAdDropdown,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.add,
                color: Colors.orange,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: CupertinoScrollbar(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: _refreshAds,
              builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent) {
                return Container(
                  alignment: Alignment.center,
                  child: CupertinoActivityIndicator(
                    color: Colors.green,
                    radius: 14,
                  ),
                );
              },
            ),
            ..._buildContentSlivers(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContentSlivers() {
    if (_isLoading) {
      return [
        SliverToBoxAdapter(
          child: GroomerSkeletonLoader(),
        ),
      ];
    }
    
    if (_error != null) {
      return [
        SliverToBoxAdapter(
          child: _buildErrorState(),
        ),
      ];
    }
    
    if (_groomingAds.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: _buildEmptyState(),
        ),
      ];
    }
    
    return [
        // Header Section
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // Groomer Service Icon Banner
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Image.asset(
                    'assets/images/groomerservice.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey.shade100,
                        child: Icon(
                          CupertinoIcons.scissors_alt,
                          size: 60,
                          color: Colors.orange.shade400,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Section Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.location_solid,
                      size: 20,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grooming service near you',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontFamily: AppFonts.getTitleFontFamily(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _userLocationName ?? (_userLocation != null ? 'Loading location...' : 'Enable location to see nearby groomers'),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontFamily: AppFonts.getLocalizedFontFamily(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_groomingAds.length} service${_groomingAds.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: AppFonts.getLocalizedFontFamily(context),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
        
        // Ads List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ServiceAdCard(serviceAd: _groomingAds[index]);
            },
            childCount: _groomingAds.length,
          ),
        ),
        
        // Bottom Padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
    ];
  }



  Widget _buildErrorState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // Header
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Image.asset(
                'assets/images/groomerservice.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey.shade100,
                    child: Icon(
                      CupertinoIcons.scissors_alt,
                      size: 60,
                      color: Colors.orange.shade400,
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 100),
          
          // Error Message
          Center(
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  size: 60,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Services',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                                          fontFamily: AppFonts.getTitleFontFamily(context),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _refreshAds,
                  icon: Icon(CupertinoIcons.refresh),
                  label: Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildEmptyState() {
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.scissors_alt,
                  size: 48,
                  color: Colors.orange.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Grooming Ads Yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                                          fontFamily: AppFonts.getTitleFontFamily(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to post a grooming service ad!\nTap the + button above to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _showPostAdDropdown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Post an Ad',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: AppFonts.getLocalizedFontFamily(context),
                          ),
                        ),
                      ],
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
