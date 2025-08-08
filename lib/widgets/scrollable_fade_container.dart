import 'package:flutter/material.dart';
import '../services/device_performance.dart';

class ScrollableFadeContainer extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  final double containerWidth;
  final double contentWidth;
  final double fadeThreshold;

  const ScrollableFadeContainer({
    super.key,
    required this.child,
    required this.scrollController,
    required this.containerWidth,
    required this.contentWidth,
    this.fadeThreshold = 0.1,
  });

  @override
  State<ScrollableFadeContainer> createState() => _ScrollableFadeContainerState();
}

class _ScrollableFadeContainerState extends State<ScrollableFadeContainer> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late final DevicePerformance _devicePerformance;
  late bool _isLowEndDevice;

  @override
  void initState() {
    super.initState();
    _devicePerformance = DevicePerformance();
    _isLowEndDevice = _devicePerformance.performanceTier == PerformanceTier.low;
    
    final animationDuration = _isLowEndDevice ? const Duration(milliseconds: 150) : const Duration(milliseconds: 300);
    
    _fadeController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: _isLowEndDevice ? Curves.linear : Curves.easeInOut,
      ),
    );
    
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _fadeController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    
    final position = widget.scrollController.position;
    final maxScrollExtent = position.maxScrollExtent;
    final currentScroll = position.pixels;
    
    if (maxScrollExtent <= 0) return;
    
    final scrollProgress = currentScroll / maxScrollExtent;
    
    if (scrollProgress > widget.fadeThreshold) {
      final fadeProgress = (scrollProgress - widget.fadeThreshold) / (1.0 - widget.fadeThreshold);
      _fadeController.value = fadeProgress;
    } else {
      _fadeController.value = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: 1.0 - _fadeAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}
