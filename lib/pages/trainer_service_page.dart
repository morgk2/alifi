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
import '../widgets/location_filter_dialog.dart';
import '../widgets/service_skeleton_loader.dart';
import '../widgets/user_ads_dialog.dart';
import 'post_service_ad_page.dart';

class TrainerServicePage extends StatefulWidget {
  const TrainerServicePage({super.key});

  @override
  State<TrainerServicePage> createState() => _TrainerServicePageState();
}

class _TrainerServicePageState extends State<TrainerServicePage> {
  List<ServiceAd> _trainingAds = [];
  bool _isLoading = true;
  bool _isLoadingLocation = false;
  String? _error;
  final GlobalKey _dropdownKey = GlobalKey();
  
  // Location variables
  latlong.LatLng? _userLocation;
  String? _userLocationName;
  latlong.LatLng? _filterLocation; // Custom filter location
  String? _filterLocationName; // Custom filter location name

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getUserLocation();
    await _loadTrainingAds();
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

  Future<void> _loadTrainingAds() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      List<ServiceAd> ads;
      
      // Use filter location if set, otherwise use user location
      final searchLocation = _filterLocation ?? _userLocation;
      
      if (searchLocation != null) {
        // Load nearby training ads sorted by distance
        ads = await ServiceAdService.getNearbyServiceAds(
          serviceType: ServiceAdType.training,
          userLatitude: searchLocation.latitude,
          userLongitude: searchLocation.longitude,
          radiusKm: 50.0,
          limit: 20,
        );
      } else {
        // Fallback to all training ads
        ads = await ServiceAdService.getServiceAdsByType(ServiceAdType.training);
      }
      
      if (mounted) {
        setState(() {
          _trainingAds = ads;
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
    await _loadTrainingAds();
  }

  void _showLocationDropdown() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(
            'Location Options',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.getLocalizedFontFamily(context),
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _showLocationFilterDialog();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.location,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Change Location Filter',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                    ),
                  ),
                ],
              ),
            ),
            if (_filterLocation != null)
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _clearLocationFilter();
                },
                isDestructiveAction: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.clear,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Clear Filter',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.getLocalizedFontFamily(context),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.getLocalizedFontFamily(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLocationFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LocationFilterDialog(
        currentLocation: _filterLocation ?? _userLocation,
        currentLocationName: _filterLocationName ?? _userLocationName,
      ),
    );

    if (result != null) {
      setState(() {
        _filterLocation = result['location'] as latlong.LatLng?;
        _filterLocationName = result['locationName'] as String?;
      });
      
      // Reload ads with new filter location
      await _refreshAds();
    }
  }

  void _clearLocationFilter() {
    setState(() {
      _filterLocation = null;
      _filterLocationName = null;
    });
    _refreshAds();
  }

  String _getDisplayLocationName() {
    if (_filterLocation != null) {
      return _filterLocationName ?? 'Custom location';
    }
    return _userLocationName ?? (_userLocation != null ? 'Loading location...' : 'Enable location to see nearby trainers');
  }

  void _showPostAdDropdown() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(
            'Post Training Ad',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
                                   fontFamily: AppFonts.getLocalizedFontFamily(context),
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _postTrainingAd();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.add_circled,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Post an Ad',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.getLocalizedFontFamily(context),
              ),
            ),
          ),
        );
      },
    );
  }

  void _postTrainingAd() async {
    final result = await NavigationService.push(
      context,
      PostServiceAdPage(serviceType: ServiceAdType.training),
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
        serviceType: ServiceAdType.training,
      ),
    ).then((_) {
      // Refresh ads when dialog is closed in case any were edited/deleted
      _refreshAds();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          l10n.trainers,
          style: TextStyle(
            fontFamily: context.titleFont,
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
                 color: Colors.blue.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(12),
               ),
               child: Icon(
                 CupertinoIcons.add,
                 color: Colors.blue,
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
                    color: Colors.blue,
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
          child: ServiceSkeletonLoader(
            serviceColor: Colors.blue,
            itemCount: 4,
          ),
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
    
    if (_trainingAds.isEmpty) {
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
            
            // Trainer Service Icon Banner
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Image.asset(
                  'assets/images/trainerservice.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey.shade100,
                      child: Icon(
                        CupertinoIcons.person_2_alt,
                        size: 60,
                        color: Colors.blue.shade400,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Section Title with Tap to Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.location_solid,
                    size: 20,
                    color: _filterLocation != null ? Colors.orange : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showLocationDropdown,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Training service near you',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                          fontFamily: AppFonts.getTitleFontFamily(context),
                                        ),
                                      ),
                                    ),
                                    if (_filterLocation != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          'Filtered',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange,
                                            fontFamily: AppFonts.getLocalizedFontFamily(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getDisplayLocationName(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            CupertinoIcons.chevron_down,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_trainingAds.length} service${_trainingAds.length == 1 ? '' : 's'}',
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
            return ServiceAdCard(serviceAd: _trainingAds[index]);
          },
          childCount: _trainingAds.length,
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
                'assets/images/trainerservice.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey.shade100,
                    child: Icon(
                      CupertinoIcons.person_2_alt,
                      size: 60,
                      color: Colors.blue.shade400,
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
                    backgroundColor: Colors.blue,
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
                'assets/images/trainerservice.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey.shade100,
                    child: Icon(
                      CupertinoIcons.person_2_alt,
                      size: 60,
                      color: Colors.blue.shade400,
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 100),
          
          // Empty State Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.person_2_alt,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'No Training Ads Yet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontFamily: AppFonts.getTitleFontFamily(context),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Be the first to offer training services in your area! Post your ad to connect with pet owners looking for professional training.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _postTrainingAd,
                    icon: Icon(CupertinoIcons.add_circled, size: 20),
                    label: Text('Post an Ad'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.getLocalizedFontFamily(context),
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