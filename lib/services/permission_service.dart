import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'push_notification_service.dart';

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
    try {
      if (kIsWeb) {
        // On web, check Firebase Messaging permission
        final messaging = FirebaseMessaging.instance;
        final settings = await messaging.getNotificationSettings();
        return settings.authorizationStatus == AuthorizationStatus.authorized ||
               settings.authorizationStatus == AuthorizationStatus.provisional;
      } else {
        // On mobile, check both permission_handler and Firebase Messaging
        final permissionStatus = await Permission.notification.status;
        if (!permissionStatus.isGranted) return false;
        
        final messaging = FirebaseMessaging.instance;
        final settings = await messaging.getNotificationSettings();
        return settings.authorizationStatus == AuthorizationStatus.authorized ||
               settings.authorizationStatus == AuthorizationStatus.provisional;
      }
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
    try {
      if (kIsWeb) {
        // On web, use Firebase Messaging directly
        final messaging = FirebaseMessaging.instance;
        final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        
        final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
                       settings.authorizationStatus == AuthorizationStatus.provisional;
        
        if (granted) {
          // Initialize the push notification service
          final pushService = PushNotificationService();
          await pushService.initialize();
        }
        
        return granted;
      } else {
        // On mobile, use both permission_handler and Firebase Messaging
        // First request through permission_handler for Android
        final permissionStatus = await Permission.notification.request();
        
        if (permissionStatus.isGranted) {
          // Then initialize Firebase Messaging
          final messaging = FirebaseMessaging.instance;
          final settings = await messaging.requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          );
          
          final firebaseGranted = settings.authorizationStatus == AuthorizationStatus.authorized ||
                                 settings.authorizationStatus == AuthorizationStatus.provisional;
          
          if (firebaseGranted) {
            // Initialize the push notification service
            final pushService = PushNotificationService();
            await pushService.initialize();
          }
          
          return firebaseGranted;
        }
        
        return false;
      }
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