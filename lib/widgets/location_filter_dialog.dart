import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/geocoding_service.dart';
import '../utils/app_fonts.dart';

class LocationFilterDialog extends StatefulWidget {
  final LatLng? currentLocation;
  final String? currentLocationName;

  const LocationFilterDialog({
    super.key,
    this.currentLocation,
    this.currentLocationName,
  });

  @override
  State<LocationFilterDialog> createState() => _LocationFilterDialogState();
}

class _LocationFilterDialogState extends State<LocationFilterDialog> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  LatLng _selectedLocation = LatLng(36.7538, 3.0588); // Default to Algiers
  String _selectedLocationName = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentLocation != null) {
      _selectedLocation = widget.currentLocation!;
      _selectedLocationName = widget.currentLocationName ?? '';
      _searchController.text = _selectedLocationName;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Search Bar
            _buildSearchBar(),
            
            // Map
            Expanded(
              child: _buildMap(),
            ),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.location_fill,
            color: Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Location Filter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontFamily: AppFonts.getTitleFontFamily(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap on the map to set your search location',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.xmark,
                size: 18,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for a location...',
          prefixIcon: Icon(CupertinoIcons.search, color: Colors.grey[600]),
          suffixIcon: _isLoading 
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CupertinoActivityIndicator(color: Colors.blue),
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: TextStyle(
          fontFamily: AppFonts.getLocalizedFontFamily(context),
        ),
        onSubmitted: _searchLocation,
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _selectedLocation,
            initialZoom: 13.0,
            onTap: (tapPosition, point) async {
              setState(() {
                _selectedLocation = point;
                _isLoading = true;
              });
              
              // Get address for the selected location
              await _getAddressFromLocation(point);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.alifi',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedLocation,
                  width: 40,
                  height: 40,
                  child: Icon(
                    CupertinoIcons.location_fill,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Location Display
          if (_selectedLocationName.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  CupertinoIcons.location,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedLocationName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply Filter',
                    style: TextStyle(
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // This is a simple implementation - you might want to use a proper geocoding service
      // For now, we'll just update the search text
      setState(() {
        _selectedLocationName = query;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _getAddressFromLocation(LatLng location) async {
    try {
      final address = await GeocodingService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );
      
      if (mounted) {
        setState(() {
          _selectedLocationName = address;
          _searchController.text = address;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedLocationName = '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
          _searchController.text = _selectedLocationName;
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter() {
    Navigator.of(context).pop({
      'location': _selectedLocation,
      'locationName': _selectedLocationName,
    });
  }
}
