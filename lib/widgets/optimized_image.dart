import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/device_performance.dart';
import '../services/comprehensive_cache_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'ios_optimized_image.dart';

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
  final ComprehensiveCacheService _cacheService = ComprehensiveCacheService();

  @override
  void initState() {
    super.initState();
    // Pre-cache the image for better performance
    _precacheImage();
  }

  Future<void> _precacheImage() async {
    try {
      await _cacheService.cacheImage(widget.imageUrl);
    } catch (e) {
      // Silently fail, image will still load normally
    }
  }

  @override
  Widget build(BuildContext context) {
    // For iOS, use the specialized iOS widget
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return IOSOptimizedImage(
        imageUrl: widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        borderRadius: widget.borderRadius,
        placeholder: widget.placeholder,
        errorWidget: widget.errorWidget,
        isCircular: widget.isCircular,
        fadeInDuration: widget.fadeInDuration,
      );
    }

    final devicePerformance = DevicePerformance();
    final isLowEndDevice = devicePerformance.performanceTier == PerformanceTier.low;
    
    // For other platforms, use the original logic
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

    // For iOS, use optimized CachedNetworkImage with better quality settings
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      width: width,
      height: height,
      fit: widget.fit,
      // Use longer fade duration for iOS to prevent jarring transitions
      fadeInDuration: const Duration(milliseconds: 400),
      fadeOutDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      cacheKey: _getCacheKey(),
      // Disable progress indicator to keep loading subtle
      progressIndicatorBuilder: null,
      // iOS-specific optimizations for better quality
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      // Increase disk cache size for iOS to maintain quality
      maxWidthDiskCache: (width != null) ? (width * 2.0).toInt() : null,
      maxHeightDiskCache: (height != null) ? (height * 2.0).toInt() : null,
      // Use higher quality settings for iOS
      filterQuality: FilterQuality.high,
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
        color: Colors.grey[100],
        borderRadius: widget.borderRadius,
        shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: widget.isCircular 
          ? const Icon(Icons.pets, color: Colors.grey)
          : Image.asset(
              'assets/images/photo_loader.png',
              fit: BoxFit.cover,
              width: widget.width,
              height: widget.height,
            ),
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

  String _getCacheKey() {
    // Use a stable cache key based on the URL for both web and mobile
    // This ensures proper caching without creating new keys on every build
    return '${widget.imageUrl.hashCode}';
  }
} 