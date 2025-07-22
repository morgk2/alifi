import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/places_service.dart';
import '../../services/database_service.dart';
import 'package:latlong2/latlong.dart';

class BulkImportPage extends StatefulWidget {
  final bool showBulkImport;
  final bool showLocationFetch;
  
  const BulkImportPage({
    super.key,
    this.showBulkImport = true,
    this.showLocationFetch = true,
  });

  @override
  State<BulkImportPage> createState() => _BulkImportPageState();
}

class _BulkImportPageState extends State<BulkImportPage> {
  final _jsonController = TextEditingController();
  bool _isLoading = false;
  String _status = '';
  int _importedCount = 0;
  int _failedCount = 0;
  bool _isFetchingLocations = false;
  String _locationFetchStatus = '';
  int _fetchedVets = 0;
  int _fetchedStores = 0;

  Future<void> _importProducts() async {
    if (_jsonController.text.isEmpty) {
      setState(() => _status = 'Please enter JSON data');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Importing products...';
      _importedCount = 0;
      _failedCount = 0;
    });

    try {
      final List<dynamic> products = json.decode(_jsonController.text);
      final batch = FirebaseFirestore.instance.batch();
      final collection = FirebaseFirestore.instance.collection('aliexpresslistings');

      for (var product in products) {
        try {
          // Add timestamps
          product['createdAt'] = FieldValue.serverTimestamp();
          product['lastUpdatedAt'] = FieldValue.serverTimestamp();
          
          // Create new document reference
          final docRef = collection.doc();
          batch.set(docRef, product);
          _importedCount++;
        } catch (e) {
          _failedCount++;
          print('Error processing product: $e');
        }
      }

      await batch.commit();
      setState(() => _status = 'Import completed: $_importedCount products imported, $_failedCount failed');
      _jsonController.clear();
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deepFetchLocations() async {
    if (_isFetchingLocations) return;

    setState(() {
      _isFetchingLocations = true;
      _locationFetchStatus = 'Starting deep fetch...';
      _fetchedVets = 0;
      _fetchedStores = 0;
    });

    try {
      // Get all major cities
      final cities = PlacesService.algeriaCities;
      final total = cities.length;
      int current = 0;

      for (final city in cities) {
        current++;
        setState(() {
          _locationFetchStatus = 'Processing city ${city['name']} ($current/$total)';
        });

        // Search for vets
        final vets = await PlacesService().searchNearbyVets(
          city['lat'],
          city['lng'],
          forceApiSearch: true, // New parameter to force API search
        );
        _fetchedVets += vets.length;

        // Search for stores using both methods
        await for (final store in PlacesService().searchNearbyStoresByType(
          city['lat'],
          city['lng'],
          forceApiSearch: true, // New parameter to force API search
        )) {
          _fetchedStores++;
          setState(() {});
        }

        await for (final store in PlacesService().searchNearbyStoresByKeyword(
          city['lat'],
          city['lng'],
          forceApiSearch: true, // New parameter to force API search
        )) {
          _fetchedStores++;
          setState(() {});
        }

        // Update status
        setState(() {
          _locationFetchStatus = 'Processed ${city['name']}\nFound $_fetchedVets vets and $_fetchedStores stores so far';
        });
      }

      // Reinitialize the cache after deep fetch
      await PlacesService.initialize();

      setState(() {
        _locationFetchStatus = 'Deep fetch completed!\nTotal: $_fetchedVets vets and $_fetchedStores stores';
        _isFetchingLocations = false;
      });
    } catch (e) {
      setState(() {
        _locationFetchStatus = 'Error during deep fetch: $e';
        _isFetchingLocations = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showLocationFetch ? 'Location Deep Fetch' : 'Bulk Import Products'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showBulkImport) ...[
              const Text(
                'Paste JSON array of products:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: TextField(
                  controller: _jsonController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '[{"title": "Product 1", ...}, {"title": "Product 2", ...}]',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_status.isNotEmpty) ...[
                Text(
                  _status,
                  style: TextStyle(
                    color: _status.contains('Error') ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: _isLoading ? null : _importProducts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Import Products',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Note: JSON should be an array of products with the following structure:\n'
                '- title (string)\n'
                '- description (string)\n'
                '- price (number)\n'
                '- originalPrice (number)\n'
                '- photos (array of strings)\n'
                '- affiliateUrl (string)\n'
                '- category (string)\n'
                '- rating (number)\n'
                '- orders (number)\n'
                '- isFreeShipping (boolean)\n'
                '- shippingTime (string)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],

            if (widget.showLocationFetch) ...[
              if (widget.showBulkImport) ...[
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
              ],

              // Deep Location Fetch Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deep Location Fetch',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This will search for all vets and pet stores in major Algerian cities using the Places API. This process may take several minutes.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      if (_isFetchingLocations) ...[
                        const LinearProgressIndicator(),
                        const SizedBox(height: 8),
                        Text(
                          _locationFetchStatus,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isFetchingLocations ? null : _deepFetchLocations,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text(
                            _isFetchingLocations ? 'Fetching...' : 'Start Deep Fetch',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 