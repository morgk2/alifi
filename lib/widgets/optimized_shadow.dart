import 'package:flutter/material.dart';
import '../services/device_performance.dart';

class OptimizedShadow extends StatelessWidget {
  final Widget child;
  final Color shadowColor;
  final double blurRadius;
  final Offset offset;
  final double spreadRadius;
  final bool enableOptimization;

  const OptimizedShadow({
    super.key,
    required this.child,
    this.shadowColor = Colors.black,
    this.blurRadius = 10.0,
    this.offset = Offset.zero,
    this.spreadRadius = 0.0,
    this.enableOptimization = true,
  });

  @override
  Widget build(BuildContext context) {
    final devicePerformance = DevicePerformance();
    final isLowEndDevice = devicePerformance.performanceTier == PerformanceTier.low;
    
    // For low-end devices, use a simpler shadow approach
    if (isLowEndDevice && enableOptimization) {
      return _buildOptimizedShadow();
    }
    
    // For medium and high-end devices, use the original BoxShadow
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            blurRadius: blurRadius,
            offset: offset,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildOptimizedShadow() {
    // Use a simpler approach for low-end devices
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: shadowColor.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// Optimized card widget with built-in shadow optimization
class OptimizedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color shadowColor;
  final double blurRadius;
  final Offset offset;
  final double spreadRadius;

  const OptimizedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.shadowColor = Colors.black,
    this.blurRadius = 10.0,
    this.offset = Offset.zero,
    this.spreadRadius = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final devicePerformance = DevicePerformance();
    final isLowEndDevice = devicePerformance.performanceTier == PerformanceTier.low;
    
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: isLowEndDevice 
            ? [
                BoxShadow(
                  color: shadowColor.withOpacity(0.05),
                  blurRadius: blurRadius * 0.5,
                  offset: offset * 0.5,
                  spreadRadius: spreadRadius * 0.5,
                ),
              ]
            : [
                BoxShadow(
                  color: shadowColor.withOpacity(0.1),
                  blurRadius: blurRadius,
                  offset: offset,
                  spreadRadius: spreadRadius,
                ),
              ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}

// Optimized container with conditional shadow
class OptimizedContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color shadowColor;
  final double blurRadius;
  final Offset offset;
  final double spreadRadius;
  final bool enableShadow;

  const OptimizedContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.shadowColor = Colors.black,
    this.blurRadius = 10.0,
    this.offset = Offset.zero,
    this.spreadRadius = 0.0,
    this.enableShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final devicePerformance = DevicePerformance();
    final isLowEndDevice = devicePerformance.performanceTier == PerformanceTier.low;
    
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: enableShadow && !isLowEndDevice
            ? [
                BoxShadow(
                  color: shadowColor.withOpacity(0.1),
                  blurRadius: blurRadius,
                  offset: offset,
                  spreadRadius: spreadRadius,
                ),
              ]
            : null,
        border: enableShadow && isLowEndDevice
            ? Border.all(
                color: shadowColor.withOpacity(0.05),
                width: 1,
              )
            : null,
      ),
      child: child,
    );
  }
} 