import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/places_service.dart';
import '../services/location_service.dart';
import '../models/lost_pet.dart';
import '../services/database_service.dart';
import '../config/mapbox_config.dart';
import '../widgets/spinning_loader.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:ui';
import '../services/local_storage_service.dart';
import '../dialogs/report_missing_pet_dialog.dart';
import '../dialogs/add_business_dialog.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../pages/user_profile_page.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_snackbar.dart';
import '../services/map_focus_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/keyboard_dismissible_text_field.dart';
import '../widgets/universal_chat_page.dart';
import '../services/map_tile_cache_service.dart';


class _PhotoCarousel extends StatefulWidget {
  final List<dynamic> photos;
  final String apiKey;

  const _PhotoCarousel({
    required this.photos,
    required this.apiKey,
  });

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.photos.length,
            itemBuilder: (context, index) {
              final photo = widget.photos[index];
              final photoUrl = 'https://maps.googleapis.com/maps/api/place/photo'
                  '?maxwidth=800'
                  '&photo_reference=${photo['photo_reference']}'
                  '&key=${widget.apiKey}';

              return Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: SpinningLoader(
                          size: 32,
                          color: Colors.orange.withOpacity(0.8),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.grey,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        // Photo counter
        if (widget.photos.length > 1)
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentPage + 1}/${widget.photos.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        // Navigation arrows
        if (widget.photos.length > 1) ...[
          // Previous button
          if (_currentPage > 0)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Next button
          if (_currentPage < widget.photos.length - 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class MapPage extends StatefulWidget {
  final User? focusUser;
  
  const MapPage({super.key, this.focusUser});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final _placesService = PlacesService();
  final _locationService = LocationService();
  final MapController _mapController = MapController();
  final MapTileCacheService _tileCacheService = MapTileCacheService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<PlacesPrediction> _searchResults = [];
  List<LostPet> _nearbyLostPets = [];
  bool _isLoading = false;
  bool _locationEnabled = false;
  Position? _currentPosition;
  Timer? _debounceTimer;
  final String _sessionToken = const Uuid().v4();
  late AnimationController _searchPanelController;
  Marker? _selectedPlaceMarker;
  LatLng? _selectedLocation;
  String? _selectedAddress;
  List<LatLng>? _routePoints;
  final List<Color> _gradientColors = [
    Colors.orange.shade300,
    Colors.deepOrange.shade500,
  ];
  bool _isDetailsVisible = false;
  bool _isDetailsMinimized = false;
  late AnimationController _minimizeController;
  late Animation<double> _heightAnimation;
  Map<String, dynamic>? _selectedPlaceDetails;
  String? _selectedPlacePrediction;
  String? _selectedPlaceDistance;
  List<Marker> _vetMarkers = [];
  List<Marker> _storeMarkers = [];
  List<Marker> _userMarkers = [];
  List<LatLng> _specialMarkerLocations = []; // Store locations of vet/store markers
  bool _isLoadingVets = false;
  bool _isLoadingStores = false;
  double _currentZoom = 15.0;
  static const double _zoomThreshold = 11.0; // Threshold for simplified markers
  final GlobalKey _plusButtonKey = GlobalKey();

  final _storeMarkersController = StreamController<List<Marker>>.broadcast();
  final _storeResults = <Map<String, dynamic>>[];
  final _processedStorePlaceIds = <String>{};
  bool _legendExpanded = false;
  bool _legendVisible = true;

  void _minimizeLegend() {
    setState(() {
      _legendExpanded = false;
    });
  }

  void _setLegendExpanded(bool expanded) {
    setState(() {
      _legendExpanded = expanded;
    });
  }

  void _hideLegend() {
    if (_legendVisible) {
      setState(() {
        _legendVisible = false;
      });
    }
  }

  void _showLegend() {
    if (!_legendVisible) {
      setState(() {
        _legendVisible = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchPanelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _minimizeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _minimizeController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize tile cache service
    _initializeTileCache();
    
    _loadNearbyLostPets();
    _loadVetLocations();
    _loadStoreLocations();
    _loadUserLocations();
    _mapController.mapEventStream.listen((event) {
      final currentZoom = event.camera.zoom;
      if ((_currentZoom < _zoomThreshold && currentZoom >= _zoomThreshold) ||
          (_currentZoom >= _zoomThreshold && currentZoom < _zoomThreshold) ||
          (_currentZoom != currentZoom)) {
        setState(() {
          _currentZoom = currentZoom;
        });
      }
    });
    _setupMarkerControllers();
    
    // Handle focus user if provided
    if (widget.focusUser != null) {
      // Delay focus user handling to ensure map is rendered first
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleFocusUser();
        }
      });
      // Delay location initialization when there's a focus user
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _initializeLocation();
        }
      });
    } else {
      // Initialize location immediately if no focus user
      _initializeLocation();
    }
  }

  void _setupMarkerControllers() {
    _storeMarkersController.stream.listen((markers) {
      if (mounted) {
        setState(() {
          _storeMarkers = markers;
        });
      }
    });
  }

  /// Initialize tile cache service and preload tiles for current area
  Future<void> _initializeTileCache() async {
    try {
      // Initialize the cache service
      await _tileCacheService.initialize();
      
      // Get current location for preloading using Geolocator
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      // Preload tiles for the current area (10km radius)
      await _tileCacheService.preloadTiles(
        minZoom: 10,
        maxZoom: 16,
        centerLat: position.latitude,
        centerLng: position.longitude,
        radiusKm: 10.0,
      );
      
      if (kDebugMode) {
        final stats = _tileCacheService.getCacheStats();
        print('🗺️ [MapPage] Tile cache stats: ${stats['cachedTiles']} tiles, ${stats['hitRate']}% hit rate');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MapPage] Failed to initialize tile cache: $e');
      }
    }
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> _getCacheStats() {
    return _tileCacheService.getCacheStats();
  }
  
  void _handleFocusUser() {
    final focusUser = widget.focusUser!;
    print('MapPage: Handling focus user ${focusUser.displayName}, location: ${focusUser.location}, accountType: ${focusUser.accountType}');
    
    // Check for different types of location data
    LatLng? targetLocation;
    String? locationName;
    
    if (focusUser.location != null) {
      // Primary: Use LatLng location if available
      targetLocation = LatLng(focusUser.location!.latitude, focusUser.location!.longitude);
      locationName = focusUser.businessName ?? focusUser.clinicName ?? focusUser.storeName ?? focusUser.displayName;
    } else if (focusUser.businessLocation != null && focusUser.businessLocation!.isNotEmpty) {
      // Secondary: Use business location string
      locationName = focusUser.businessLocation;
      // For string locations, we'll show the dialog but not move the map
      // since we don't have coordinates
    } else if (focusUser.clinicLocation != null && focusUser.clinicLocation!.isNotEmpty) {
      // Tertiary: Use clinic location string
      locationName = focusUser.clinicLocation;
      // For string locations, we'll show the dialog but not move the map
      // since we don't have coordinates
    }
    
    if (targetLocation != null) {
      // Move to focus user location after ensuring map is rendered
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          print('MapPage: Moving map to ${targetLocation!.latitude}, ${targetLocation!.longitude}');
          _mapController.move(targetLocation!, 15.0);
          
          // Show business dialog for vet/store accounts after a short delay
          if (focusUser.accountType == 'vet' || focusUser.accountType == 'store') {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                print('MapPage: Showing business dialog for ${focusUser.displayName}');
                _showBusinessDialog(focusUser);
                // Don't clear the focus user immediately - let the dialog handle it
                // The focus user will be cleared when the dialog is dismissed
              }
            });
          }
        }
      });
    } else if (locationName != null && (focusUser.accountType == 'vet' || focusUser.accountType == 'store')) {
      // If we have a location name but no coordinates, just show the dialog
      if (mounted) {
        print('MapPage: Showing business dialog for ${focusUser.displayName} (no coordinates)');
        _showBusinessDialog(focusUser);
        // Don't clear the focus user immediately - let the dialog handle it
      }
    } else {
      print('MapPage: Focus user has no location data');
      // Only clear focus user if there's no location data and no dialog to show
      if (focusUser.accountType != 'vet' && focusUser.accountType != 'store') {
        Provider.of<MapFocusService>(context, listen: false).clearFocusUser();
      }
    }
  }

  @override
  void didUpdateWidget(MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if focusUser changed and handle it
    if (widget.focusUser != null && widget.focusUser != oldWidget.focusUser) {
      print('MapPage: Focus user changed to ${widget.focusUser?.displayName}');
      _handleFocusUser();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchPanelController.dispose();
    _minimizeController.dispose();
    _storeMarkersController.close();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    setState(() => _isLoading = true);
    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Show dialog to enable location services or enter manually
        if (!mounted) return;
        final String? action = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.locationServicesDisabled),
            content: Text(AppLocalizations.of(context)!.pleaseEnableLocationServicesOrEnterManually),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'manual'),
                child: Text(AppLocalizations.of(context)!.enterManually),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'settings'),
                child: Text(AppLocalizations.of(context)!.openSettings),
              ),
            ],
          ),
        );
        
        if (action == 'settings') {
          await Geolocator.openLocationSettings();
        } else if (action == 'manual') {
          if (!mounted) return;
          _showManualLocationInput();
        }
        setState(() => _isLoading = false);
      return;
    }

      // Then check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          CustomSnackBarHelper.showError(
            context,
            'Location permission is required to use this feature',
            duration: const Duration(seconds: 3),
          );
          setState(() => _isLoading = false);
      return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Show dialog to open app settings
        if (!mounted) return;
        final bool? openSettings = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.locationPermissionRequired),
            content: Text(AppLocalizations.of(context)!.locationPermissionRequiredForFeature),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)!.openSettings),
              ),
            ],
          ),
        );
        
        if (openSettings == true) {
          await openAppSettings();
        }
        setState(() => _isLoading = false);
        return;
      }

      // Get current position with timeout and accuracy settings
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      ).catchError((error) async {
        // If high accuracy times out, try with lower accuracy
        if (error is TimeoutException) {
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 5),
          );
        }
        throw error;
      }).catchError((error) async {
        // If medium accuracy times out, try with lowest accuracy
        if (error is TimeoutException) {
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 5),
          );
        }
        throw error;
      });
      
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _locationEnabled = true;
        _isLoading = false;
      });

      // Only move map to current location if no focus user is provided
      if (widget.focusUser == null) {
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          15.0,
        );
      }

      // Start listening to location updates
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen(
        (Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
        },
        onError: (error) {
          print('Location stream error: $error');
          // Try to reinitialize location if there's an error
          if (mounted) {
            _initializeLocation();
          }
        },
      );
    } catch (e) {
      print('Error getting location: $e');
      if (!mounted) return;
      
      CustomSnackBarHelper.showError(
        context,
        'Error getting location: ${e.toString()}',
        duration: const Duration(seconds: 10),
        actionLabel: 'Enter Manually',
        onAction: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _showManualLocationInput();
                },
      );
      
      setState(() {
        _isLoading = false;
        _locationEnabled = false;
      });
    }
  }

  Future<void> _handleSearch(String query) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // If query is empty, clear results
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    // Set loading state
    setState(() => _isLoading = true);

    // Debounce the search
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        // Add keywords to help find vets and pet stores
        final keywords = [
          query,
          '$query vet',
          '$query veterinaire',
          '$query pet store',
          '$query animalerie',
          '$query pet shop',
          '$query animal clinic',
        ];

        final allResults = <PlacesPrediction>[];
        
        // Search with each keyword
        for (final keyword in keywords) {
          final results = await _placesService.getPlacePredictions(keyword);
          allResults.addAll(results);
        }

        // Remove duplicates based on placeId
        final uniqueResults = allResults.fold<Map<String, PlacesPrediction>>(
          {},
          (map, prediction) {
            if (!map.containsKey(prediction.placeId)) {
              map[prediction.placeId] = prediction;
            }
            return map;
          },
        ).values.toList();

        if (mounted) {
          setState(() {
            _searchResults = uniqueResults;
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Search error: $e');
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _loadNearbyLostPets() async {
    try {
      final databaseService = context.read<DatabaseService>();
      // Listen to the stream and update state when new data arrives
      databaseService.getAllLostPets().listen((pets) {
        if (mounted) {
          setState(() {
            _nearbyLostPets = pets;
          });
        }
      });
    } catch (e) {
      print('Error loading nearby lost pets: $e');
    }
  }

  Future<void> _showManualLocationInput() async {
    final TextEditingController addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSearching = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.enterYourLocation),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter your street address, city, or area',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                if (isSearching)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: SpinningLoader(
                      size: 32,
                      color: Colors.orange,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: isSearching
                ? null
                : () async {
                    if (formKey.currentState?.validate() ?? false) {
                      setState(() => isSearching = true);
                      try {
                        final predictions = await _placesService.getPlacePredictions(addressController.text);
                        if (predictions.isNotEmpty) {
                          final details = await _getPlaceDetails(predictions.first.placeId);
                          if (details != null && details['geometry'] != null) {
                            final location = LatLng(
                              details['geometry']['location']['lat'],
                              details['geometry']['location']['lng'],
                            );
                          Navigator.pop(context, {
                              'location': location,
                              'address': predictions.first.description,
                          });
                          }
                        }
                      } catch (e) {
                        setState(() => isSearching = false);
                        CustomSnackBarHelper.showError(
                          context,
                          'Error finding location: ${e.toString()}',
                        );
                      }
                    }
                  },
              child: Text(AppLocalizations.of(context)!.search),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final location = result['location'] as LatLng;
      final address = result['address'] as String;
      
      setState(() {
        _currentPosition = Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        _locationEnabled = true;
      });

      // Move map to entered location
      _mapController.move(location, 15.0);

      // Show confirmation
      if (!mounted) return;
      CustomSnackBarHelper.showSuccess(
        context,
        'Location set to: $address',
      );
    }
  }

  Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
    try {
      print('Fetching details for place_id: $placeId');
      final url = Uri.parse(
        'https://maps.gomaps.pro/maps/api/place/details/json'
        '?place_id=$placeId'
        '&key=AlzaSylphbmAZJYT82Ie_cY1MVEbiQ4NRUxaqIo'
      );
      
      print('Making request to URL: $url');
      final response = await http.get(url);
      print('Response status code: \\${response.statusCode}');
      print('API response: \\${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data;
        } else {
          print('API returned non-OK status: ${data['status']}');
        }
      }
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  height: 48, // Match height with plus button
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: KeyboardDismissibleTextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _handleSearch,
                    decoration: InputDecoration(
                      hintText: 'Search places...',
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black.withOpacity(0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.black.withOpacity(0.6),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _handleSearch('');
                            },
                          )
                        : _isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(8),
                              child: SpinningLoader(
                                size: 24,
                                color: Colors.orange.shade300,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                key: _plusButtonKey,
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange.withOpacity(0.8), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _showAddMenu(context),
                    child: Icon(
                      Icons.add,
                      color: Colors.orange.shade50,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final authService = context.read<AuthService>();
    final isAdmin = authService.currentUser?.isAdmin ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _searchResults.isEmpty ? 0 : 300,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _searchResults.isEmpty ? 0.0 : 1.0,
                child: Container(
                decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
                  boxShadow: [
                    BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                  offset: const Offset(0, 2),
                    ),
                  ],
                ),
            child: _isLoading
              ? const Center(
                  child: SpinningLoader(
                    size: 32,
                    color: Colors.orange,
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final prediction = _searchResults[index];
                      final isVet = prediction.description.toLowerCase().contains('vet') ||
                                  prediction.description.toLowerCase().contains('veterinaire') ||
                                  prediction.description.toLowerCase().contains('clinic');
                      final isStore = prediction.description.toLowerCase().contains('pet') ||
                                    prediction.description.toLowerCase().contains('animal') ||
                                    prediction.description.toLowerCase().contains('animalerie');
                      
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                        border: Border(
                          bottom: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _selectSearchResult(prediction),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: isVet 
                                        ? Colors.blue.withOpacity(0.1)
                                        : isStore
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                      isVet 
                                        ? Icons.medical_services
                                        : isStore
                                          ? Icons.pets
                                          : Icons.location_on,
                                      color: isVet 
                                        ? Colors.blue
                                        : isStore
                                          ? Colors.green
                                          : Colors.orange.shade700,
                                    size: 20,
                                  ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        prediction.mainText,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        prediction.secondaryText,
                                        style: TextStyle(
                                            color: Colors.black.withOpacity(0.6),
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                                  if (isAdmin) ...[
                                    IconButton(
                                      icon: const Icon(Icons.local_hospital),
                                      color: Colors.blue,
                                      onPressed: () => _addBusinessToMap(prediction, true),
                                      tooltip: 'Add as Vet',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.pets),
                                      color: Colors.green,
                                      onPressed: () => _addBusinessToMap(prediction, false),
                                      tooltip: 'Add as Store',
                                    ),
                                  ],
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                    color: Colors.black.withOpacity(0.3),
                                  size: 16,
                    ),
                  ],
                ),
              ),
            ),
                      ),
                    );
                  },
                  ),
                ),
              ),
        ),
      ),
    );
  }

  // Add this method to safely update markers
  void _updateSelectedMarker(LatLng location, String label) {
    try {
      setState(() {
        _selectedPlaceMarker = Marker(
          point: location,
            width: 40,
            height: 40,
                      child: Column(
                        children: [
                          Container(
                      width: 20,
                      height: 20,
                        decoration: BoxDecoration(
                    color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
            ],
                    ),
        );
      });
    } catch (e) {
      print('Error updating marker: $e');
    }
  }

  // Add these methods to the _MapPageState class

  // Update the _selectSearchResult method to show the details
  Future<void> _selectSearchResult(PlacesPrediction prediction) async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      final details = await _getPlaceDetails(prediction.placeId);

      if (!mounted) return;

      if (details != null && details['result'] != null) {
        final result = details['result'];

        if (result['geometry'] != null && result['geometry']['location'] != null) {
          final location = result['geometry']['location'];
          final lat = location['lat'];
          final lng = location['lng'];

          final selectedLocation = LatLng(lat, lng);

          // Update state
          setState(() {
            _selectedLocation = selectedLocation;
            _selectedAddress = prediction.description;
            _searchResults = [];
            _searchController.clear();
            _searchFocusNode.unfocus();
            _isLoading = false;
          });

          // Move map to selected location
          try {
            _mapController.move(selectedLocation, 15.0);
          } catch (e) {
            print('Error moving map: $e');
          }

          // Update marker
          _updateSelectedMarker(selectedLocation, prediction.mainText);

          // Update route line
                            if (_currentPosition != null) {
            _updateRoutePolyline(selectedLocation);
          }

          // Show place details
          _showPlaceDetails(details, prediction.description);
                            } else {
          _handleError('Location coordinates not found in response');
        }
      } else {
        _handleError('Could not find location details');
      }
    } catch (e) {
      _handleError('Error selecting location: ${e.toString()}');
    }
  }

  void _handleError(String message) {
    print('Error: $message');
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
                              CustomSnackBarHelper.showError(
                                context,
                                message,
                              );
                            }

  void _updateRoutePolyline(LatLng destination) {
    if (_currentPosition == null) return;
    
    final userLocation = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    setState(() {
      _routePoints = [
        userLocation,
        destination,
      ];
    });
  }

  void _clearRoute() {
    setState(() {
      _routePoints = null;
    });
  }

  // Add this method to the _MapPageState class
  void _showPlaceDetails(Map<String, dynamic> placeDetails, String prediction) {
    print('DEBUG: placeDetails = $placeDetails');
    if (!mounted) return;

    // Support both wrapped and unwrapped result
    final result = placeDetails['result'] ?? placeDetails;
    if (result == null) {
      _handleError('No details found for this place.');
      return;
    }
    if (result['geometry'] == null || result['geometry']['location'] == null) {
      _handleError('No location data found for this place.');
      return;
    }

    final location = result['geometry']['location'];
    final lat = (location['lat'] as num?)?.toDouble();
    final lng = (location['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) {
      _handleError('Invalid coordinates for this place.');
      return;
    }

    final hasPhotos = result['photos'] != null && result['photos'].isNotEmpty;
    
    // Calculate distance if user location is available
    String? distance;
    if (_currentPosition != null) {
      final userLat = _currentPosition!.latitude;
      final userLng = _currentPosition!.longitude;
      final distanceInMeters = Geolocator.distanceBetween(userLat, userLng, lat, lng);
      if (distanceInMeters < 1000) {
        distance = '${distanceInMeters.round()}m';
      } else {
        distance = '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
      }
    }

    setState(() {
      _isDetailsVisible = true;
      _selectedPlaceDetails = placeDetails;
      _selectedPlacePrediction = prediction;
      _selectedPlaceDistance = distance;
      _isDetailsMinimized = false;
    });

    if (_isDetailsMinimized) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
        reverseDuration: const Duration(milliseconds: 300),
      ),
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final maxWidth = screenWidth > 425 ? 425.0 : screenWidth;
        final horizontalPadding = screenWidth > 357 ? (screenWidth - 357) / 2 : 8.0;
        
        return AnimatedBuilder(
          animation: ModalRoute.of(context)!.animation!,
          builder: (context, child) {
            final value = ModalRoute.of(context)!.animation!.value;
            return Transform.translate(
              offset: Offset(0, (1 - value) * 100),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onTap: () {}, // Prevent taps from dismissing the dialog
            child: Padding(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: MediaQuery.of(context).padding.bottom + 110,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
                            decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.45),
          borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
                              boxShadow: [
                                BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                        // Only show photo section if photos are available
                        if (hasPhotos) ...[
            Stack(
              children: [
                              SizedBox(
                                height: 140,
                                child: _PhotoCarousel(
                    photos: result['photos'],
                    apiKey: 'AlzaSy8GCoFh_rNeeXKWnVnqeCauTmWq3i85B6H',
                            ),
                          ),
                        Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () {
                                    setState(() => _isDetailsMinimized = true);
                      Navigator.pop(context);
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
                                    ),
                                    child: Icon(Icons.remove, color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                ),
                              ],
                            ),
                        ] else ...[
                          // Just show the minimize button without photo section
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, right: 8),
                              child: IconButton(
                                onPressed: () {
                                  setState(() => _isDetailsMinimized = true);
                                  Navigator.pop(context);
                                },
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
                                  ),
                                  child: Icon(Icons.remove, color: Colors.black.withOpacity(0.6)),
                            ),
                          ),
                        ),
                          ),
                        ],
                        Flexible(
                          child: SingleChildScrollView(
                            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business Name and Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                                          result['name'] ?? prediction,
                          style: const TextStyle(
                                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (result['rating'] != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                  child: Row(
                    children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                result['rating'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                  ),
                                ],
                              ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                                  // Business Type and Distance
                                  Row(
                                    children: [
                  if (result['types'] != null && result['types'].isNotEmpty)
                    Text(
                                          result['types'][0].toString().replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                                            color: Colors.black.withOpacity(0.6),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      if (distance != null) ...[
                                        if (result['types'] != null && result['types'].isNotEmpty)
                                          Text(
                                            ' • ',
                          style: TextStyle(
                                              color: Colors.black.withOpacity(0.6),
                                              fontSize: 12,
                        ),
                      ),
                                        Text(
                            distance,
                            style: TextStyle(
                                            color: Colors.black.withOpacity(0.6),
                                            fontSize: 12,
                              fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                                  // Opening Hours and Phone
                                  if (result['opening_hours'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: result['opening_hours']['open_now'] 
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                      result['opening_hours']['open_now'] ? AppLocalizations.of(context)!.openNow : AppLocalizations.of(context)!.closed,
                      style: TextStyle(
                        color: result['opening_hours']['open_now'] ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                      ),
                    ),
                                    ),
                                  if (result['formatted_phone_number'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      result['formatted_phone_number'],
                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                        fontSize: 13,
                      ),
                    ),
                                  ],
                  const SizedBox(height: 16),
                  // Navigation Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
                        launchUrl(Uri.parse(url));
                      },
                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.withOpacity(0.9),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.directions),
                      label: Text(
                        AppLocalizations.of(context)!.navigate,
                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
    ).whenComplete(() {
      if (mounted && !_isDetailsMinimized) {
        setState(() {
          _isDetailsVisible = false;
          _selectedPlaceDetails = null;
          _selectedPlacePrediction = null;
          _selectedPlaceDistance = null;
          _selectedPlaceMarker = null;
          _selectedLocation = null;
          _selectedAddress = null;
          _clearRoute();
        });
      }
    });
  }

  Widget _buildMinimizedPill(BuildContext context) {
    if (_selectedPlaceDetails == null) return const SizedBox.shrink();
    
    final result = _selectedPlaceDetails!['result'];
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 425 ? 425.0 : screenWidth;
    final horizontalPadding = screenWidth > 357 ? (screenWidth - 357) / 2 : 8.0;

    return Positioned(
      left: horizontalPadding,
      right: horizontalPadding,
      bottom: MediaQuery.of(context).padding.bottom + 110,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isDetailsMinimized = false;
            _showPlaceDetails(_selectedPlaceDetails!, _selectedPlacePrediction!);
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              height: 64,
              constraints: BoxConstraints(maxWidth: maxWidth),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.45),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            result['name'] ?? '',
                            style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          ),
                        ),
                          const Text(' • '),
                          if (_selectedPlaceDistance != null) ...[
                            Text(
                              _selectedPlaceDistance!,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.6),
                                fontSize: 14,
                      ),
                    ),
                            const Text(' • '),
                ],
                          if (result['opening_hours'] != null)
                            Text(
                              result['opening_hours']['open_now'] ? AppLocalizations.of(context)!.open : AppLocalizations.of(context)!.closed,
                              style: TextStyle(
                                color: result['opening_hours']['open_now'] 
                                  ? Colors.green 
                                  : Colors.red,
                                fontWeight: FontWeight.w500,
            ),
          ),
        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedPlaceDetails = null;
                        _selectedPlacePrediction = null;
                        _selectedPlaceDistance = null;
                        _isDetailsMinimized = false;
                        _isDetailsVisible = false;
                        _selectedPlaceMarker = null;
                        _selectedLocation = null;
                        _selectedAddress = null;
                        _clearRoute();
                      });
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
                      ),
                      child: Icon(Icons.close, color: Colors.black.withOpacity(0.6), size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to create a marker
  Marker _createVetMarker(Map<String, dynamic> vet) {
    print('Creating vet marker for: \\${vet['place_id']}');
    print('Vet data: $vet');
    
    try {
      // Support both 'location' and 'geometry.location'
      final location = vet['location'] ?? vet['geometry']?['location'];
      print('Location data: $location');
      
      if (location == null) {
        print('Error: Location is null for vet \\${vet['place_id']}');
        return Marker(
          point: const LatLng(0, 0),
          child: Container(),
        );
      }

      // Support both 'lat'/'lng' and 'latitude'/'longitude' keys
      final lat = (location['lat'] ?? location['latitude']) as double;
      final lng = (location['lng'] ?? location['longitude']) as double;
      print('Lat: $lat, Lng: $lng');

      return Marker(
        point: LatLng(lat, lng),
        width: 20,
        height: 20,
        child: RepaintBoundary(
          child: GestureDetector(
            onTap: () => _showVetDetails(vet),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.blue,  // Blue for vets
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('Error creating vet marker: $e');
      print('Stack trace: $stackTrace');
      print('Vet data that caused error: $vet');
      return Marker(
        point: const LatLng(0, 0),
        child: Container(),
      );
    }
  }

  Marker _createStoreMarker(Map<String, dynamic> store) {
    print('Creating store marker for: \\${store['place_id']}');
    print('Store data: $store');
    
    try {
      // Support both 'location' and 'geometry.location'
      final location = store['location'] ?? store['geometry']?['location'];
      print('Location data: $location');
      
      if (location == null) {
        print('Error: Location is null for store \\${store['place_id']}');
        return Marker(
          point: const LatLng(0, 0),
          child: Container(),
        );
      }

      // Support both 'lat'/'lng' and 'latitude'/'longitude' keys
      final lat = (location['lat'] ?? location['latitude']) as double;
      final lng = (location['lng'] ?? location['longitude']) as double;
      print('Lat: $lat, Lng: $lng');

      return Marker(
        point: LatLng(lat, lng),
        width: 20,
        height: 20,
        child: RepaintBoundary(
          child: GestureDetector(
            onTap: () => _showStoreDetails(store),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green,  // Green for stores
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('Error creating store marker: $e');
      print('Stack trace: $stackTrace');
      print('Store data that caused error: $store');
      return Marker(
        point: const LatLng(0, 0),
        child: Container(),
      );
    }
  }

  Marker _createUserMarker(User user) {
    final lat = user.location?.latitude ?? 0.0;
    final lng = user.location?.longitude ?? 0.0;
    
    // Make vet and store markers much bigger
    final isBusinessAccount = user.accountType == 'vet' || user.accountType == 'store';
    final markerSize = isBusinessAccount ? 60.0 : 30.0;
    
    return Marker(
      point: LatLng(lat, lng),
      width: markerSize,
      height: markerSize,
      child: RepaintBoundary(
        child: _MarkerWithJiggle(
          onTap: () {
            final isBusinessAccount = user.accountType == 'vet' || user.accountType == 'store';
            if (isBusinessAccount) {
              _showBusinessDialog(user);
            } else {
              Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(user: user),
            ),
              );
            }
          },
          child: _buildUserMarkerIcon(user),
        ),
      ),
    );
  }

  Marker _createUserMarkerWithDimming(User user, List<User> allUsers) {
    final lat = user.location?.latitude ?? 0.0;
    final lng = user.location?.longitude ?? 0.0;
    
    // Make vet and store markers much bigger
    final isBusinessAccount = user.accountType == 'vet' || user.accountType == 'store';
    final markerSize = isBusinessAccount ? 60.0 : 30.0;
    
    return Marker(
      point: LatLng(lat, lng),
      width: markerSize,
      height: markerSize,
      child: RepaintBoundary(
        child: _MarkerWithJiggle(
          onTap: () {
            final isBusinessAccount = user.accountType == 'vet' || user.accountType == 'store';
            if (isBusinessAccount) {
              _showBusinessDialog(user);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(user: user),
                ),
              );
            }
          },
          child: _buildUserMarkerIconWithDimming(user, allUsers),
        ),
      ),
    );
  }

    Widget _buildUserMarkerIcon(User user) {
    // Check if this marker should be dimmed
    final shouldDim = _shouldDimMarker(user);
    final opacity = shouldDim ? 0.3 : 1.0;
    
    // For vet and store users, use custom icons based on subscription
    if (user.accountType == 'vet') {
      final isFavorite = user.subscriptionPlan == 'alifi favorite';
      return Opacity(
        opacity: opacity,
        child: Image.asset(
          isFavorite ? 'assets/images/vet_fav.png' : 'assets/images/vet_normal.png',
          width: 60,
          height: 60,
        ),
      );
    } else if (user.accountType == 'store') {
      final isFavorite = user.subscriptionPlan == 'alifi favorite';
      return Opacity(
        opacity: opacity,
        child: Image.asset(
          isFavorite ? 'assets/images/store_fav.png' : 'assets/images/store_normal.png',
          width: 60,
          height: 60,
        ),
      );
    } else {
      // Regular users get a smaller circle
      return Opacity(
        opacity: opacity,
          child: Container(
          width: 20,
          height: 20,
            decoration: BoxDecoration(
            color: Colors.orange,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
      );
    }
  }

  Widget _buildUserMarkerIconWithDimming(User user, List<User> allUsers) {
    // Check if this marker should be dimmed
    final shouldDim = _shouldDimMarkerWithUsers(user, allUsers);
    final opacity = shouldDim ? 0.3 : 1.0;
    
    // For vet and store users, use custom icons based on subscription
    if (user.accountType == 'vet') {
      final isFavorite = user.subscriptionPlan == 'alifi favorite';
      return Opacity(
        opacity: opacity,
        child: Image.asset(
          isFavorite ? 'assets/images/vet_fav.png' : 'assets/images/vet_normal.png',
          width: 60,
          height: 60,
        ),
      );
    } else if (user.accountType == 'store') {
      final isFavorite = user.subscriptionPlan == 'alifi favorite';
      return Opacity(
        opacity: opacity,
        child: Image.asset(
          isFavorite ? 'assets/images/store_fav.png' : 'assets/images/store_normal.png',
          width: 60,
          height: 60,
        ),
      );
    } else {
      // Regular users get a smaller circle
      return Opacity(
        opacity: opacity,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
        ),
      );
    }
  }

  bool _shouldDimMarkerWithUsers(User user, List<User> allUsers) {
    // Don't dim special markers (vet/store)
    if (user.accountType == 'vet' || user.accountType == 'store') {
      return false;
    }
    
    // Don't dim if this is the current user's location
    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser;
    if (currentUser != null && user.id == currentUser.id) {
      return false;
    }
    
    if (user.location == null) return false;
    
    // Check if within range of any special markers
    const double dimRadius = 500.0; // 500 meters radius
    
    // Check proximity to vet/store users
    for (final otherUser in allUsers) {
      if (otherUser.id == user.id) continue; // Skip self
      
      if ((otherUser.accountType == 'vet' || otherUser.accountType == 'store') &&
          otherUser.location != null) {
        
        final distance = Geolocator.distanceBetween(
          user.location!.latitude,
          user.location!.longitude,
          otherUser.location!.latitude,
          otherUser.location!.longitude,
        );
        
        if (distance <= dimRadius) {
          return true;
        }
      }
    }
    
    return false;
  }

  bool _shouldDimMarker(User user) {
    // Don't dim special markers (vet/store) or user location
    if (user.accountType == 'vet' || user.accountType == 'store') {
      return false;
    }
    
    // Don't dim if this is the current user's location
    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser;
    if (currentUser != null && user.id == currentUser.id) {
      return false;
    }
    
    if (user.location == null) return false;
    
    // Check if within range of any special markers
    const double dimRadius = 500.0; // 500 meters radius
    
    // Check proximity to vet/store users
    for (final marker in _userMarkers) {
      // Find the user associated with this marker
      final otherUser = _findUserForMarker(marker);
      if (otherUser != null && 
          (otherUser.accountType == 'vet' || otherUser.accountType == 'store') &&
          otherUser.location != null) {
        
        final distance = Geolocator.distanceBetween(
          user.location!.latitude,
          user.location!.longitude,
          otherUser.location!.latitude,
          otherUser.location!.longitude,
        );
        
        if (distance <= dimRadius) {
          return true;
        }
      }
    }
    
    return false;
  }

  bool _shouldDimLostPetMarker(LostPet pet) {
    // Check if within range of any special markers (vet/store users)
    const double dimRadius = 500.0; // 500 meters radius
    
    // Check proximity to special marker locations
    for (final specialLocation in _specialMarkerLocations) {
      final distance = Geolocator.distanceBetween(
        pet.location.latitude,
        pet.location.longitude,
        specialLocation.latitude,
        specialLocation.longitude,
      );
      
      if (distance <= dimRadius) {
        return true;
      }
    }
    
    return false;
  }

  User? _findUserForMarker(Marker marker) {
    // This is a helper method to find the user associated with a marker
    // Since we don't have direct access to the user from the marker,
    // we'll need to implement this differently
    return null;
  }

  void _navigateToLocation(User user) {
    // Get the location from user data
    LatLng? location;
    String? locationName;
    
    if (user.location != null) {
      location = LatLng(user.location!.latitude, user.location!.longitude);
      locationName = user.businessName ?? user.clinicName ?? user.storeName ?? user.displayName;
    } else if (user.businessLocation != null && user.businessLocation!.isNotEmpty) {
      // businessLocation is a string, so we'll use it as the destination name
      locationName = user.businessLocation;
      // Try to get coordinates from the location string or use the business name
      final destination = user.businessName ?? user.businessLocation ?? user.displayName ?? 'Unknown Location';
      final url = 'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(destination)}';
      launchUrl(Uri.parse(url));
      return;
    } else if (user.clinicLocation != null && user.clinicLocation!.isNotEmpty) {
      // clinicLocation is a string, so we'll use it as the destination name
      locationName = user.clinicLocation;
      // Try to get coordinates from the location string or use the clinic name
      final destination = user.clinicName ?? user.clinicLocation ?? user.displayName ?? 'Unknown Location';
      final url = 'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(destination)}';
      launchUrl(Uri.parse(url));
      return;
    }
    
    if (location != null) {
      final url = 'https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}';
      if (locationName != null && locationName.isNotEmpty) {
        final encodedName = Uri.encodeComponent(locationName);
        final urlWithName = 'https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}&destination_place_id=$encodedName';
        launchUrl(Uri.parse(urlWithName));
      } else {
        launchUrl(Uri.parse(url));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No location data available for ${user.displayName}')),
      );
    }
  }

  void _showBusinessDialog(User user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent, // no global blur/dim
      builder: (dialogContext) {
        // Clear focus user when dialog is dismissed
        return PopScope(
          onPopInvoked: (didPop) {
            if (didPop) {
              Provider.of<MapFocusService>(context, listen: false).clearFocusUser();
            }
          },
          child: Builder(
            builder: (context) {
              final bool isVet = user.accountType == 'vet';
              final bool isFavorite = (user.subscriptionPlan ?? '').toLowerCase() == 'alifi favorite';
              final String displayName = [user.firstName, user.lastName]
                  .where((p) => (p ?? '').trim().isNotEmpty)
                  .join(' ');
              final String basicInfo = user.basicInfo ?? '';
              final int followers = user.followersCount != 0
                  ? user.followersCount
                  : (user.followers).length;
              final int orders = user.totalOrders;
              final String rating = user.rating.toStringAsFixed(1);

              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 350),
                tween: Tween(begin: 1.0, end: 0.0),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, value * 400), // Slide up from bottom
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 100, // Position above navigation bar
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    constraints: const BoxConstraints(maxWidth: 520),
                                    padding: const EdgeInsets.all(22),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(color: Colors.grey.shade300, width: 1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 64,
                                              height: 64,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isVet ? Colors.blue : Colors.orange,
                                                  width: 3,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(32),
                                                child: (user.photoURL != null && user.photoURL!.isNotEmpty)
                                                    ? Image.network(
                                                        user.photoURL!,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) => _buildDefaultProfileImage(user),
                                                      )
                                                    : _buildDefaultProfileImage(user),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    displayName.isNotEmpty
                                                        ? displayName
                                                        : (isVet ? (user.clinicName ?? 'Veterinary Clinic') : (user.storeName ?? 'Pet Store')),
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w800,
                                                      fontFamily: 'InterDisplay',
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  if (basicInfo.isNotEmpty)
                                                    Text(
                                                      basicInfo,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[700],
                                                        fontFamily: 'InterDisplay',
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 16),

                                        if (isFavorite)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFFF6B35).withOpacity(0.25),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.verified, color: Colors.white, size: 16),
                                                const SizedBox(width: 6),
                                                Text(
                                                  AppLocalizations.of(context)!.alifiFavorite,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'InterDisplay',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        // Alifi Affiliated badge
                                        if ((user.subscriptionPlan ?? '').toLowerCase() == 'alifi affiliated')
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF3B82F6).withOpacity(0.25),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.verified, color: Colors.white, size: 16),
                                                const SizedBox(width: 6),
                                                Text(
                                                  AppLocalizations.of(context)!.alifiAffiliated,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'InterDisplay',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        if (isFavorite || (user.subscriptionPlan ?? '').toLowerCase() == 'alifi affiliated') const SizedBox(height: 16),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildStatItem('Followers', followers.toString(), Icons.people, Colors.blue),
                                            _buildStatItem('Orders', orders.toString(), Icons.shopping_bag, Colors.green),
                                            _buildStatItem('Rating', rating, Icons.star, Colors.amber),
                                          ],
                                        ),

                                        const SizedBox(height: 20),

                                        // Action buttons row
                                        Row(
                                          children: [
                                            // Navigate button
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  _navigateToLocation(user);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  elevation: 0,
                                                  shadowColor: Colors.transparent,
                                                ),
                                                icon: const Icon(Icons.directions, size: 20),
                                                label: Text(
                                                  AppLocalizations.of(context)!.navigate,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'InterDisplay',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Visit Profile button
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(dialogContext).pop();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => UserProfilePage(user: user),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isVet ? Colors.blue : Colors.orange,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  elevation: 0,
                                                  shadowColor: Colors.transparent,
                                                ),
                                                child: Text(
                                                  isVet ? AppLocalizations.of(context)!.visitClinicProfile : AppLocalizations.of(context)!.visitStoreProfile,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'InterDisplay',
                                                  ),
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

                              Positioned(
                                top: -6,
                                right: -6,
                                child: Transform.rotate(
                                  angle: -0.2,
                                  child: Image.asset(
                                    'assets/images/stamp.png',
                                    width: 84,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDefaultProfileImage(User user) {
    final bool isVet = user.accountType == 'vet';
    return Container(
      color: Colors.transparent,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (isVet ? Colors.blue : Colors.orange).withOpacity(0.1),
        ),
        child: Icon(
          isVet ? Icons.local_hospital : Icons.store,
          color: isVet ? Colors.blue : Colors.orange,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'InterDisplay',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'InterDisplay',
            ),
          ),
        ],
      ),
    );
  }

  // Add this method to cluster markers
  List<Marker> _clusterMarkers(List<Marker> markers, double zoom) {
    if (zoom >= 10) {  // Changed from 13 to 10 to show individual markers sooner
      return markers;
    }

    final clusters = <Marker>[];
    final gridSize = zoom < 8 ? 0.5 : 0.2;  // Reduced grid sizes to create smaller clusters
    final processed = <int>{};

    for (var i = 0; i < markers.length; i++) {
      if (processed.contains(i)) continue;

      final marker = markers[i];
      final lat = marker.point.latitude;
      final lng = marker.point.longitude;
      
      // Find nearby markers
      final nearbyMarkers = <Marker>[marker];
      processed.add(i);

      for (var j = i + 1; j < markers.length; j++) {
        if (processed.contains(j)) continue;

        final other = markers[j];
        final otherLat = other.point.latitude;
        final otherLng = other.point.longitude;

        // Check if markers are in the same grid cell
        if ((otherLat - lat).abs() <= gridSize && 
            (otherLng - lng).abs() <= gridSize) {
          nearbyMarkers.add(other);
          processed.add(j);
        }
      }

      if (nearbyMarkers.length == 1) {
        clusters.add(marker);
      } else {
        // Create a cluster marker
        final centerLat = nearbyMarkers.map((m) => m.point.latitude).reduce((a, b) => a + b) / nearbyMarkers.length;
        final centerLng = nearbyMarkers.map((m) => m.point.longitude).reduce((a, b) => a + b) / nearbyMarkers.length;

        clusters.add(Marker(
          point: LatLng(centerLat, centerLng),
          width: 30,
          height: 30,
          child: RepaintBoundary(
            child: GestureDetector(
              onTap: () {
                // Zoom in when cluster is tapped
                _mapController.move(LatLng(centerLat, centerLng), zoom + 2);  // Zoom in by 2 levels
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${nearbyMarkers.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
      }
    }

    return clusters;
  }

  // Helper function to add new vets to the map
  Future<void> _addNewVets(List<Map<String, dynamic>> newVets, Set<String> processedPlaceIds) async {
    if (!mounted) return;
    
    final newMarkers = <Marker>[];
    
    for (final vet in newVets) {
      try {
        final placeId = vet['place_id'] as String;
        if (!processedPlaceIds.contains(placeId)) {
          processedPlaceIds.add(placeId);
          newMarkers.add(_createVetMarker(vet));
          print('Added vet: ${vet['name']}');
          print('  Address: ${vet['vicinity']}');
          if (vet['opening_hours'] != null) {
            print('  Open now: ${vet['opening_hours']['open_now']}');
          }
        }
      } catch (e) {
        print('Error creating vet marker: $e');
      }
    }

    if (newMarkers.isNotEmpty && mounted) {
      setState(() {
        _vetMarkers = [..._vetMarkers, ...newMarkers];
      });
    }
  }

  Future<void> _loadVetLocations() async {
    setState(() => _isLoadingVets = true);

    try {
      // Initialize Places Service
      await PlacesService.initialize();
      
      // Load from LocationService first as fallback
      final vets = await _locationService.getAllVetClinics();
      final vetMarkers = vets.map((vet) => _createVetMarker(vet)).toList();
      
      if (mounted) {
        setState(() {
          _vetMarkers = vetMarkers;
        });
      }

      // Then try to load additional vets from Places Service
      final placesVets = await _placesService.getAllVetClinics();
      if (placesVets.isNotEmpty) {
        final additionalMarkers = placesVets
          .where((vet) => !_vetMarkers.any((m) => m.key.toString() == vet['place_id']))
          .map((vet) => _createVetMarker(vet))
          .toList();

        if (mounted) {
          setState(() {
            _vetMarkers = [..._vetMarkers, ...additionalMarkers];
          });
        }
      }
    } catch (e) {
      print('Error loading vet locations: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingVets = false);
      }
    }
  }

  Future<void> _loadStoreLocations() async {
    if (_isLoadingStores) return;

    setState(() {
      _isLoadingStores = true;
      _storeMarkers = [];
    });

    try {
      // Initialize Places Service
      await PlacesService.initialize();
      
      // Load from LocationService first as fallback
      final stores = await _locationService.getAllPetStores();
      final storeMarkers = stores.map((store) => _createStoreMarker(store)).toList();
      
      if (mounted) {
        setState(() {
          _storeMarkers = storeMarkers;
        });
      }

      // Then try to load additional stores from Places Service
      final placesStores = await _placesService.getAllPetStores();
      if (placesStores.isNotEmpty) {
        final additionalMarkers = placesStores
          .where((store) => !_storeMarkers.any((m) => m.key.toString() == store['place_id']))
          .map((store) => _createStoreMarker(store))
          .toList();

        if (mounted) {
          setState(() {
            _storeMarkers = [..._storeMarkers, ...additionalMarkers];
          });
        }
      }
    } catch (e) {
      print('Error loading store locations: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingStores = false);
      }
    }
  }

  Future<void> _loadUserLocations() async {
    try {
      final databaseService = context.read<DatabaseService>();
      databaseService.getUsersWithLocation().listen((users) {
        if (mounted) {
          setState(() {
            _userMarkers = users.map((user) => _createUserMarkerWithDimming(user, users)).toList();
            
            // Update special marker locations for proximity checking
            _specialMarkerLocations = users
                .where((user) => 
                    (user.accountType == 'vet' || user.accountType == 'store') && 
                    user.location != null)
                .map((user) => user.location!)
                .toList();
          });
        }
      });
    } catch (e) {
      print('Error loading user locations: $e');
    }
  }

  bool _isVetLocation(String name, List<String> types) {
    // Keywords that might appear in vet location names
    final vetKeywords = [
      'vet',
      'veterinaire',
      'veterinary',
      'clinique',
      'clinic',
      'cabinet',
      'hopital',
      'hospital',
      'animal',
      'pet',
      'عيادة',
      'بيطري',
      'طبيب',
      'حيوانات',
    ];

    // Common types for vet locations
    final vetTypes = [
      'veterinary_care',
      'pet_store',
      'health',
      'doctor',
      'medical',
      'clinic',
      'hospital',
    ];

    // Check if name contains any vet-related keywords
    final hasVetKeyword = vetKeywords.any((keyword) => 
      name.contains(keyword) || 
      name.contains(keyword.replaceAll('e', 'é')) // Handle accented characters
    );

    // Check if types contain any vet-related types
    final hasVetType = vetTypes.any((type) => types.contains(type));

    return hasVetKeyword || hasVetType;
  }

  void _showAddMenu(BuildContext context) {
    if (kIsWeb) {
      _showWebMenu(context);
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      _showiOSMenu(context);
    } else {
      _showAndroidMenu(context);
    }
  }

  void _showWebMenu(BuildContext context) {
    final RenderBox button = _plusButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);
    final Size size = button.size;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        overlay.size.width - (offset.dx + size.width),
        overlay.size.height - (offset.dy + size.height),
      ),
      items: [
        PopupMenuItem(
          child: Text(
            AppLocalizations.of(context)!.reportMissingPet,
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () => _showReportMissingPetDialog(context),
        ),
        PopupMenuItem(
          child: Text(
            AppLocalizations.of(context)!.addYourBusiness,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
          onTap: () => _showAddBusinessDialog(context),
        ),
      ],
    );
  }

  void _showiOSMenu(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _showReportMissingPetDialog(context);
            },
            child: Text(AppLocalizations.of(context)!.reportMissingPet),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showAddBusinessDialog(context);
            },
            child: Text(AppLocalizations.of(context)!.addYourBusiness),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
      ),
    );
  }

  void _showAndroidMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.pets, color: Colors.red.shade700),
            title: Text(
              'Report Missing Pet',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _showReportMissingPetDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.store, color: Colors.black87),
            title: const Text(
              'Add Your Business',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _showAddBusinessDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showReportMissingPetDialog(BuildContext context) {
    final authService = context.read<AuthService>();
    if (authService.currentUser == null) {
      // Show login prompt if user is not authenticated
      CustomSnackBarHelper.showInfo(
        context,
        'Please login to report a missing pet',
        duration: const Duration(seconds: 2),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => ReportMissingPetDialog(
        userId: authService.currentUser!.id,
      ),
    );
  }

  void _showAddBusinessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddBusinessDialog(),
    );
  }

  Future<void> _addBusinessToMap(PlacesPrediction prediction, bool isVet) async {
    try {
      setState(() => _isLoading = true);
      
      // Get place details
      final details = await _getPlaceDetails(prediction.placeId);
      if (details == null || details['result'] == null) {
        throw 'Could not get place details';
      }

      final result = details['result'];
      if (result['geometry'] == null || result['geometry']['location'] == null) {
        throw 'Location coordinates not found';
      }

      final location = result['geometry']['location'];
      final lat = location['lat'] as double;
      final lng = location['lng'] as double;

      // Check if place already exists in database
      final dbService = context.read<DatabaseService>();
      final existingLocation = isVet 
        ? await dbService.getVetLocation(prediction.placeId)
        : await dbService.getStoreLocation(prediction.placeId);

      if (existingLocation != null) {
        if (!mounted) return;
        CustomSnackBarHelper.showInfo(
          context,
          'This ${isVet ? 'vet' : 'store'} is already in the database',
        );
        return;
      }

      // Save to database using new methods
      if (isVet) {
        await dbService.saveVetLocation(prediction.placeId, lat, lng);
      } else {
        await dbService.saveStoreLocation(prediction.placeId, lat, lng);
      }

      // Add marker
      final marker = isVet 
        ? _createVetMarker(result)
        : _createStoreMarker(result);

      setState(() {
        if (isVet) {
          _vetMarkers = [..._vetMarkers, marker];
        } else {
          _storeMarkers = [..._storeMarkers, marker];
        }
        _searchResults = [];
        _searchController.clear();
        _searchFocusNode.unfocus();
      });

      // Show success message
      if (!mounted) return;
      CustomSnackBarHelper.showSuccess(
        context,
        'Added ${isVet ? 'vet clinic' : 'pet store'} to map',
      );

      // Move map to new location
      _mapController.move(LatLng(lat, lng), 15.0);

      // Refresh the cache in PlacesService
      await PlacesService.initialize();

    } catch (e) {
      print('Error adding business: $e');
      if (!mounted) return;
      CustomSnackBarHelper.showError(
        context,
        'Error adding business: $e',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Apply clustering based on zoom level
    final displayedVetMarkers = _clusterMarkers(_vetMarkers, _currentZoom);
    final displayedStoreMarkers = _clusterMarkers(_storeMarkers, _currentZoom);

    // Debug: Print the number of markers being displayed
    print('DEBUG: Displaying \\${displayedStoreMarkers.length} store markers, \\${displayedVetMarkers.length} vet markers, \\${_userMarkers.length} user markers at zoom level \\${_currentZoom}');

    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : const LatLng(36.7538, 3.0588), // Default to Algiers
                initialZoom: 10.0,  // Changed from 15 to 10 to show more markers initially
                minZoom: 5.0,  // Add minimum zoom level
                maxZoom: 18.0,  // Add maximum zoom level
                initialRotation: 0.0,  // Lock rotation to north
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.flingAnimation | InteractiveFlag.doubleTapZoom,
                ),
                onMapEvent: (event) {
                  final currentZoom = event.camera.zoom;
                  if ((_currentZoom < _zoomThreshold && currentZoom >= _zoomThreshold) ||
                      (_currentZoom >= _zoomThreshold && currentZoom < _zoomThreshold) ||
                      (_currentZoom != currentZoom)) {
                    setState(() {
                      _currentZoom = currentZoom;
                    });
                  }
                  
                  // Lock rotation to north (0 degrees)
                  if (event.camera.rotation != 0.0) {
                    _mapController.rotate(0.0);
                  }
                  
                  // Only hide legend on drag/move, NOT on tap
                  if (event is MapEventMove || event is MapEventMoveStart || event is MapEventMoveEnd) {
                    _hideLegend();
                  }
                  if (_legendExpanded) _minimizeLegend();
                },
                onTap: (tapPosition, latlng) {
                  _showLegend();
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _tileCacheService.getTileUrl(0, 0, 0), // This will be overridden by our custom tile provider
                  tileProvider: _CachedTileProvider(_tileCacheService),
                  tileBuilder: (context, widget, tile) {
                    return RepaintBoundary(
                      child: widget,
                    );
                  },
                ),
                // Lost pet zones
                if (_nearbyLostPets.isNotEmpty)
                  CircleLayer(
                    circles: _nearbyLostPets.map((pet) {
                      final circleColor = Colors.red.withOpacity(0.2);
                      final borderColor = Colors.red.withOpacity(0.5);
                      
                      return CircleMarker(
                        point: pet.location,
                        radius: 500.0, // 500 meters radius
                        useRadiusInMeter: true,
                        color: circleColor,
                        borderColor: borderColor,
                        borderStrokeWidth: 2,
                      );
                    }).toList(),
                  ),

                // Lost pet markers
                if (_nearbyLostPets.isNotEmpty)
                  MarkerLayer(
                    markers: _nearbyLostPets.map((pet) {
                      final shouldDim = _shouldDimLostPetMarker(pet);
                      final opacity = shouldDim ? 0.3 : 1.0;
                      
                      return Marker(
                        point: pet.location,
                        width: 20,
                        height: 20,
                        child: GestureDetector(
                          onTap: () => _showLostPetDetails(pet),
                          child: Opacity(
                            opacity: opacity,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.pets,
                              color: Colors.white,
                              size: 10,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                // Current location marker
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        width: 20,
                        height: 20,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                // Selected place marker
                if (_selectedPlaceMarker != null)
                  MarkerLayer(
                    markers: [_selectedPlaceMarker!],
                  ),

                // Vet markers layer with clustering
                if (displayedVetMarkers.isNotEmpty)
                  MarkerLayer(
                    markers: displayedVetMarkers,
                  ),

                // Store markers layer with clustering
                if (displayedStoreMarkers.isNotEmpty)
                  MarkerLayer(
                    markers: displayedStoreMarkers,
                  ),

                // User markers layer
                if (_userMarkers.isNotEmpty)
                  MarkerLayer(
                    markers: _userMarkers,
                  ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildSearchResults(),
                ],
              ),
            ),
          ),
          // Location button with visibility animation
          AnimatedPositioned(
            right: 16,
            bottom: 104,
            duration: const Duration(milliseconds: 300),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isDetailsVisible ? 0.0 : 1.0,
              child: IgnorePointer(
                ignoring: _isDetailsVisible,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.45),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _locationEnabled ? _moveToCurrentLocation : _initializeLocation,
                          child: _isLoading
                            ? Center(
                                child: SpinningLoader(
                                  size: 24,
                                  color: Colors.blue.shade300,
                                ),
                              )
                            : Icon(
                _locationEnabled ? Icons.my_location : Icons.location_searching,
                color: Colors.blue,
                                size: 24,
                      ),
                    ),
                ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Remove the separate loading indicator since it's now integrated into the button
          if (_isLoadingVets)
            Positioned(
              right: 16,
              bottom: 164, // Above the location button
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SpinningLoader(
                      size: 16,
                      color: Colors.green.shade300,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Loading vets (${_vetMarkers.length} found)...',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoadingStores)
            Positioned(
              right: 16,
              bottom: 164, // Above the location button
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SpinningLoader(
                      size: 16,
                      color: Colors.green.shade300,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Loading stores (${_storeMarkers.length} found)...',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          // Enable the AnimatedSlide for the legend
          Positioned(
            left: 24,
            bottom: 100,
            child: AnimatedSlide(
              offset: _legendVisible ? Offset.zero : const Offset(-2.0, 0),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              child: MapLegend(
                expanded: _legendExpanded,
                onMinimize: _minimizeLegend,
                onExpandChanged: _setLegendExpanded,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _moveToCurrentLocation() {
                            if (_currentPosition != null) {
                              _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                15.0,
                              );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

    void _showLostPetDetails(LostPet pet) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 380,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with close button
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              CupertinoIcons.heart_fill,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lost Pet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade800,
                                    fontFamily: 'InterDisplay',
                                  ),
                                ),
                                Text(
                                  'Help bring ${pet.pet.name} home',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                CupertinoIcons.xmark,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pet Image Section
                    if (pet.pet.imageUrls.isNotEmpty)
                      Container(
                        height: 200,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              PageView.builder(
                                itemCount: pet.pet.imageUrls.length,
                                itemBuilder: (context, index) {
                                  return CachedNetworkImage(
                                    imageUrl: pet.pet.imageUrls[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.shade200,
                                      child: Center(
                                        child: CupertinoActivityIndicator(
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        CupertinoIcons.photo,
                                        color: Colors.grey.shade400,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (pet.pet.imageUrls.length > 1)
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: BackdropFilter(
                                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '1/${pet.pet.imageUrls.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                    // Content Section
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pet Name and Status
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    pet.pet.name,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'InterDisplay',
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade500,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'MISSING',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Pet Info Cards
                            _buildInfoCard(
                              icon: CupertinoIcons.paw,
                              title: 'Pet Details',
                              content: pet.pet.breed != null ? '${pet.pet.species} • ${pet.pet.breed}' : pet.pet.species,
                              color: Colors.blue,
                            ),
                            
                            const SizedBox(height: 12),
                            
                            _buildInfoCard(
                              icon: CupertinoIcons.location,
                              title: 'Last Seen Location',
                              content: pet.address,
                              color: Colors.orange,
                            ),
                            
                            const SizedBox(height: 12),
                            
                            _buildInfoCard(
                              icon: CupertinoIcons.calendar,
                              title: 'Last Seen Date',
                              content: _formatDate(pet.lastSeenDate),
                              color: Colors.purple,
                            ),
                            
                            if (pet.reward != null && pet.reward! > 0) ...[
                              const SizedBox(height: 12),
                              _buildRewardCard(pet.reward!),
                            ],
                            
                            if (pet.additionalInfo != null && pet.additionalInfo!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoCard(
                                icon: CupertinoIcons.info_circle,
                                title: 'Additional Information',
                                content: pet.additionalInfo!,
                                color: Colors.teal,
                              ),
                            ],
                            
                            const SizedBox(height: 24),
                            
                            // Contact Section
                            if (pet.contactNumbers.isNotEmpty) ...[
                              Text(
                                'Contact Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade800,
                                  fontFamily: 'InterDisplay',
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...pet.contactNumbers.map((number) => 
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: _buildActionButton(
                                    icon: CupertinoIcons.phone,
                                    label: number,
                                    color: Colors.green,
                                    onTap: () => launchUrl(Uri.parse('tel:$number')),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Action Buttons
                            _buildActionButton(
                              icon: CupertinoIcons.chat_bubble_2,
                              label: 'Contact Owner',
                              color: Colors.orange,
                              isPrimary: true,
                              onTap: () async {
                                await _contactOwner(context, pet);
                              },
                            ),
                            
                            const SizedBox(height: 12),
                            
                            _buildActionButton(
                              icon: CupertinoIcons.person_circle,
                              label: 'View Owner Profile',
                              color: Colors.blue,
                              onTap: () async {
                                await _viewOwnerProfile(context, pet);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    fontFamily: 'InterDisplay',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontFamily: 'Inter',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(double reward) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.green.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              CupertinoIcons.money_dollar_circle,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reward Offered',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'InterDisplay',
                  ),
                ),
                Text(
                  '\$${reward.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'InterDisplay',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                )
              : null,
          color: isPrimary ? null : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : color,
                fontFamily: 'InterDisplay',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _contactOwner(BuildContext context, LostPet pet) async {
    try {
      Navigator.pop(context);
      _showLoadingDialog(context);
      
      final owner = await context.read<DatabaseService>().getUser(pet.reportedByUserId);
      if (context.mounted) Navigator.pop(context);
      
      if (owner != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UniversalChatPage(
              otherUser: owner,
              chatType: ChatType.discussion,
              subtitle: 'About ${pet.pet.name} (Lost Pet)',
              themeColor: Colors.orange,
              initialLostPet: pet,
            ),
          ),
        );
      } else {
        _showErrorSnackBar(context, 'Could not load owner information');
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _showErrorSnackBar(context, 'Error: $e');
    }
  }

  Future<void> _viewOwnerProfile(BuildContext context, LostPet pet) async {
    try {
      Navigator.pop(context);
      _showLoadingDialog(context);
      
      final owner = await context.read<DatabaseService>().getUser(pet.reportedByUserId);
      if (context.mounted) Navigator.pop(context);
      
      if (owner != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfilePage(user: owner),
          ),
        );
      } else {
        _showErrorSnackBar(context, 'Could not load owner profile');
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _showErrorSnackBar(context, 'Error loading profile: $e');
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const CupertinoActivityIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showVetDetails(Map<String, dynamic> vet) async {
    final placeId = vet['place_id'];
    final details = await _getPlaceDetails(placeId);
    if (details != null) {
      if (details.containsKey('result')) {
        _showPlaceDetails(details, details['result']['name'] ?? vet['name'] ?? '');
      } else {
        _showPlaceDetails({'result': details}, details['name'] ?? vet['name'] ?? '');
      }
    } else {
      _handleError('Could not find location details');
    }
  }

  void _showStoreDetails(Map<String, dynamic> store) async {
    final placeId = store['place_id'];
    final details = await _getPlaceDetails(placeId);
    if (details != null) {
      if (details.containsKey('result')) {
        _showPlaceDetails(details, details['result']['name'] ?? store['name'] ?? '');
      } else {
        _showPlaceDetails({'result': details}, details['name'] ?? store['name'] ?? '');
      }
    } else {
      _handleError('Could not find location details');
    }
  }
}

class MapLegend extends StatefulWidget {
  final VoidCallback? onMinimize;
  final ValueChanged<bool>? onExpandChanged;
  final bool expanded;
  const MapLegend({Key? key, this.onMinimize, this.onExpandChanged, required this.expanded}) : super(key: key);

  @override
  State<MapLegend> createState() => _MapLegendState();
}

class _MapLegendState extends State<MapLegend> with TickerProviderStateMixin {
  void minimize() {
    if (widget.expanded) widget.onExpandChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: widget.expanded ? 280 : 48,
      height: widget.expanded ? 320 : 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(widget.expanded ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.expanded ? 20 : 24),
        child: widget.expanded ? _buildExpandedLegend() : _buildCollapsedLegend(),
      ),
    );
  }

  Widget _buildExpandedLegend() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.layers,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Map Layers',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.grey.shade800,
                      fontFamily: 'InterDisplay',
                    ),
                  ),
                ],
            ),
          GestureDetector(
            onTap: () {
                  widget.onExpandChanged?.call(false);
                  widget.onMinimize?.call();
            },
            child: Container(
                  padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                  ),
                ],
              ),
          
          const SizedBox(height: 16),
          
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                  // Legend items
                  _buildThinLegendItem(
                    color: const Color(0xFFEA9800),
                    label: 'Your Location',
                    subtitle: 'Current position',
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildThinLegendItem(
                    color: const Color(0xFF2196F3),
                    label: 'Vet Locations',
                    subtitle: 'Medical care & checkups',
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildThinLegendItem(
                    color: const Color(0xFF4CAF50),
                    label: 'Store Locations',
                    subtitle: 'Food, toys & supplies',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Special markers section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Special Markers',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.amber.shade800,
                                fontFamily: 'InterDisplay',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildImageMarkerIndicator(
                              imagePath: 'assets/images/vet_normal.png',
                              label: 'Verified',
                            ),
                            const SizedBox(width: 12),
                            _buildImageMarkerIndicator(
                              imagePath: 'assets/images/vet_fav.png',
                              label: 'Favorite',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                      children: [
                            _buildImageMarkerIndicator(
                              imagePath: 'assets/images/store_normal.png',
                              label: 'Verified Store',
                            ),
                            const SizedBox(width: 12),
                            _buildImageMarkerIndicator(
                              imagePath: 'assets/images/store_fav.png',
                              label: 'Favorite Store',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedLegend() {
    return GestureDetector(
      onTap: () => widget.onExpandChanged?.call(true),
      child: Container(
        width: 48,
        height: 48,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.65),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                      ).createShader(bounds),
                      child: Icon(
                        Icons.layers,
                        color: Colors.white, // This will be masked by the gradient
                        size: 20,
                      ),
                    ),
                  ),
                  // Subtle inner glow effect
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 0.5,
                        ),
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

  Widget _buildThinLegendItem({
    required Color color,
    required String label,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Simple colored circle (matching map markers)
          Container(
            width: 16,
            height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
        boxShadow: [
          BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    fontFamily: 'InterDisplay',
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMarkerIndicator({
    required String imagePath,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3.5),
            child: Image.asset(
              imagePath,
              width: 20,
              height: 20,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image doesn't exist
                return Container(
                  color: Colors.grey.shade300,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
          label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.amber.shade800,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}

class _MarkerWithJiggle extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _MarkerWithJiggle({
    required this.onTap,
    required this.child,
  });

  @override
  State<_MarkerWithJiggle> createState() => _MarkerWithJiggleState();
}

class _MarkerWithJiggleState extends State<_MarkerWithJiggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _jiggleController;
  late Animation<double> _jiggleAnimation;

  @override
  void initState() {
    super.initState();
    _jiggleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _jiggleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.15, end: 0.15)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.15, end: -0.08)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.08, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25.0,
      ),
    ]).animate(_jiggleController);
  }

  @override
  void dispose() {
    _jiggleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _jiggleController.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _jiggleAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _jiggleAnimation.value,
            alignment: Alignment.bottomCenter, // Pivot at bottom
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Custom TileProvider that uses cached tiles
class _CachedTileProvider extends TileProvider {
  final MapTileCacheService _cacheService;

  _CachedTileProvider(this._cacheService);

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = _cacheService.getTileUrl(
      coordinates.z.round(),
      coordinates.x.round(),
      coordinates.y.round(),
    );
    
    if (url.startsWith('file://')) {
      // Return cached file
      return FileImage(File(url.substring(7)));
    } else {
      // Return network image for uncached tiles
      return NetworkImage(url);
    }
  }
}
