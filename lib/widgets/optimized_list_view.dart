import 'package:flutter/material.dart';
import '../services/device_performance.dart';

class OptimizedListView extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int? itemCount;
  final IndexedWidgetBuilder? itemBuilder;
  final bool enableOptimization;

  const OptimizedListView({
    super.key,
    this.children = const [],
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.itemCount,
    this.itemBuilder,
    this.enableOptimization = true,
  });

  @override
  State<OptimizedListView> createState() => _OptimizedListViewState();
}

class _OptimizedListViewState extends State<OptimizedListView> {
  final DevicePerformance _devicePerformance = DevicePerformance();
  late bool _isLowEndDevice;

  @override
  void initState() {
    super.initState();
    _isLowEndDevice = _devicePerformance.performanceTier == PerformanceTier.low;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableOptimization || !_isLowEndDevice) {
      // Use standard ListView for high-end devices
      if (widget.itemBuilder != null) {
        return ListView.builder(
          controller: widget.controller,
          padding: widget.padding,
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          itemCount: widget.itemCount,
          itemBuilder: widget.itemBuilder!,
        );
      } else {
        return ListView(
          controller: widget.controller,
          padding: widget.padding,
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          children: widget.children,
        );
      }
    }

    // Use optimized ListView for low-end devices
    return _buildOptimizedListView();
  }

  Widget _buildOptimizedListView() {
    if (widget.itemBuilder != null) {
      return ListView.builder(
        controller: widget.controller,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics ?? const ClampingScrollPhysics(),
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          return widget.itemBuilder!(context, index);
        },
        // Optimize for low-end devices
        cacheExtent: 200, // Reduce cache extent
        addAutomaticKeepAlives: false, // Disable automatic keep alive
        addRepaintBoundaries: false, // Disable repaint boundaries to prevent glitches
      );
    } else {
      return ListView(
        controller: widget.controller,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics ?? const ClampingScrollPhysics(),
        children: widget.children.map((child) => RepaintBoundary(child: child)).toList(),
        // Optimize for low-end devices
        cacheExtent: 200,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
      );
    }
  }
}

class OptimizedGridView extends StatefulWidget {
  final SliverGridDelegate gridDelegate;
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int? itemCount;
  final IndexedWidgetBuilder? itemBuilder;
  final bool enableOptimization;

  const OptimizedGridView({
    super.key,
    required this.gridDelegate,
    this.children = const [],
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.itemCount,
    this.itemBuilder,
    this.enableOptimization = true,
  });

  @override
  State<OptimizedGridView> createState() => _OptimizedGridViewState();
}

class _OptimizedGridViewState extends State<OptimizedGridView> {
  final DevicePerformance _devicePerformance = DevicePerformance();
  late bool _isLowEndDevice;

  @override
  void initState() {
    super.initState();
    _isLowEndDevice = _devicePerformance.performanceTier == PerformanceTier.low;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableOptimization || !_isLowEndDevice) {
      // Use standard GridView for high-end devices
      if (widget.itemBuilder != null) {
        return GridView.builder(
          gridDelegate: widget.gridDelegate,
          controller: widget.controller,
          padding: widget.padding,
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          itemCount: widget.itemCount,
          itemBuilder: widget.itemBuilder!,
        );
      } else {
        return GridView.builder(
          gridDelegate: widget.gridDelegate,
          controller: widget.controller,
          padding: widget.padding,
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          itemCount: widget.children.length,
          itemBuilder: (context, index) => widget.children[index],
        );
      }
    }

    // Use optimized GridView for low-end devices
    return _buildOptimizedGridView();
  }

  Widget _buildOptimizedGridView() {
    if (widget.itemBuilder != null) {
      return GridView.builder(
        gridDelegate: widget.gridDelegate,
        controller: widget.controller,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics ?? const ClampingScrollPhysics(),
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          return widget.itemBuilder!(context, index);
        },
        // Optimize for low-end devices
        cacheExtent: 200,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
      );
    } else {
      return GridView.builder(
        gridDelegate: widget.gridDelegate,
        controller: widget.controller,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics ?? const ClampingScrollPhysics(),
        itemCount: widget.children.length,
        itemBuilder: (context, index) => widget.children[index],
        // Optimize for low-end devices
        cacheExtent: 200,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
      );
    }
  }
}

// Optimized horizontal list view
class OptimizedHorizontalListView extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int? itemCount;
  final IndexedWidgetBuilder? itemBuilder;
  final bool enableOptimization;

  const OptimizedHorizontalListView({
    super.key,
    this.children = const [],
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.itemCount,
    this.itemBuilder,
    this.enableOptimization = true,
  });

  @override
  State<OptimizedHorizontalListView> createState() => _OptimizedHorizontalListViewState();
}

class _OptimizedHorizontalListViewState extends State<OptimizedHorizontalListView> {
  final DevicePerformance _devicePerformance = DevicePerformance();
  late bool _isLowEndDevice;

  @override
  void initState() {
    super.initState();
    _isLowEndDevice = _devicePerformance.performanceTier == PerformanceTier.low;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableOptimization || !_isLowEndDevice) {
      // Use standard ListView for high-end devices
      if (widget.itemBuilder != null) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          controller: widget.controller,
          padding: widget.padding,
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          itemCount: widget.itemCount,
          itemBuilder: widget.itemBuilder!,
        );
      } else {
        return ListView(
          scrollDirection: Axis.horizontal,
          controller: widget.controller,
          padding: widget.padding,
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          children: widget.children,
        );
      }
    }

    // Use optimized horizontal ListView for low-end devices
    return _buildOptimizedHorizontalListView();
  }

  Widget _buildOptimizedHorizontalListView() {
    if (widget.itemBuilder != null) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: widget.controller,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics ?? const ClampingScrollPhysics(),
        itemCount: widget.itemCount,
                 itemBuilder: (context, index) {
           return widget.itemBuilder!(context, index);
         },
         // Optimize for low-end devices
         cacheExtent: 200,
         addAutomaticKeepAlives: false,
         addRepaintBoundaries: false,
      );
    } else {
      return ListView(
        scrollDirection: Axis.horizontal,
        controller: widget.controller,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics ?? const ClampingScrollPhysics(),
        children: widget.children,
        // Optimize for low-end devices
        cacheExtent: 200,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
      );
    }
  }
} 