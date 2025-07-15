import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/mapbox_config.dart';
import '../services/places_service.dart';
import '../dialogs/report_missing_pet_dialog.dart';
import '../dialogs/add_business_dialog.dart';

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
  bool _locationEnabled = false;
  Position? _currentPosition;
  List<PlaceSearchResult> _searchResults = [];
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

    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _initializeLocation() async {
    // Request location permission
    final status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      return;
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
        _locationEnabled = true;
      });

      // Move map to current location
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        15.0,
      );

      // Start listening to location updates
      Geolocator.getPositionStream().listen((Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            _mapController.zoom,
          );
        }
      });
    } catch (e) {
      print('Error getting location: $e');
    }
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
      print('Cannot search: position=$_currentPosition, query=$query'); // Debug log
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Searching from position: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}'); // Debug log
      final results = await _placesService.searchNearby(
        query: query,
        location: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        radiusKm: 20, // Increased search radius
        limit: 15, // Increased limit
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });

        // Add markers for search results
        if (results.isNotEmpty) {
          // Center the map to show all results
          final bounds = LatLngBounds.fromPoints(
            results.map((r) => r.location).toList(),
          );
          _mapController.fitBounds(
            bounds,
            options: const FitBoundsOptions(
              padding: EdgeInsets.all(50.0),
            ),
          );
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
                        showDialog(
                          context: context,
                          useRootNavigator: true,
                          barrierColor: Colors.black54,
                          builder: (context) => const ReportMissingPetDialog(),
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

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          'No results found. Try a different search term.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final place = _searchResults[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.local_hospital, color: Colors.blue),
          ),
          title: Text(place.name),
          subtitle: Text(place.address),
          trailing: place.distance != null
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    place.distance!,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : null,
          onTap: () => _selectPlace(place),
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentSearches.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(_recentSearches[index]),
              onTap: () {
                _searchController.text = _recentSearches[index];
                _searchPlaces(_recentSearches[index]);
              },
            );
          },
        ),
      ],
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
            options: const MapOptions(
              initialCenter: LatLng(
                37.7749, // Default latitude (e.g., San Francisco)
                -122.4194, // Default longitude (e.g., San Francisco)
              ),
              initialZoom: 12.0, // Default zoom level
              interactionOptions: InteractionOptions(
                enableScrollWheel: true,
                enableMultiFingerGestureRace: true,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=${MapboxConfig.accessToken}',
                additionalOptions: const {
                  'accessToken': MapboxConfig.accessToken,
                  'id': 'mapbox.streets',
                },
              ),
              // Current location marker
              if (_locationEnabled && _currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Search UI
          Column(
            children: [
              // Search bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            focusNode: _searchFocusNode,
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search for veterinarians, pet shops...',
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
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final RenderBox button =
                                context.findRenderObject() as RenderBox;
                            final position = button.localToGlobal(Offset.zero);
                            _toggleMenu(context, position);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Search results
              if (_isSearchFocused)
                Expanded(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            color: Colors.white,
                            child: SingleChildScrollView(
                              child: _searchController.text.isEmpty
                                  ? _buildRecentSearches()
                                  : _buildSearchResults(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
