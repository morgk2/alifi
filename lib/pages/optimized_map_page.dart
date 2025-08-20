import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../services/optimized_map_service.dart';
import '../services/auth_service.dart';
import '../widgets/custom_snackbar.dart';
import '../dialogs/add_business_dialog.dart';
import '../dialogs/report_missing_pet_dialog.dart';

class OptimizedMapPage extends StatefulWidget {
  const OptimizedMapPage({super.key});

  @override
  State<OptimizedMapPage> createState() => _OptimizedMapPageState();
}

class _OptimizedMapPageState extends State<OptimizedMapPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
  // Services
  final OptimizedMapService _mapService = OptimizedMapService();
  
  // Controllers
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  // State variables
  List<Marker> _markers = [];
  bool _isLoading = false;
  bool _locationEnabled = false;
  Position? _currentPosition;
  Timer? _debounceTimer;
  
  // Animation controllers
  late AnimationController _searchPanelController;
  late AnimationController _minimizeController;
  
  // Map settings
  double _currentZoom = 15.0;
  bool _showVets = true;
  bool _showStores = true;
  bool _showLostPets = true;
  
  // Legend state
  bool _legendExpanded = false;
  bool _legendVisible = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeMap();
  }

  void _initializeControllers() {
    _searchPanelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _minimizeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);
    
    try {
      await _getCurrentLocation();
      await _loadInitialMarkers();
    } catch (e) {
      print('Error initializing map: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationEnabled = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _locationEnabled = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _locationEnabled = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _locationEnabled = true;
      });

      // Move map to current location
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        _currentZoom,
      );
    } catch (e) {
      print('Error getting location: $e');
      setState(() => _locationEnabled = false);
    }
  }

  Future<void> _loadInitialMarkers() async {
    final bounds = _mapController.camera.visibleBounds;
    await _loadMarkersForViewport(bounds, _currentZoom);
  }

  Future<void> _loadMarkersForViewport(LatLngBounds bounds, double zoom) async {
    try {
      final markers = await _mapService.getOptimizedMarkers(
        viewport: bounds,
        zoom: zoom,
        showVets: _showVets,
        showStores: _showStores,
      );

      if (mounted) {
        setState(() {
          _markers = markers;
        });
      }
    } catch (e) {
      print('Error loading markers: $e');
    }
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMove || event is MapEventRotate) {
      _currentZoom = event.camera.zoom;
      
      // Hide legend while navigating
      if (_legendExpanded && _legendVisible) {
        setState(() {
          _legendExpanded = false;
        });
      }
      
      // Debounced viewport update
      _mapService.updateViewport(
        event.camera.visibleBounds,
        _currentZoom,
        () => _loadMarkersForViewport(event.camera.visibleBounds, _currentZoom),
      );
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    // Handle map tap
    _searchFocusNode.unfocus();
  }

  void _toggleVets() {
    setState(() {
      _showVets = !_showVets;
    });
    _refreshMarkers();
  }

  void _toggleStores() {
    setState(() {
      _showStores = !_showStores;
    });
    _refreshMarkers();
  }

  void _toggleLostPets() {
    setState(() {
      _showLostPets = !_showLostPets;
    });
    // TODO: Implement lost pets loading
  }

  void _refreshMarkers() {
    final bounds = _mapController.camera.visibleBounds;
    _loadMarkersForViewport(bounds, _currentZoom);
  }

  void _centerOnCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15.0,
      );
    } else {
      _getCurrentLocation();
    }
  }

  void _showReportMissingPetDialog() {
    final authService = context.read<AuthService>();
    if (authService.currentUser == null) {
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

  void _showAddBusinessDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddBusinessDialog(),
    );
  }

  @override
  void dispose() {
    _searchPanelController.dispose();
    _minimizeController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _mapService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : const LatLng(36.7538, 3.0588), // Algiers default
              initialZoom: _currentZoom,
              minZoom: 5.0,
              maxZoom: 18.0,
              onTap: _onMapTap,
              onMapEvent: _onMapEvent,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              // Cached tile layer
              _mapService.getCachedTileLayer(),
              
              // Markers layer
              MarkerLayer(markers: _markers),
              
              // Current location marker
              if (_currentPosition != null && _locationEnabled)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Search panel
          _buildSearchPanel(),

          // Legend with fade animation
          if (_legendVisible)
            AnimatedOpacity(
              opacity: _legendVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _buildLegend(),
            ),

          // Control buttons
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildSearchPanel() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
          decoration: InputDecoration(
            hintText: 'Search places...',
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: (value) {
            // TODO: Implement search functionality
          },
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      bottom: 120,
      left: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        width: _legendExpanded ? 280 : 56,
        height: _legendExpanded ? 280 : 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(_legendExpanded ? 20 : 28),
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
          borderRadius: BorderRadius.circular(_legendExpanded ? 20 : 28),
          child: _legendExpanded ? _buildExpandedLegend() : _buildCollapsedLegend(),
        ),
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
                onTap: () => setState(() => _legendExpanded = false),
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
          
          const SizedBox(height: 20),
          
          // Legend items
          _buildModernLegendItem(
            color: const Color(0xFF2196F3),
            gradientColors: [const Color(0xFF2196F3), const Color(0xFF1976D2)],
            icon: Icons.local_hospital,
            label: 'Veterinary Clinics',
            subtitle: 'Medical care & checkups',
            isActive: _showVets,
            onTap: _toggleVets,
          ),
          
          const SizedBox(height: 12),
          
          _buildModernLegendItem(
            color: const Color(0xFFFF9800),
            gradientColors: [const Color(0xFFFF9800), const Color(0xFFF57C00)],
            icon: Icons.store,
            label: 'Pet Stores',
            subtitle: 'Food, toys & supplies',
            isActive: _showStores,
            onTap: _toggleStores,
          ),
          
          const SizedBox(height: 12),
          
          _buildModernLegendItem(
            color: const Color(0xFFE91E63),
            gradientColors: [const Color(0xFFE91E63), const Color(0xFFC2185B)],
            icon: Icons.pets,
            label: 'Lost Pets',
            subtitle: 'Help find missing pets',
            isActive: _showLostPets,
            onTap: _toggleLostPets,
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
                    _buildSpecialMarkerIndicator(
                      color: Colors.blue,
                      icon: Icons.verified,
                      label: 'Verified',
                    ),
                    const SizedBox(width: 12),
                    _buildSpecialMarkerIndicator(
                      color: Colors.orange,
                      icon: Icons.local_offer,
                      label: 'Featured',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedLegend() {
    return GestureDetector(
      onTap: () => setState(() => _legendExpanded = true),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.layers,
                color: Colors.white,
                size: 24,
              ),
            ),
            // Animated pulse effect
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _searchPanelController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLegendItem({
    required Color color,
    required List<Color> gradientColors,
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color.withOpacity(0.2) : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon container with gradient
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: isActive 
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade400, Colors.grey.shade500],
                    ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : [],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.grey.shade800 : Colors.grey.shade500,
                      fontFamily: 'InterDisplay',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive ? Colors.grey.shade600 : Colors.grey.shade400,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            
            // Toggle indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isActive ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive ? color : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isActive 
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  )
                : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialMarkerIndicator({
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 10,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.amber.shade800,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current location button
          FloatingActionButton(
            mini: true,
            heroTag: "location",
            onPressed: _centerOnCurrentLocation,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.my_location,
              color: _locationEnabled ? Colors.blue : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          
          // Add business button
          FloatingActionButton(
            mini: true,
            heroTag: "add_business",
            onPressed: _showAddBusinessDialog,
            backgroundColor: Colors.green,
            child: const Icon(Icons.add_business, color: Colors.white),
          ),
          const SizedBox(height: 8),
          
          // Report missing pet button
          FloatingActionButton(
            mini: true,
            heroTag: "missing_pet",
            onPressed: _showReportMissingPetDialog,
            backgroundColor: Colors.red,
            child: const Icon(Icons.pets, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
