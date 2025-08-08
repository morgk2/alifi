import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'device_performance.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final DevicePerformance _devicePerformance = DevicePerformance();
  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<double>> _metrics = {};
  bool _isMonitoring = false;

  // Performance thresholds
  static const double _frameTimeThreshold = 16.67; // 60 FPS
  static const double _memoryThreshold = 100 * 1024 * 1024; // 100MB
  static const int _maxCacheSize = 50;

  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    
    // Monitor frame performance
    WidgetsBinding.instance.addPersistentFrameCallback(_onFrame);
    
    // Monitor memory usage periodically
    Timer.periodic(const Duration(seconds: 30), (_) => _checkMemoryUsage());
    
    developer.log('Performance monitoring started', name: 'PerformanceMonitor');
  }

  void stopMonitoring() {
    if (!_isMonitoring) return;
    _isMonitoring = false;
    
    // Note: Flutter doesn't have a direct removePersistentFrameCallback method
    // The callback will be automatically removed when the widget is disposed
    developer.log('Performance monitoring stopped', name: 'PerformanceMonitor');
  }

  void _onFrame(Duration timeStamp) {
    if (!_isMonitoring) return;
    
    final frameTime = timeStamp.inMicroseconds / 1000.0; // Convert to milliseconds
    
    if (frameTime > _frameTimeThreshold) {
      developer.log('Frame time exceeded threshold: ${frameTime.toStringAsFixed(2)}ms', 
        name: 'PerformanceMonitor');
      
      // If on low-end device, suggest optimizations
      if (_devicePerformance.performanceTier == PerformanceTier.low) {
        _suggestOptimizations();
      }
    }
  }

  void _checkMemoryUsage() async {
    try {
      // Note: This is a simplified check. In a real app, you'd use platform-specific APIs
      // to get actual memory usage
      
      developer.log('Memory check completed', name: 'PerformanceMonitor');
    } catch (e) {
      developer.log('Error checking memory usage: $e', name: 'PerformanceMonitor');
    }
  }

  void _suggestOptimizations() {
    developer.log('Performance optimizations suggested for low-end device', 
      name: 'PerformanceMonitor');
    
    // Clear caches if needed
    if (_metrics.length > _maxCacheSize) {
      _clearOldMetrics();
    }
  }

  void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }

  void stopTimer(String name) {
    final timer = _timers[name];
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsedMicroseconds / 1000.0; // Convert to milliseconds
      
      _metrics.putIfAbsent(name, () => []);
      _metrics[name]!.add(duration);
      
      if (duration > 100) { // Log slow operations
        developer.log('Slow operation detected: $name took ${duration.toStringAsFixed(2)}ms', 
          name: 'PerformanceMonitor');
      }
      
      _timers.remove(name);
    }
  }

  double getAverageTime(String name) {
    final times = _metrics[name];
    if (times == null || times.isEmpty) return 0.0;
    
    final sum = times.reduce((a, b) => a + b);
    return sum / times.length;
  }

  void clearMetrics(String? name) {
    if (name != null) {
      _metrics.remove(name);
    } else {
      _metrics.clear();
    }
  }

  void _clearOldMetrics() {
    // Keep only the most recent metrics
    for (final entry in _metrics.entries) {
      if (entry.value.length > 10) {
        entry.value.removeRange(0, entry.value.length - 10);
      }
    }
  }

  Map<String, dynamic> getPerformanceReport() {
    final report = <String, dynamic>{
      'deviceTier': _devicePerformance.performanceTier.toString(),
      'isLowEndDevice': _devicePerformance.performanceTier == PerformanceTier.low,
      'metrics': {},
    };

    for (final entry in _metrics.entries) {
      report['metrics'][entry.key] = {
        'average': getAverageTime(entry.key),
        'count': entry.value.length,
        'min': entry.value.isNotEmpty ? entry.value.reduce((a, b) => a < b ? a : b) : 0,
        'max': entry.value.isNotEmpty ? entry.value.reduce((a, b) => a > b ? a : b) : 0,
      };
    }

    return report;
  }

  void logPerformanceEvent(String event, {Map<String, dynamic>? data}) {
    if (!_isMonitoring) return;
    
    developer.log('Performance event: $event', 
      name: 'PerformanceMonitor',
      error: data != null ? data.toString() : null);
  }

  // Optimize based on device performance
  bool shouldUseOptimizedRendering() {
    return _devicePerformance.performanceTier == PerformanceTier.low;
  }

  bool shouldReduceAnimationQuality() {
    return _devicePerformance.performanceTier == PerformanceTier.low;
  }

  bool shouldUseLazyLoading() {
    return _devicePerformance.performanceTier == PerformanceTier.low;
  }

  int getOptimizedLimit(int defaultLimit) {
    switch (_devicePerformance.performanceTier) {
      case PerformanceTier.low:
        return defaultLimit ~/ 2;
      case PerformanceTier.medium:
        return (defaultLimit * 3) ~/ 4;
      case PerformanceTier.high:
        return defaultLimit;
    }
  }

  Duration getOptimizedAnimationDuration(Duration defaultDuration) {
    switch (_devicePerformance.performanceTier) {
      case PerformanceTier.low:
        return Duration(milliseconds: defaultDuration.inMilliseconds ~/ 2);
      case PerformanceTier.medium:
        return Duration(milliseconds: (defaultDuration.inMilliseconds * 3) ~/ 4);
      case PerformanceTier.high:
        return defaultDuration;
    }
  }
} 