import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    if (kIsWeb) {
      // On web, we'll assume location is available if the browser supports it
      return true;
    }
    
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  /// Check if notification permission is granted
  Future<bool> isNotificationPermissionGranted() async {
    if (kIsWeb) {
      // On web, notifications are handled differently and may not be available
      return false;
    }
    
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking notification permission: $e');
      return false;
    }
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    if (kIsWeb) {
      // On web, location permission is handled by the browser
      // We'll return true as the browser will handle the permission request
      return true;
    }
    
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    if (kIsWeb) {
      // On web, notification permissions are handled differently
      // We'll return false as web notifications may not be available
      return false;
    }
    
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    if (kIsWeb) {
      // On web, location services are handled by the browser
      return true;
    }
    
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('Error checking location service: $e');
      return false;
    }
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    if (kIsWeb) {
      // On web, we can't open app settings
      print('App settings not available on web');
      return;
    }
    
    try {
      await openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
    }
  }

  /// Get permission status for both location and notification
  Future<Map<String, bool>> getPermissionStatus() async {
    final locationGranted = await isLocationPermissionGranted();
    final notificationGranted = await isNotificationPermissionGranted();
    
    return {
      'location': locationGranted,
      'notification': notificationGranted,
    };
  }
} 