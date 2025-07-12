import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DevicePerformance {
  static final DevicePerformance _instance = DevicePerformance._internal();
  factory DevicePerformance() => _instance;
  DevicePerformance._internal();

  late final PerformanceTier _performanceTier;
  final _deviceInfoPlugin = DeviceInfoPlugin();
  
  // Initialize and detect device performance tier
  Future<void> initialize() async {
    _performanceTier = await _detectPerformanceTier();
  }

  PerformanceTier get performanceTier => _performanceTier;

  // Get appropriate blur sigma based on device performance
  double getBlurSigma(double defaultSigma) {
    switch (_performanceTier) {
      case PerformanceTier.low:
        return defaultSigma * 0.5; // Reduce blur for low-end devices
      case PerformanceTier.medium:
        return defaultSigma * 0.75; // Slightly reduce blur for medium devices
      case PerformanceTier.high:
        return defaultSigma; // Full blur for high-end devices
    }
  }

  // Get appropriate animation duration based on device performance
  Duration getAnimationDuration(Duration defaultDuration) {
    switch (_performanceTier) {
      case PerformanceTier.low:
        return defaultDuration * 0.5; // Faster animations for low-end devices
      case PerformanceTier.medium:
        return defaultDuration * 0.75; // Slightly faster for medium devices
      case PerformanceTier.high:
        return defaultDuration; // Full duration for high-end devices
    }
  }

  Future<PerformanceTier> _detectPerformanceTier() async {
    // Web platform check
    if (kIsWeb) {
      return PerformanceTier.high; // Assume high performance for web
    }

    // Android-specific detection
    if (Platform.isAndroid) {
      try {
        // Check device memory and other specs
        final deviceInfo = await _deviceInfoPlugin.androidInfo;
        
        // Use system memory class to determine device tier
        // https://developer.android.com/reference/android/app/ActivityManager#MEMORY_CLASS_HIGH
        final memoryClass = deviceInfo.version.sdkInt;
        final isHighEndDevice = deviceInfo.supportedAbis.contains('arm64-v8a');
        
        if (isHighEndDevice && memoryClass >= 29) { // Android 10 and above
          return PerformanceTier.high;
        } else if (memoryClass >= 26) { // Android 8.0 and above
          return PerformanceTier.medium;
        } else {
          return PerformanceTier.low;
        }
      } catch (e) {
        debugPrint('Error detecting device performance: $e');
        return PerformanceTier.medium; // Default to medium on error
      }
    }

    // iOS-specific detection
    if (Platform.isIOS) {
      try {
        final deviceInfo = await _deviceInfoPlugin.iosInfo;
        // Check device model and iOS version
        final model = deviceInfo.model.toLowerCase();
        
        // Newer devices (iPhone X and later) are considered high performance
        if (model.contains('iphone x') || 
            model.contains('iphone 11') || 
            model.contains('iphone 12') || 
            model.contains('iphone 13') ||
            model.contains('iphone 14') ||
            model.contains('iphone 15')) {
          return PerformanceTier.high;
        }
        
        // Older but still capable devices
        if (model.contains('iphone 8') || 
            model.contains('iphone 7') ||
            model.contains('iphone se')) {
          return PerformanceTier.medium;
        }
        
        // Older devices
        return PerformanceTier.low;
      } catch (e) {
        debugPrint('Error detecting device performance: $e');
        return PerformanceTier.medium; // Default to medium on error
      }
    }

    // Default for other platforms
    return PerformanceTier.medium;
  }
}

enum PerformanceTier {
  low,
  medium,
  high,
} 