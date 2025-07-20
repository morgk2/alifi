import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BulkImportPage extends StatefulWidget {
  const BulkImportPage({super.key});

  @override
  State<BulkImportPage> createState() => _BulkImportPageState();
}

class _BulkImportPageState extends State<BulkImportPage> {
  final _jsonController = TextEditingController();
  bool _isLoading = false;
  String _status = '';
  int _importedCount = 0;
  int _failedCount = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Import Products'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Paste JSON array of products:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
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
        ),
      ),
    );
  }
} 