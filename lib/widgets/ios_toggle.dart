import 'package:flutter/material.dart';
import 'dart:math' as math;

class IOSToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;

  const IOSToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 51.0,
    this.height = 31.0,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
  });

  @override
  State<IOSToggle> createState() => _IOSToggleState();
}

class _IOSToggleState extends State<IOSToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.value ? 1.0 : 0.0,
      end: widget.value ? 1.0 : 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(IOSToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: oldWidget.value ? 1.0 : 0.0,
        end: widget.value ? 1.0 : 0.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? Colors.blue;
    final inactiveColor = widget.inactiveColor ?? Colors.grey[300]!;
    final thumbColor = widget.thumbColor ?? Colors.white;

    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              color: Color.lerp(inactiveColor, activeColor, _animation.value),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background track
                Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    color: Colors.transparent,
                  ),
                ),
                
                // Thumb
                Positioned(
                  left: _animation.value * (widget.width - widget.height + 2),
                  top: 1,
                  child: Container(
                    width: widget.height - 2,
                    height: widget.height - 2,
                    decoration: BoxDecoration(
                      color: thumbColor,
                      borderRadius: BorderRadius.circular((widget.height - 2) / 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _animation.value,
                        duration: const Duration(milliseconds: 150),
                        child: Icon(
                          Icons.check,
                          size: (widget.height - 2) * 0.5,
                          color: activeColor,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Subtle inner shadow for depth
                Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 