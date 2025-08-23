import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// iOS-specific optimized image widget that handles sizing and quality issues
class IOSOptimizedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool isCircular;
  final Duration fadeInDuration;

  const IOSOptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.isCircular = false,
    this.fadeInDuration = const Duration(milliseconds: 400),
  });

  @override
  State<IOSOptimizedImage> createState() => _IOSOptimizedImageState();
}

class _IOSOptimizedImageState extends State<IOSOptimizedImage> {
  @override
  Widget build(BuildContext context) {
    // For iOS, we need to ensure proper container constraints
    Widget imageWidget = _buildIOSImage();
    
    // Apply border radius if specified
    if (widget.borderRadius != null && widget.borderRadius != BorderRadius.zero) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }
    
    return imageWidget;
  }
  
  Widget _buildIOSImage() {
    // Use Container to ensure proper sizing constraints
    return Container(
      width: widget.width,
      height: widget.height,
      constraints: BoxConstraints(
        minWidth: widget.width ?? 0,
        maxWidth: widget.width ?? double.infinity,
        minHeight: widget.height ?? 0,
        maxHeight: widget.height ?? double.infinity,
      ),
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        // iOS-specific optimizations
        fadeInDuration: widget.fadeInDuration,
        fadeOutDuration: const Duration(milliseconds: 200),
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        // High quality settings for iOS
        filterQuality: FilterQuality.high,
        // Proper cache settings for iOS
        memCacheWidth: widget.width?.toInt(),
        memCacheHeight: widget.height?.toInt(),
        maxWidthDiskCache: (widget.width != null) ? (widget.width! * 2.0).toInt() : null,
        maxHeightDiskCache: (widget.height != null) ? (widget.height! * 2.0).toInt() : null,
        // Disable progress indicator for cleaner loading
        progressIndicatorBuilder: null,
      ),
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
}
