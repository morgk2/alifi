import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async' show TimeoutException;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../config/mapbox_config.dart';
import '../services/places_service.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../models/lost_pet.dart';
import '../dialogs/report_missing_pet_dialog.dart';
import '../dialogs/add_business_dialog.dart';
import '../widgets/spinning_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MapPage extends StatefulWidget {
  final Function(bool)? onSearchFocusChange;
  
  const MapPage({
    super.key,
    this.onSearchFocusChange,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final PlacesService _placesService = PlacesService();
  final DatabaseService _databaseService = DatabaseService();
  bool _locationEnabled = false;
  Position? _currentPosition;
  List<PlaceSearchResult> _searchResults = [];
  List<LostPet> _nearbyLostPets = [];
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;
  bool _isSearchFocused = false;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  // Recent searches storage
  final List<String> _recentSearches = [
    'Veterinary Clinic',
    'Pet Shop',
    'Animal Hospital',
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
    _searchController.addListener(_onSearchTextChange);
    _initializeLocation();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Load all lost pets initially with a default location
    _loadNearbyLostPets(
      Position(
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
      ),
    );
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
          await Geolocator.openAppSettings();
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
        latlong.LatLng(position.latitude, position.longitude),
        15.0,
      );

      // Load nearby lost pets
      _loadNearbyLostPets(position);

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
          _loadNearbyLostPets(position);
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
                    child: CircularProgressIndicator(),
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
                        final results = await _placesService.searchNearbyBroad(
                          query: addressController.text,
                          location: const latlong.LatLng(0, 0), // Default to center
                          radiusKm: 50,
                          limit: 1,
                        );
                        if (results.isNotEmpty) {
                          Navigator.pop(context, {
                            'location': results.first.location,
                            'address': results.first.address,
                          });
                        } else {
                          throw Exception('Location not found');
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
      final location = result['location'] as latlong.LatLng;
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

      // Load nearby lost pets for the entered location
      _loadNearbyLostPets(_currentPosition!);

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

  void _loadNearbyLostPets(Position position) {
    print('Loading lost pets near: ${position.latitude}, ${position.longitude}'); // Debug log
    _databaseService.getAllLostPets().listen((pets) {
      print('Found ${pets.length} lost pets'); // Debug log
      if (mounted) {
        setState(() => _nearbyLostPets = pets);
      }
    });
  }

  void _onSearchFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
    if (_isSearchFocused) {
      _animationController.forward();
      widget.onSearchFocusChange?.call(false); // Hide nav bar
    } else {
      _animationController.reverse();
      widget.onSearchFocusChange?.call(true); // Show nav bar
    }
  }

  void _onSearchTextChange() {
    if (_searchController.text.isNotEmpty) {
      // Debounce the search to avoid too many API calls
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_searchController.text.isNotEmpty) {
          _searchPlaces(_searchController.text);
        }
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (_currentPosition == null || query.isEmpty) {
      print('Cannot search: position= [38;5;246m$_currentPosition [0m, query=$query'); // Debug log
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Searching from position: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}'); // Debug log
      // Remove the forced 'veterinary' keyword so all business types can be found
      final results = await _placesService.searchNearbyBroad(
        query: query,
        location: latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        radiusKm: 20, // Increased search radius
        limit: 15, // Increased limit
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });

        // Optionally, center the map to the first result
        if (results.isNotEmpty) {
          _mapController.move(results.first.location, 15.0);
        }
      }
    } catch (e) {
      print('Error in map page search: $e'); // Debug log
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectPlace(PlaceSearchResult place) {
    _searchFocusNode.unfocus();
    _mapController.move(place.location, 15);
  }

  void _clearSearch() async {
    _searchController.clear();
    await _animationController.reverse();
    setState(() {
      _isSearchFocused = false;
    });
    _searchFocusNode.unfocus();
    widget.onSearchFocusChange?.call(true); // Show nav bar
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchController.removeListener(_onSearchTextChange);
    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchFocusNode.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu(BuildContext context, Offset buttonPosition) {
    if (_isMenuOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      _overlayEntry = _createOverlayEntry(context, buttonPosition);
      Overlay.of(context).insert(_overlayEntry!);
    }
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  OverlayEntry _createOverlayEntry(BuildContext context, Offset buttonPosition) {
    final screenWidth = MediaQuery.of(context).size.width;
    const menuWidth = 180.0;
    const rightPadding = 16.0;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _toggleMenu(context, buttonPosition),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
            ),
          ),
          Positioned(
            top: buttonPosition.dy + 60,
            right: rightPadding,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: menuWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        _toggleMenu(context, buttonPosition);
                        final authService = context.read<AuthService>();
                        if (authService.currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please sign in to report a missing pet'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        showDialog(
                          context: context,
                          useRootNavigator: true,
                          barrierColor: Colors.black54,
                          builder: (context) => ReportMissingPetDialog(
                            userId: authService.currentUser!.id,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.pets,
                              color: Colors.red[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Report a missing pet',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    InkWell(
                      onTap: () {
                        _toggleMenu(context, buttonPosition);
                        showDialog(
                          context: context,
                          useRootNavigator: true,
                          barrierColor: Colors.black54,
                          builder: (context) => const AddBusinessDialog(),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.store_rounded,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Add your business',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSearchPanel() {
    final bool showPanel = _isSearchFocused || _searchController.text.isNotEmpty;
    return showPanel
        ? Positioned.fill(
            top: 90, // Height of the search bar area
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: showPanel ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !showPanel,
                child: Container(
                  color: Colors.white.withOpacity(0.97),
                  child: SafeArea(
                    top: false,
                    child: _searchController.text.isEmpty
                        ? _buildRecentSearchesChips()
                        : _buildAnimatedSearchResults(),
                  ),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildAnimatedSearchResults() {
    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          const SpinningLoader(color: Colors.orange),
          const SizedBox(height: 16),
          const Text('Searching...', style: TextStyle(color: Colors.grey)),
        ],
      );
    }
    if (_searchResults.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text('No results found', style: TextStyle(color: Colors.grey)),
        ],
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final place = _searchResults[index];
        IconData icon = Icons.location_on;
        Color iconColor = Colors.blue;
        if (place.placeType != null) {
          if (place.placeType!.toLowerCase().contains('vet')) {
            icon = Icons.local_hospital;
            iconColor = Colors.redAccent;
          } else if (place.placeType!.toLowerCase().contains('shop')) {
            icon = Icons.store;
            iconColor = Colors.orange;
          }
        }
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + index * 30),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            title: Text(
              place.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(
              place.address,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: place.distance != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      place.distance!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : null,
            onTap: () => _selectPlace(place),
            splashColor: Colors.blue.withOpacity(0.08),
            hoverColor: Colors.blue.withOpacity(0.04),
          ),
        );
      },
    );
  }

  Widget _buildRecentSearchesChips() {
    if (_recentSearches.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _recentSearches.map((search) {
          return ActionChip(
            label: Text(search),
            avatar: const Icon(Icons.history, size: 18, color: Colors.grey),
            backgroundColor: Colors.grey[100],
            onPressed: () {
              _searchController.text = search;
              _searchPlaces(search);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition != null
                  ? latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : const latlong.LatLng(36.7538, 3.0588), // Default to Algiers
              initialZoom: 15,
              maxZoom: 18,
              minZoom: 3,
            ),
            children: [
              TileLayer(
                urlTemplate: MapboxConfig.mapboxStyleUrl,
                additionalOptions: const {
                  'accessToken': MapboxConfig.mapboxAccessToken,
                  'id': MapboxConfig.mapboxStyleId,
                },
              ),
              // Lost pet circles for range indication
              CircleLayer(
                circles: [
                  // Outer circles (500m radius)
                  ..._nearbyLostPets.map((pet) => CircleMarker(
                  point: pet.location,
                  radius: 500, // 500 meters radius
                    color: Colors.red.withOpacity(0.1),
                    borderColor: Colors.red.withOpacity(0.3),
                  borderStrokeWidth: 2,
                  useRadiusInMeter: true,
                  )),
                  // Inner circles (100m radius)
                  ..._nearbyLostPets.map((pet) => CircleMarker(
                    point: pet.location,
                    radius: 100, // 100 meters radius
                    color: Colors.red.withOpacity(0.2),
                    borderColor: Colors.red.withOpacity(0.4),
                    borderStrokeWidth: 1.5,
                    useRadiusInMeter: true,
                  )),
                ],
              ),
              // Current location marker
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 50,
                      height: 50,
                      child: Column(
                        children: [
                          Container(
                      width: 20,
                      height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue,
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
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              // Lost pet markers
              MarkerLayer(
                rotate: true, // Enable marker rotation
                markers: _nearbyLostPets.map((pet) => Marker(
                  point: pet.location,
                  width: 60,
                  height: 80,
                  rotate: true, // Enable per-marker rotation
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () => _showLostPetDetails(pet),
                    child: Stack(
                      children: [
                        // Fixed-size paw icon
                        Positioned(
                          left: 5,
                          right: 5,
                    child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                        Icons.pets,
                        color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        // Name label
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              pet.pet.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),

          // Search UI
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextField(
                                focusNode: _searchFocusNode,
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search for veterinarians, pet shops... ',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: _isSearchFocused
                                      ? IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: _clearSearch,
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                        decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.25),
                          shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.6),
                                width: 1.5,
                              ),
                          boxShadow: [
                            BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                              icon: Icon(
                                Icons.add,
                                color: Colors.orange[700],
                              ),
                          onPressed: () {
                            final RenderBox button =
                                context.findRenderObject() as RenderBox;
                            final position = button.localToGlobal(Offset.zero);
                            _toggleMenu(context, position);
                          },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildAnimatedSearchPanel(),
            ],
          ),

          // Location Button
          Positioned(
            right: 16,
            bottom: 104, // Increased from 88 to 104 to move it higher
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                const maxNavWidth = 320.0;
                const minNavWidth = 220.0;
                double sidePadding = 16.0;
                double buttonSize = 64.0;
                double iconSize = 24.0;

                // Responsive adjustments for very slim screens
                if (screenWidth < minNavWidth + 2 * sidePadding + buttonSize + 8) {
                  sidePadding = 6.0;
                  buttonSize = 44.0;
                  iconSize = 16.0;
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: buttonSize,
                      height: buttonSize,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.45),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (_currentPosition != null) {
                              _mapController.move(
                                latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                15.0,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Location not available'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          customBorder: const CircleBorder(),
                          child: Center(
                            child: AnimatedRotation(
                              duration: const Duration(milliseconds: 300),
                              turns: _locationEnabled ? 0 : 0.5,
                              child: Icon(
                                Icons.near_me,
                                color: _locationEnabled ? Colors.blue : Colors.grey,
                                size: iconSize,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLostPetDetails(LostPet pet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pet.pet.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pet.pet.species,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Last Seen Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pet.address,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coordinates: ${pet.location.latitude.toStringAsFixed(6)}, ${pet.location.longitude.toStringAsFixed(6)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            if (pet.additionalInfo != null) ...[
            const SizedBox(height: 16),
              Text(
                pet.additionalInfo!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Contact Numbers',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pet.contactNumbers.map((number) => Chip(
                avatar: const Icon(Icons.phone, size: 18),
                label: Text(number),
                backgroundColor: Colors.grey[100],
              )).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                onPressed: () {
                      _mapController.move(pet.location, 16);
                      Navigator.pop(context);
                },
                    icon: const Icon(Icons.location_on),
                    label: const Text('Show on Map'),
                style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                ),
                ),
              ],
              ),
          ],
        ),
      ),
    );
  }
}
