import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/adoption_listing.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'add_adoption_listing_dialog.dart';

class MyListingsDialog extends StatefulWidget {
  final String userId;

  const MyListingsDialog({
    super.key,
    required this.userId,
  });

  @override
  State<MyListingsDialog> createState() => _MyListingsDialogState();
}

class _MyListingsDialogState extends State<MyListingsDialog> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  List<AdoptionListing> _listings = [];

  @override
  void initState() {
    super.initState();
    _loadMyListings();
  }

  Future<void> _loadMyListings() async {
    try {
      setState(() => _isLoading = true);
      
      // Get user's adoption listings - convert stream to list
      final listingsStream = _databaseService.getUserAdoptionListings(widget.userId);
      final listings = await listingsStream.first;
      
      if (mounted) {
        setState(() {
          _listings = listings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading listings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteListing(AdoptionListing listing) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Listing'),
          content: Text('Are you sure you want to delete "${listing.title}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Delete images from storage
      if (listing.imageUrls.isNotEmpty) {
        final storageService = StorageService(Supabase.instance.client);
        for (final imageUrl in listing.imageUrls) {
          try {
            await storageService.deleteAdoptionListingImage(imageUrl);
          } catch (e) {
            print('Error deleting image $imageUrl: $e');
            // Continue with other images even if one fails
          }
        }
      }

      // Delete listing from database
      await _databaseService.deleteAdoptionListing(listing.id);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Refresh listings
        await _loadMyListings();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting listing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editListing(AdoptionListing listing) async {
    // Close the current dialog
    Navigator.of(context).pop();
    
    // Navigate to edit dialog
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddAdoptionListingDialog(listing: listing),
      ),
    );
    
    // If the listing was updated, refresh the list
    if (result == true && mounted) {
      await _loadMyListings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.pets,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'My Listings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _listings.isEmpty
                      ? _buildEmptyState()
                      : _buildListingsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No listings yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first adoption listing',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _showAddListingDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Listing'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsList() {
    return ListView.builder(
      itemCount: _listings.length,
      itemBuilder: (context, index) {
        final listing = _listings[index];
        return _buildListingCard(listing);
      },
    );
  }

  Widget _buildListingCard(AdoptionListing listing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Container(
              width: 80,
              height: 80,
              child: listing.imageUrls.isNotEmpty
                  ? Image.network(
                      listing.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.pets,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.pets,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${listing.petType} • ${listing.breed}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${listing.age} years old • ${listing.gender}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: listing.isActive ? Colors.green[100] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          listing.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            color: listing.isActive ? Colors.green[700] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${listing.adoptionFee.toStringAsFixed(0)} DZD',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Actions
          Column(
            children: [
              IconButton(
                onPressed: () => _editListing(listing),
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => _deleteListing(listing),
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddListingDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddAdoptionListingDialog(),
      ),
    );
  }
}
