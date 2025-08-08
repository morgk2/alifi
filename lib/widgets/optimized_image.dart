import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/device_performance.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class OptimizedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool isCircular;
  final bool enableProgressiveLoading;
  final Duration fadeInDuration;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.isCircular = false,
    this.enableProgressiveLoading = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
  @override
  Widget build(BuildContext context) {
    final devicePerformance = DevicePerformance();
    final isLowEndDevice = devicePerformance.performanceTier == PerformanceTier.low;
    
    // Optimize image size based on device performance
    final optimizedWidth = isLowEndDevice && widget.width != null 
        ? widget.width! * 0.8 
        : widget.width;
    final optimizedHeight = isLowEndDevice && widget.height != null 
        ? widget.height! * 0.8 
        : widget.height;

    // Use ClipRRect only when borderRadius is specified
    final Widget imageWidget = _buildOptimizedImage(optimizedWidth, optimizedHeight, isLowEndDevice);
    
    // Only apply ClipRRect if needed (borderRadius is specified and not zero)
    if (widget.borderRadius != null && widget.borderRadius != BorderRadius.zero) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }
    
    return imageWidget;
  }
  
  Widget _buildOptimizedImage(double? width, double? height, bool isLowEndDevice) {
    // For web, use a simpler approach to avoid octo_image issues
    if (kIsWeb) {
      return Image.network(
        widget.imageUrl,
        width: width,
        height: height,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          // Use subtle placeholder instead of progress indicator
          return _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }

    // For Android, use a simpler approach to avoid rendering issues
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Image.network(
        widget.imageUrl,
        width: width,
        height: height,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }

    // For iOS, use CachedNetworkImage with optimizations
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      width: width,
      height: height,
      fit: widget.fit,
      // Reduce animation duration on low-end devices
      fadeInDuration: isLowEndDevice ? const Duration(milliseconds: 100) : widget.fadeInDuration,
      fadeOutDuration: const Duration(milliseconds: 100),
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      cacheKey: _getCacheKey(),
      // Disable progress indicator on low-end devices
      // Use placeholder only, no visible progress indicator to keep loading subtle
      progressIndicatorBuilder: null,
      // Improve memory management
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      maxWidthDiskCache: (width != null) ? (width * 1.5).toInt() : null,
      maxHeightDiskCache: (height != null) ? (height * 1.5).toInt() : null,
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }
    
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: widget.borderRadius,
        shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: widget.isCircular 
          ? const Icon(Icons.pets, color: Colors.grey)
          : const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }
    
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: widget.borderRadius,
        shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: widget.isCircular 
          ? const Icon(Icons.pets, color: Colors.grey)
          : const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  // Progress indicator methods removed to keep image loading subtle without spinners

  String _getCacheKey() {
    // Use a stable cache key based on the URL for both web and mobile
    // This ensures proper caching without creating new keys on every build
    return '${widget.imageUrl.hashCode}';
  }
} 