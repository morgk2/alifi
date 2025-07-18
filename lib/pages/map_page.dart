import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/mapbox_config.dart';
import '../services/places_service.dart';
import '../services/database_service.dart';
import '../models/lost_pet.dart';
import '../dialogs/report_missing_pet_dialog.dart';
import '../dialogs/add_business_dialog.dart';
import '../widgets/spinning_loader.dart';
import 'user_profile_page.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';

class MapPage extends StatefulWidget {
  final Function(bool)? onSearchFocusChange;
  final latlong.LatLng? centerOnLocation;
  final VoidCallback? onMapCentered;
  
  const MapPage({
    super.key,
    this.onSearchFocusChange,
    this.centerOnLocation,
    this.onMapCentered,
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
        latlong.LatLng(position.latitude, position.longitude),
        15.0,
      );

      // Load nearby lost pets
      _loadNearbyLostPets(position);

      // Start listening to location updates
      Geolocator.getPositionStream().listen((Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
          _loadNearbyLostPets(position);
        }
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _loadNearbyLostPets(Position position) {
    final userLocation = latlong.LatLng(position.latitude, position.longitude);
    _databaseService.getNearbyLostPets(
      userLocation: userLocation,
      radiusInKm: 10,
    ).listen((pets) {
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
              // Lost pet circles
              CircleLayer(
                circles: _nearbyLostPets.map((pet) => CircleMarker(
                  point: pet.location,
                  radius: 500, // 500 meters radius
                  color: Colors.red.withOpacity(0.2),
                  borderColor: Colors.red,
                  borderStrokeWidth: 2,
                  useRadiusInMeter: true,
                )).toList(),
              ),
              // Current location marker
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
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
              // Lost pet markers
              MarkerLayer(
                markers: _nearbyLostPets.map((pet) => Marker(
                  point: pet.location,
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _showLostPetDetails(pet),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                )).toList(),
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
              // The new animated search panel
              _buildAnimatedSearchPanel(),
            ],
          ),
        ],
      ),
    );
  }

  void _showLostPetDetails(LostPet pet) async {
    final owner = await showGeneralDialog<User?>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Lost Pet Details',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic));
        return SlideTransition(
          position: offset,
          child: Opacity(
            opacity: anim1.value,
            child: Center(
              child: _LostPetDialog(pet: pet),
            ),
          ),
        );
      },
    );
    if (owner != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UserProfilePage(user: owner),
        ),
      );
    }
  }
}

class _LostPetDialog extends StatelessWidget {
  final LostPet pet;
  const _LostPetDialog({required this.pet});

  String _formatLastSeen(DateTime date) {
    // Example: July 18, 2025 at 2:51 AM
    return DateFormat('MMMM d, y').format(date) +
        ' at ' + DateFormat('h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                if (pet.pet.imageUrls.isNotEmpty)
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(pet.pet.imageUrls.first),
                    ),
                  ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    pet.pet.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    pet.pet.species,
                    style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                if (pet.pet.description != null && pet.pet.description!.isNotEmpty)
                  Center(
                    child: Text(
                      pet.pet.description!,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (pet.additionalInfo != null && pet.additionalInfo!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: Text(
                        pet.additionalInfo!,
                        style: const TextStyle(fontSize: 15, color: Colors.black54, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time, color: Colors.red, size: 20),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Last seen: ' + _formatLastSeen(pet.lastSeenDate),
                        style: const TextStyle(fontSize: 15, color: Colors.red),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 20),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        pet.address,
                        style: const TextStyle(fontSize: 15, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (pet.reward != null && pet.reward!.isNotEmpty)
                  Center(
                    child: Text(
                      'Reward: ${pet.reward}',
                      style: const TextStyle(fontSize: 15, color: Colors.orange, fontWeight: FontWeight.w600),
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Fetch the owner's user data and return it to the parent
                      final db = DatabaseService();
                      final owner = await db.getUser(pet.reportedByUserId);
                      if (owner != null && context.mounted) {
                        Navigator.of(context).pop(owner);
                      }
                    },
                    icon: const Icon(Icons.account_circle),
                    label: const Text("Show Owner's Profile"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9E42),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Account user: ${pet.reportedByUserId}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
