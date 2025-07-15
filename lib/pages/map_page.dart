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
import '../widgets/spinning_loader.dart';

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
            15.0, // Use a fixed zoom level instead of the deprecated zoom property
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
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(50.0),
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
          const CircularProgressIndicator(),
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
              initialCenter: LatLng(
                37.7749, // Default latitude (e.g., San Francisco)
                -122.4194, // Default longitude (e.g., San Francisco)
              ),
              initialZoom: 12.0, // Default zoom level
              // Remove interaction options as they're not needed in newer versions
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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
              // The new animated search panel
              _buildAnimatedSearchPanel(),
            ],
          ),
        ],
      ),
    );
  }
}
