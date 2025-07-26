import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final _placesService = PlacesService();
  final _locationService = LocationService();
  final MapController _mapController = MapController();
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
  bool _isLoadingVets = false;
  bool _isLoadingStores = false;
  double _currentZoom = 15.0;
  static const double _zoomThreshold = 11.0; // Threshold for simplified markers
  final GlobalKey _plusButtonKey = GlobalKey();

  final _storeMarkersController = StreamController<List<Marker>>.broadcast();
  final _storeResults = <Map<String, dynamic>>[];
  final _processedStorePlaceIds = <String>{};
  bool _legendExpanded = false;

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
    _initializeLocation();
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
            title: const Text('Location Services Disabled'),
            content: const Text('Please enable location services or enter your location manually.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'manual'),
                child: const Text('Enter Manually'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'settings'),
                child: const Text('Open Settings'),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission is required to use this feature'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
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
            title: const Text('Location Permission Required'),
            content: const Text(
              'Location permission is required for this feature. '
              'Please enable it in your app settings.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open Settings'),
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

      // Move map to current location
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        15.0,
      );

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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child: Text('Error getting location: ${e.toString()}'),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _showManualLocationInput();
                },
                child: const Text(
                  'Enter Manually',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: _initializeLocation,
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
        ),
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
          title: const Text('Enter Your Location'),
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
              child: const Text('Cancel'),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error finding location: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
              child: const Text('Search'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location set to: $address'),
          backgroundColor: Colors.green,
        ),
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
                  child: TextField(
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
    
                              ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
                                  backgroundColor: Colors.red,
                                ),
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
                      result['opening_hours']['open_now'] ? 'Open Now' : 'Closed',
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
                      label: const Text(
                        'Navigate',
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
                              result['opening_hours']['open_now'] ? 'Open' : 'Closed',
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
    
    return Marker(
      point: LatLng(lat, lng),
      width: 20,
      height: 20,
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(user: user),
            ),
          ),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.orange,  // Orange for users
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
            _userMarkers = users.map(_createUserMarker).toList();
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
            'Report Missing Pet',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () => _showReportMissingPetDialog(context),
        ),
        PopupMenuItem(
          child: const Text(
            'Add Your Business',
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
            child: const Text('Report Missing Pet'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showAddBusinessDialog(context);
            },
            child: const Text('Add Your Business'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to report a missing pet'),
          duration: Duration(seconds: 2),
        ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This ${isVet ? 'vet' : 'store'} is already in the database'),
            backgroundColor: Colors.orange,
          ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${isVet ? 'vet clinic' : 'pet store'} to map'),
          backgroundColor: Colors.green,
        ),
      );

      // Move map to new location
      _mapController.move(LatLng(lat, lng), 15.0);

      // Refresh the cache in PlacesService
      await PlacesService.initialize();

    } catch (e) {
      print('Error adding business: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding business: $e'),
          backgroundColor: Colors.red,
        ),
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
                onMapEvent: (event) {
                  final currentZoom = event.camera.zoom;
                  if ((_currentZoom < _zoomThreshold && currentZoom >= _zoomThreshold) ||
                      (_currentZoom >= _zoomThreshold && currentZoom < _zoomThreshold) ||
                      (_currentZoom != currentZoom)) {
                    setState(() {
                      _currentZoom = currentZoom;
                    });
                  }
                  if (_legendExpanded) _minimizeLegend();
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: MapboxConfig.mapboxStyleUrl,
                  additionalOptions: const {
                    'accessToken': MapboxConfig.mapboxAccessToken,
                    'id': MapboxConfig.mapboxStyleId,
                  },
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
                      return Marker(
                        point: pet.location,
                        width: 20,
                        height: 20,
                        child: GestureDetector(
                          onTap: () => _showLostPetDetails(pet),
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
          MapLegend(
            onMinimize: _minimizeLegend,
            onExpandChanged: _setLegendExpanded,
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
      barrierColor: Colors.black38,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (pet.pet.imageUrls.isNotEmpty) ...[
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          itemCount: pet.pet.imageUrls.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(pet.pet.imageUrls[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                // Photo count indicator
                                if (pet.pet.imageUrls.length > 1)
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
                                        '${index + 1}/${pet.pet.imageUrls.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
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
                              // Pet Name and Status
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      pet.pet.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      'LOST',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Pet Type and Last Seen
                              Row(
                                children: [
                                  Text(
                                    pet.pet.species,
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.6),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    ' • ',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.6),
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Last seen ${_formatDate(pet.lastSeenDate)}',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.6),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Location
                              Text(
                                'Last Known Location:',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pet.address,
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Description
                              if (pet.additionalInfo != null && pet.additionalInfo!.isNotEmpty) ...[
                                Text(
                                  'Description:',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pet.additionalInfo!,
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.6),
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              // Contact Numbers
                              if (pet.contactNumbers.isNotEmpty) ...[
                                Text(
                                  'Contact Numbers:',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...pet.contactNumbers.map((number) => 
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: ElevatedButton.icon(
                                      onPressed: () => launchUrl(Uri.parse('tel:$number')),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.withOpacity(0.9),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      icon: const Icon(Icons.phone),
                                      label: Text(
                                        number,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              // Visit Owner Profile Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    // First close the dialog
                                    Navigator.pop(context);
                                    // Then get the owner's data
                                    final owner = await context.read<DatabaseService>().getUser(pet.reportedByUserId);
                                    if (owner != null && context.mounted) {
                                      // Navigate to owner's profile
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserProfilePage(user: owner),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.withOpacity(0.9),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(Icons.person),
                                  label: const Text(
                                    'Visit Owner\'s Profile',
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
  const MapLegend({Key? key, this.onMinimize, this.onExpandChanged}) : super(key: key);

  @override
  State<MapLegend> createState() => _MapLegendState();
}

class _MapLegendState extends State<MapLegend> with TickerProviderStateMixin {
  bool _expanded = false;

  void minimize() {
    if (_expanded) setState(() => _expanded = false);
  }

  void _setExpanded(bool expanded) {
    if (_expanded != expanded) {
      setState(() => _expanded = expanded);
      widget.onExpandChanged?.call(expanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      bottom: 100,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            if (_expanded)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    _setExpanded(false);
                    widget.onMinimize?.call();
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(),
                ),
              ),
            GestureDetector(
              onTap: () {
                _setExpanded(!_expanded);
              },
              child: Container(
                width: _expanded ? 220 : 44,
                padding: _expanded
                    ? const EdgeInsets.symmetric(horizontal: 20, vertical: 20)
                    : const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _expanded
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            color: Colors.white.withOpacity(0.7),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _legendRow(Colors.orange, 'Your location', const Color(0xFFEA9800)),
                                const SizedBox(height: 12),
                                _legendRow(Colors.blue, 'Vet locations', const Color(0xFF2196F3)),
                                const SizedBox(height: 12),
                                _legendRow(Colors.green, 'Store locations', const Color(0xFF4CAF50)),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _legendCircle(Colors.orange),
                          const SizedBox(height: 12),
                          _legendCircle(Colors.blue),
                          const SizedBox(height: 12),
                          _legendCircle(Colors.green),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendCircle(Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label, Color? overrideColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _legendCircle(overrideColor ?? color),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: overrideColor ?? color,
          ),
        ),
      ],
    );
  }
}
