import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceAdType { grooming, training }

class ServiceAd {
  final String id;
  final String userId;
  final String userName;
  final String userProfileImage;
  final ServiceAdType serviceType;
  final String serviceName;
  final String description;
  final String? imageUrl;
  final List<String> availableDays;
  final String startTime;
  final String endTime;
  final List<String> petTypes;
  final String locationAddress;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final double rating;
  final int reviewCount;

  ServiceAd({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.serviceType,
    required this.serviceName,
    required this.description,
    this.imageUrl,
    required this.availableDays,
    required this.startTime,
    required this.endTime,
    required this.petTypes,
    required this.locationAddress,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  // Convert ServiceAd to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'serviceType': serviceType.toString().split('.').last,
      'serviceName': serviceName,
      'description': description,
      'imageUrl': imageUrl,
      'availableDays': availableDays,
      'startTime': startTime,
      'endTime': endTime,
      'petTypes': petTypes,
      'locationAddress': locationAddress,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  // Create ServiceAd from Firestore document
  factory ServiceAd.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceAd(
      id: documentId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfileImage: map['userProfileImage'] ?? '',
      serviceType: _parseServiceType(map['serviceType']),
      serviceName: map['serviceName'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      availableDays: List<String>.from(map['availableDays'] ?? []),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      petTypes: List<String>.from(map['petTypes'] ?? []),
      locationAddress: map['locationAddress'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
    );
  }

  // Create ServiceAd from Firestore DocumentSnapshot
  factory ServiceAd.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceAd.fromMap(data, doc.id);
  }

  // Helper method to parse service type from string
  static ServiceAdType _parseServiceType(String? typeString) {
    switch (typeString?.toLowerCase()) {
      case 'grooming':
        return ServiceAdType.grooming;
      case 'training':
        return ServiceAdType.training;
      default:
        return ServiceAdType.grooming;
    }
  }

  // Create a copy with updated fields
  ServiceAd copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfileImage,
    ServiceAdType? serviceType,
    String? serviceName,
    String? description,
    String? imageUrl,
    List<String>? availableDays,
    String? startTime,
    String? endTime,
    List<String>? petTypes,
    String? locationAddress,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    double? rating,
    int? reviewCount,
  }) {
    return ServiceAd(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      serviceType: serviceType ?? this.serviceType,
      serviceName: serviceName ?? this.serviceName,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      availableDays: availableDays ?? this.availableDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      petTypes: petTypes ?? this.petTypes,
      locationAddress: locationAddress ?? this.locationAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  @override
  String toString() {
    return 'ServiceAd{id: $id, serviceName: $serviceName, serviceType: $serviceType, userId: $userId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceAd && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
