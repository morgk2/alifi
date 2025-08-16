import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../models/service_ad.dart';
import 'database_service.dart';

class ServiceAdService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  static const String _collectionName = 'service_ads';
  static const String _storageBucket = 'pet-photos';
  static const Uuid _uuid = Uuid();

  // Get current authenticated user
  static auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Create a new service ad
  static Future<String> createServiceAd({
    required ServiceAdType serviceType,
    required String serviceName,
    required String description,
    File? imageFile,
    required List<String> availableDays,
    required String startTime,
    required String endTime,
    required List<String> petTypes,
    required String locationAddress,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get user profile information from Firestore
      final dbService = DatabaseService();
      final userProfile = await dbService.getUser(user.uid);
      
      String userName = userProfile?.displayName ?? user.displayName ?? 'Anonymous User';
      String userProfileImage = userProfile?.photoURL ?? user.photoURL ?? '';

      // Upload image to Supabase if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, serviceType);
      }

      // Create service ad document
      final serviceAdId = _uuid.v4();
      final now = DateTime.now();

      final serviceAd = ServiceAd(
        id: serviceAdId,
        userId: user.uid,
        userName: userName,
        userProfileImage: userProfileImage,
        serviceType: serviceType,
        serviceName: serviceName,
        description: description,
        imageUrl: imageUrl,
        availableDays: availableDays,
        startTime: startTime,
        endTime: endTime,
        petTypes: petTypes,
        locationAddress: locationAddress,
        latitude: latitude,
        longitude: longitude,
        createdAt: now,
        updatedAt: now,
      );

      // Save to Firestore
      await _firestore
          .collection(_collectionName)
          .doc(serviceAdId)
          .set(serviceAd.toMap());

      return serviceAdId;
    } catch (e) {
      throw Exception('Failed to create service ad: $e');
    }
  }

  // Upload image to Supabase Storage with compression
  static Future<String> _uploadImage(File imageFile, ServiceAdType serviceType) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Compress image to 50% quality
      final compressedImage = await _compressImage(imageFile);
      if (compressedImage == null) {
        throw Exception('Failed to compress image');
      }

      // Generate unique filename
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final fileName = '${user.uid}/${serviceType.toString().split('.').last}/${_uuid.v4()}$fileExtension';

      // Upload compressed image to Supabase Storage
      await _supabase.storage
          .from(_storageBucket)
          .uploadBinary(fileName, compressedImage);

      // Get public URL
      final imageUrl = _supabase.storage
          .from(_storageBucket)
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Compress image to 50% quality
  static Future<Uint8List?> _compressImage(File imageFile) async {
    try {
      // Get file extension to determine format
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      
      // Determine compression format
      CompressFormat format = CompressFormat.jpeg;
      if (fileExtension == '.png') {
        format = CompressFormat.png;
      } else if (fileExtension == '.webp') {
        format = CompressFormat.webp;
      }

      // Compress image with 50% quality
      final compressedImage = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: 50, // 50% compression
        format: format,
        minWidth: 800, // Reasonable max width
        minHeight: 600, // Reasonable max height
        keepExif: false, // Remove EXIF data to reduce size
      );

      return compressedImage;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  // Get service ads by type
  static Future<List<ServiceAd>> getServiceAdsByType(ServiceAdType serviceType) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('serviceType', isEqualTo: serviceType.toString().split('.').last)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ServiceAd.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get service ads: $e');
    }
  }

  // Get nearby service ads
  static Future<List<ServiceAd>> getNearbyServiceAds({
    required ServiceAdType serviceType,
    required double userLatitude,
    required double userLongitude,
    double radiusKm = 50.0,
    int limit = 20,
  }) async {
    try {
      // For now, we'll get all ads and filter by distance
      // In production, you might want to use a geohashing solution
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('serviceType', isEqualTo: serviceType.toString().split('.').last)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit * 2) // Get more to filter by distance
          .get();

      final allAds = querySnapshot.docs
          .map((doc) => ServiceAd.fromDocument(doc))
          .toList();

      // Filter by distance
      final nearbyAds = allAds.where((ad) {
        final distance = _calculateDistance(
          userLatitude,
          userLongitude,
          ad.latitude,
          ad.longitude,
        );
        return distance <= radiusKm;
      }).toList();

      // Sort by distance
      nearbyAds.sort((a, b) {
        final distanceA = _calculateDistance(
          userLatitude,
          userLongitude,
          a.latitude,
          a.longitude,
        );
        final distanceB = _calculateDistance(
          userLatitude,
          userLongitude,
          b.latitude,
          b.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      return nearbyAds.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get nearby service ads: $e');
    }
  }

  // Get top-rated service ads
  static Future<List<ServiceAd>> getTopRatedServiceAds({
    required ServiceAdType serviceType,
    int limit = 10,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('serviceType', isEqualTo: serviceType.toString().split('.').last)
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .orderBy('reviewCount', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ServiceAd.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get top rated service ads: $e');
    }
  }

  // Get user's service ads
  static Future<List<ServiceAd>> getUserServiceAds(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ServiceAd.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user service ads: $e');
    }
  }

  // Update service ad
  static Future<void> updateServiceAd(String adId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      
      await _firestore
          .collection(_collectionName)
          .doc(adId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update service ad: $e');
    }
  }

  // Delete service ad
  static Future<void> deleteServiceAd(String adId) async {
    try {
      // Get the ad first to check ownership and get image URL
      final doc = await _firestore
          .collection(_collectionName)
          .doc(adId)
          .get();

      if (!doc.exists) {
        throw Exception('Service ad not found');
      }

      final serviceAd = ServiceAd.fromDocument(doc);
      final user = _auth.currentUser;

      if (user == null || serviceAd.userId != user.uid) {
        throw Exception('Unauthorized to delete this ad');
      }

      // Delete image from Supabase if exists
      if (serviceAd.imageUrl != null && serviceAd.imageUrl!.isNotEmpty) {
        await _deleteImage(serviceAd.imageUrl!);
      }

      // Delete document from Firestore
      await _firestore
          .collection(_collectionName)
          .doc(adId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete service ad: $e');
    }
  }

  // Delete image from Supabase Storage
  static Future<void> _deleteImage(String imageUrl) async {
    try {
      // Extract filename from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length >= 2) {
        // For pet-photos bucket, the path structure is different
        // URL format: https://[project].supabase.co/storage/v1/object/public/pet-photos/[path]
        final fileName = pathSegments.sublist(pathSegments.indexOf('pet-photos') + 1).join('/');
        await _supabase.storage
            .from(_storageBucket)
            .remove([fileName]);
      }
    } catch (e) {
      // Log error but don't throw - we still want to delete the Firestore document
      print('Failed to delete image: $e');
    }
  }

  // Toggle ad active status
  static Future<void> toggleAdActiveStatus(String adId, bool isActive) async {
    try {
      await updateServiceAd(adId, {'isActive': isActive});
    } catch (e) {
      throw Exception('Failed to toggle ad status: $e');
    }
  }

  // Search service ads
  static Future<List<ServiceAd>> searchServiceAds({
    required ServiceAdType serviceType,
    required String searchQuery,
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('serviceType', isEqualTo: serviceType.toString().split('.').last)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit * 2) // Get more to filter by search
          .get();

      final allAds = querySnapshot.docs
          .map((doc) => ServiceAd.fromDocument(doc))
          .toList();

      // Filter by search query (case-insensitive)
      final searchLower = searchQuery.toLowerCase();
      final filteredAds = allAds.where((ad) {
        return ad.serviceName.toLowerCase().contains(searchLower) ||
               ad.description.toLowerCase().contains(searchLower) ||
               ad.locationAddress.toLowerCase().contains(searchLower) ||
               ad.petTypes.any((petType) => 
                   petType.toLowerCase().contains(searchLower));
      }).toList();

      return filteredAds.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to search service ads: $e');
    }
  }

  // Calculate distance between two points using Haversine formula
  static double _calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // Get service ad by ID
  static Future<ServiceAd?> getServiceAdById(String adId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(adId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return ServiceAd.fromDocument(doc);
    } catch (e) {
      throw Exception('Failed to get service ad: $e');
    }
  }

  // Stream service ads for real-time updates
  static Stream<List<ServiceAd>> streamServiceAdsByType(ServiceAdType serviceType) {
    return _firestore
        .collection(_collectionName)
        .where('serviceType', isEqualTo: serviceType.toString().split('.').last)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceAd.fromDocument(doc))
            .toList());
  }
}
