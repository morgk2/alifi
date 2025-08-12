import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../config/mapbox_config.dart';
import '../services/places_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/keyboard_dismissible_text_field.dart';

class LocationPickerDialog extends StatefulWidget {
  final latlong.LatLng? initialLocation;

  const LocationPickerDialog({
    super.key,
    this.initialLocation,
  });

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  final MapController _mapController = MapController();
  final PlacesService _placesService = PlacesService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  latlong.LatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isSearching = false;
  List<PlacesPrediction> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    try {
      final results = await _placesService.getPlacePredictions(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
        'https://maps.gomaps.pro/maps/api/place/details/json'
        '?place_id=$placeId'
        '&key=AlzaSylphbmAZJYT82Ie_cY1MVEbiQ4NRUxaqIo'
      );
      
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['result'] != null) {
          return data['result'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  Future<void> _selectSearchResult(PlacesPrediction prediction) async {
    setState(() => _isSearching = true);
    try {
      final details = await _getPlaceDetails(prediction.placeId);
      if (details != null && details['geometry'] != null) {
        final location = latlong.LatLng(
          details['geometry']['location']['lat'],
          details['geometry']['location']['lng'],
        );
    setState(() {
          _selectedLocation = location;
          _selectedAddress = prediction.description;
      _searchResults = [];
      _searchController.clear();
      _searchFocusNode.unfocus();
          _isSearching = false;
    });
        _mapController.move(location, 15);
      } else {
        setState(() => _isSearching = false);
      }
    } catch (e) {
      print('Error selecting location: $e');
      setState(() => _isSearching = false);
    }
  }

  Future<void> _reverseGeocode(latlong.LatLng point) async {
    try {
      final url = Uri.parse(
        'https://maps.gomaps.pro/maps/api/geocode/json'
        '?latlng=${point.latitude},${point.longitude}'
        '&key=AlzaSy8GCoFh_rNeeXKWnVnqeCauTmWq3i85B6H'
      );
      
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
          setState(() => _selectedAddress = data['results'][0]['formatted_address']);
        }
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: KeyboardDismissibleTextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(),
                              )
                            : IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: _searchLocation,
                              ),
                        ),
                        onSubmitted: (_) => _searchLocation(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            if (_searchResults.isNotEmpty)
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final prediction = _searchResults[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(prediction.mainText),
                      subtitle: Text(
                        prediction.secondaryText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _selectSearchResult(prediction),
                    );
                  },
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedLocation ?? const latlong.LatLng(36.7538, 3.0588),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                        ),
                        onTap: (_, point) {
                          setState(() => _selectedLocation = point);
                          _reverseGeocode(point);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: MapboxConfig.mapboxStyleUrl,
                          additionalOptions: const {
                            'accessToken': MapboxConfig.mapboxAccessToken,
                            'id': MapboxConfig.mapboxStyleId,
                          },
                        ),
                        if (_selectedLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selectedLocation!,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_selectedAddress != null)
                          Container(
                            padding: const EdgeInsets.all(12),
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
                            child: Text(
                              _selectedAddress!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _selectedLocation == null
                            ? null
                            : () => Navigator.pop(
                                context,
                                {
                                  'location': _selectedLocation,
                                  'address': _selectedAddress,
                                },
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Confirm Location',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 