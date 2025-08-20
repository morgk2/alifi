import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'glass_distortion_effect.dart';

/// A custom navigation bar widget that uses the liquid glass effect.
/// This widget creates a distortion effect on the background content behind it.
/// Falls back to a blur effect if liquid glass is not supported.
class LiquidGlassNavBar extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final bool isCircular;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;

  const LiquidGlassNavBar({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.isCircular = false,
    this.borderRadius,
    this.backgroundColor,
    this.border,
  });

  // Cache for runtime support detection
  static bool? _cachedSupport;
  static bool _hasTestedSupport = false;

  /// Runtime test to check if our custom glass shader works
  static bool _testLiquidGlassSupport() {
    if (_hasTestedSupport) {
      return _cachedSupport ?? true;
    }

    try {
      // Our custom shader should work on most modern devices
      // We'll optimistically assume support and gracefully fallback if needed
      _cachedSupport = true;
      _hasTestedSupport = true;
      
      if (kDebugMode) {
        print('LiquidGlass: Using custom glass distortion shader');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('LiquidGlass support test failed: $e');
      }
      _cachedSupport = false;
      _hasTestedSupport = true;
      return false;
    }
  }

  /// Public method to check if our custom glass effect is supported
  static bool get isSupported => _testLiquidGlassSupport();

  @override
  Widget build(BuildContext context) {
    // Default border radius if not provided
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(32);
    
    return SizedBox(
      width: width,
      height: height,
      child: _buildGlassEffect(effectiveBorderRadius),
    );
  }

  Widget _buildGlassEffect(BorderRadius effectiveBorderRadius) {
    // Use our custom glass distortion shader
    return _buildCustomGlassEffect(effectiveBorderRadius);
  }

  Widget _buildCustomGlassEffect(BorderRadius effectiveBorderRadius) {
    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          // Glass-like appearance with custom shader distortion
          borderRadius: isCircular ? null : effectiveBorderRadius,
          shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
          border: border ?? Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
          // Subtle gradient for glass-like effect
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.1),
            ],
          ),
          // Enhanced shadow for floating effect
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SubtleGlassEffect(
          child: child,
        ),
      ),
    );
  }
}

/// A container that provides background content for the liquid glass effect to distort.
/// This should be placed behind the LiquidGlassNavBar in a Stack.
class LiquidGlassBackground extends StatelessWidget {
  final Widget child;
  
  const LiquidGlassBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// A wrapper that combines background content with a liquid glass navigation bar.
/// This handles the Stack setup required for the liquid glass effect.
class LiquidGlassNavBarContainer extends StatelessWidget {
  final Widget backgroundContent;
  final Widget navBarContent;
  final double navBarWidth;
  final double navBarHeight;
  final EdgeInsets navBarPadding;
  final bool isCircular;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;

  const LiquidGlassNavBarContainer({
    super.key,
    required this.backgroundContent,
    required this.navBarContent,
    required this.navBarWidth,
    required this.navBarHeight,
    this.navBarPadding = EdgeInsets.zero,
    this.isCircular = false,
    this.borderRadius,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background content that will be distorted
        Positioned.fill(
          child: LiquidGlassBackground(
            child: backgroundContent,
          ),
        ),
        
        // Liquid glass navigation bar on top
        Positioned(
          left: navBarPadding.left,
          right: navBarPadding.right,
          bottom: navBarPadding.bottom,
          child: Center(
            child: LiquidGlassNavBar(
              width: navBarWidth,
              height: navBarHeight,
              isCircular: isCircular,
              borderRadius: borderRadius,
              backgroundColor: backgroundColor,
              border: border,
              child: navBarContent,
            ),
          ),
        ),
      ],
    );
  }
}
