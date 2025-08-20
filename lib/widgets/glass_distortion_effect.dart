import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A widget that applies a custom glass distortion effect to its child
class GlassDistortionEffect extends StatefulWidget {
  final Widget child;
  final double distortionStrength;
  final bool animate;

  const GlassDistortionEffect({
    super.key,
    required this.child,
    this.distortionStrength = 0.3,
    this.animate = true,
  });

  @override
  State<GlassDistortionEffect> createState() => _GlassDistortionEffectState();
}

class _GlassDistortionEffectState extends State<GlassDistortionEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    if (widget.animate) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For now, let's use a simpler CSS-like transform approach
    // that works reliably while we debug the shader
    return _buildCSSDistortionEffect();
  }

  Widget _buildCSSDistortionEffect() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Create subtle distortion using transforms
        final time = _animationController.value * 2 * 3.14159;
        final wave1 = (math.sin(time * 0.5) * 0.002 * widget.distortionStrength);
        final wave2 = (math.cos(time * 0.3) * 0.001 * widget.distortionStrength);
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(0, 1, wave1) // Slight skew X
            ..setEntry(1, 0, wave2) // Slight skew Y
            ..scale(1.0 + wave1 * 0.5, 1.0 + wave2 * 0.5), // Subtle scale variation
          child: widget.child,
        );
      },
    );
  }
}

/// A more subtle glass effect for navigation bars
class SubtleGlassEffect extends StatelessWidget {
  final Widget child;
  
  const SubtleGlassEffect({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Use a simple static transform for navigation bars
    // This ensures icons remain visible while adding subtle glass-like distortion
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(0, 1, 0.001) // Very slight skew for glass effect
        ..setEntry(1, 0, -0.0005) // Opposite skew for more realistic glass
        ..scale(1.002, 0.998), // Minimal scale variation
      child: child,
    );
  }
}
