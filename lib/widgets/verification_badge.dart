import 'package:flutter/material.dart';

class VerificationBadge extends StatelessWidget {
  final double size;
  final Color color;

  const VerificationBadge({
    super.key,
    this.size = 12,
    this.color = const Color(0xFF1DA1F2), // Twitter blue color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: size * 0.66,
      ),
    );
  }
} 