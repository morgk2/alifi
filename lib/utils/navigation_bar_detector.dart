import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavigationBarDetector {
  static bool _hasNavigationBar = false;
  static double _navigationBarHeight = 0.0;
  static bool _isInitialized = false;

  /// Initialize the navigation bar detection
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Check if we can get the navigation bar height
      final mediaQuery = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
      final viewPadding = mediaQuery.viewPadding;
      
      // Calculate navigation bar height
      _navigationBarHeight = viewPadding.bottom;
      
      // Consider it has navigation bar if bottom padding is significant
      _hasNavigationBar = _navigationBarHeight > 0;
      
      _isInitialized = true;
    } catch (e) {
      // Fallback: assume no navigation bar
      _hasNavigationBar = false;
      _navigationBarHeight = 0.0;
      _isInitialized = true;
    }
  }

  /// Check if the device has a navigation bar
  static bool get hasNavigationBar => _hasNavigationBar;

  /// Get the navigation bar height
  static double get navigationBarHeight => _navigationBarHeight;

  /// Get the recommended bottom padding for the app's tab bar
  static double getRecommendedBottomPadding(BuildContext context) {
    if (!_isInitialized) {
      // If not initialized, use a default calculation
      final mediaQuery = MediaQuery.of(context);
      final bottomPadding = mediaQuery.padding.bottom;
      return bottomPadding > 0 ? bottomPadding + 8.0 : 24.0;
    }

    if (_hasNavigationBar) {
      // If there's a navigation bar, add extra padding to avoid clipping
      return _navigationBarHeight + 8.0;
    } else {
      // If no navigation bar (gesture navigation), use standard padding
      return 24.0;
    }
  }

  /// Get the recommended bottom padding for SafeArea
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final bottomPadding = getRecommendedBottomPadding(context);
    return EdgeInsets.only(
      left: 0,
      right: 0,
      top: 0,
      bottom: bottomPadding,
    );
  }

  /// Get debug information about navigation bar detection
  static Map<String, dynamic> getDebugInfo(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return {
      'hasNavigationBar': _hasNavigationBar,
      'navigationBarHeight': _navigationBarHeight,
      'isInitialized': _isInitialized,
      'mediaQueryBottomPadding': mediaQuery.padding.bottom,
      'mediaQueryViewInsetsBottom': mediaQuery.viewInsets.bottom,
      'recommendedBottomPadding': getRecommendedBottomPadding(context),
    };
  }
} 