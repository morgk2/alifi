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

class ProfileVerificationBadge extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const ProfileVerificationBadge({
    super.key,
    this.size = 24,
    this.backgroundColor = Colors.white,
    this.iconColor = const Color(0xFF1DA1F2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        Icons.verified_rounded,
        color: iconColor,
        size: size * 0.7,
      ),
    );
  }
} 